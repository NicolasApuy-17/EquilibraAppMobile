/* global fetch */
const { test } = require("node:test");
const assert = require("node:assert/strict");
const host = process.env.FIREBASE_STORAGE_EMULATOR_HOST;

function token(uid) {
  const encode = (value) => Buffer.from(JSON.stringify(value)).toString("base64url");
  const project = "demo-equilibra-review";
  return `${encode({ alg: "none", typ: "JWT" })}.${encode({
    sub: uid, user_id: uid, aud: project, iss: `https://securetoken.google.com/${project}`,
    iat: Math.floor(Date.now() / 1000), exp: Math.floor(Date.now() / 1000) + 3600,
    firebase: { sign_in_provider: "custom" },
  })}.`;
}

test("Storage accepts profile/news images and rejects unauthorized files", { skip: !host }, async () => {
  assert.match(host, /^(127\.0\.0\.1|localhost):\d+$/);
  const base = `http://${host}/v0/b/demo-equilibra-review.appspot.com/o`;
  async function upload(uid, name, type, expected, size = 4) {
    const response = await fetch(`${base}?name=${encodeURIComponent(name)}&uploadType=media`, {
      method: "POST", headers: { Authorization: `Bearer ${token(uid)}`, "Content-Type": type },
      body: Buffer.alloc(size),
    });
    assert.equal(response.status, expected, await response.text());
  }
  await upload("patient", "users/patient/profile_photo.jpg", "image/jpeg", 200);
  await upload("other", "users/patient/forbidden.jpg", "image/jpeg", 403);
  await upload("patient", "users/patient/script.html", "text/html", 403);
  await upload("patient", "users/patient/large.jpg", "image/jpeg", 403, 10 * 1024 * 1024 + 1);
  await upload("b", "news_images/b/news.png", "image/png", 200);
  await upload("patient", "news_images/patient/news.png", "image/png", 403);
  const deleted = await fetch(`${base}/${encodeURIComponent('users/patient/profile_photo.jpg')}`, {
    method: "DELETE", headers: { Authorization: `Bearer ${token("patient")}` },
  });
  assert.ok([200, 204].includes(deleted.status), await deleted.text());
});
