const { test } = require("node:test");
const assert = require("node:assert/strict");
const admin = require("firebase-admin");
const project = "demo-equilibra-review";
for (const variable of ["FIRESTORE_EMULATOR_HOST", "FIREBASE_STORAGE_EMULATOR_HOST"]) {
  if (!/^(127\.0\.0\.1|localhost):\d+$/.test(process.env[variable] || "")) {
    throw new Error("Deletion tests must run exclusively in local emulators.");
  }
}
admin.initializeApp({ projectId: project, storageBucket: `${project}.appspot.com` });
const { deleteAccountData } = require("../account_deletion");
const db = admin.firestore();
const bucket = admin.storage().bucket();

test("account deletion purges personal documents, messages and files, and retries safely", async () => {
  const user = db.doc("users/deletion-patient");
  const clinician = db.doc("users/deletion-clinician");
  const other = db.doc("users/deletion-other");
  await user.set({ role: "paciente", psychologistRef: clinician });
  await clinician.set({ role: "psicologo" });
  await other.set({ role: "paciente", psychologistRef: clinician });
  const removed = ["users/deletion-patient", "user_prefs/deletion-patient",
    "patient_notes/deletion-patient", "users/deletion-clinician/patient_notes/deletion-patient",
    "users/deletion-patient/nested/private", "conversations/deletion-chat",
    "conversations/deletion-chat/messages/private", "records/deletion-record",
    "notifications/deletion-patient", "notifications/deletion-about-patient",
    "notifications/deletion-message"];
  for (const path of removed) {
    if (path.startsWith("users/") && path.split("/").length === 2) continue;
    await db.doc(path).set({ notes: "Personal", userRef: user, recipientRef: user,
      patientRef: user, psychologistRef: clinician,
      subjectRef: user, conversationId: "deletion-chat" });
  }
  for (const collection of ["behavioral_records", "goals", "tasks", "sessions",
    "session_requests", "activity_assignments", "app_errors"]) {
    const path = `${collection}/deletion-patient`;
    removed.push(path);
    await db.doc(path).set({ userRef: user, patientRef: user, psychologistRef: clinician });
  }
  await db.doc("records/deletion-other").set({ userRef: other, psychologistRef: clinician });
  await db.doc("users/orphan/patient_notes/deletion-patient").set({ notes: "Orphaned" });
  removed.push("users/orphan/patient_notes/deletion-patient");
  const personalFile = bucket.file("users/deletion-patient/photo.jpg");
  const otherFile = bucket.file("users/deletion-other/photo.jpg");
  await personalFile.save(Buffer.from("photo"), { resumable: false });
  await otherFile.save(Buffer.from("other"), { resumable: false });
  await deleteAccountData(user.id);
  for (const path of removed) assert.equal((await db.doc(path).get()).exists, false, path);
  assert.equal((await personalFile.exists())[0], false);
  assert.equal((await otherFile.exists())[0], true);
  assert.equal((await db.doc("records/deletion-other").get()).exists, true);
  await deleteAccountData(user.id);

  // Deleting a clinician must unlink their patients, preserving their history.
  await db.doc("tasks/deletion-other").set({ userRef: other, psychologistRef: clinician,
    createdByRef: clinician, title: "Keep patient task" });
  await db.doc("news/deletion-clinician").set({ psychologistRef: clinician });
  const newsFile = bucket.file("news_images/deletion-clinician/photo.jpg");
  await newsFile.save(Buffer.from("news"), { resumable: false });
  await deleteAccountData(clinician.id);
  assert.equal((await clinician.get()).exists, false);
  assert.equal((await other.get()).data().psychologistRef, undefined);
  assert.equal((await db.doc("records/deletion-other").get()).exists, true);
  assert.equal((await db.doc("tasks/deletion-other").get()).data().createdByRef, null);
  assert.equal((await db.doc("news/deletion-clinician").get()).exists, false);
  assert.equal((await newsFile.exists())[0], false);
  await assert.rejects(deleteAccountData("invalid/uid"), /Invalid/);
});
