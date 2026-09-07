const admin = require("firebase-admin");
const { onDocumentWritten } = require("firebase-functions/v2/firestore");

// Kept short: the client truncates further if it wants, but a notification
// list row has limited room and Firestore has no reason to store a full
// 2000-character message/comment for something this transient.
const PREVIEW_LENGTH = 140;

function truncate(text) {
  if (!text) return "";
  const trimmed = `${text}`.trim();
  return trimmed.length > PREVIEW_LENGTH
    ? `${trimmed.slice(0, PREVIEW_LENGTH)}…`
    : trimmed;
}

/**
 * Writes one notification doc for `recipientUid`. Never throws -- every
 * caller of this is a side effect of some other write (a message, a
 * comment, a task update, ...) that must still succeed even if writing the
 * notification itself fails for some reason.
 */
async function notifyUser(recipientUid, { type, title, body, subjectRef = null, conversationId = null }) {
  if (!recipientUid) return;
  try {
    await admin.firestore().collection("notifications").add({
      recipientRef: admin.firestore().collection("users").doc(recipientUid),
      type,
      title,
      body: truncate(body),
      subjectRef,
      conversationId,
      read: false,
      createdTime: admin.firestore.FieldValue.serverTimestamp(),
    });
  } catch (error) {
    console.error(`[notifyUser] failed for ${recipientUid}:`, error);
  }
}

/**
 * Notifies every admin account -- for events an admin should know about
 * without having triggered them directly (a new self-service link, a
 * logged app error), as opposed to their own admin-panel actions.
 */
async function notifyAdmins({ type, title, body, subjectRef = null }) {
  try {
    const adminsSnap = await admin.firestore().collection("users").where("role", "==", "admin").get();
    await Promise.all(
      adminsSnap.docs.map((doc) => notifyUser(doc.id, { type, title, body, subjectRef }))
    );
  } catch (error) {
    console.error("[notifyAdmins] failed:", error);
  }
}

/** Best-effort display name lookup, for composing a notification body. */
async function displayNameFor(uid) {
  if (!uid) return "Alguien";
  try {
    const snap = await admin.firestore().collection("users").doc(uid).get();
    if (!snap.exists) return "Alguien";
    const data = snap.data();
    return data.display_name || data.email || "Alguien";
  } catch (error) {
    console.error(`[displayNameFor] failed for ${uid}:`, error);
    return "Alguien";
  }
}

/**
 * `records`/`behavioral_records`: a new one notifies the assigned
 * psychologist (if any); a new/changed `psychologistComment` on an
 * existing one notifies the patient. Fired by an `onDocumentWritten`
 * trigger separate from `onRecordActivity`/`onBehavioralRecordActivity` in
 * psychologists.js, which only maintains `lastActivityAt` -- kept apart so
 * a bug in one never risks the other's already-working behavior.
 */
function recordNotificationTrigger(documentPath, { createdTitle, createdNoun }) {
  return onDocumentWritten(documentPath, async (event) => {
    const before = event.data?.before?.exists ? event.data.before.data() : null;
    const after = event.data?.after?.exists ? event.data.after.data() : null;
    if (!after) return null;

    if (!before) {
      if (!after.psychologistRef || !after.userRef) return null;
      const patientName = await displayNameFor(after.userRef.id);
      return notifyUser(after.psychologistRef.id, {
        type: createdTitle,
        title: "Nuevo registro",
        body: `${patientName} agregó un nuevo ${createdNoun}.`,
        subjectRef: after.userRef,
      });
    }

    if (after.psychologistComment && before.psychologistComment !== after.psychologistComment) {
      if (!after.userRef) return null;
      return notifyUser(after.userRef.id, {
        type: "psychologist_comment",
        title: "Nueva observación de tu psicólogo",
        body: after.psychologistComment,
      });
    }
    return null;
  });
}

exports.onRecordNotification = recordNotificationTrigger("records/{recordId}", {
  createdTitle: "record_created",
  createdNoun: "registro emocional",
});
exports.onBehavioralRecordNotification = recordNotificationTrigger(
  "behavioral_records/{recordId}",
  { createdTitle: "behavioral_record_created", createdNoun: "registro de conducta" }
);

/**
 * `tasks`: a psychologist-assigned task notifies the patient when created,
 * and again when the psychologist leaves feedback; the psychologist is
 * notified when the patient completes it. A self-created task (patient's
 * own to-do, no psychologist involved) never notifies anyone -- there's no
 * one else to tell.
 */
exports.onTaskNotification = onDocumentWritten("tasks/{taskId}", async (event) => {
  const before = event.data?.before?.exists ? event.data.before.data() : null;
  const after = event.data?.after?.exists ? event.data.after.data() : null;
  if (!after || !after.userRef) return null;

  const isAssignedByPsychologist =
    after.createdByRef && after.createdByRef.path !== after.userRef.path;

  if (!before) {
    if (!isAssignedByPsychologist) return null;
    return notifyUser(after.userRef.id, {
      type: "task_assigned",
      title: "Nueva tarea asignada",
      body: after.title
        ? `Tu psicólogo te asignó: "${after.title}"`
        : "Tu psicólogo te asignó una nueva tarea.",
    });
  }

  if (after.feedback && before.feedback !== after.feedback) {
    return notifyUser(after.userRef.id, {
      type: "task_feedback",
      title: "Tu psicólogo comentó tu tarea",
      body: after.feedback,
    });
  }

  if (
    isAssignedByPsychologist &&
    after.status === "completada" &&
    before.status !== after.status
  ) {
    const recipientUid = (after.psychologistRef || after.createdByRef).id;
    const patientName = await displayNameFor(after.userRef.id);
    return notifyUser(recipientUid, {
      type: "task_completed",
      title: "Tarea completada",
      body: `${patientName} completó la tarea "${after.title || ""}".`,
      subjectRef: after.userRef,
    });
  }
  return null;
});

/**
 * `activity_assignments`: mirrors the `tasks` pattern above. No prior
 * trigger existed on this collection (only `lastActivityAt` triggers exist
 * for `records`/`behavioral_records`/`tasks`), so this is the first one.
 */
exports.onActivityAssignmentNotification = onDocumentWritten(
  "activity_assignments/{assignmentId}",
  async (event) => {
    const before = event.data?.before?.exists ? event.data.before.data() : null;
    const after = event.data?.after?.exists ? event.data.after.data() : null;
    if (!after || !after.patientRef) return null;

    if (!before) {
      return notifyUser(after.patientRef.id, {
        type: "activity_assigned",
        title: "Nueva actividad asignada",
        body: after.activityName
          ? `Tu psicólogo te asignó: "${after.activityName}"`
          : "Tu psicólogo te asignó una nueva actividad.",
      });
    }

    if (
      after.psychologistRef &&
      after.status === "completada" &&
      before.status !== after.status
    ) {
      const patientName = await displayNameFor(after.patientRef.id);
      return notifyUser(after.psychologistRef.id, {
        type: "activity_completed",
        title: "Actividad completada",
        body: `${patientName} completó "${after.activityName || "una actividad"}".`,
        subjectRef: after.patientRef,
      });
    }
    return null;
  }
);

/** Notifies every admin the first time an `app_errors` doc is created. */
exports.onAppErrorNotification = onDocumentWritten("app_errors/{errorId}", async (event) => {
  if (event.data?.before?.exists || !event.data?.after?.exists) return null;
  const data = event.data.after.data();
  return notifyAdmins({
    type: "app_error",
    title: "Nuevo error registrado",
    body: data.context ? `${data.context}: ${data.message || ""}` : data.message || "",
  });
});

module.exports.notifyUser = notifyUser;
module.exports.notifyAdmins = notifyAdmins;
module.exports.displayNameFor = displayNameFor;
