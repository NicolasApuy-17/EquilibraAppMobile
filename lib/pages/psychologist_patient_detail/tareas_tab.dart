import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/utils/date_format_es.dart';
import '/utils/error_messages.dart';
import '/utils/task_status.dart';
import '/utils/validators.dart';
import '/services/psychologist_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'shared_widgets.dart';

class TareasTab extends StatefulWidget {
  const TareasTab({super.key, required this.patient});

  final UsersRecord patient;

  @override
  State<TareasTab> createState() => _TareasTabState();
}

class _TareasTabState extends State<TareasTab> {
  String? _statusFilter;
  late Future<List<TasksRecord>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  // A one-time fetch, not a live `.snapshots()` listener: `tasks` reads are
  // gated by `isAssignedPsychologist()`, a security rule that does a
  // `get()` on the patient's `users/{uid}` doc -- and that same doc gets
  // written to (its `lastActivityAt`) by the `onTaskActivity` Cloud
  // Function trigger every time a task changes. A live listener whose rule
  // depends on a document that gets rewritten moments later is exactly the
  // pattern that made this tab's data flash correctly for an instant, then
  // silently drop to empty with no error -- reliably reproducible, and the
  // same reason `records`/`behavioral_records` had it too (see
  // registros_tab.dart, avances_tab.dart). Refreshed manually instead: on
  // pull-to-refresh, and after any action that could have changed the data.
  Future<List<TasksRecord>> _load() => queryTasksRecordOnce(
        queryBuilder: (q) =>
            q.where('userRef', isEqualTo: widget.patient.reference),
      );

  Future<void> _refresh() async {
    final future = _load();
    setState(() => _future = future);
    await future;
  }

  Future<void> _openAssignForm() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AssignTaskSheet(patient: widget.patient),
    );
    _refresh();
  }

  Future<void> _openTaskDetail(TasksRecord task) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _TaskDetailSheet(task: task),
    );
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<TasksRecord>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Padding(
            padding: EdgeInsets.all(24.0),
            child: AsyncErrorHint(text: 'No se pudieron cargar las tareas.'),
          );
        }
        if (!snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 32.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final allTasks = snapshot.data!
          ..sort((a, b) => (b.assignedDate ?? b.createdTime ?? DateTime(2000))
              .compareTo(a.assignedDate ?? a.createdTime ?? DateTime(2000)));
        final tasks = _statusFilter == null
            ? allTasks
            : allTasks.where((t) => t.status == _statusFilter).toList();

        return Stack(
          children: [
            RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                padding: const EdgeInsetsDirectional.fromSTEB(
                    24.0, 12.0, 24.0, 96.0),
                children: [
                  ChoiceChipRow(
                    options: ['todas', ...kTaskStatuses],
                    labelBuilder: (o) =>
                        o == 'todas' ? 'Todas' : taskStatusLabel(o),
                    selected: _statusFilter ?? 'todas',
                    onSelected: (o) => setState(
                        () => _statusFilter = o == 'todas' ? null : o),
                  ),
                  const SizedBox(height: 16.0),
                  if (tasks.isEmpty)
                    const EmptyHint('No hay tareas con este filtro.',
                        icon: Icons.assignment_outlined)
                  else
                    ...tasks.map((task) => _TaskRow(
                          task: task,
                          onTap: () => _openTaskDetail(task),
                        )),
                ],
              ),
            ),
            PositionedDirectional(
              bottom: 16.0,
              end: 0.0,
              child: FloatingActionButton.extended(
                backgroundColor: FlutterFlowTheme.of(context).primary,
                foregroundColor: FlutterFlowTheme.of(context).onPrimary,
                onPressed: _openAssignForm,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Asignar tarea'),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _TaskRow extends StatelessWidget {
  const _TaskRow({required this.task, required this.onTap});

  final TasksRecord task;
  final VoidCallback onTap;

  bool get _isAssignedByPsychologist =>
      task.hasCreatedByRef() && task.createdByRef!.id != task.userRef?.id;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 10.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.0),
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
                      task.title.isEmpty ? 'Sin título' : task.title,
                      style: theme.bodyMedium.override(
                        font: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                        color: theme.primaryText,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        8.0, 3.0, 8.0, 3.0),
                    decoration: BoxDecoration(
                      color: taskStatusColor(context, task.status)
                          .withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Text(
                      taskStatusLabel(task.status),
                      style: theme.labelSmall.override(
                        font: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                        color: taskStatusColor(context, task.status),
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              if (!_isAssignedByPsychologist)
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0.0, 4.0, 0.0, 0.0),
                  child: Text(
                    'Creada por el consultante',
                    style: theme.bodySmall.override(
                      font: GoogleFonts.outfit(),
                      color: theme.secondaryText,
                      letterSpacing: 0.0,
                    ),
                  ),
                ),
              if (task.dueDate != null)
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0.0, 4.0, 0.0, 0.0),
                  child: Text(
                    'Vence: ${formatDateEs(task.dueDate!)}',
                    style: theme.bodySmall.override(
                      font: GoogleFonts.outfit(),
                      color: theme.secondaryText,
                      letterSpacing: 0.0,
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

class _TaskDetailSheet extends StatefulWidget {
  const _TaskDetailSheet({required this.task});

  final TasksRecord task;

  @override
  State<_TaskDetailSheet> createState() => _TaskDetailSheetState();
}

class _TaskDetailSheetState extends State<_TaskDetailSheet> {
  late TextEditingController _feedbackController;
  bool _isSaving = false;
  bool _isSendingReminder = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _feedbackController =
        TextEditingController(text: widget.task.feedback ?? '');
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _sendReminder() async {
    final patientRef = widget.task.userRef;
    if (patientRef == null) return;
    setState(() => _isSendingReminder = true);
    try {
      await PsychologistService().sendConversationMessage(
        conversationId: patientRef.id,
        text: 'Recuerda completar la tarea "${widget.task.title}"'
            '${widget.task.dueDate != null ? ' antes del ${formatDateEs(widget.task.dueDate!)}' : ''}.',
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

  Future<void> _saveFeedback() async {
    setState(() {
      _isSaving = true;
      _errorText = null;
    });
    try {
      await widget.task.reference.update(createTasksRecordData(
        feedback: normalizeWhitespace(_feedbackController.text),
        feedbackAt: DateTime.now(),
      ));
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(() => _errorText = genericSaveErrorMessage('guardar el feedback'));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
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
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  task.title.isEmpty ? 'Sin título' : task.title,
                  style: theme.titleMedium.override(
                    font: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                    color: theme.primaryText,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (task.description.isNotEmpty)
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(0.0, 6.0, 0.0, 0.0),
                    child: Text(task.description),
                  ),
                const SizedBox(height: 12.0),
                Text('Estado: ${taskStatusLabel(task.status)}'),
                if (task.dueDate != null)
                  Text('Fecha límite: ${formatDateEs(task.dueDate!)}'),
                if (task.hasFrequency() && task.frequency.isNotEmpty)
                  Text('Frecuencia: ${taskFrequencyLabel(task.frequency)}'),
                const SizedBox(height: 16.0),
                if (task.responseType == 'texto' &&
                    task.responseText.isNotEmpty) ...[
                  SectionTitle('Respuesta del consultante'),
                  Text(task.responseText),
                  const SizedBox(height: 12.0),
                ] else if (task.responseType == 'escala' &&
                    task.hasResponseValue()) ...[
                  SectionTitle('Respuesta del consultante'),
                  Text('${task.responseValue!.round()}/10'),
                  const SizedBox(height: 12.0),
                ],
                if (task.responseAt != null)
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 12.0),
                    child: Text(
                      'Respondió el ${formatDateEs(task.responseAt!)}',
                      style: theme.bodySmall.override(
                        font: GoogleFonts.outfit(),
                        color: theme.secondaryText,
                        letterSpacing: 0.0,
                      ),
                    ),
                  ),
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
                LabeledField(
                  label: 'Feedback para el consultante',
                  controller: _feedbackController,
                  maxLines: 3,
                  hintText: 'Escribe un comentario sobre su respuesta...',
                ),
                if (_errorText != null)
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 12.0),
                    child: Text(
                      _errorText!,
                      style: TextStyle(color: theme.error, fontSize: 12.0),
                    ),
                  ),
                PrimaryButton(
                  label: 'Guardar feedback',
                  isLoading: _isSaving,
                  onPressed: _saveFeedback,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AssignTaskSheet extends StatefulWidget {
  const _AssignTaskSheet({required this.patient});

  final UsersRecord patient;

  @override
  State<_AssignTaskSheet> createState() => _AssignTaskSheetState();
}

class _AssignTaskSheetState extends State<_AssignTaskSheet> {
  final _titleController = TextEditingController();
  final _instructionsController = TextEditingController();
  DateTime? _dueDate;
  String _frequency = 'una_vez';
  String _responseType = 'completado';
  bool _isSaving = false;
  String? _errorText;

  @override
  void dispose() {
    _titleController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _submit() async {
    final titleError = validateFreeText(
      _titleController.text,
      maxLength: 80,
      required: true,
      requiredMessage: 'El título es obligatorio.',
    );
    if (titleError != null) {
      setState(() => _errorText = titleError);
      return;
    }
    setState(() {
      _isSaving = true;
      _errorText = null;
    });
    try {
      final myRef = currentUserReference;
      await TasksRecord.collection.doc().set(createTasksRecordData(
            title: normalizeWhitespace(_titleController.text),
            description: _instructionsController.text.trim(),
            dueDate: _dueDate,
            status: 'pendiente',
            userRef: widget.patient.reference,
            createdByRef: myRef,
            createdTime: DateTime.now(),
            assignedDate: DateTime.now(),
            frequency: _frequency,
            responseType: _responseType,
          ));
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(() => _errorText = genericSaveErrorMessage('asignar la tarea'));
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
                  'Asignar tarea',
                  style: FlutterFlowTheme.of(context).titleMedium.override(
                        font: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                        color: FlutterFlowTheme.of(context).primaryText,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16.0),
                LabeledField(label: 'Título', controller: _titleController),
                LabeledField(
                  label: 'Instrucciones',
                  controller: _instructionsController,
                  maxLines: 3,
                  hintText:
                      'Ej. Durante esta semana registra tres situaciones donde aparezca ansiedad...',
                ),
                Text(
                  'Fecha límite',
                  style: FlutterFlowTheme.of(context).labelMedium.override(
                        font: GoogleFonts.outfit(),
                        color: FlutterFlowTheme.of(context).primaryText,
                        letterSpacing: 0.0,
                      ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0.0, 4.0, 0.0, 12.0),
                  child: InkWell(
                    onTap: _pickDueDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 12.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(
                            color: FlutterFlowTheme.of(context).alternate),
                      ),
                      child: Text(_dueDate != null
                          ? formatDateEs(_dueDate!)
                          : 'Sin fecha (toca para elegir)'),
                    ),
                  ),
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
                Text(
                  'Tipo de respuesta',
                  style: FlutterFlowTheme.of(context).labelMedium.override(
                        font: GoogleFonts.outfit(),
                        color: FlutterFlowTheme.of(context).primaryText,
                        letterSpacing: 0.0,
                      ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0.0, 4.0, 0.0, 16.0),
                  child: ChoiceChipRow(
                    options: kTaskResponseTypes,
                    labelBuilder: taskResponseTypeLabel,
                    selected: _responseType,
                    onSelected: (v) => setState(() => _responseType = v),
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
                  label: 'Enviar tarea',
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
