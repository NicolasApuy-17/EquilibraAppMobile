// v7 of firebase-functions dropped the v1 API from the top-level import;
// `onUserDeleted` below is a 1st-gen Auth trigger, which is only available
// via this explicit subpath (the v2 equivalent requires migrating the
// project to Identity Platform, which is out of scope here).
const functions = require("firebase-functions/v1");
const admin = require("firebase-admin");
admin.initializeApp();

exports.onUserDeleted = functions.auth.user().onDelete(async (user) => {
  let firestore = admin.firestore();
  await firestore.collection("users").doc(user.uid).delete();
});

const {
  createPsychologist,
  linkPsychologistByCode,
  adminAssignPsychologist,
  adminDiagnosePatientLink,
  setAccountActive,
  sendConversationMessage,
  onRecordActivity,
  onBehavioralRecordActivity,
  onTaskActivity,
} = require("./psychologists");
exports.createPsychologist = createPsychologist;
exports.linkPsychologistByCode = linkPsychologistByCode;
exports.adminAssignPsychologist = adminAssignPsychologist;
exports.adminDiagnosePatientLink = adminDiagnosePatientLink;
exports.setAccountActive = setAccountActive;
exports.sendConversationMessage = sendConversationMessage;
exports.onRecordActivity = onRecordActivity;
exports.onBehavioralRecordActivity = onBehavioralRecordActivity;
exports.onTaskActivity = onTaskActivity;
