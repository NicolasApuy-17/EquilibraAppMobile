/* global fetch */
const { test } = require("node:test");
const assert = require("node:assert/strict");
const admin = require("firebase-admin");
for (const key of ["FIRESTORE_EMULATOR_HOST", "FIREBASE_AUTH_EMULATOR_HOST", "FIREBASE_STORAGE_EMULATOR_HOST"]) {
  if (!/^(127\.0\.0\.1|localhost):\d+$/.test(process.env[key] || "")) {
    throw new Error("Account action tests require only local Firebase emulators.");
  }
}
const project = "equilibra-w5rl2h";
admin.initializeApp({ projectId: project, storageBucket: `${project}.firebasestorage.app` });
const db = admin.firestore();
const password = "LocalGuardTest2026!";

async function create(suffix, profile = {}) {
  const uid = `guard-${suffix}`;
  const email = `${uid}@example.com`;
  await admin.auth().createUser({ uid, email, password });
  await db.doc(`users/${uid}`).set({ email, role: "admin", active: true, ...profile });
  return { uid, email };
}

async function login(user) {
  const response = await fetch(`http://${process.env.FIREBASE_AUTH_EMULATOR_HOST}/identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=local-only`, {
    method: "POST", headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ email: user.email, password, returnSecureToken: true }),
  });
  const body = await response.json();
  assert.ok(response.ok, "Local sign-in failed");
  return body.idToken;
}

async function call(token, name, data) {
  const response = await fetch(`http://127.0.0.1:5008/${project}/us-central1/${name}`, {
    method: "POST", headers: { "Content-Type": "application/json", Authorization: `Bearer ${token}` },
    body: JSON.stringify({ data }),
  });
  return { status: response.status, body: await response.json() };
}

async function clean(...users) {
  for (const user of users) {
    if (!user.uid.startsWith("guard-")) throw new Error("Only disposable local guard accounts may be cleaned.");
    try { await admin.auth().deleteUser(user.uid); } catch (error) {
      if (error.code !== "auth/user-not-found") throw error;
    }
    await db.doc(`users/${user.uid}`).delete();
  }
}

test("real callable preserves the last admin and rejects unavailable backups", async () => {
  assert.equal((await db.collection("users").where("role", "==", "admin").get()).empty, true,
    "Run guard integration tests before seeding Pixel fixtures");
  const owner = await create("sole");
  const backup = await create("unavailable", { active: false });
  try {
    const token = await login(owner);
    for (const state of ["inactive", "disabled", "orphan", "pending"]) {
      await db.doc(`users/${backup.uid}`).set({ email: backup.email, role: "admin", active: state !== "inactive",
        ...(state === "pending" ? { accountDeletion: { id: "reserved", startedAt: 0 } } : {}) });
      if (state === "disabled") await admin.auth().updateUser(backup.uid, { disabled: true });
      if (state === "orphan") await admin.auth().deleteUser(backup.uid);
      if (state === "pending") await admin.auth().createUser({ uid: backup.uid, email: backup.email, password });
      const result = await call(token, "deleteMyAccount", { confirmationEmail: owner.email });
      assert.equal(result.body.error?.status, "FAILED_PRECONDITION", state);
      assert.match(result.body.error.message, /única cuenta/);
      assert.ok(await admin.auth().getUser(owner.uid));
      assert.equal((await db.doc(`users/${owner.uid}`).get()).data().accountDeletion, undefined);
    }
  } finally { await clean(owner, backup); }
});

test("real Firestore transactions preserve exactly one admin during concurrent self deletion", async () => {
  const a = await create("concurrent-a"), b = await create("concurrent-b");
  try {
    const tokens = await Promise.all([login(a), login(b)]);
    const outcomes = await Promise.all([call(tokens[0], "deleteMyAccount", { confirmationEmail: a.email }),
      call(tokens[1], "deleteMyAccount", { confirmationEmail: b.email })]);
    assert.equal(outcomes.filter((result) => result.status === 200).length, 1, JSON.stringify(outcomes));
    assert.equal(outcomes.filter((result) => result.body.error?.status === "FAILED_PRECONDITION").length, 1);
    const remaining = await Promise.all([a, b].map(async (user) => {
      try { return await admin.auth().getUser(user.uid); } catch (error) {
        if (error.code === "auth/user-not-found") return null;
        throw error;
      }
    }));
    assert.equal(remaining.filter(Boolean).length, 1);
  } finally { await clean(a, b); }
});

test("administrative deletion respects a concurrently reserved caller", async () => {
  const caller = await create("caller"), target = await create("target");
  try {
    const token = await login(caller);
    await db.doc(`users/${caller.uid}`).update({ accountDeletion: { id: "pending", startedAt: Date.now() } });
    const denied = await call(token, "adminDeleteAccount", { uid: target.uid, confirmationEmail: target.email });
    assert.equal(denied.body.error?.status, "FAILED_PRECONDITION");
    assert.ok(await admin.auth().getUser(target.uid));
    await db.doc(`users/${caller.uid}`).update({ accountDeletion: admin.firestore.FieldValue.delete() });
    const allowed = await call(token, "adminDeleteAccount", { uid: target.uid, confirmationEmail: target.email });
    assert.equal(allowed.body.result.deleted, true);
    assert.ok(await admin.auth().getUser(caller.uid));
  } finally { await clean(caller, target); }
});
