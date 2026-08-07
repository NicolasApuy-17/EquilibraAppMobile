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

String getInitials(String? fullName) {
  if (fullName == null || fullName.trim().isEmpty) {
    return '?';
  }

  final parts = fullName
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .toList();

  final firstInitial = parts.first[0].toUpperCase();

  if (parts.length == 1) {
    return firstInitial;
  }

  final lastInitial = parts.last[0].toUpperCase();

  return '$firstInitial$lastInitial';
}
