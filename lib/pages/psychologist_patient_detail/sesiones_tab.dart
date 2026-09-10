import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/utils/date_format_es.dart';
import '/utils/error_logging.dart';
import '/utils/error_messages.dart';
import '/utils/session_request_status.dart';
import '/utils/validators.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'shared_widgets.dart';

/// Chronological, 100% private log of clinical sessions with this patient.
/// Only the assigned psychologist can ever read this tab's data (enforced
/// by firestore.rules, not just hidden in the UI) -- the patient never sees
/// any of it.
class SesionesTab extends StatefulWidget {
  const SesionesTab({super.key, required this.patient});

  final UsersRecord patient;

  @override
  State<SesionesTab> createState() => _SesionesTabState();
}

class _SesionesTabState extends State<SesionesTab> {
  Future<void> _respondToRequest(
    SessionRequestsRecord request, {
    required bool confirm,
  }) async {
    final noteController = TextEditingController();
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text(confirm ? 'Confirmar sesión' : 'No confirmar sesión'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(confirm
                    ? '¿Confirmas la sesión del ${formatDateEs(request.requestedDate ?? DateTime.now())} '
                        'a las ${formatTime24(request.requestedDate ?? DateTime.now())}?'
                    : '¿Deseas indicar a tu consultante que esta fecha no funciona?'),
                const SizedBox(height: 12.0),
                TextField(
                  controller: noteController,
                  minLines: 2,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: confirm
                        ? 'Nota opcional para tu consultante...'
                        : 'Explica brevemente por qué (opcional)...',
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Volver'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: Text(confirm ? 'Confirmar' : 'No confirmar'),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed || !mounted) return;
    try {
      await request.reference.update({
        'status': confirm ? 'confirmada' : 'rechazada',
        'respondedAt': DateTime.now(),
        'psychologistNote': noteController.text.trim(),
      });
    } catch (e, stackTrace) {
      logAppError(
        context: 'SesionesTab._respondToRequest',
        error: e,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(genericSaveErrorMessage('responder la solicitud'))),
      );
    }
  }

  Future<void> _openSessionForm({
    SessionsRecord? existing,
    required int nextSessionNumber,
  }) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _SessionFormSheet(
        patient: widget.patient,
        existing: existing,
        sessionNumber: existing?.sessionNumber ?? nextSessionNumber,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final patientRef = widget.patient.reference;
    final myRef = currentUserReference;

    return StreamBuilder<List<SessionsRecord>>(
      stream: querySessionsRecord(
        queryBuilder: (q) => q
            .where('patientRef', isEqualTo: patientRef)
            .where('psychologistRef', isEqualTo: myRef),
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Padding(
            padding: EdgeInsets.all(24.0),
            child: AsyncErrorHint(text: 'No se pudieron cargar las sesiones.'),
          );
        }
        if (!snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 32.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final sessions = snapshot.data!
          ..sort((a, b) => (b.sessionDate ?? DateTime(2000))
              .compareTo(a.sessionDate ?? DateTime(2000)));
        final nextSessionNumber = sessions.isEmpty
            ? 1
            : sessions
                    .map((s) => s.sessionNumber)
                    .fold<int>(0, (a, b) => a > b ? a : b) +
                1;

        return Stack(
          children: [
            ListView(
              padding: const EdgeInsetsDirectional.fromSTEB(
                  24.0, 12.0, 24.0, 96.0),
              children: [
                // Scheduling requests the patient sent from their own
                // "Programar sesión" screen -- separate from the private
                // clinical session log below, which only exists for
                // sessions that already happened.
                StreamBuilder<List<SessionRequestsRecord>>(
                  stream: querySessionRequestsRecord(
                    queryBuilder: (q) => q
                        .where('patientRef', isEqualTo: patientRef)
                        .where('psychologistRef', isEqualTo: myRef),
                  ).handleError((error, stackTrace) {
                    logAppError(
                      context: 'SesionesTab.requests',
                      error: error,
                      stackTrace: stackTrace,
                    );
                    throw error;
                  }),
                  builder: (context, requestsSnap) => asyncSection(
                    requestsSnap,
                    errorText: 'No se pudieron cargar las solicitudes de sesión.',
                    (requests) {
                      if (requests.isEmpty) return const SizedBox.shrink();
                      final sorted = [...requests]
                        ..sort((a, b) => (b.createdTime ?? DateTime(2000))
                            .compareTo(a.createdTime ?? DateTime(2000)));
                      return Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            0.0, 0.0, 0.0, 20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SectionTitle('Solicitudes de sesión'),
                            ...sorted.map((request) => _SessionRequestCard(
                                  request: request,
                                  onConfirm: request.status == 'pendiente'
                                      ? () => _respondToRequest(request,
                                          confirm: true)
                                      : null,
                                  onDecline: request.status == 'pendiente'
                                      ? () => _respondToRequest(request,
                                          confirm: false)
                                      : null,
                                )),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                if (sessions.isEmpty)
                  const EmptyHint('Aún no hay sesiones registradas.',
                      icon: Icons.event_note_outlined)
                else
                  ...sessions.map((session) => _SessionCard(
                        session: session,
                        onTap: () => _openSessionForm(
                          existing: session,
                          nextSessionNumber: nextSessionNumber,
                        ),
                      )),
              ],
            ),
            PositionedDirectional(
              bottom: 16.0,
              end: 0.0,
              child: FloatingActionButton.extended(
                backgroundColor: FlutterFlowTheme.of(context).primary,
                foregroundColor: FlutterFlowTheme.of(context).onPrimary,
                onPressed: () =>
                    _openSessionForm(nextSessionNumber: nextSessionNumber),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Nueva sesión'),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SessionRequestCard extends StatelessWidget {
  const _SessionRequestCard({
    required this.request,
    this.onConfirm,
    this.onDecline,
  });

  final SessionRequestsRecord request;
  final VoidCallback? onConfirm;
  final VoidCallback? onDecline;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 10.0),
      child: Container(
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
          borderRadius: BorderRadius.circular(18.0),
          border: Border.all(
              color: sessionRequestStatusColor(context, request.status)
                  .withValues(alpha: 0.4)),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    request.requestedDate != null
                        ? '${formatDateEs(request.requestedDate!)} · ${formatTime24(request.requestedDate!)}'
                        : 'Fecha no especificada',
                    style: theme.titleSmall.override(
                      font: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                      color: theme.primaryText,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsetsDirectional.fromSTEB(8.0, 3.0, 8.0, 3.0),
                  decoration: BoxDecoration(
                    color: sessionRequestStatusColor(context, request.status)
                        .withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Text(
                    sessionRequestStatusLabel(request.status),
                    style: theme.labelSmall.override(
                      font: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                      color: sessionRequestStatusColor(context, request.status),
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            if (request.note.isNotEmpty)
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0.0, 6.0, 0.0, 0.0),
                child: Text(
                  request.note,
                  style: theme.bodyMedium.override(
                    font: GoogleFonts.outfit(),
                    color: theme.secondaryText,
                    letterSpacing: 0.0,
                  ),
                ),
              ),
            if (onConfirm != null || onDecline != null)
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 0.0),
                child: Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: Wrap(
                    children: [
                      if (onDecline != null)
                        TextButton(
                          onPressed: onDecline,
                          child: const Text('No confirmar'),
                        ),
                      if (onConfirm != null)
                        TextButton(
                          onPressed: onConfirm,
                          child: const Text('Confirmar'),
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  const _SessionCard({required this.session, required this.onTap});

  final SessionsRecord session;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 12.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18.0),
        child: Container(
          decoration: BoxDecoration(
            color: theme.secondaryBackground,
            borderRadius: BorderRadius.circular(18.0),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sesión N.º ${session.sessionNumber}'
                '${session.sessionDate != null ? ' – ${formatDateEs(session.sessionDate!)}' : ''}',
                style: theme.titleSmall.override(
                  font: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                  color: theme.primaryText,
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (session.topic.isNotEmpty)
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0.0, 4.0, 0.0, 0.0),
                  child: Text(
                    session.topic,
                    style: theme.bodyMedium.override(
                      font: GoogleFonts.outfit(),
                      color: theme.secondaryText,
                      letterSpacing: 0.0,
                    ),
                  ),
                ),
              if (session.nextSessionDate != null)
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 0.0),
                  child: Text(
                    'Próxima sesión: ${formatDateEs(session.nextSessionDate!)}',
                    style: theme.bodySmall.override(
                      font: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                      color: theme.primary,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SessionFormSheet extends StatefulWidget {
  const _SessionFormSheet({
    required this.patient,
    required this.sessionNumber,
    this.existing,
  });

  final UsersRecord patient;
  final int sessionNumber;
  final SessionsRecord? existing;

  @override
  State<_SessionFormSheet> createState() => _SessionFormSheetState();
}

class _SessionFormSheetState extends State<_SessionFormSheet> {
  late TextEditingController _topicController;
  late TextEditingController _summaryController;
  late TextEditingController _objectivesController;
  late TextEditingController _techniqueController;
  late TextEditingController _clinicalNotesController;
  late TextEditingController _agreementsController;
  late TextEditingController _homeworkController;
  late TextEditingController _nextObjectivesController;
  late DateTime _sessionDate;
  DateTime? _nextSessionDate;
  bool _isSaving = false;
  String? _errorText;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _topicController = TextEditingController(text: e?.topic ?? '');
    _summaryController = TextEditingController(text: e?.summary ?? '');
    _objectivesController = TextEditingController(text: e?.objectives ?? '');
    _techniqueController = TextEditingController(text: e?.technique ?? '');
    _clinicalNotesController =
        TextEditingController(text: e?.clinicalNotes ?? '');
    _agreementsController = TextEditingController(text: e?.agreements ?? '');
    _homeworkController = TextEditingController(text: e?.homework ?? '');
    _nextObjectivesController =
        TextEditingController(text: e?.nextSessionObjectives ?? '');
    _sessionDate = e?.sessionDate ?? DateTime.now();
    _nextSessionDate = e?.nextSessionDate;
  }

  @override
  void dispose() {
    _topicController.dispose();
    _summaryController.dispose();
    _objectivesController.dispose();
    _techniqueController.dispose();
    _clinicalNotesController.dispose();
    _agreementsController.dispose();
    _homeworkController.dispose();
    _nextObjectivesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isNextSession}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isNextSession
          ? (_nextSessionDate ?? DateTime.now())
          : _sessionDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(DateTime.now().year + 5),
    );
    if (picked == null) return;
    setState(() {
      if (isNextSession) {
        _nextSessionDate = picked;
      } else {
        _sessionDate = picked;
      }
    });
  }

  Future<void> _submit() async {
    final topicError = validateFreeText(
      _topicController.text,
      maxLength: 120,
      required: true,
      requiredMessage: 'Ingresa el tema trabajado.',
    );
    if (topicError != null) {
      setState(() => _errorText = topicError);
      return;
    }
    setState(() {
      _isSaving = true;
      _errorText = null;
    });
    try {
      final data = createSessionsRecordData(
        patientRef: widget.patient.reference,
        psychologistRef: currentUserReference,
        sessionNumber: widget.sessionNumber,
        sessionDate: _sessionDate,
        topic: normalizeWhitespace(_topicController.text),
        summary: _summaryController.text.trim(),
        objectives: _objectivesController.text.trim(),
        technique: _techniqueController.text.trim(),
        clinicalNotes: _clinicalNotesController.text.trim(),
        agreements: _agreementsController.text.trim(),
        homework: _homeworkController.text.trim(),
        nextSessionObjectives: _nextObjectivesController.text.trim(),
        nextSessionDate: _nextSessionDate,
        updatedTime: DateTime.now(),
      );
      if (_isEditing) {
        await widget.existing!.reference.update(data);
      } else {
        await SessionsRecord.collection.doc().set({
          ...data,
          'createdTime': DateTime.now(),
        });
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(() => _errorText = genericSaveErrorMessage('guardar la sesión'));
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
          maxHeight: MediaQuery.of(context).size.height * 0.9,
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
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  _isEditing
                      ? 'Sesión N.º ${widget.sessionNumber}'
                      : 'Nueva sesión N.º ${widget.sessionNumber}',
                  style: FlutterFlowTheme.of(context).titleMedium.override(
                        font: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                        color: FlutterFlowTheme.of(context).primaryText,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  'Esta información es privada: tu consultante nunca la ve.',
                  style: FlutterFlowTheme.of(context).bodySmall.override(
                        font: GoogleFonts.outfit(fontStyle: FontStyle.italic),
                        color: FlutterFlowTheme.of(context).secondaryText,
                        letterSpacing: 0.0,
                        fontStyle: FontStyle.italic,
                      ),
                ),
                const SizedBox(height: 16.0),
                InkWell(
                  onTap: () => _pickDate(isNextSession: false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12.0, vertical: 12.0),
                    margin: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 12.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(
                          color: FlutterFlowTheme.of(context).alternate),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today_rounded,
                            size: 18.0,
                            color: FlutterFlowTheme.of(context).secondaryText),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: Text(
                              'Fecha de la sesión: ${formatDateEs(_sessionDate)}'),
                        ),
                      ],
                    ),
                  ),
                ),
                LabeledField(
                    label: 'Tema trabajado', controller: _topicController),
                LabeledField(
                    label: 'Resumen de la sesión',
                    controller: _summaryController,
                    maxLines: 3),
                LabeledField(
                    label: 'Objetivos trabajados',
                    controller: _objectivesController,
                    maxLines: 2),
                LabeledField(
                    label: 'Intervención / técnica utilizada',
                    controller: _techniqueController,
                    maxLines: 2),
                LabeledField(
                    label: 'Observaciones clínicas',
                    controller: _clinicalNotesController,
                    maxLines: 3),
                LabeledField(
                    label: 'Acuerdos', controller: _agreementsController, maxLines: 2),
                LabeledField(
                    label: 'Tarea para casa (referencia interna)',
                    controller: _homeworkController,
                    maxLines: 2,
                    hintText:
                        'Si quieres que el consultante la vea, usa "Asignar tarea" en la pestaña Tareas.'),
                LabeledField(
                    label: 'Objetivos para la próxima sesión',
                    controller: _nextObjectivesController,
                    maxLines: 2),
                InkWell(
                  onTap: () => _pickDate(isNextSession: true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12.0, vertical: 12.0),
                    margin: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 16.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(
                          color: FlutterFlowTheme.of(context).alternate),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.event_rounded,
                            size: 18.0,
                            color: FlutterFlowTheme.of(context).secondaryText),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: Text(_nextSessionDate != null
                              ? 'Próxima sesión: ${formatDateEs(_nextSessionDate!)}'
                              : 'Próxima sesión: sin definir (toca para elegir)'),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_errorText != null)
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 12.0),
                    child: Text(
                      _errorText!,
                      style: FlutterFlowTheme.of(context).bodySmall.override(
                            font: GoogleFonts.outfit(),
                            color: FlutterFlowTheme.of(context).error,
                            letterSpacing: 0.0,
                          ),
                    ),
                  ),
                PrimaryButton(
                  label: _isEditing ? 'Guardar cambios' : 'Guardar sesión',
                  isLoading: _isSaving,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
