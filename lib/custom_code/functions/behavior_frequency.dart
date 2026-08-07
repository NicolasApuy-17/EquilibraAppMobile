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

/// Monitored-behavior counts, sorted from most to least frequent.
List<MapEntry<String, int>> behaviorFrequency(List<RecordsRecord> records) {
  final counts = <String, int>{};
  for (final r in records) {
    for (final behavior in r.behaviors) {
      counts[behavior] = (counts[behavior] ?? 0) + 1;
    }
  }
  final entries = counts.entries.toList();
  entries.sort((a, b) => b.value.compareTo(a.value));
  return entries;
}
