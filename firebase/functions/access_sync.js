const admin = require("firebase-admin");
const { FieldPath } = require("firebase-admin/firestore");

/** Re-read the live profile inside every commit, so delayed events cannot
 * restore an obsolete assignment or consent. References are query indexes,
 * never the source of truth for authorization. */
async function syncPatientAccess(patientRef) {
  const db = admin.firestore();
  const result = {};
  for (const [collection, ownerField, shared] of [
    ["records", "userRef", true],
    ["behavioral_records", "userRef", true],
    ["tasks", "userRef", false],
    ["session_requests", "patientRef", false],
  ]) {
    let cursor;
    let updated = 0;
    for (;;) {
      let query = db.collection(collection).where(ownerField, "==", patientRef)
        .orderBy(FieldPath.documentId()).limit(100);
      if (cursor) query = query.startAfter(cursor);
      const page = await query.get();
      if (page.empty) break;
      updated += await db.runTransaction(async (tx) => {
        const patient = await tx.get(patientRef);
        if (!patient.exists) return 0;
        const profile = patient.data();
        const target = shared && profile.shareDataWithPsychologist === false
          ? null : profile.psychologistRef || null;
        const docs = await tx.getAll(...page.docs.map((doc) => doc.ref));
        let count = 0;
        for (const doc of docs) {
          if (!doc.exists || doc.data()[ownerField]?.path !== patientRef.path) continue;
          const stored = doc.data().psychologistRef || null;
          if (stored?.path === target?.path) continue;
          tx.update(doc.ref, { psychologistRef: target });
          count++;
        }
        return count;
      });
      cursor = page.docs[page.docs.length - 1];
      if (page.size < 100) break;
    }
    result[collection] = { updated, skippedNoPsychologist: 0 };
  }
  return result;
}

module.exports = { syncPatientAccess };
