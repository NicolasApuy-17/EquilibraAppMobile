const { AsyncLocalStorage } = require("node:async_hooks");
const { onDocumentWritten: register } = require("firebase-functions/v2/firestore");
const eventContext = new AsyncLocalStorage();

function onDocumentWritten(options, handler) {
  // Preserve the region of the project's existing Firestore triggers.
  const triggerOptions = typeof options === "string"
    ? { document: options, region: "southamerica-east1" }
    : { region: "southamerica-east1", ...options };
  return register(triggerOptions, (event) => eventContext.run(event.id, () => handler(event)));
}

module.exports = { onDocumentWritten, eventContext };
