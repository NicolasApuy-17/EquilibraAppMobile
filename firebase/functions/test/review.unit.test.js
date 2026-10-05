const { test } = require("node:test");
const assert = require("node:assert/strict");
const vm = require("node:vm");
const fs = require("node:fs");
const path = require("node:path");

test("a failed psychologist profile compensates only the newly created Auth account", async () => {
  const deleted = [];
  const query = { where: () => query, limit: () => query,
    get: async () => ({ empty: true }) };
  const auth = { createUser: async () => ({ uid: "new-account" }),
    deleteUser: async (uid) => deleted.push(uid) };
  const firestore = () => ({ collection: (name) => ({
    ...query, add: async () => ({}), doc: (uid) => ({
      get: async () => ({ exists: true, data: () => ({ role: "admin" }) }),
      set: async () => {
        if (name === "users" && uid === "new-account") throw new Error("Simulated write failure");
      },
    }),
  }) });
  firestore.FieldValue = { serverTimestamp: () => "now" };
  const exports = {};
  class HttpsError extends Error {
    constructor(code, message) { super(message); this.code = code; }
  }
  const dependencies = {
    "firebase-admin": { firestore, auth: () => auth },
    "firebase-admin/firestore": { FieldValue: firestore.FieldValue },
    "firebase-functions/v2/https": { onCall: (options, handler) => ({ run: handler }), HttpsError },
    "./event_context": { onDocumentWritten: (options, handler) => ({ run: handler }) },
    "./access_sync": { syncPatientAccess: async () => ({}) },
    "./notifications": { notifyUser: async () => {}, notifyAdmins: async () => {}, displayNameFor: async () => "Test" },
  };
  vm.runInNewContext(fs.readFileSync(path.join(__dirname, "../psychologists.js"), "utf8"), {
    exports, require: (name) => dependencies[name], console: { error() {} },
  });
  await assert.rejects(exports.createPsychologist.run({ auth: { uid: "admin" }, data: {
    displayName: "María García", email: "maria@example.com", specialty: "Psicología", password: "testpassword",
  } }), (error) => error.code === "internal");
  assert.deepEqual(deleted, ["new-account"]);
});
