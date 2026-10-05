import 'package:flutter/foundation.dart';

/// Development diagnostics must never be written to production device logs.
void developmentLog(String message) {
  if (kDebugMode) debugPrint(message);
}
