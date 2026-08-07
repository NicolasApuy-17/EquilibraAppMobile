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

/// Average intensity per weekday, index 0 = Monday .. index 6 = Sunday.
/// A null entry means there were no records that day.
List<double?> averageIntensityPerWeekday(List<RecordsRecord> records) {
  final sums = List<double>.filled(7, 0.0);
  final counts = List<int>.filled(7, 0);
  for (final r in records) {
    final ts = r.timestamp;
    if (ts == null) continue;
    final idx = ts.weekday - 1;
    sums[idx] += r.intensity;
    counts[idx]++;
  }
  return List<double?>.generate(
      7, (i) => counts[i] == 0 ? null : sums[i] / counts[i]);
}
