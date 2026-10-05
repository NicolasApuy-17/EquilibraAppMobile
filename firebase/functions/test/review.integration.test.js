/* global fetch */
// Run only against the disposable local emulator:
// FIRESTORE_EMULATOR_HOST=127.0.0.1:8188 node --test test/review.integration.test.js
const { test } = require("node:test");
const assert = require("node:assert/strict");
const admin = require("firebase-admin");
const fs = require("node:fs");
const path = require("node:path");

const project = "demo-equilibra-review";
const host = process.env.FIRESTORE_EMULATOR_HOST;
if (!host || !/^(127\.0\.0\.1|localhost):\d+$/.test(host)) {
  throw new Error("These tests require an explicitly configured LOCAL Firestore emulator.");
}
admin.initializeApp({ projectId: project });
const db = admin.firestore();
const backend = require("../psychologists");
const { syncPatientAccess } = require("../access_sync");
const { notifyUser } = require("../notifications");
const { sendDailyReminders } = require("../reminders");
const base = `http://${host}/v1/projects/${project}/databases/(default)/documents`;

function token(uid) {
  const encode = (value) => Buffer.from(JSON.stringify(value)).toString("base64url");
  return `${encode({ alg: "none", typ: "JWT" })}.${encode({
    sub: uid, user_id: uid, aud: project, iss: `https://securetoken.google.com/${project}`,
    iat: Math.floor(Date.now() / 1000), exp: Math.floor(Date.now() / 1000) + 3600,
    firebase: { sign_in_provider: "custom" },
  })}.`;
}

async function request(uid, url, method = "GET", body) {
  const response = await fetch(url, {
    method, headers: { Authorization: `Bearer ${token(uid)}`, "Content-Type": "application/json" },
    ...(body ? { body: JSON.stringify(body) } : {}),
  });
  return { status: response.status, body: await response.text() };
}
async function read(uid, docPath, allowed = true) {
  const result = await request(uid, `${base}/${docPath}`);
  assert.equal(result.status, allowed ? 200 : 403, `${uid} reading ${docPath}: ${result.body}`);
}
async function update(uid, docPath, fields, allowed = true) {
  const mask = Object.keys(fields).map((key) => `updateMask.fieldPaths=${key}`).join("&");
  const result = await request(uid, `${base}/${docPath}?${mask}`, "PATCH", { fields });
  assert.equal(result.status, allowed ? 200 : 403, `${uid} updating ${docPath}: ${result.body}`);
}
async function list(uid, collection, field, ref, allowed = true) {
  const result = await request(uid, `${base}:runQuery`, "POST", { structuredQuery: {
    from: [{ collectionId: collection }],
    where: { fieldFilter: { field: { fieldPath: field }, op: "EQUAL", value: {
      referenceValue: `projects/${project}/databases/(default)/documents/${ref.path}`,
    } } },
  } });
  assert.equal(result.status, allowed ? 200 : 403, `${uid} querying ${collection}: ${result.body}`);
  if (allowed) assert.ok(result.body.includes('"document"'), result.body);
}

test("authorization, reassignment, privacy, chat and reminder regressions", async () => {
  const rulesResponse = await fetch(`http://${host}/emulator/v1/projects/${project}:securityRules`, {
    method: "PUT", headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ rules: { files: [{ name: "firestore.rules", content:
      fs.readFileSync(path.join(__dirname, "../../firestore.rules"), "utf8") }] } }),
  });
  assert.equal(rulesResponse.status, 200, await rulesResponse.text());
  await fetch(`http://${host}/emulator/v1/projects/${project}/databases/(default)/documents`, { method: "DELETE" });
  const patient = db.doc("users/patient");
  const a = db.doc("users/a");
  const b = db.doc("users/b");
  await Promise.all([
    patient.set({ role: "paciente", psychologistRef: a, shareDataWithPsychologist: true }),
    a.set({ role: "psicologo", linkCode: "A-1234" }), b.set({ role: "psicologo", linkCode: "B-1234" }),
    db.doc("users/other").set({ role: "paciente" }),
    db.doc("users/admin").set({ role: "admin" }),
  ]);
  await Promise.all([
    db.doc("records/r").set({ userRef: patient, psychologistRef: a, emotion: "Alegría" }),
    db.doc("behavioral_records/r").set({ userRef: patient, psychologistRef: a, notes: "Ejercicio" }),
    db.doc("goals/g").set({ userRef: patient, title: "Dormir" }),
    db.doc("tasks/t").set({ userRef: patient, psychologistRef: a, createdByRef: a, status: "pendiente" }),
    db.doc("session_requests/s").set({ patientRef: patient, psychologistRef: a, status: "pendiente" }),
    db.doc("patient_notes/patient").set({ notes: "Nota privada de A" }),
    db.doc("conversations/patient").set({ patientRef: patient, psychologistRef: a }),
    db.doc("conversations/patient/messages/old").set({ senderRef: a, text: "Historial de A" }),
  ]);
  for (const collection of ["records", "behavioral_records", "goals", "tasks"]) {
    await list("a", collection, "userRef", patient);
    await list("other", collection, "userRef", patient, false);
  }
  await update("patient", "records/r", { description: { stringValue: "Actualizado" } });
  await update("patient", "behavioral_records/r", { notes: { stringValue: "Actualizado" } });
  await update("patient", "goals/g", { completed: { booleanValue: true } });
  await update("patient", "tasks/t", { status: { stringValue: "completada" } });
  const adminList = await request("admin", `${base}:runQuery`, "POST", {
    structuredQuery: { from: [{ collectionId: "records" }] },
  });
  assert.equal(adminList.status, 200, adminList.body);
  for (const docPath of ["records/r", "behavioral_records/r", "goals/g"]) {
    await update("patient", docPath, { userRef: { referenceValue: `${base.replace('http://' + host + '/v1/', '')}/users/other` } }, false);
  }
  await update("patient", "records/r", { psychologistComment: { stringValue: "Falsificado" } }, false);
  await update("a", "records/r", { psychologistComment: { stringValue: "Compartido" } });
  await read("patient", "records/r");

  // Live consent blocks access BEFORE any background trigger runs.
  await patient.update({ shareDataWithPsychologist: false });
  await read("a", "records/r", false);
  await list("a", "records", "userRef", patient, false);
  await read("a", "goals/g", false);
  await syncPatientAccess(patient);
  assert.equal((await db.doc("records/r").get()).data().psychologistRef, null);
  await backend.adminBackfillPsychologistRefs.run({ auth: { uid: "admin" }, data: {} });
  assert.equal((await db.doc("records/r").get()).data().psychologistRef, null);
  await patient.update({ shareDataWithPsychologist: true });

  const assigned = await backend.adminAssignPsychologist.run({ auth: { uid: "admin" },
    data: { patientId: "patient", psychologistId: "b" } });
  assert.notEqual(assigned.conversationId, "patient");
  await read("a", "records/r", false);
  await list("b", "records", "userRef", patient);
  await read("b", "conversations/patient/messages/old", false);
  await read("a", "conversations/patient/messages/old");
  await read("b", "patient_notes/patient", false);
  await read("a", "patient_notes/patient");
  await db.doc("users/a/patient_notes/patient").set({ notes: "Solo A" });
  await read("b", "users/a/patient_notes/patient", false);
  await read("patient", "users/a/patient_notes/patient", false);
  await read("a", "users/a/patient_notes/patient");
  await update("b", "users/b/patient_notes/patient", { notes: { stringValue: "Nota de B" } });
  await read("a", "users/b/patient_notes/patient", false);
  await list("b", "tasks", "userRef", patient);
  await list("b", "session_requests", "patientRef", patient);

  // Deliver an obsolete sharing-enabled event after the patient disabled it.
  await patient.update({ shareDataWithPsychologist: false });
  const snapshot = (data) => ({ exists: true, data: () => data });
  await backend.onShareDataWithPsychologistChanged.run({ id: "late", params: { uid: "patient" }, data: {
    before: snapshot({ role: "paciente", shareDataWithPsychologist: false, psychologistRef: a }),
    after: snapshot({ role: "paciente", shareDataWithPsychologist: true, psychologistRef: a }),
  } });
  assert.equal((await db.doc("records/r").get()).data().psychologistRef, null);
  assert.equal((await db.doc("tasks/t").get()).data().psychologistRef.path, b.path);

  const message = { auth: { uid: "patient" }, data: {
    conversationId: assigned.conversationId, messageId: "retry-1", text: "Hola B",
  } };
  await backend.sendConversationMessage.run(message);
  await backend.sendConversationMessage.run(message);
  assert.equal((await db.doc(`conversations/${assigned.conversationId}`).collection("messages").get()).size, 1);
  await assert.rejects(backend.sendConversationMessage.run({ auth: { uid: "patient" }, data: {
    conversationId: "patient", messageId: "archived-1", text: "No enviar a otro profesional",
    resolvePatientAlias: false,
  } }), (error) => error.code === "failed-precondition");
  await backend.sendConversationMessage.run({ auth: { uid: "patient" }, data: {
    conversationId: "patient", messageId: "alias-1", text: "Mensaje al profesional actual",
    resolvePatientAlias: true,
  } });
  await assert.rejects(backend.sendConversationMessage.run({ auth: { uid: "a" }, data: message.data }),
    (error) => error.code === "permission-denied");
  await Promise.all([1, 2].map(() => notifyUser("patient", {
    type: "test", title: "Una notificación", body: "Prueba", notificationId: "same-event",
  })));
  assert.equal((await db.collection("notifications").where("type", "==", "test").get()).size, 1);

  await db.doc("user_prefs/patient").set({ dailyReminderEnabled: true });
  const scheduleTime = "2026-09-30T14:00:00Z";
  await sendDailyReminders.run({ scheduleTime });
  await sendDailyReminders.run({ scheduleTime });
  assert.equal((await db.collection("notifications").where("type", "==", "daily_reminder").get()).size, 1);
  await db.doc("user_prefs/patient").update({ dailyReminderEnabled: false });
  await sendDailyReminders.run({ scheduleTime: "2026-10-01T14:00:00Z" });
  assert.equal((await db.collection("notifications").where("type", "==", "daily_reminder").get()).size, 1);
  await db.doc("users/unassigned").set({ role: "paciente" });
  const links = await Promise.allSettled(["A-1234", "B-1234"].map((code) =>
    backend.linkPsychologistByCode.run({ auth: { uid: "unassigned" }, data: { code } })));
  assert.equal(links.filter((result) => result.status === "fulfilled").length, 1);
  await db.terminate();
  await admin.app().delete();
});
