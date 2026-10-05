const admin = require("firebase-admin");
const { randomUUID } = require("node:crypto");
const { FieldValue } = require("firebase-admin/firestore");
const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { deleteAccountData } = require("./account_deletion");

async function verifiedCaller(request) {
  if (!request.auth) throw new HttpsError("unauthenticated", "Debes iniciar sesión.");
  const authenticatedAt = Number(request.auth.token?.auth_time);
  const age = Date.now() / 1000 - authenticatedAt;
  if (!Number.isFinite(authenticatedAt) || age < -30 || age > 300) {
    throw new HttpsError("failed-precondition", "Verifica nuevamente tu contraseña para eliminar la cuenta.");
  }
  try {
    const caller = await admin.auth().getUser(request.auth.uid);
    if (caller.disabled) throw new HttpsError("permission-denied", "Tu cuenta está deshabilitada.");
    return caller;
  } catch (error) {
    if (error.code === "auth/user-not-found") {
      throw new HttpsError("unauthenticated", "La cuenta ya no existe.");
    }
    throw error;
  }
}

// Reserve before calling Auth (never perform an irreversible Auth operation in
// a retryable Firestore transaction). Every admin deletion reads the same admin
// query and writes its target: concurrent attempts cannot both count each other
// as the administrator that will remain. Pending deletions never count as backup.
async function reserveAdminDeletion(uid, target) {
  const db = admin.firestore();
  const ref = db.doc(`users/${uid}`);
  const id = randomUUID();
  return db.runTransaction(async (transaction) => {
    const profile = await transaction.get(ref);
    const data = profile.data();
    if (!target || data?.role !== "admin") return null;
    // A crashed invocation can be retried after its maximum execution time.
    // Its reservation remains excluded from other deletions until it is resolved.
    if (data.accountDeletion?.id && Date.now() - data.accountDeletion.startedAt < 20 * 60 * 1000) {
      throw new HttpsError("failed-precondition", "La eliminación de esta cuenta ya está en proceso. Espera antes de reintentar.");
    }
    if (!target.disabled && data.active !== false) {
      const admins = await transaction.get(db.collection("users").where("role", "==", "admin"));
      let backupAvailable = false;
      for (const candidate of admins.docs) {
        const candidateData = candidate.data();
        if (candidate.id === uid || candidateData.active === false || candidateData.accountDeletion?.id) continue;
        try {
          const user = await admin.auth().getUser(candidate.id);
          if (!user.disabled) { backupAvailable = true; break; }
        } catch (error) {
          if (error.code !== "auth/user-not-found") throw error;
        }
      }
      if (!backupAvailable) {
        throw new HttpsError("failed-precondition",
          "No puedes eliminar la única cuenta de administrador disponible. Debe quedar otro administrador activo con acceso.");
      }
    }
    transaction.update(ref, { accountDeletion: { id, startedAt: Date.now() } });
    return id;
  });
}

async function releaseAdminDeletion(uid, id) {
  if (!id) return;
  const db = admin.firestore();
  const ref = db.doc(`users/${uid}`);
  await db.runTransaction(async (transaction) => {
    const profile = await transaction.get(ref);
    if (profile.data()?.accountDeletion?.id === id) {
      transaction.update(ref, { accountDeletion: FieldValue.delete() });
    }
  });
}

async function removeAccount(uid, confirmationEmail) {
  if (typeof uid !== "string" || !uid || uid.includes("/")) {
    throw new HttpsError("invalid-argument", "Selecciona una cuenta válida.");
  }
  let target;
  try {
    target = await admin.auth().getUser(uid);
  } catch (error) {
    if (error.code !== "auth/user-not-found") throw error;
  }
  const profile = await admin.firestore().doc(`users/${uid}`).get();
  const email = target?.email || profile.data()?.email;
  if (!email && !target && !profile.exists) return { deleted: true, cleanupPending: false };
  if (typeof confirmationEmail !== "string" || !email ||
      confirmationEmail.trim().toLowerCase() !== email.toLowerCase()) {
    throw new HttpsError("invalid-argument", "Escribe el correo de la cuenta que deseas eliminar.");
  }
  if (target) {
    const reservation = await reserveAdminDeletion(uid, target);
    // The existing retryable Auth deletion trigger purges Firestore and Storage.
    try {
      await admin.auth().deleteUser(uid);
    } catch (error) {
      // Another idempotent request or the operator may already have deleted Auth.
      if (error.code === "auth/user-not-found") return { deleted: true, cleanupPending: true };
      if (reservation) {
        try {
          // Clear only when Auth confirms it still exists. Ambiguous failures
          // remain reserved so another administrator cannot be deleted unsafely.
          await admin.auth().getUser(uid);
          await releaseAdminDeletion(uid, reservation);
        } catch (recoveryError) {
          console.error("[admin account deletion] reservation recovery failed", recoveryError.code);
        }
      }
      throw error;
    }
    return { deleted: true, cleanupPending: true };
  }
  // Recover orphaned profiles when Auth was already deleted on an earlier attempt.
  await deleteAccountData(uid);
  return { deleted: true, cleanupPending: false };
}

exports.deleteMyAccount = onCall({ cors: true, timeoutSeconds: 540 }, async (request) => {
  const caller = await verifiedCaller(request);
  // Ignore any client-supplied UID: this endpoint can only delete its caller.
  return removeAccount(caller.uid, request.data?.confirmationEmail);
});

exports.adminDeleteAccount = onCall({ cors: true, timeoutSeconds: 540 }, async (request) => {
  const caller = await verifiedCaller(request);
  const profile = await admin.firestore().doc(`users/${caller.uid}`).get();
  if (!profile.exists || profile.data().role !== "admin" || profile.data().active === false) {
    throw new HttpsError("permission-denied", "Solo un administrador activo puede eliminar cuentas.");
  }
  if (request.data?.uid === caller.uid) {
    throw new HttpsError("failed-precondition", "Elimina tu propia cuenta desde tu perfil personal.");
  }
  return removeAccount(request.data?.uid, request.data?.confirmationEmail);
});
