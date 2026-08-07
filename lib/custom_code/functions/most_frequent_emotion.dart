import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import '/flutter_flow/custom_functions.dart';
import '/flutter_flow/lat_lng.dart';
import '/flutter_flow/place.dart';
import '/flutter_flow/uploaded_file.dart';
import '/backend/backend.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/auth/firebase_auth/auth_util.dart';

String mostFrequentEmotion(List<RecordsRecord> records) {
  if (records.isEmpty) return "Ninguna";
  final counts = <String, int>{};
  for (final r in records) {
    counts[r.emotion] = (counts[r.emotion] ?? 0) + 1;
  }
  String topEmotion = "";
  int maxCount = -1;
  for (final entry in counts.entries) {
    if (entry.value > maxCount) {
      maxCount = entry.value;
      topEmotion = entry.key;
    }
  }
  return topEmotion;
}
