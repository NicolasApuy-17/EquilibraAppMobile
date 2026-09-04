const admin = require("firebase-admin");
const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { onDocumentWritten } = require("firebase-functions/v2/firestore");

// Same pattern the client uses in lib/utils/validators.dart — kept in sync
// by hand since this is server-side JS, not shared code with the Dart app.
const NAME_REGEX = /^[A-Za-zÁÉÍÓÚÜÑáéíóúüñ]+(?: [A-Za-zÁÉÍÓÚÜÑáéíóúüñ]+)*$/;
const EMAIL_REGEX = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

const MAX_MESSAGE_LENGTH = 2000;

// Strips accents/diacritics and anything that isn't A-Z from `name`, used
// as the prefix of a psychologist's link code (e.g. "Fabrizzio Ruiz" ->
// "FABRIZZIORUIZ" -> the function below then takes the first word only).
function linkCodeSlug(displayName) {
  const firstWord = displayName.trim().split(/\s+/)[0] ?? "";
  return firstWord
    .normalize("NFD")
    .replace(/[^A-Za-z]/g, "")
    .toUpperCase();
}

/** Generates a unique "NOMBRE-1234" link code, retrying on collision. */
async function generateUniqueLinkCode(displayName) {
  const slug = linkCodeSlug(displayName) || "PSICOLOGO";
  const usersRef = admin.firestore().collection("users");
  for (let attempt = 0; attempt < 5; attempt++) {
    const suffix = Math.floor(1000 + Math.random() * 9000);
    const candidate = `${slug}-${suffix}`;
    const existing = await usersRef
      .where("linkCode", "==", candidate)
      .limit(1)
      .get();
    if (existing.empty) return candidate;
  }
  throw new HttpsError(
    "internal",
    "No se pudo generar un código de vinculación único. Intenta nuevamente."
  );
}

/**
 * Mirrors a server-side failure into the same `app_errors` collection the
 * Flutter client logs to (see lib/utils/error_logging.dart), so the admin
 * panel's "Incidencias" tab shows backend failures too, not just
 * client-side ones. Best-effort: never lets a logging failure mask the
 * original error.
 */
async function logServerError(context, error, userUid) {
  try {
    await admin.firestore().collection("app_errors").add({
      context,
      message: `${error?.message ?? error}`,
      stackTrace: error?.stack ? `${error.stack}`.split("\n").slice(0, 20).join("\n") : null,
      userRef: userUid ? admin.firestore().collection("users").doc(userUid) : null,
      role: "system",
      createdTime: admin.firestore.FieldValue.serverTimestamp(),
    });
  } catch (loggingError) {
    console.error("[logServerError] failed to log:", loggingError);
  }
}

function assertAuthenticated(request) {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Debes iniciar sesión.");
  }
}

/**
 * Throws unless the caller's own `users/{uid}` document has role == 'admin'.
 * Trusts Firestore (read via the Admin SDK, so this bypasses security
 * rules) as the source of truth for roles, never a client-supplied claim.
 */
async function assertIsAdmin(uid) {
  const snap = await admin.firestore().collection("users").doc(uid).get();
  if (!snap.exists || snap.data().role !== "admin") {
    throw new HttpsError(
      "permission-denied",
      "Solo un administrador puede realizar esta acción."
    );
  }
}

exports.createPsychologist = onCall({ cors: true }, async (request) => {
  assertAuthenticated(request);
  await assertIsAdmin(request.auth.uid);

  const displayName = `${request.data?.displayName ?? ""}`.trim();
  const email = `${request.data?.email ?? ""}`.trim();
  const specialty = `${request.data?.specialty ?? ""}`.trim();
  const password = `${request.data?.password ?? ""}`;

  if (!NAME_REGEX.test(displayName) || displayName.length < 2 || displayName.length > 60) {
    throw new HttpsError(
      "invalid-argument",
      "El nombre solo puede contener letras y espacios (2 a 60 caracteres)."
    );
  }
  if (!EMAIL_REGEX.test(email)) {
    throw new HttpsError("invalid-argument", "Ingresa un correo electrónico válido.");
  }
  if (!specialty || specialty.length > 200) {
    throw new HttpsError(
      "invalid-argument",
      "Ingresa una especialidad breve (máximo 200 caracteres)."
    );
  }
  if (password.length < 8) {
    throw new HttpsError(
      "invalid-argument",
      "La contraseña debe tener al menos 8 caracteres."
    );
  }

  let uid;
  try {
    const userRecord = await admin.auth().createUser({
      email,
      password,
      displayName,
    });
    uid = userRecord.uid;
  } catch (error) {
    if (error.code === "auth/email-already-exists") {
      throw new HttpsError(
        "already-exists",
        "Ese correo electrónico ya está registrado."
      );
    }
    console.error("[createPsychologist] createUser failed:", error);
    await logServerError("createPsychologist: createUser failed", error, request.auth.uid);
    throw new HttpsError(
      "internal",
      "No se pudo crear la cuenta del psicólogo. Intenta nuevamente."
    );
  }

  const linkCode = await generateUniqueLinkCode(displayName);

  await admin.firestore().collection("users").doc(uid).set({
    email,
    display_name: displayName,
    uid,
    role: "psicologo",
    specialty,
    linkCode,
    created_time: admin.firestore.FieldValue.serverTimestamp(),
  });

  return { uid, linkCode };
});

/**
 * Shared by `linkPsychologistByCode` and `adminAssignPsychologist`: points
 * `patientRef` at `psychologistRef` and creates/updates their shared
 * conversation. Does not check whether the patient already has a
 * psychologist assigned — callers decide whether that's allowed.
 */
async function linkPatientToPsychologist(patientRef, psychologistRef) {
  const firestore = admin.firestore();
  const conversationRef = firestore
    .collection("conversations")
    .doc(patientRef.id);
  const now = admin.firestore.FieldValue.serverTimestamp();

  await firestore.runTransaction(async (transaction) => {
    transaction.update(patientRef, {
      psychologistRef,
      psychologistLinkedAt: now,
    });
    transaction.set(
      conversationRef,
      { patientRef, psychologistRef, createdTime: now },
      { merge: true }
    );
  });

  return conversationRef.id;
}

exports.linkPsychologistByCode = onCall({ cors: true }, async (request) => {
  assertAuthenticated(request);

  const code = `${request.data?.code ?? ""}`.trim().toUpperCase();
  if (!code) {
    throw new HttpsError("invalid-argument", "Ingresa el código de tu psicólogo.");
  }

  const firestore = admin.firestore();
  const patientRef = firestore.collection("users").doc(request.auth.uid);

  const patientSnap = await patientRef.get();
  if (patientSnap.exists && patientSnap.data().psychologistRef) {
    throw new HttpsError(
      "failed-precondition",
      "Ya tienes un psicólogo asignado. Si necesitas cambiarlo, contacta al administrador."
    );
  }

  const matches = await firestore
    .collection("users")
    .where("role", "==", "psicologo")
    .where("linkCode", "==", code)
    .limit(1)
    .get();
  if (matches.empty) {
    throw new HttpsError("not-found", "Ese código no corresponde a ningún psicólogo.");
  }

  const conversationId = await linkPatientToPsychologist(
    patientRef,
    matches.docs[0].ref
  );
  return { conversationId };
});

exports.adminAssignPsychologist = onCall({ cors: true }, async (request) => {
  assertAuthenticated(request);
  await assertIsAdmin(request.auth.uid);

  const patientId = `${request.data?.patientId ?? ""}`.trim();
  const psychologistId = `${request.data?.psychologistId ?? ""}`.trim();
  if (!patientId || !psychologistId) {
    throw new HttpsError("invalid-argument", "Selecciona un paciente y un psicólogo.");
  }

  const firestore = admin.firestore();
  const patientRef = firestore.collection("users").doc(patientId);
  const psychologistRef = firestore.collection("users").doc(psychologistId);

  const [patientSnap, psychologistSnap] = await Promise.all([
    patientRef.get(),
    psychologistRef.get(),
  ]);
  if (!patientSnap.exists || patientSnap.data().role !== "paciente") {
    throw new HttpsError("not-found", "Ese paciente no existe.");
  }
  if (!psychologistSnap.exists || psychologistSnap.data().role !== "psicologo") {
    throw new HttpsError("not-found", "Ese psicólogo no existe.");
  }

  const conversationId = await linkPatientToPsychologist(patientRef, psychologistRef);
  return { conversationId };
});

/**
 * Admin-only diagnostic: compares a patient's stored `psychologistRef`
 * value against a reference freshly reconstructed from the same uid (the
 * same way `currentUserReference` and the admin's own "Consultantes: N"
 * count do), and reports whether Firestore's `==` query filter actually
 * finds the patient using each. Exists to debug "the patient is linked but
 * doesn't show up in the psychologist's list" reports without needing
 * direct Firestore console/API access.
 */
exports.adminDiagnosePatientLink = onCall({ cors: true }, async (request) => {
  assertAuthenticated(request);
  await assertIsAdmin(request.auth.uid);

  const patientId = `${request.data?.patientId ?? ""}`.trim();
  if (!patientId) {
    throw new HttpsError("invalid-argument", "Falta patientId.");
  }

  const db = admin.firestore();
  const patientSnap = await db.collection("users").doc(patientId).get();
  if (!patientSnap.exists) {
    throw new HttpsError("not-found", "Paciente no encontrado.");
  }
  const patientData = patientSnap.data();
  const storedRef = patientData.psychologistRef;

  const result = {
    patientId,
    role: patientData.role ?? null,
    storedPsychologistRefPath: storedRef ? storedRef.path : null,
  };

  // Ground truth via the Admin SDK, which bypasses firestore.rules entirely
  // -- these counts are what actually exists for this patient, regardless
  // of whether the psychologist's app can currently read them or whether a
  // psychologist is even linked yet. Comparing this against what the app
  // shows tells us whether a reported "no records" complaint is a real
  // data gap or a rules/query bug.
  const patientRef = patientSnap.ref;
  const [recordsSnap, behavioralSnap, tasksSnap, activitiesSnap] =
    await Promise.all([
      db.collection("records").where("userRef", "==", patientRef).get(),
      db.collection("behavioral_records").where("userRef", "==", patientRef).get(),
      db.collection("tasks").where("userRef", "==", patientRef).get(),
      db.collection("activity_assignments").where("patientRef", "==", patientRef).get(),
    ]);
  result.recordsCount = recordsSnap.size;
  result.behavioralRecordsCount = behavioralSnap.size;
  result.tasksCount = tasksSnap.size;
  result.activityAssignmentsCount = activitiesSnap.size;

  // Raw field dump of each record, with its stored type made explicit --
  // this is what actually decides whether the Flutter client's own parser
  // can read the document back out. A `userRef` stored as a plain string
  // instead of a real Firestore reference (or a `timestamp` that isn't a
  // Timestamp) would match this Admin SDK query fine, yet make the client
  // throw while parsing that one document and silently drop it from the
  // list -- no error shown, indistinguishable from "no records".
  const describeValue = (v) => {
    if (v === null || v === undefined) return "null";
    if (v instanceof admin.firestore.Timestamp) {
      return `Timestamp(${v.toDate().toISOString()})`;
    }
    if (v instanceof admin.firestore.DocumentReference) return `Ref(${v.path})`;
    if (Array.isArray(v)) return `Array(${v.length})`;
    return `${typeof v}:${JSON.stringify(v)}`;
  };
  const describeDoc = (doc) => {
    const out = { id: doc.id };
    for (const [key, value] of Object.entries(doc.data())) {
      out[key] = describeValue(value);
    }
    return out;
  };
  result.recordsRaw = recordsSnap.docs.map(describeDoc);
  result.behavioralRecordsRaw = behavioralSnap.docs.map(describeDoc);

  if (!storedRef) return result;

  const withStoredRef = await db.collection("users")
    .where("role", "==", "paciente")
    .where("psychologistRef", "==", storedRef)
    .get();
  result.matchCountUsingStoredRef = withStoredRef.size;

  const reconstructedRef = db.collection("users").doc(storedRef.id);
  result.reconstructedRefPath = reconstructedRef.path;
  result.reconstructedEqualsStored = reconstructedRef.isEqual(storedRef);

  const withReconstructedRef = await db.collection("users")
    .where("role", "==", "paciente")
    .where("psychologistRef", "==", reconstructedRef)
    .get();
  result.matchCountUsingReconstructedRef = withReconstructedRef.size;

  return result;
});

/**
 * Admin-only: activates or deactivates a psychologist's or patient's
 * account. Disables the underlying Firebase Auth user (blocking sign-in
 * and invalidating their session at the next token refresh) in addition to
 * mirroring `active` on their `users/{uid}` doc for the UI -- toggling only
 * the Firestore field would leave a still-logged-in session fully working.
 */
exports.setAccountActive = onCall({ cors: true }, async (request) => {
  assertAuthenticated(request);
  await assertIsAdmin(request.auth.uid);

  const uid = `${request.data?.uid ?? ""}`.trim();
  const active = request.data?.active;
  if (!uid || typeof active !== "boolean") {
    throw new HttpsError("invalid-argument", "Datos inválidos.");
  }
  if (uid === request.auth.uid) {
    throw new HttpsError("invalid-argument", "No puedes desactivar tu propia cuenta.");
  }

  const userSnap = await admin.firestore().collection("users").doc(uid).get();
  if (!userSnap.exists || userSnap.data().role === "admin") {
    throw new HttpsError("not-found", "Esa cuenta no existe o no se puede modificar.");
  }

  await admin.auth().updateUser(uid, { disabled: !active });
  await admin.firestore().collection("users").doc(uid).set({ active }, { merge: true });

  return { active };
});

/**
 * Admin-only: changes a user's role between 'paciente' and 'psicologo' --
 * this is what actually determines which screens/permissions a user has in
 * this app (see firestore.rules), so "change role" and "grant a specific
 * set of options" are the same action here. Deliberately never touches
 * 'admin': promoting/demoting an admin is out of scope and too sensitive
 * for a same-panel action.
 *
 * Turning a patient into a psychologist generates them a link code (same
 * as `createPsychologist`) and drops their own `psychologistRef`, since a
 * psychologist doesn't have one. Turning a psychologist back into a
 * patient is refused while they still have patients assigned, so nobody
 * gets silently orphaned -- the admin must reassign those first.
 */
exports.setUserRole = onCall({ cors: true }, async (request) => {
  assertAuthenticated(request);
  await assertIsAdmin(request.auth.uid);

  const uid = `${request.data?.uid ?? ""}`.trim();
  const newRole = `${request.data?.newRole ?? ""}`.trim();
  if (!uid || !["paciente", "psicologo", "admin"].includes(newRole)) {
    throw new HttpsError("invalid-argument", "Rol inválido.");
  }
  if (uid === request.auth.uid) {
    throw new HttpsError("invalid-argument", "No puedes cambiar tu propio rol.");
  }

  const firestore = admin.firestore();
  const userRef = firestore.collection("users").doc(uid);
  const snap = await userRef.get();
  if (!snap.exists) {
    throw new HttpsError("not-found", "Ese usuario no existe.");
  }
  const data = snap.data();
  if (data.role === newRole) {
    return { role: newRole };
  }

  // Leaving the psicologo role behind (to paciente or admin) orphans any
  // patient still pointing at this account -- must be reassigned first,
  // regardless of which role they're moving to.
  if (data.role === "psicologo" && newRole !== "psicologo") {
    const stillAssigned = await firestore
      .collection("users")
      .where("role", "==", "paciente")
      .where("psychologistRef", "==", userRef)
      .limit(1)
      .get();
    if (!stillAssigned.empty) {
      throw new HttpsError(
        "failed-precondition",
        "Este psicólogo todavía tiene consultantes asignados. Reasígnalos antes de cambiar su rol."
      );
    }
  }

  if (newRole === "psicologo") {
    const linkCode = await generateUniqueLinkCode(data.display_name || "");
    await userRef.update({
      role: "psicologo",
      linkCode,
      specialty: data.specialty || "",
      psychologistRef: admin.firestore.FieldValue.delete(),
      psychologistLinkedAt: admin.firestore.FieldValue.delete(),
    });
    return { role: "psicologo", linkCode };
  }

  if (newRole === "admin") {
    await userRef.update({
      role: "admin",
      linkCode: admin.firestore.FieldValue.delete(),
      specialty: admin.firestore.FieldValue.delete(),
      psychologistRef: admin.firestore.FieldValue.delete(),
      psychologistLinkedAt: admin.firestore.FieldValue.delete(),
    });
    return { role: "admin" };
  }

  await userRef.update({
    role: "paciente",
    linkCode: admin.firestore.FieldValue.delete(),
    specialty: admin.firestore.FieldValue.delete(),
    psychologistRef: admin.firestore.FieldValue.delete(),
    psychologistLinkedAt: admin.firestore.FieldValue.delete(),
  });
  return { role: "paciente" };
});

exports.sendConversationMessage = onCall({ cors: true }, async (request) => {
  assertAuthenticated(request);

  const conversationId = `${request.data?.conversationId ?? ""}`.trim();
  const text = `${request.data?.text ?? ""}`.trim();
  if (!conversationId) {
    throw new HttpsError("invalid-argument", "Conversación inválida.");
  }
  if (!text) {
    throw new HttpsError("invalid-argument", "El mensaje está vacío.");
  }
  if (text.length > MAX_MESSAGE_LENGTH) {
    throw new HttpsError(
      "invalid-argument",
      `El mensaje supera el máximo de ${MAX_MESSAGE_LENGTH} caracteres.`
    );
  }

  const firestore = admin.firestore();
  const conversationRef = firestore.collection("conversations").doc(conversationId);
  const callerRef = firestore.collection("users").doc(request.auth.uid);

  const conversationSnap = await conversationRef.get();
  if (!conversationSnap.exists) {
    throw new HttpsError("not-found", "Esa conversación no existe.");
  }
  const conversation = conversationSnap.data();
  const isParticipant =
    conversation.patientRef?.path === callerRef.path ||
    conversation.psychologistRef?.path === callerRef.path;
  if (!isParticipant) {
    throw new HttpsError(
      "permission-denied",
      "No formas parte de esta conversación."
    );
  }

  const now = admin.firestore.FieldValue.serverTimestamp();
  await conversationRef.collection("messages").add({
    senderRef: callerRef,
    text,
    timestamp: now,
  });
  await conversationRef.set(
    { lastMessageText: text, lastMessageTime: now },
    { merge: true }
  );

  return { sent: true };
});

/**
 * Stamps `lastActivityAt` on the patient's own `users/{uid}` doc so the
 * psychologist dashboard can show "última actividad" without querying every
 * patient's records/tasks live. Silently no-ops if the document has no
 * `userRef` or the referenced user doesn't exist (shouldn't happen for
 * patient-owned collections, but a trigger must never throw on bad data).
 */
async function touchLastActivity(userRef) {
  if (!userRef) return;
  try {
    await userRef.update({
      lastActivityAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  } catch (error) {
    console.error("[touchLastActivity] failed for", userRef.path, error);
    await logServerError(`touchLastActivity failed for ${userRef.path}`, error, userRef.id);
  }
}

function activityTrigger(documentPath) {
  return onDocumentWritten(documentPath, (event) => {
    // Only create/update count as "activity"; a deleted document has no
    // `after` snapshot to read `userRef` from.
    if (!event.data?.after?.exists) return null;
    return touchLastActivity(event.data.after.data()?.userRef ?? null);
  });
}

exports.onRecordActivity = activityTrigger("records/{recordId}");
exports.onBehavioralRecordActivity = activityTrigger(
  "behavioral_records/{recordId}"
);
exports.onTaskActivity = activityTrigger("tasks/{taskId}");
