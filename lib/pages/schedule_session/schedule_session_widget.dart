import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '/utils/date_format_es.dart';
import '/utils/error_logging.dart';
import '/utils/error_messages.dart';
import '/utils/session_request_status.dart';
import '/utils/validators.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Lets a patient request a session with their assigned psychologist, and
/// see the status of past requests. The patient may pick any date/time for
/// now -- there's no availability check yet against the psychologist's
/// schedule (planned for later); every request starts as `'pendiente'`
/// until the psychologist confirms or declines it from their "Sesiones"
/// tab (see psychologist_patient_detail/sesiones_tab.dart).
class ScheduleSessionWidget extends StatefulWidget {
  const ScheduleSessionWidget({super.key});

  static String routeName = 'ScheduleSession';
  static String routePath = '/scheduleSession';

  @override
  State<ScheduleSessionWidget> createState() => _ScheduleSessionWidgetState();
}

class _ScheduleSessionWidgetState extends State<ScheduleSessionWidget> {
  Future<void> _openRequestForm() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _RequestSessionSheet(),
    );
  }

  Future<void> _confirmCancel(SessionRequestsRecord request) async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Cancelar solicitud'),
            content: const Text(
                '¿Deseas cancelar esta solicitud de sesión? Tu psicólogo ya no la verá como pendiente.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Volver'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Cancelar solicitud'),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed) return;
    try {
      await request.reference.update({'status': 'cancelada'});
    } catch (e, stackTrace) {
      logAppError(
        context: 'ScheduleSessionWidget._confirmCancel',
        error: e,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(genericSaveErrorMessage('cancelar la solicitud'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasPsychologist = currentUserDocument?.psychologistRef != null;

    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      floatingActionButton: hasPsychologist
          ? FloatingActionButton.extended(
              backgroundColor: FlutterFlowTheme.of(context).primary,
              foregroundColor: FlutterFlowTheme.of(context).onPrimary,
              onPressed: _openRequestForm,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Solicitar sesión'),
            )
          : null,
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
                      'Programar sesión',
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: FlutterFlowTheme.of(context).titleLarge.override(
                            font: GoogleFonts.outfit(fontWeight: FontWeight.bold),
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
              child: !hasPsychologist
                  ? _NoPsychologistHint(
                      onLink: () => context
                          .pushNamed(LinkPsychologistWidget.routeName),
                    )
                  : StreamBuilder<List<SessionRequestsRecord>>(
                      // A direct match on the caller's own `patientRef` --
                      // no `get()` involved, so a live listener is safe
                      // here (see the note on `isAssignedPsychologist` in
                      // firestore.rules for why that's not always true).
                      stream: querySessionRequestsRecord(
                        queryBuilder: (q) => q.where('patientRef',
                            isEqualTo: currentUserReference),
                      ).handleError((error, stackTrace) {
                        logAppError(
                          context: 'ScheduleSessionWidget.requests',
                          error: error,
                          stackTrace: stackTrace,
                        );
                        throw error;
                      }),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return _StateMessage(
                            icon: Icons.error_outline_rounded,
                            title: 'No se pudieron cargar tus solicitudes.',
                            subtitle: 'Intenta nuevamente más tarde.',
                          );
                        }
                        if (!snapshot.hasData) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        final requests = snapshot.data!
                          ..sort((a, b) => (b.createdTime ?? DateTime(2000))
                              .compareTo(a.createdTime ?? DateTime(2000)));
                        if (requests.isEmpty) {
                          return _StateMessage(
                            icon: Icons.event_available_rounded,
                            title: 'Aún no has solicitado sesiones',
                            subtitle:
                                'Toca "Solicitar sesión" para elegir un día y hora con tu psicólogo.',
                          );
                        }
                        return ListView.builder(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              24.0, 0.0, 24.0, 96.0),
                          itemCount: requests.length,
                          itemBuilder: (context, index) {
                            final request = requests[index];
                            return Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  0.0, 0.0, 0.0, 12.0),
                              child: _SessionRequestCard(
                                request: request,
                                onCancel: request.status == 'pendiente'
                                    ? () => _confirmCancel(request)
                                    : null,
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoPsychologistHint extends StatelessWidget {
  const _NoPsychologistHint({required this.onLink});
  final VoidCallback onLink;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.psychology_alt_rounded, size: 40.0, color: theme.secondaryText),
            const SizedBox(height: 12.0),
            Text(
              'Aún no tienes un psicólogo vinculado',
              textAlign: TextAlign.center,
              style: theme.titleSmall.override(
                font: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                color: theme.primaryText,
                letterSpacing: 0.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4.0),
            Text(
              'Vincula tu cuenta con el código de tu psicólogo para poder solicitar sesiones.',
              textAlign: TextAlign.center,
              style: theme.bodyMedium.override(
                font: GoogleFonts.outfit(),
                color: theme.secondaryText,
                letterSpacing: 0.0,
              ),
            ),
            const SizedBox(height: 16.0),
            TextButton(onPressed: onLink, child: const Text('Vincular ahora')),
          ],
        ),
      ),
    );
  }
}

class _StateMessage extends StatelessWidget {
  const _StateMessage({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: FlutterFlowTheme.of(context).secondaryText, size: 40.0),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 4.0),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: FlutterFlowTheme.of(context).titleSmall.override(
                      font: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                      color: FlutterFlowTheme.of(context).primaryText,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: FlutterFlowTheme.of(context).bodyMedium.override(
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

class _SessionRequestCard extends StatelessWidget {
  const _SessionRequestCard({required this.request, this.onCancel});

  final SessionRequestsRecord request;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(20.0),
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
          if (request.psychologistNote.isNotEmpty)
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 0.0),
              child: Text(
                'Tu psicólogo: ${request.psychologistNote}',
                style: theme.bodySmall.override(
                  font: GoogleFonts.outfit(fontStyle: FontStyle.italic),
                  color: theme.primary,
                  letterSpacing: 0.0,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          if (onCancel != null)
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton(
                onPressed: onCancel,
                child: const Text('Cancelar solicitud'),
              ),
            ),
        ],
      ),
    );
  }
}

class _RequestSessionSheet extends StatefulWidget {
  const _RequestSessionSheet();

  @override
  State<_RequestSessionSheet> createState() => _RequestSessionSheetState();
}

class _RequestSessionSheetState extends State<_RequestSessionSheet> {
  final _noteController = TextEditingController();
  DateTime? _date;
  TimeOfDay? _time;
  bool _isSaving = false;
  String? _errorText;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? now,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 2),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time ?? const TimeOfDay(hour: 9, minute: 0),
    );
    if (picked != null) setState(() => _time = picked);
  }

  Future<void> _submit() async {
    if (_date == null || _time == null) {
      setState(() => _errorText = 'Elige un día y una hora para tu sesión.');
      return;
    }
    final requestedDate = DateTime(
      _date!.year,
      _date!.month,
      _date!.day,
      _time!.hour,
      _time!.minute,
    );
    if (requestedDate.isBefore(DateTime.now())) {
      setState(() => _errorText = 'Elige una fecha y hora futuras.');
      return;
    }
    final noteError = validateFreeText(
      _noteController.text,
      maxLength: 300,
      required: false,
    );
    if (noteError != null) {
      setState(() => _errorText = noteError);
      return;
    }
    final psychologistRef = currentUserDocument?.psychologistRef;
    if (psychologistRef == null) {
      setState(() => _errorText = 'Aún no tienes un psicólogo vinculado.');
      return;
    }
    setState(() {
      _isSaving = true;
      _errorText = null;
    });
    try {
      await SessionRequestsRecord.collection.doc().set(
            createSessionRequestsRecordData(
              patientRef: currentUserReference,
              psychologistRef: psychologistRef,
              requestedDate: requestedDate,
              note: _noteController.text.trim(),
              status: 'pendiente',
              createdTime: DateTime.now(),
            ),
          );
      if (mounted) Navigator.pop(context);
    } catch (e, stackTrace) {
      logAppError(
        context: 'ScheduleSessionWidget._submit',
        error: e,
        stackTrace: stackTrace,
      );
      if (mounted) {
        setState(() => _errorText = genericSaveErrorMessage('enviar la solicitud'));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: theme.primaryBackground,
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
              Center(
                child: Container(
                  width: 40.0,
                  height: 4.0,
                  decoration: BoxDecoration(
                    color: theme.alternate,
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 0.0, 4.0),
                child: Text(
                  'Solicitar sesión',
                  style: theme.titleMedium.override(
                    font: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                    color: theme.primaryText,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 16.0),
                child: Text(
                  'Elige el día y la hora que prefieras. Tu psicólogo confirmará la '
                  'sesión según su disponibilidad.',
                  style: theme.bodySmall.override(
                    font: GoogleFonts.outfit(),
                    color: theme.secondaryText,
                    letterSpacing: 0.0,
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _pickDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12.0, vertical: 12.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(color: theme.alternate),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today_rounded,
                                size: 18.0, color: theme.secondaryText),
                            const SizedBox(width: 8.0),
                            Expanded(
                              child: Text(
                                _date != null ? formatDateEs(_date!) : 'Elige el día',
                                overflow: TextOverflow.ellipsis,
                                style: theme.bodyMedium.override(
                                  font: GoogleFonts.outfit(),
                                  color: theme.primaryText,
                                  letterSpacing: 0.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: InkWell(
                      onTap: _pickTime,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12.0, vertical: 12.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(color: theme.alternate),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.schedule_rounded,
                                size: 18.0, color: theme.secondaryText),
                            const SizedBox(width: 8.0),
                            Expanded(
                              child: Text(
                                _time != null ? _time!.format(context) : 'Elige la hora',
                                overflow: TextOverflow.ellipsis,
                                style: theme.bodyMedium.override(
                                  font: GoogleFonts.outfit(),
                                  color: theme.primaryText,
                                  letterSpacing: 0.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              Text(
                'Motivo (opcional)',
                style: theme.labelMedium.override(
                  font: GoogleFonts.outfit(),
                  color: theme.primaryText,
                  letterSpacing: 0.0,
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0.0, 4.0, 0.0, 12.0),
                child: TextField(
                  controller: _noteController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Ej. Me gustaría hablar sobre...',
                    isDense: true,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(color: theme.alternate),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(color: theme.primary),
                    ),
                  ),
                ),
              ),
              if (_errorText != null)
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 12.0),
                  child: Text(
                    _errorText!,
                    style: theme.bodySmall.override(
                      font: GoogleFonts.outfit(),
                      color: theme.error,
                      letterSpacing: 0.0,
                    ),
                  ),
                ),
              InkWell(
                onTap: _isSaving ? null : _submit,
                child: Container(
                  height: 48.0,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: theme.primary,
                    borderRadius: BorderRadius.circular(24.0),
                  ),
                  child: _isSaving
                      ? SizedBox(
                          width: 20.0,
                          height: 20.0,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.0,
                            valueColor: AlwaysStoppedAnimation(theme.onPrimary),
                          ),
                        )
                      : Text(
                          'Enviar solicitud',
                          style: theme.labelMedium.override(
                            font: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                            color: theme.onPrimary,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.bold,
                          ),
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
