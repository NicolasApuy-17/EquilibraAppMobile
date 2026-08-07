import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_theme.dart';

/// Shared color/icon mapping for emotions and monitored behaviors, used
/// anywhere records are rendered (Progreso, Mis registros).
Color emotionColor(BuildContext context, String emotion) {
  switch (emotion) {
    case 'Alegría':
      return FlutterFlowTheme.of(context).success;
    case 'Tranquilo':
      return FlutterFlowTheme.of(context).primary;
    case 'Miedo':
      return FlutterFlowTheme.of(context).info;
    case 'Tristeza':
      return Color(0xFF64B5F6);
    case 'Enojo':
      return FlutterFlowTheme.of(context).error;
    case 'Vergüenza':
      return FlutterFlowTheme.of(context).warning;
    default:
      return FlutterFlowTheme.of(context).accent3;
  }
}

IconData behaviorIcon(String behavior) {
  switch (behavior) {
    case 'Sueño':
      return Icons.bed_rounded;
    case 'Alimentación':
      return Icons.restaurant_rounded;
    case 'Socialización':
      return Icons.group_rounded;
    case 'Ejercicio':
      return Icons.self_improvement_rounded;
    case 'Trabajo/Estudio':
      return Icons.work_rounded;
    default:
      return Icons.circle_rounded;
  }
}
