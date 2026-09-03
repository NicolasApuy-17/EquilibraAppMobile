import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/utils/date_format_es.dart';
import '/utils/error_messages.dart';
import '/utils/task_status.dart';
import '/services/psychologist_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'shared_widgets.dart';

class ActividadesTab extends StatefulWidget {
  const ActividadesTab({super.key, required this.patient});

  final UsersRecord patient;

  @override
  State<ActividadesTab> createState() => _ActividadesTabState();
}

class _ActividadesTabState extends State<ActividadesTab> {
  Future<void> _openAssignSheet() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _AssignActivitySheet(patient: widget.patient),
    );
  }

  @override
  Widget build(BuildContext context) {
    final patientRef = widget.patient.reference;
    final myRef = currentUserReference;

    return StreamBuilder<List<ActivityAssignmentsRecord>>(
      stream: queryActivityAssignmentsRecord(
        queryBuilder: (q) => q
            .where('patientRef', isEqualTo: patientRef)
            .where('psychologistRef', isEqualTo: myRef),
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 32.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final assignments = snapshot.data!
          ..sort((a, b) => (b.assignedTime ?? DateTime(2000))
              .compareTo(a.assignedTime ?? DateTime(2000)));

        return Stack(
          children: [
            ListView(
              padding: const EdgeInsetsDirectional.fromSTEB(
                  24.0, 12.0, 24.0, 96.0),
              children: [
                if (assignments.isEmpty)
                  const EmptyHint('Aún no le has asignado actividades.')
                else
                  ...assignments.map((a) => _AssignmentCard(assignment: a)),
              ],
            ),
            PositionedDirectional(
              bottom: 16.0,
              end: 0.0,
              child: FloatingActionButton.extended(
                backgroundColor: FlutterFlowTheme.of(context).primary,
                foregroundColor: FlutterFlowTheme.of(context).onPrimary,
                onPressed: _openAssignSheet,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Asignar actividad'),
              ),
            ),
          ],
        );
      },
    );
  }
}

String _assignmentStatusLabel(String status) {
  switch (status) {
    case 'abierta':
      return 'Abierta';
    case 'completada':
      return 'Completada';
    default:
      return 'Pendiente';
  }
}

Color _assignmentStatusColor(BuildContext context, String status) {
  switch (status) {
    case 'abierta':
      return FlutterFlowTheme.of(context).info;
    case 'completada':
      return FlutterFlowTheme.of(context).success;
    default:
      return FlutterFlowTheme.of(context).warning;
  }
}

class _AssignmentCard extends StatefulWidget {
  const _AssignmentCard({required this.assignment});

  final ActivityAssignmentsRecord assignment;

  @override
  State<_AssignmentCard> createState() => _AssignmentCardState();
}

class _AssignmentCardState extends State<_AssignmentCard> {
  bool _isSendingReminder = false;

  Future<void> _sendReminder() async {
    final assignment = widget.assignment;
    final patientRef = assignment.patientRef;
    if (patientRef == null) return;
    setState(() => _isSendingReminder = true);
    try {
      await PsychologistService().sendConversationMessage(
        conversationId: patientRef.id,
        text: 'Recuerda completar la actividad "${assignment.activityName}" '
            'que te recomendé.',
      );
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Recordatorio enviado por chat.')));
      }
    } on PsychologistServiceException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _isSendingReminder = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final assignment = widget.assignment;
    final theme = FlutterFlowTheme.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 10.0),
      child: Container(
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
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
                    assignment.activityName.isEmpty
                        ? 'Actividad'
                        : assignment.activityName,
                    style: theme.bodyMedium.override(
                      font: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                      color: theme.primaryText,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsetsDirectional.fromSTEB(8.0, 3.0, 8.0, 3.0),
                  decoration: BoxDecoration(
                    color: _assignmentStatusColor(context, assignment.status)
                        .withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Text(
                    _assignmentStatusLabel(assignment.status),
                    style: theme.labelSmall.override(
                      font: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                      color: _assignmentStatusColor(context, assignment.status),
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            if (assignment.instructions.isNotEmpty)
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0.0, 4.0, 0.0, 0.0),
                child: Text(
                  assignment.instructions,
                  style: theme.bodySmall.override(
                    font: GoogleFonts.outfit(),
                    color: theme.secondaryText,
                    letterSpacing: 0.0,
                  ),
                ),
              ),
            if (assignment.hasFrequency() && assignment.frequency.isNotEmpty)
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0.0, 4.0, 0.0, 0.0),
                child: Text(
                  'Frecuencia: ${taskFrequencyLabel(assignment.frequency)}',
                  style: theme.bodySmall.override(
                    font: GoogleFonts.outfit(),
                    color: theme.secondaryText,
                    letterSpacing: 0.0,
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(0.0, 6.0, 0.0, 0.0),
              child: Text(
                [
                  if (assignment.assignedTime != null)
                    'Asignada: ${formatDateEs(assignment.assignedTime!)}',
                  if (assignment.openedAt != null)
                    'Abierta: ${formatDateEs(assignment.openedAt!)}',
                  if (assignment.completedAt != null)
                    'Completada: ${formatDateEs(assignment.completedAt!)}',
                ].join(' · '),
                style: theme.bodySmall.override(
                  font: GoogleFonts.outfit(),
                  color: theme.secondaryText,
                  letterSpacing: 0.0,
                ),
              ),
            ),
            if (assignment.status != 'completada')
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: TextButton.icon(
                  onPressed: _isSendingReminder ? null : _sendReminder,
                  icon: _isSendingReminder
                      ? const SizedBox(
                          width: 14.0,
                          height: 14.0,
                          child: CircularProgressIndicator(strokeWidth: 2.0),
                        )
                      : const Icon(Icons.chat_bubble_outline_rounded, size: 16.0),
                  label: const Text('Recordar por chat'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AssignActivitySheet extends StatefulWidget {
  const _AssignActivitySheet({required this.patient});

  final UsersRecord patient;

  @override
  State<_AssignActivitySheet> createState() => _AssignActivitySheetState();
}

class _AssignActivitySheetState extends State<_AssignActivitySheet> {
  ActivitiesRecord? _selected;
  final _instructionsController = TextEditingController();
  String _frequency = 'una_vez';
  bool _isSaving = false;
  String? _errorText;

  @override
  void dispose() {
    _instructionsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_selected == null) {
      setState(() => _errorText = 'Elige una actividad de la lista.');
      return;
    }
    setState(() {
      _isSaving = true;
      _errorText = null;
    });
    try {
      await ActivityAssignmentsRecord.collection.doc().set(
            createActivityAssignmentsRecordData(
              patientRef: widget.patient.reference,
              psychologistRef: currentUserReference,
              activityRef: _selected!.reference,
              activityName: _selected!.name,
              routeName: _selected!.routeName,
              instructions: _instructionsController.text.trim(),
              frequency: _frequency,
              status: 'pendiente',
              assignedTime: DateTime.now(),
            ),
          );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(
            () => _errorText = genericSaveErrorMessage('asignar la actividad'));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).primaryBackground,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(28.0),
            topRight: Radius.circular(28.0),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Asignar actividad',
                style: FlutterFlowTheme.of(context).titleMedium.override(
                      font: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                      color: FlutterFlowTheme.of(context).primaryText,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12.0),
              Flexible(
                child: StreamBuilder<List<ActivitiesRecord>>(
                  stream: queryActivitiesRecord(
                    queryBuilder: (q) => q.where('active', isEqualTo: true),
                  ),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24.0),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    final activities = snapshot.data!;
                    if (activities.isEmpty) {
                      return const EmptyHint(
                          'El administrador aún no ha cargado actividades en el catálogo.');
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: activities.length,
                      itemBuilder: (context, index) {
                        final activity = activities[index];
                        final isSelected = _selected?.reference.id ==
                            activity.reference.id;
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(activity.name),
                          subtitle: Text(
                            [
                              if (activity.category.isNotEmpty)
                                activity.category,
                              activity.description,
                            ].where((s) => s.isNotEmpty).join(' · '),
                          ),
                          trailing: isSelected
                              ? Icon(Icons.check_circle_rounded,
                                  color: FlutterFlowTheme.of(context).primary)
                              : null,
                          onTap: () => setState(() => _selected = activity),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 8.0),
              LabeledField(
                label: 'Indicaciones (opcional)',
                controller: _instructionsController,
                maxLines: 2,
              ),
              Text(
                'Frecuencia',
                style: FlutterFlowTheme.of(context).labelMedium.override(
                      font: GoogleFonts.outfit(),
                      color: FlutterFlowTheme.of(context).primaryText,
                      letterSpacing: 0.0,
                    ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0.0, 4.0, 0.0, 12.0),
                child: ChoiceChipRow(
                  options: kTaskFrequencies,
                  labelBuilder: taskFrequencyLabel,
                  selected: _frequency,
                  onSelected: (v) => setState(() => _frequency = v),
                ),
              ),
              if (_errorText != null)
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 12.0),
                  child: Text(
                    _errorText!,
                    style: TextStyle(
                        color: FlutterFlowTheme.of(context).error,
                        fontSize: 12.0),
                  ),
                ),
              PrimaryButton(
                label: 'Enviar actividad',
                isLoading: _isSaving,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
