import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

Future initFirebase() async {
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: FirebaseOptions(
            apiKey: "AIzaSyAUfZGO9v5LSuojyxw9z2RkOJJaUYHxpRQ",
            authDomain: "equilibra-w5rl2h.firebaseapp.com",
            projectId: "equilibra-w5rl2h",
            storageBucket: "equilibra-w5rl2h.firebasestorage.app",
            messagingSenderId: "229293546081",
            appId: "1:229293546081:web:3af89aeeb5ff560c62a820",
            measurementId: "G-4QWH9XZ6V8"));
  } else {
    await Firebase.initializeApp();
  }
}
