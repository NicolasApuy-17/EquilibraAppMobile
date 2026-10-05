const admin = require("firebase-admin");
const { FieldPath } = require("firebase-admin/firestore");
const { onSchedule } = require("firebase-functions/v2/scheduler");
const { notifyUser } = require("./notifications");

// Uses the existing in-app inbox. No device token or push permission required.
exports.sendDailyReminders = onSchedule(
  { schedule: "0 9 * * *", timeZone: "America/Lima", retryCount: 3 },
  async (event) => {
    const db = admin.firestore();
    const date = new Date(event.scheduleTime || Date.now()).toLocaleDateString("en-CA", {
      timeZone: "America/Lima",
    });
    let cursor;
    for (;;) {
      let query = db.collection("user_prefs").where("dailyReminderEnabled", "==", true)
        .orderBy(FieldPath.documentId()).limit(100);
      if (cursor) query = query.startAfter(cursor);
      const page = await query.get();
      if (page.empty) break;
      for (const pref of page.docs) {
        const [currentPref, user] = await Promise.all([
          pref.ref.get(), db.collection("users").doc(pref.id).get(),
        ]);
        if (!currentPref.data()?.dailyReminderEnabled || !user.exists ||
            user.data().role !== "paciente" || user.data().active === false) continue;
        await notifyUser(pref.id, {
          type: "daily_reminder", title: "¿Cómo te sientes hoy?",
          body: "Dedica un momento a registrar cómo te sientes.",
          notificationId: `daily-reminder:${date}:${pref.id}`,
          throwOnFailure: true,
        });
      }
      cursor = page.docs[page.docs.length - 1];
      if (page.size < 100) break;
    }
  }
);
