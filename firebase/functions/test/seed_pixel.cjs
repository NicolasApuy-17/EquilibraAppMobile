// This file never runs against production, even though the Android native
// config retains the real project ID for package/Firebase initialization.
const admin = require("firebase-admin");
for (const variable of ["FIRESTORE_EMULATOR_HOST", "FIREBASE_AUTH_EMULATOR_HOST",
  "FIREBASE_STORAGE_EMULATOR_HOST"]) {
  if (!/^(127\.0\.0\.1|localhost):\d+$/.test(process.env[variable] || "")) {
    throw new Error("Pixel fixtures require exclusively local Firebase emulators.");
  }
}
admin.initializeApp({ projectId: "equilibra-w5rl2h",
  storageBucket: "equilibra-w5rl2h.firebasestorage.app" });
async function main() {
  for (const email of ["pixel-patient@example.com"]) {
    try {
      const previous = await admin.auth().getUserByEmail(email);
      await admin.auth().deleteUser(previous.uid);
      await admin.firestore().recursiveDelete(admin.firestore().doc(`users/${previous.uid}`));
    } catch (error) { if (error.code !== "auth/user-not-found") throw error; }
  }
  const profile = { email: "pixel-psychologist@example.com", password: "PixelTest2026!",
    displayName: "Profesional Prueba" };
  try {
    await admin.auth().updateUser("pixel-test-psychologist", profile);
  } catch (error) {
    if (error.code !== "auth/user-not-found") throw error;
    await admin.auth().createUser({ uid: "pixel-test-psychologist", ...profile });
  }
  await admin.firestore().doc("users/pixel-test-psychologist").set({
    role: "psicologo", display_name: "Profesional Prueba", email: "pixel-psychologist@example.com",
    uid: "pixel-test-psychologist", linkCode: "PIXEL-2026", active: true,
  });
  console.log("Local Pixel fixture ready.");
}
main().catch((error) => { console.error(error.message); process.exitCode = 1; });
