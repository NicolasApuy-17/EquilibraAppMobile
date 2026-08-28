const admin = require("firebase-admin");
const { onCall, HttpsError } = require("firebase-functions/v2/https");

// Same pattern the client uses in lib/utils/validators.dart — kept in sync
// by hand since this is server-side JS, not shared code with the Dart app.
const NAME_REGEX = /^[A-Za-zÁÉÍÓÚÜÑáéíóúüñ]+(?: [A-Za-zÁÉÍÓÚÜÑáéíóúüñ]+)*$/;
const EMAIL_REGEX = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

const MAX_MESSAGE_LENGTH = 2000;

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
    throw new HttpsError(
      "internal",
      "No se pudo crear la cuenta del psicólogo. Intenta nuevamente."
    );
  }

  await admin.firestore().collection("users").doc(uid).set({
    email,
    display_name: displayName,
    uid,
    role: "psicologo",
    specialty,
    created_time: admin.firestore.FieldValue.serverTimestamp(),
  });

  return { uid };
});

exports.assignPsychologist = onCall({ cors: true }, async (request) => {
  assertAuthenticated(request);

  const psychologistId = `${request.data?.psychologistId ?? ""}`.trim();
  if (!psychologistId) {
    throw new HttpsError("invalid-argument", "Selecciona un psicólogo.");
  }

  const firestore = admin.firestore();
  const patientRef = firestore.collection("users").doc(request.auth.uid);
  const psychologistRef = firestore.collection("users").doc(psychologistId);
  const conversationRef = firestore
    .collection("conversations")
    .doc(request.auth.uid);

  const psychologistSnap = await psychologistRef.get();
  if (!psychologistSnap.exists || psychologistSnap.data().role !== "psicologo") {
    throw new HttpsError("not-found", "Ese psicólogo ya no está disponible.");
  }

  await firestore.runTransaction(async (transaction) => {
    transaction.update(patientRef, { psychologistRef });
    transaction.set(
      conversationRef,
      {
        patientRef,
        psychologistRef,
        createdTime: admin.firestore.FieldValue.serverTimestamp(),
      },
      { merge: true }
    );
  });

  return { conversationId: request.auth.uid };
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
