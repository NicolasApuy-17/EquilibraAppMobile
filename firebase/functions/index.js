// v7 of firebase-functions dropped the v1 API from the top-level import;
// `onUserDeleted` below is a 1st-gen Auth trigger, which is only available
// via this explicit subpath (the v2 equivalent requires migrating the
// project to Identity Platform, which is out of scope here).
const functions = require("firebase-functions/v1");
const admin = require("firebase-admin");
admin.initializeApp();

const { deleteAccountData } = require("./account_deletion");
exports.onUserDeleted = functions.runWith({ timeoutSeconds: 540, failurePolicy: true })
  .auth.user().onDelete((user) => deleteAccountData(user.uid));
exports.deleteMyAccount = require("./account_actions").deleteMyAccount;
exports.adminDeleteAccount = require("./account_actions").adminDeleteAccount;

const {
  createPsychologist,
  linkPsychologistByCode,
  adminAssignPsychologist,
  adminDiagnosePatientLink,
  adminBackfillPsychologistRefs,
  setAccountActive,
  setUserRole,
  sendConversationMessage,
  onRecordActivity,
  onBehavioralRecordActivity,
  onTaskActivity,
  onShareDataWithPsychologistChanged,
} = require("./psychologists");
exports.createPsychologist = createPsychologist;
exports.linkPsychologistByCode = linkPsychologistByCode;
exports.adminAssignPsychologist = adminAssignPsychologist;
exports.adminDiagnosePatientLink = adminDiagnosePatientLink;
exports.adminBackfillPsychologistRefs = adminBackfillPsychologistRefs;
exports.setAccountActive = setAccountActive;
exports.setUserRole = setUserRole;
exports.sendConversationMessage = sendConversationMessage;
exports.onRecordActivity = onRecordActivity;
exports.onBehavioralRecordActivity = onBehavioralRecordActivity;
exports.onTaskActivity = onTaskActivity;
exports.onShareDataWithPsychologistChanged = onShareDataWithPsychologistChanged;

const {
  onRecordNotification,
  onBehavioralRecordNotification,
  onTaskNotification,
  onActivityAssignmentNotification,
  onSessionRequestNotification,
  onAppErrorNotification,
} = require("./notifications");
exports.onRecordNotification = onRecordNotification;
exports.onBehavioralRecordNotification = onBehavioralRecordNotification;
exports.onTaskNotification = onTaskNotification;
exports.onActivityAssignmentNotification = onActivityAssignmentNotification;
exports.onSessionRequestNotification = onSessionRequestNotification;
exports.onAppErrorNotification = onAppErrorNotification;
exports.sendDailyReminders = require("./reminders").sendDailyReminders;
