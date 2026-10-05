const { test } = require("node:test");
const assert = require("node:assert/strict");
const vm = require("node:vm");
const fs = require("node:fs");
const path = require("node:path");

function fixture() {
  const profiles = { admin: { role: "admin", email: "admin@example.com" },
    patient: { role: "paciente", email: "patient@example.com" },
    orphan: { role: "paciente", email: "orphan@example.com" } };
  const users = { admin: { uid: "admin", email: "admin@example.com" },
    patient: { uid: "patient", email: "patient@example.com" } };
  const deleted = [], purged = [];
  const deleteField = Symbol("delete");
  let deleteFailure;
  let beforeDelete = async () => {};
  const snapshot = (uid) => ({ id: uid, exists: !!profiles[uid], data: () => profiles[uid] });
  const firestore = {
    doc: (docPath) => ({ uid: docPath.split("/")[1], get: async () => snapshot(docPath.split("/")[1]) }),
    collection: () => ({ where: () => ({ admins: true }) }),
  };
  let transactions = Promise.resolve();
  firestore.runTransaction = (run) => {
    const pending = transactions.then(() => run({
      get: async (ref) => ref.admins ? { docs: Object.keys(profiles)
        .filter((uid) => profiles[uid].role === "admin").map(snapshot) } : snapshot(ref.uid),
      update: (ref, fields) => {
        for (const [key, value] of Object.entries(fields)) {
          if (value === deleteField) delete profiles[ref.uid][key];
          else profiles[ref.uid][key] = value;
        }
      },
    }));
    transactions = pending.catch(() => {});
    return pending;
  };
  class HttpsError extends Error {
    constructor(code, message) { super(message); this.code = code; }
  }
  const exports = {};
  const dependencies = {
    "firebase-admin": {
      auth: () => ({ getUser: async (uid) => {
        if (!users[uid]) throw Object.assign(new Error("missing"), { code: "auth/user-not-found" });
        return users[uid];
      }, deleteUser: async (uid) => {
        await beforeDelete(uid);
        if (deleteFailure) throw deleteFailure;
        deleted.push(uid); delete users[uid];
      } }),
      firestore: () => firestore,
    },
    "node:crypto": require("node:crypto"),
    "firebase-admin/firestore": { FieldValue: { delete: () => deleteField } },
    "firebase-functions/v2/https": { onCall: (options, run) => ({ run }), HttpsError },
    "./account_deletion": { deleteAccountData: async (uid) => purged.push(uid) },
  };
  vm.runInNewContext(fs.readFileSync(path.join(__dirname, "../account_actions.js"), "utf8"), {
    exports, require: (name) => dependencies[name], console,
  });
  return { api: exports, deleted, purged, profiles, users,
    failDelete: (error) => { deleteFailure = error; },
    beforeDelete: (run) => { beforeDelete = run; } };
}
const request = (uid, data = {}, age = 0) => ({
  auth: { uid, token: { auth_time: Math.floor(Date.now() / 1000) - age } }, data,
});
const codeIs = (code) => (error) => error.code === code;

test("deletion rejects anonymous, expired, future and deleted identities", async () => {
  const f = fixture();
  await assert.rejects(f.api.deleteMyAccount.run({ data: {} }), codeIs("unauthenticated"));
  for (const age of [301, -60, NaN]) {
    await assert.rejects(f.api.deleteMyAccount.run(request("patient", {}, age)), codeIs("failed-precondition"));
  }
  await assert.rejects(f.api.deleteMyAccount.run(request("missing")), codeIs("unauthenticated"));
  f.users.patient.disabled = true;
  await assert.rejects(f.api.deleteMyAccount.run(request("patient")), codeIs("permission-denied"));
  assert.deepEqual(f.deleted, []);
});

test("self deletion verifies the email and never accepts another account's UID", async () => {
  const f = fixture();
  await assert.rejects(f.api.deleteMyAccount.run(request("patient", {
    confirmationEmail: "admin@example.com", uid: "admin",
  })), codeIs("invalid-argument"));
  assert.deepEqual(f.deleted, []);
  const result = await f.api.deleteMyAccount.run(request("patient", {
    confirmationEmail: "PATIENT@example.com", uid: "admin",
  }));
  assert.equal(result.cleanupPending, true);
  assert.deepEqual(f.deleted, ["patient"]);
  assert.ok(f.users.admin);
});

test("admin deletion requires the live administrator role and confirmation", async () => {
  const f = fixture();
  const data = { uid: "patient", confirmationEmail: "patient@example.com" };
  await assert.rejects(f.api.adminDeleteAccount.run(request("patient", data)), codeIs("permission-denied"));
  f.profiles.admin.active = false;
  await assert.rejects(f.api.adminDeleteAccount.run(request("admin", data)), codeIs("permission-denied"));
  f.profiles.admin.active = true;
  await assert.rejects(f.api.adminDeleteAccount.run(request("admin", {
    uid: "admin", confirmationEmail: "admin@example.com",
  })), codeIs("failed-precondition"));
  await assert.rejects(f.api.adminDeleteAccount.run(request("admin", {
    uid: "patient", confirmationEmail: "wrong@example.com",
  })), codeIs("invalid-argument"));
  assert.deepEqual(f.deleted, []);
  await f.api.adminDeleteAccount.run(request("admin", data));
  assert.deepEqual(f.deleted, ["patient"]);
});

test("admin retries clean an orphaned profile without deleting another Auth user", async () => {
  const f = fixture();
  const result = await f.api.adminDeleteAccount.run(request("admin", {
    uid: "orphan", confirmationEmail: "orphan@example.com",
  }));
  assert.equal(result.cleanupPending, false);
  assert.deepEqual(f.purged, ["orphan"]);
  assert.deepEqual(f.deleted, []);
});

function addBackup(f, values = {}) {
  f.profiles.backup = { role: "admin", email: "backup@example.com", ...values };
  f.users.backup = { uid: "backup", email: "backup@example.com" };
}

test("the last available administrator cannot delete their own account", async () => {
  const f = fixture();
  await assert.rejects(f.api.deleteMyAccount.run(request("admin", {
    confirmationEmail: "admin@example.com",
  })), (error) => error.code === "failed-precondition" && error.message.includes("única cuenta"));
  assert.deepEqual(f.deleted, []);
  assert.equal(f.profiles.admin.accountDeletion, undefined);
});

test("inactive, disabled, orphaned and pending administrators are not available backups", async () => {
  for (const state of ["inactive", "disabled", "orphan", "pending"]) {
    const f = fixture();
    addBackup(f);
    if (state === "inactive") f.profiles.backup.active = false;
    if (state === "disabled") f.users.backup.disabled = true;
    if (state === "orphan") delete f.users.backup;
    if (state === "pending") f.profiles.backup.accountDeletion = { id: "pending", startedAt: 0 };
    await assert.rejects(f.api.deleteMyAccount.run(request("admin", {
      confirmationEmail: "admin@example.com",
    })), codeIs("failed-precondition"));
    assert.deepEqual(f.deleted, [], state);
  }
});

test("an administrator may delete themselves or another admin when a backup remains", async () => {
  for (const own of [true, false]) {
    const f = fixture();
    addBackup(f);
    const result = own ? await f.api.deleteMyAccount.run(request("admin", {
      confirmationEmail: "admin@example.com",
    })) : await f.api.adminDeleteAccount.run(request("admin", {
      uid: "backup", confirmationEmail: "backup@example.com",
    }));
    assert.equal(result.deleted, true);
    assert.deepEqual(f.deleted, [own ? "admin" : "backup"]);
    assert.ok(f.users[own ? "backup" : "admin"]);
  }
});

test("a reserved administrator cannot be counted by another deletion in either endpoint", async () => {
  for (const own of [true, false]) {
    const f = fixture();
    addBackup(f);
    let finishDelete;
    let reserved;
    const ready = new Promise((resolve) => { reserved = resolve; });
    f.beforeDelete(async () => {
      reserved();
      await new Promise((resolve) => { finishDelete = resolve; });
    });
    const first = f.api.deleteMyAccount.run(request("admin", { confirmationEmail: "admin@example.com" }));
    await ready;
    await assert.rejects(own ? f.api.deleteMyAccount.run(request("backup", {
      confirmationEmail: "backup@example.com",
    })) : f.api.adminDeleteAccount.run(request("admin", {
      uid: "backup", confirmationEmail: "backup@example.com",
    })), codeIs("failed-precondition"));
    finishDelete();
    await first;
    assert.deepEqual(f.deleted, ["admin"]);
    assert.ok(f.users.backup);
  }
});

test("a confirmed Auth failure releases the reservation without deleting the account", async () => {
  const f = fixture();
  addBackup(f);
  f.failDelete(Object.assign(new Error("Unavailable"), { code: "auth/internal-error" }));
  await assert.rejects(f.api.deleteMyAccount.run(request("admin", {
    confirmationEmail: "admin@example.com",
  })), codeIs("auth/internal-error"));
  assert.equal(f.profiles.admin.accountDeletion, undefined);
  assert.deepEqual(f.deleted, []);
});

test("a crashed reservation can be retried while its account never counts as backup", async () => {
  const f = fixture();
  addBackup(f);
  f.profiles.admin.accountDeletion = { id: "old", startedAt: Date.now() };
  await assert.rejects(f.api.deleteMyAccount.run(request("admin", {
    confirmationEmail: "admin@example.com",
  })), codeIs("failed-precondition"));
  f.profiles.admin.accountDeletion.startedAt -= 21 * 60 * 1000;
  await f.api.deleteMyAccount.run(request("admin", { confirmationEmail: "admin@example.com" }));
  assert.deepEqual(f.deleted, ["admin"]);
});
