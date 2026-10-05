const admin = require("firebase-admin");
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
for (const key of ["FIRESTORE_EMULATOR_HOST", "FIREBASE_AUTH_EMULATOR_HOST", "FIREBASE_STORAGE_EMULATOR_HOST"]) {
  if (!/^(127\.0\.0\.1|localhost):\d+$/.test(process.env[key] || "")) {
    throw new Error("Deletion fixtures require only local Firebase emulators.");
  }
}
admin.initializeApp({ projectId: "equilibra-w5rl2h", storageBucket: "equilibra-w5rl2h.firebasestorage.app" });
const db = admin.firestore();
const bucket = admin.storage().bucket();
async function main() {
  if (process.argv.includes("--verify")) {
    for (const suffix of ["patient", "admin", "psychologist"]) {
      const uid = `pixel-deletion-${suffix}`;
      for (let attempt = 0; attempt < 60 && (await db.doc(`users/${uid}`).get()).exists; attempt++) {
        await new Promise((resolve) => setTimeout(resolve, 1000));
      }
      await assert.rejects(admin.auth().getUser(uid), (error) => error.code === "auth/user-not-found");
      assert.equal((await db.doc(`users/${uid}`).get()).exists, false);
      assert.equal((await db.doc(`records/${uid}`).get()).exists, false);
      assert.equal((await bucket.file(`users/${uid}/pixel.png`).exists())[0], false);
    }
    const other = "pixel-deletion-other";
    assert.ok(await admin.auth().getUser(other));
    assert.equal((await db.doc(`users/${other}`).get()).exists, true);
    assert.equal((await db.doc(`records/${other}`).get()).exists, true);
    assert.equal((await bucket.file(`users/${other}/pixel.png`).exists())[0], true);
    const backup = "pixel-deletion-backup";
    assert.ok(await admin.auth().getUser(backup));
    assert.equal((await db.doc(`users/${backup}`).get()).data().role, "admin");
    fs.writeFileSync(path.join(__dirname, "../../../account-deletion-pixel-verify.json"),
      JSON.stringify({ localOnly: true, deletedAuthAccounts: 3, deletedProfiles: 3,
        deletedRecords: 3, deletedPersonalFiles: 3, unrelatedAccountPreserved: true,
        remainingAdministratorPreserved: true }, null, 2));
    console.log("PASS: Auth, Firestore and Storage deleted; unrelated account preserved.");
    return;
  }
  for (const [suffix, role, displayName] of [["admin", "admin", "Administrador Prueba"],
    ["patient", "paciente", "Cuenta Para Eliminar"], ["other", "paciente", "Cuenta Para Conservar"],
    ["backup", "paciente", "Administrador De Respaldo"], ["psychologist", "psicologo", "Psicólogo Prueba"]]) {
    const uid = `pixel-deletion-${suffix}`;
    const email = `pixel-delete-${suffix}@example.com`;
    const values = { email, password: "PixelTest2026!", displayName, disabled: false };
    try { await admin.auth().updateUser(uid, values); } catch (error) {
      if (error.code !== "auth/user-not-found") throw error;
      await admin.auth().createUser({ uid, ...values });
    }
    const ref = db.doc(`users/${uid}`);
    await ref.set({ role, active: true, email, display_name: displayName });
    await db.doc(`records/${uid}`).set({ userRef: ref, emotion: "Tranquilo", intensity: 2 });
    await bucket.file(`users/${uid}/pixel.png`).save(Buffer.from("local-test"),
      { resumable: false, metadata: { contentType: "image/png" } });
  }
  console.log("Local deletion fixtures ready.");
}
main().catch((error) => { console.error(error); process.exitCode = 1; });
