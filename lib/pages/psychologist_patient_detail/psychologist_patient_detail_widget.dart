import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/utils/date_format_es.dart';
import '/utils/error_messages.dart';
import '/utils/validators.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Read-only follow-up view for one patient, reached from
/// `PsychologistHomeWidget`. Shows their emotional/behavioral records, goals
/// and tasks, and lets the assigned psychologist leave a short comment on a
/// given emotional/behavioral record — the only write this screen performs,
/// and Firestore rules only allow the assigned psychologist to touch those
/// two comment fields, nothing else on the patient's record.
class PsychologistPatientDetailWidget extends StatefulWidget {
  const PsychologistPatientDetailWidget({super.key, required this.patient});

  final UsersRecord patient;

  static String routeName = 'PsychologistPatientDetail';
  static String routePath = '/psychologistPatientDetail';

  @override
  State<PsychologistPatientDetailWidget> createState() =>
      _PsychologistPatientDetailWidgetState();
}

class _PsychologistPatientDetailWidgetState
    extends State<PsychologistPatientDetailWidget> {
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
          title: const Text('Comentario del psicólogo'),
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
                Text(
                  errorText!,
                  style: const TextStyle(color: Colors.red, fontSize: 12.0),
                ),
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
        SnackBar(content: Text(genericSaveErrorMessage('guardar el comentario'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final patientRef = widget.patient.reference;

    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  FlutterFlowIconButton(
                    borderRadius: 8.0,
                    buttonSize: 40.0,
                    fillColor: Colors.transparent,
                    icon: Icon(
                      Icons.arrow_back_rounded,
                      color: FlutterFlowTheme.of(context).primaryText,
                      size: 24.0,
                    ),
                    onPressed: () => context.safePop(),
                  ),
                  Expanded(
                    child: Text(
                      widget.patient.displayName.isEmpty
                          ? widget.patient.email
                          : widget.patient.displayName,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: FlutterFlowTheme.of(context).titleLarge.override(
                            font:
                                GoogleFonts.outfit(fontWeight: FontWeight.bold),
                            color: FlutterFlowTheme.of(context).primaryText,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  const SizedBox(width: 40.0),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsetsDirectional.fromSTEB(
                    24.0, 0.0, 24.0, 24.0),
                children: [
                  _sectionTitle(context, 'Registros emocionales'),
                  StreamBuilder<List<RecordsRecord>>(
                    stream: queryRecordsRecord(
                      queryBuilder: (q) =>
                          q.where('userRef', isEqualTo: patientRef),
                    ),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const _LoadingRow();
                      }
                      final records = snapshot.data!
                        ..sort((a, b) => (b.timestamp ?? DateTime(2000))
                            .compareTo(a.timestamp ?? DateTime(2000)));
                      if (records.isEmpty) {
                        return _emptyRow(context, 'Sin registros emocionales.');
                      }
                      return Column(
                        children: records
                            .map((record) => _EmotionalRecordCard(
                                  record: record,
                                  onEditComment: () => _editComment(
                                    currentComment: record.psychologistComment,
                                    onSave: (comment) =>
                                        record.reference.update(
                                      createRecordsRecordData(
                                        psychologistComment: comment,
                                        psychologistCommentTime:
                                            DateTime.now(),
                                      ),
                                    ),
                                  ),
                                ))
                            .toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 24.0),
                  _sectionTitle(context, 'Registros de conducta'),
                  StreamBuilder<List<BehavioralRecordsRecord>>(
                    stream: queryBehavioralRecordsRecord(
                      queryBuilder: (q) =>
                          q.where('userRef', isEqualTo: patientRef),
                    ),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const _LoadingRow();
                      }
                      final records = snapshot.data!
                        ..sort((a, b) => (b.createdAt ?? DateTime(2000))
                            .compareTo(a.createdAt ?? DateTime(2000)));
                      if (records.isEmpty) {
                        return _emptyRow(context, 'Sin registros de conducta.');
                      }
                      return Column(
                        children: records
                            .map((record) => _BehavioralRecordCard(
                                  record: record,
                                  onEditComment: () => _editComment(
                                    currentComment: record.psychologistComment,
                                    onSave: (comment) =>
                                        record.reference.update(
                                      createBehavioralRecordsRecordData(
                                        psychologistComment: comment,
                                        psychologistCommentTime:
                                            DateTime.now(),
                                      ),
                                    ),
                                  ),
                                ))
                            .toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 24.0),
                  _sectionTitle(context, 'Metas'),
                  StreamBuilder<List<GoalsRecord>>(
                    stream: queryGoalsRecord(
                      queryBuilder: (q) =>
                          q.where('userRef', isEqualTo: patientRef),
                    ),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const _LoadingRow();
                      final goals = snapshot.data!;
                      if (goals.isEmpty) {
                        return _emptyRow(context, 'Sin metas registradas.');
                      }
                      return Column(
                        children: goals
                            .map((goal) => _SimpleRow(
                                  title: goal.title,
                                  subtitle: goal.completed
                                      ? 'Cumplida'
                                      : 'Pendiente',
                                ))
                            .toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 24.0),
                  _sectionTitle(context, 'Tareas'),
                  StreamBuilder<List<TasksRecord>>(
                    stream: queryTasksRecord(
                      queryBuilder: (q) =>
                          q.where('userRef', isEqualTo: patientRef),
                    ),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const _LoadingRow();
                      final tasks = snapshot.data!;
                      if (tasks.isEmpty) {
                        return _emptyRow(context, 'Sin tareas registradas.');
                      }
                      return Column(
                        children: tasks
                            .map((task) => _SimpleRow(
                                  title: task.title,
                                  subtitle: task.status,
                                ))
                            .toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String text) => Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 8.0),
        child: Text(
          text,
          style: FlutterFlowTheme.of(context).titleSmall.override(
                font: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                color: FlutterFlowTheme.of(context).primaryText,
                letterSpacing: 0.0,
                fontWeight: FontWeight.bold,
              ),
        ),
      );

  Widget _emptyRow(BuildContext context, String text) => Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 8.0),
        child: Text(
          text,
          style: FlutterFlowTheme.of(context).bodySmall.override(
                font: GoogleFonts.outfit(),
                color: FlutterFlowTheme.of(context).secondaryText,
                letterSpacing: 0.0,
              ),
        ),
      );
}

class _LoadingRow extends StatelessWidget {
  const _LoadingRow();

  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 8.0),
        child: LinearProgressIndicator(),
      );
}

class _SimpleRow extends StatelessWidget {
  const _SimpleRow({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(14.0),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title.isEmpty ? 'Sin título' : title,
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.outfit(),
                      color: FlutterFlowTheme.of(context).primaryText,
                      letterSpacing: 0.0,
                    ),
              ),
            ),
            Text(
              subtitle,
              style: FlutterFlowTheme.of(context).bodySmall.override(
                    font: GoogleFonts.outfit(),
                    color: FlutterFlowTheme.of(context).secondaryText,
                    letterSpacing: 0.0,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmotionalRecordCard extends StatelessWidget {
  const _EmotionalRecordCard({
    required this.record,
    required this.onEditComment,
  });

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
  const _BehavioralRecordCard({
    required this.record,
    required this.onEditComment,
  });

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
