const admin = require("firebase-admin");
const { FieldPath, FieldValue } = require("firebase-admin/firestore");

// Called only after Auth deletion by an authorized operator or the Auth SDK.
// Any legally required retention must be exported to a restricted archive by
// the operator BEFORE deleting Auth. This routine removes the live app data.
async function deleteAccountData(uid) {
  if (typeof uid !== "string" || !uid || uid.includes("/")) {
    throw new Error("Invalid account UID");
  }
  const db = admin.firestore();
  const user = db.doc(`users/${uid}`);

  async function deleteQuery(query) {
    // Requery the first page: deleted documents no longer occupy the cursor.
    for (;;) {
      const page = await query.limit(100).get();
      if (page.empty) return;
      for (const doc of page.docs) {
        await deleteQuery(db.collection("notifications").where("subjectRef", "==", doc.ref));
        await db.recursiveDelete(doc.ref);
      }
    }
  }

  for (const [collection, field] of [
    ["records", "userRef"], ["behavioral_records", "userRef"],
    ["goals", "userRef"], ["tasks", "userRef"],
    ["sessions", "patientRef"], ["session_requests", "patientRef"],
    ["activity_assignments", "patientRef"], ["app_errors", "userRef"],
    ["notifications", "recipientRef"], ["notifications", "subjectRef"],
    ["sessions", "psychologistRef"], ["news", "psychologistRef"],
  ]) {
    await deleteQuery(db.collection(collection).where(field, "==", user));
  }

  for (const field of ["patientRef", "psychologistRef"]) {
    const query = db.collection("conversations").where(field, "==", user);
    for (;;) {
      const page = await query.limit(100).get();
      if (page.empty) break;
      for (const doc of page.docs) {
        await deleteQuery(db.collection("notifications").where("conversationId", "==", doc.id));
        await db.recursiveDelete(doc.ref); // Includes all messages.
      }
    }
  }

  // Notes are keyed by patient ID rather than a stored patientRef. A bounded
  // scan also finds orphaned note subcollections under deleted user profiles.
  let cursor;
  for (;;) {
    let query = db.collectionGroup("patient_notes")
      .orderBy(FieldPath.documentId()).limit(100);
    if (cursor) query = query.startAfter(cursor);
    const page = await query.get();
    if (page.empty) break;
    for (const doc of page.docs) {
      if (doc.id === uid || doc.data().psychologistRef?.path === user.path) {
        await db.recursiveDelete(doc.ref);
      }
    }
    cursor = page.docs[page.docs.length - 1];
  }
  await db.recursiveDelete(db.doc(`patient_notes/${uid}`));
  await db.recursiveDelete(db.doc(`user_prefs/${uid}`));

  // Preserve other patients' records. Remove the deleted professional's
  // assignment so they can link to another professional without losing data.
  for (const collection of ["users", "records", "behavioral_records", "tasks",
    "session_requests", "activity_assignments"]) {
    for (;;) {
      const page = await db.collection(collection).where("psychologistRef", "==", user).limit(100).get();
      if (page.empty) break;
      const batch = db.batch();
      for (const doc of page.docs) {
        const fields = { psychologistRef: FieldValue.delete() };
        if (collection === "users") {
          fields.activeConversationId = FieldValue.delete();
          fields.psychologistLinkedAt = FieldValue.delete();
        }
        batch.update(doc.ref, fields);
      }
      await batch.commit();
    }
  }
  for (;;) {
    const page = await db.collection("tasks").where("createdByRef", "==", user).limit(100).get();
    if (page.empty) break;
    const batch = db.batch();
    page.docs.forEach((doc) => batch.update(doc.ref, {
      createdByRef: null,
    }));
    await batch.commit();
  }

  const bucket = admin.storage().bucket();
  await bucket.deleteFiles({ prefix: `users/${uid}/` });
  await bucket.deleteFiles({ prefix: `news_images/${uid}/` });
  // Delete profile last: a failed Storage deletion leaves a retryable job,
  // rather than reporting completion while files still exist.
  await db.recursiveDelete(user);
}

module.exports = { deleteAccountData };
