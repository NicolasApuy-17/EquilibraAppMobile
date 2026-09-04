import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/utils/date_format_es.dart';
import '/utils/error_messages.dart';
import '/utils/validators.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'shared_widgets.dart';

/// Emotional + behavioral records for this patient, filterable by date.
/// Emotional and behavioral records stay in their own sections throughout
/// -- they're independent observations, never merged into one feed (see
/// the note on `BehavioralRecordsRecord`).
class RegistrosTab extends StatefulWidget {
  const RegistrosTab({super.key, required this.patient});

  final UsersRecord patient;

  @override
  State<RegistrosTab> createState() => _RegistrosTabState();
}

class _RegistrosTabState extends State<RegistrosTab> {
  DateTimeRange? _range;

  Future<void> _pickRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 3),
      lastDate: now,
      initialDateRange: _range,
    );
    if (picked != null) setState(() => _range = picked);
  }

  bool _inRange(DateTime? date) {
    if (_range == null || date == null) return true;
    final day = DateTime(date.year, date.month, date.day);
    final start = DateTime(_range!.start.year, _range!.start.month, _range!.start.day);
    final end = DateTime(_range!.end.year, _range!.end.month, _range!.end.day);
    return !day.isBefore(start) && !day.isAfter(end);
  }

  Future<void> _editComment({
    required String? currentComment,
    required Future<void> Function(String comment) onSave,
  }) async {
    final controller = TextEditingController(text: currentComment ?? '');
    String? errorText;
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: const Text('Observación privada'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: controller,
                autofocus: true,
                minLines: 3,
                maxLines: 6,
                maxLength: 1000,
                decoration: const InputDecoration(
                  hintText: 'Escribe una observación breve...',
                ),
                onChanged: (_) {
                  if (errorText != null) setDialogState(() => errorText = null);
                },
              ),
              if (errorText != null)
                Text(errorText!,
                    style: const TextStyle(color: Colors.red, fontSize: 12.0)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                final error = validateDescription(controller.text,
                    maxLength: 1000, required: true);
                if (error != null) {
                  setDialogState(() => errorText = error);
                  return;
                }
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
    if (result != true || !mounted) return;
    try {
      await onSave(controller.text.trim());
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(genericSaveErrorMessage('guardar la observación'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final patientRef = widget.patient.reference;

    return ListView(
      padding: const EdgeInsetsDirectional.fromSTEB(24.0, 12.0, 24.0, 24.0),
      children: [
        InkWell(
          onTap: _pickRange,
          borderRadius: BorderRadius.circular(12.0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).secondaryBackground,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Row(
              children: [
                Icon(Icons.filter_alt_rounded,
                    size: 18.0, color: FlutterFlowTheme.of(context).secondaryText),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Text(
                    _range == null
                        ? 'Filtrar por fecha'
                        : '${formatDateEs(_range!.start)} – ${formatDateEs(_range!.end)}',
                  ),
                ),
                if (_range != null)
                  InkWell(
                    onTap: () => setState(() => _range = null),
                    child: const Icon(Icons.close_rounded, size: 18.0),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16.0),
        SectionTitle('Registros emocionales'),
        StreamBuilder<List<RecordsRecord>>(
          stream: queryRecordsRecord(
            queryBuilder: (q) => q.where('userRef', isEqualTo: patientRef),
          ),
          builder: (context, snapshot) => asyncSection(
            snapshot,
            errorText: 'No se pudieron cargar los registros emocionales.',
            (data) {
              final records = data.where((r) => _inRange(r.timestamp)).toList()
                ..sort((a, b) => (b.timestamp ?? DateTime(2000))
                    .compareTo(a.timestamp ?? DateTime(2000)));
              if (records.isEmpty) {
                return const EmptyHint('Sin registros emocionales en este rango.',
                    icon: Icons.mood_outlined);
              }
              return Column(
                children: records
                    .map((record) => _EmotionalRecordCard(
                          record: record,
                          onEditComment: () => _editComment(
                            currentComment: record.psychologistComment,
                            onSave: (comment) => record.reference.update(
                              createRecordsRecordData(
                                psychologistComment: comment,
                                psychologistCommentTime: DateTime.now(),
                              ),
                            ),
                          ),
                        ))
                    .toList(),
              );
            },
          ),
        ),
        const SizedBox(height: 24.0),
        SectionTitle('Registros de conducta'),
        StreamBuilder<List<BehavioralRecordsRecord>>(
          stream: queryBehavioralRecordsRecord(
            queryBuilder: (q) => q.where('userRef', isEqualTo: patientRef),
          ),
          builder: (context, snapshot) => asyncSection(
            snapshot,
            errorText: 'No se pudieron cargar los registros de conducta.',
            (data) {
              final records = data.where((r) => _inRange(r.createdAt)).toList()
                ..sort((a, b) => (b.createdAt ?? DateTime(2000))
                    .compareTo(a.createdAt ?? DateTime(2000)));
              if (records.isEmpty) {
                return const EmptyHint('Sin registros de conducta en este rango.',
                    icon: Icons.checklist_outlined);
              }
              return Column(
                children: records
                    .map((record) => _BehavioralRecordCard(
                          record: record,
                          onEditComment: () => _editComment(
                            currentComment: record.psychologistComment,
                            onSave: (comment) => record.reference.update(
                              createBehavioralRecordsRecordData(
                                psychologistComment: comment,
                                psychologistCommentTime: DateTime.now(),
                              ),
                            ),
                          ),
                        ))
                    .toList(),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _EmotionalRecordCard extends StatelessWidget {
  const _EmotionalRecordCard({required this.record, required this.onEditComment});

  final RecordsRecord record;
  final VoidCallback onEditComment;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(14.0),
        ),
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${record.emotion} · ${record.intensity.round()}/10',
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          font: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                          color: FlutterFlowTheme.of(context).primaryText,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                if (record.timestamp != null)
                  Text(
                    formatDateEs(record.timestamp!),
                    style: FlutterFlowTheme.of(context).bodySmall.override(
                          font: GoogleFonts.outfit(),
                          color: FlutterFlowTheme.of(context).secondaryText,
                          letterSpacing: 0.0,
                        ),
                  ),
              ],
            ),
            if (record.description.isNotEmpty)
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0.0, 4.0, 0.0, 0.0),
                child: Text(
                  record.description,
                  style: FlutterFlowTheme.of(context).bodySmall.override(
                        font: GoogleFonts.outfit(),
                        color: FlutterFlowTheme.of(context).secondaryText,
                        letterSpacing: 0.0,
                      ),
                ),
              ),
            if (record.hasPsychologistComment())
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 0.0),
                child: Text(
                  'Tu comentario: ${record.psychologistComment}',
                  style: FlutterFlowTheme.of(context).bodySmall.override(
                        font: GoogleFonts.outfit(fontStyle: FontStyle.italic),
                        color: FlutterFlowTheme.of(context).primary,
                        letterSpacing: 0.0,
                        fontStyle: FontStyle.italic,
                      ),
                ),
              ),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton(
                onPressed: onEditComment,
                child: Text(record.hasPsychologistComment()
                    ? 'Editar comentario'
                    : 'Dejar comentario'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BehavioralRecordCard extends StatelessWidget {
  const _BehavioralRecordCard({required this.record, required this.onEditComment});

  final BehavioralRecordsRecord record;
  final VoidCallback onEditComment;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(14.0),
        ),
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${record.behaviorType} · ${record.value}',
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          font: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                          color: FlutterFlowTheme.of(context).primaryText,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                if (record.createdAt != null)
                  Text(
                    formatDateEs(record.createdAt!),
                    style: FlutterFlowTheme.of(context).bodySmall.override(
                          font: GoogleFonts.outfit(),
                          color: FlutterFlowTheme.of(context).secondaryText,
                          letterSpacing: 0.0,
                        ),
                  ),
              ],
            ),
            if (record.notes.isNotEmpty)
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0.0, 4.0, 0.0, 0.0),
                child: Text(
                  record.notes,
                  style: FlutterFlowTheme.of(context).bodySmall.override(
                        font: GoogleFonts.outfit(),
                        color: FlutterFlowTheme.of(context).secondaryText,
                        letterSpacing: 0.0,
                      ),
                ),
              ),
            if (record.hasPsychologistComment())
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 0.0),
                child: Text(
                  'Tu comentario: ${record.psychologistComment}',
                  style: FlutterFlowTheme.of(context).bodySmall.override(
                        font: GoogleFonts.outfit(fontStyle: FontStyle.italic),
                        color: FlutterFlowTheme.of(context).primary,
                        letterSpacing: 0.0,
                        fontStyle: FontStyle.italic,
                      ),
                ),
              ),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton(
                onPressed: onEditComment,
                child: Text(record.hasPsychologistComment()
                    ? 'Editar comentario'
                    : 'Dejar comentario'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
