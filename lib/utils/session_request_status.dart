import 'package:flutter/material.dart';
import '/flutter_flow/flutter_flow_theme.dart';

/// Shared across the patient's "Programar sesión" screen and the
/// psychologist's "Sesiones" tab, so both sides always agree on the same
/// states for a `SessionRequestsRecord`.
const kSessionRequestStatuses = ['pendiente', 'confirmada', 'rechazada', 'cancelada'];

String sessionRequestStatusLabel(String status) {
  switch (status) {
    case 'confirmada':
      return 'Confirmada';
    case 'rechazada':
      return 'No confirmada';
    case 'cancelada':
      return 'Cancelada';
    default:
      return 'Pendiente';
  }
}

Color sessionRequestStatusColor(BuildContext context, String status) {
  switch (status) {
    case 'confirmada':
      return FlutterFlowTheme.of(context).success;
    case 'rechazada':
      return FlutterFlowTheme.of(context).error;
    case 'cancelada':
      return FlutterFlowTheme.of(context).secondaryText;
    default:
      return FlutterFlowTheme.of(context).warning;
  }
}
