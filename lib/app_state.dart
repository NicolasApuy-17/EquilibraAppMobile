import 'package:flutter/material.dart';
import '/backend/backend.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'flutter_flow/flutter_flow_util.dart';

class FFAppState extends ChangeNotifier {
  static FFAppState _instance = FFAppState._internal();

  factory FFAppState() {
    return _instance;
  }

  FFAppState._internal();

  static void reset() {
    _instance = FFAppState._internal();
  }

  Future initializePersistedState() async {}

  void update(VoidCallback callback) {
    callback();
    notifyListeners();
  }

  String _userName = 'Valeria';
  String get userName => _userName;
  set userName(String value) {
    _userName = value;
  }

  int _recordsCount = 24;
  int get recordsCount => _recordsCount;
  set recordsCount(int value) {
    _recordsCount = value;
  }
}
