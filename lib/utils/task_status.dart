import 'package:flutter/material.dart';
import '/flutter_flow/flutter_flow_theme.dart';

/// Shared across the patient's own Tareas screen and the psychologist's
/// Tareas tab so both sides always agree on the same four states.
const kTaskStatuses = ['pendiente', 'en_proceso', 'completada', 'no_realizada'];

String taskStatusLabel(String status) {
  switch (status) {
    case 'en_proceso':
      return 'En proceso';
    case 'completada':
      return 'Completada';
    case 'no_realizada':
      return 'No realizada';
    default:
      return 'Pendiente';
  }
}

Color taskStatusColor(BuildContext context, String status) {
  switch (status) {
    case 'en_proceso':
      return FlutterFlowTheme.of(context).info;
    case 'completada':
      return FlutterFlowTheme.of(context).success;
    case 'no_realizada':
      return FlutterFlowTheme.of(context).error;
    default:
      return FlutterFlowTheme.of(context).warning;
  }
}

const kTaskFrequencies = ['una_vez', 'diaria', 'varias_veces_semana'];

String taskFrequencyLabel(String frequency) {
  switch (frequency) {
    case 'diaria':
      return 'Diaria';
    case 'varias_veces_semana':
      return 'Varias veces por semana';
    default:
      return 'Una vez';
  }
}

const kTaskResponseTypes = ['completado', 'texto', 'escala', 'registro'];

String taskResponseTypeLabel(String responseType) {
  switch (responseType) {
    case 'texto':
      return 'Respuesta de texto';
    case 'escala':
      return 'Escala 1-10';
    case 'registro':
      return 'Registro en la app';
    default:
      return 'Completado / no completado';
  }
}
