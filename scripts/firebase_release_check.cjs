// Uses the user's existing Firebase CLI login. Never exports credentials or
// changes enforcement for other apps sharing the backend.
const path = require("node:path");
const fs = require("node:fs");
const cli = path.join(process.env.APPDATA, "npm/node_modules/firebase-tools/lib");
const { requireAuth } = require(path.join(cli, "requireAuth.js"));
const { getGlobalDefaultAccount } = require(path.join(cli, "auth.js"));
const { Client } = require(path.join(cli, "apiv2.js"));

async function main() {
  const account = getGlobalDefaultAccount();
  if (!account) throw new Error("Run firebase login first.");
  await requireAuth({ ...account, project: "equilibra-w5rl2h" });
  const app = "projects/229293546081/apps/1:229293546081:android:cbcaa00183f9b88d62a820";
  const client = new Client({ urlPrefix: "https://firebaseappcheck.googleapis.com", apiVersion: "v1" });
  const config = await client.get(`/${app}/playIntegrityConfig`, { resolveOnHTTPError: true });
  console.log("App Check configuration HTTP", config.status);
  if (config.status === 404 && process.argv.includes("--configure-app-check")) {
    const configured = await client.patch(`/${app}/playIntegrityConfig`,
      { name: `${app}/playIntegrityConfig`, tokenTtl: "3600s" },
      { queryParams: { updateMask: "tokenTtl" } });
    console.log("App Check configured:", JSON.stringify(configured.body));
  } else if (config.status === 200) {
    console.log("App Check:", JSON.stringify(config.body));
  } else {
    console.log("App Check response:", JSON.stringify(config.body));
  }
  const services = await client.get("/projects/229293546081/services", { resolveOnHTTPError: true });
  console.log("Existing enforcement:", JSON.stringify(services.body));

  const auth = new Client({ urlPrefix: "https://identitytoolkit.googleapis.com", apiVersion: "v2" });
  const authConfig = await auth.get("/projects/equilibra-w5rl2h/config", { resolveOnHTTPError: true });
  console.log("Auth configuration:", JSON.stringify({ status: authConfig.status,
    emailEnabled: authConfig.body?.signIn?.email?.enabled,
    phoneEnabled: authConfig.body?.signIn?.phoneNumber?.enabled }));
  const keys = new Client({ urlPrefix: "https://apikeys.googleapis.com", apiVersion: "v2" });
  const keyInfo = await keys.get("/projects/229293546081/locations/global/keys/1beba193-4995-4c05-b7f0-e2b992238a6d",
    { resolveOnHTTPError: true });
  const androidRestrictions = keyInfo.body?.restrictions?.androidKeyRestrictions || null;
  console.log("Android API key restrictions:", JSON.stringify({ status: keyInfo.status, androidRestrictions }));

  // Public resource readiness is independent of a successful URL launch.
  const pages = {};
  for (const url of ["https://www.equilibra.com.pe/eliminar-cuenta/",
    "https://www.equilibra.com.pe/politica-de-privacidad-app/"]) {
    try {
      const response = await fetch(url, { signal: AbortSignal.timeout(20000) });
      const html = await response.text();
      pages[url] = { status: response.status, finalUrl: response.url,
        title: html.match(/<title[^>]*>([\s\S]*?)<\/title>/i)?.[1]?.trim(),
        bodyCharacters: html.length };
    } catch (error) { pages[url] = { error: error.message }; }
  }
  console.log("Public pages:", JSON.stringify(pages));
  fs.writeFileSync(path.join(__dirname, "../firebase-release-check.json"),
    JSON.stringify({ app, appCheckStatus: config.status, services: services.body,
      emailEnabled: authConfig.body?.signIn?.email?.enabled,
      androidKeyRestrictions: androidRestrictions, pages }, null, 2));
}
main().catch((error) => { console.error(error.message); process.exitCode = 1; });
