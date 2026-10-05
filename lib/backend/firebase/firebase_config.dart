import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future initFirebase() async {
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: "AIzaSyAUfZGO9v5LSuojyxw9z2RkOJJaUYHxpRQ",
            authDomain: "equilibra-w5rl2h.firebaseapp.com",
            projectId: "equilibra-w5rl2h",
            storageBucket: "equilibra-w5rl2h.firebasestorage.app",
            messagingSenderId: "229293546081",
            appId: "1:229293546081:web:3af89aeeb5ff560c62a820",
            measurementId: "G-4QWH9XZ6V8"));
  } else {
    await Firebase.initializeApp();
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      // Emotional and clinical records must not be persisted to an iOS disk
      // cache. This must run before any Firestore queries or listeners.
      FirebaseFirestore.instance.settings =
          const Settings(persistenceEnabled: false);
      await FirebaseAppCheck.instance.activate(
        appleProvider: kReleaseMode
            ? AppleProvider.appAttestWithDeviceCheckFallback
            : AppleProvider.debug,
      );
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      await FirebaseAppCheck.instance.activate(
        androidProvider: kReleaseMode
            ? AndroidProvider.playIntegrity
            : AndroidProvider.debug,
      );
    }
  }
}
