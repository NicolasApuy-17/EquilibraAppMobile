const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.onUserDeleted = functions.auth.user().onDelete(async (user) => {
  let firestore = admin.firestore();
  await firestore.collection("users").doc(user.uid).delete();
});

const { chatWithGemini } = require("./chatbot");
exports.chatWithGemini = chatWithGemini;
