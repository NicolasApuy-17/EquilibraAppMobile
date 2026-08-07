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

String formatShortName(String? fullName) {
  if (fullName == null || fullName.trim().isEmpty) {
    return '';
  }

  final parts = fullName
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .toList();

  String capitalize(String text) {
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  final firstName = capitalize(parts.first);

  if (parts.length == 1) {
    return firstName;
  }

  final initial = parts[1][0].toUpperCase();
  return '$firstName $initial';
}
