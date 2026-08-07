import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/components/bottom_nav5/bottom_nav5_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '/utils/date_format_es.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'tasks_model.dart';
export 'tasks_model.dart';

const _kTaskStatuses = ['pendiente', 'en_proceso', 'completada'];

String _statusLabel(String status) {
  switch (status) {
    case 'en_proceso':
      return 'En proceso';
    case 'completada':
      return 'Completada';
    default:
      return 'Pendiente';
  }
}

Color _statusColor(BuildContext context, String status) {
  switch (status) {
    case 'en_proceso':
      return FlutterFlowTheme.of(context).info;
    case 'completada':
      return FlutterFlowTheme.of(context).success;
    default:
      return FlutterFlowTheme.of(context).warning;
  }
}

class TasksWidget extends StatefulWidget {
  const TasksWidget({super.key});

  static String routeName = 'Tasks';
  static String routePath = '/tasks';

  @override
  State<TasksWidget> createState() => _TasksWidgetState();
}

class _TasksWidgetState extends State<TasksWidget> {
  late TasksModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => TasksModel());
    _model.searchController.addListener(() {
      safeSetState(() => _model.searchQuery = _model.searchController.text);
    });
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  Future<void> _openTaskForm({TasksRecord? existingTask}) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _TaskFormSheet(existingTask: existingTask),
    );
  }

  Future<void> _confirmDelete(TasksRecord task) async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (alertDialogContext) => AlertDialog(
            title: Text('Eliminar tarea'),
            content: Text(
                '¿Deseas eliminar "${task.title}"? Esta acción no se puede deshacer.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(alertDialogContext, false),
                child: Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(alertDialogContext, true),
                child: Text('Eliminar'),
              ),
            ],
          ),
        ) ??
        false;
    if (confirmed) {
      await task.reference.delete();
    }
  }

  Future<void> _toggleComplete(TasksRecord task) async {
    await task.reference.update(createTasksRecordData(
      status: task.status == 'completada' ? 'pendiente' : 'completada',
    ));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        floatingActionButton: FloatingActionButton(
          backgroundColor: FlutterFlowTheme.of(context).primary,
          foregroundColor: FlutterFlowTheme.of(context).onPrimary,
          onPressed: () => _openTaskForm(),
          child: Icon(Icons.add_rounded),
        ),
        body: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding: EdgeInsets.all(24.0),
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
                      onPressed: () async {
                        context.safePop();
                      },
                    ),
                    Text(
                      'Tareas e indicaciones',
                      style: FlutterFlowTheme.of(context).titleLarge.override(
                            font: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                            ),
                            color: FlutterFlowTheme.of(context).primaryText,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    FlutterFlowIconButton(
                      borderRadius: 8.0,
                      buttonSize: 40.0,
                      fillColor: Colors.transparent,
                      icon: Icon(
                        Icons.history_rounded,
                        color: FlutterFlowTheme.of(context).primaryText,
                        size: 24.0,
                      ),
                      onPressed: () async {
                        context.pushNamed(MyRecordsWidget.routeName);
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      height: 44.0,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(
                          color: FlutterFlowTheme.of(context).alternate,
                        ),
                      ),
                      child: Row(
                        children: [
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                12.0, 0.0, 8.0, 0.0),
                            child: Icon(
                              Icons.search_rounded,
                              color: FlutterFlowTheme.of(context).secondaryText,
                              size: 20.0,
                            ),
                          ),
                          Expanded(
                            child: TextField(
                              controller: _model.searchController,
                              decoration: InputDecoration(
                                hintText: 'Buscar tareas...',
                                hintStyle: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      font: GoogleFonts.outfit(),
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryText,
                                      letterSpacing: 0.0,
                                    ),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    font: GoogleFonts.outfit(),
                                    color: FlutterFlowTheme.of(context)
                                        .primaryText,
                                    letterSpacing: 0.0,
                                  ),
                            ),
                          ),
                          if (_model.searchQuery.isNotEmpty)
                            InkWell(
                              onTap: () => _model.searchController.clear(),
                              child: Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    0.0, 0.0, 12.0, 0.0),
                                child: Icon(
                                  Icons.close_rounded,
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryText,
                                  size: 18.0,
                                ),
                              ),
                            )
                          else
                            SizedBox(width: 12.0),
                        ],
                      ),
                    ),
                    SizedBox(height: 12.0),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _FilterChip(
                                  label: 'Todas',
                                  selected: _model.statusFilter == null,
                                  onTap: () => safeSetState(
                                      () => _model.statusFilter = null),
                                ),
                                for (final status in _kTaskStatuses)
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        8.0, 0.0, 0.0, 0.0),
                                    child: _FilterChip(
                                      label: _statusLabel(status),
                                      selected: _model.statusFilter == status,
                                      onTap: () => safeSetState(
                                        () => _model.statusFilter =
                                            _model.statusFilter == status
                                                ? null
                                                : status,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              8.0, 0.0, 0.0, 0.0),
                          child: FlutterFlowIconButton(
                            borderRadius: 8.0,
                            buttonSize: 40.0,
                            fillColor: FlutterFlowTheme.of(context)
                                .secondaryBackground,
                            icon: Icon(
                              _model.sortAscending
                                  ? Icons.arrow_upward_rounded
                                  : Icons.arrow_downward_rounded,
                              color: FlutterFlowTheme.of(context).primary,
                              size: 20.0,
                            ),
                            onPressed: () async {
                              safeSetState(() =>
                                  _model.sortAscending = !_model.sortAscending);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: StreamBuilder<List<TasksRecord>>(
                  stream: queryTasksRecord(
                    queryBuilder: (tasksRecord) => tasksRecord.where('userRef',
                        isEqualTo: currentUserReference),
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return _StateMessage(
                        icon: Icons.error_outline_rounded,
                        title: 'No se pudieron cargar tus tareas.',
                        subtitle: 'Intenta nuevamente más tarde.',
                      );
                    }
                    if (!snapshot.hasData) {
                      return Center(
                        child: SizedBox(
                          width: 50,
                          height: 50,
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    final allTasks = snapshot.data!;
                    var tasks = allTasks.toList();

                    if (_model.statusFilter != null) {
                      tasks = tasks
                          .where((t) => t.status == _model.statusFilter)
                          .toList();
                    }
                    if (_model.searchQuery.trim().isNotEmpty) {
                      final query = _model.searchQuery.trim().toLowerCase();
                      tasks = tasks
                          .where((t) =>
                              t.title.toLowerCase().contains(query) ||
                              t.description.toLowerCase().contains(query))
                          .toList();
                    }
                    tasks.sort((a, b) {
                      final da = a.dueDate ?? a.createdTime ?? DateTime(2100);
                      final db = b.dueDate ?? b.createdTime ?? DateTime(2100);
                      return _model.sortAscending
                          ? da.compareTo(db)
                          : db.compareTo(da);
                    });

                    if (tasks.isEmpty) {
                      return _StateMessage(
                        icon: Icons.assignment_outlined,
                        title: allTasks.isEmpty
                            ? 'Aún no tienes tareas'
                            : 'Sin resultados',
                        subtitle: allTasks.isEmpty
                            ? 'Toca "+" para crear tu primera tarea o indicación.'
                            : 'Prueba con otra búsqueda o filtro.',
                      );
                    }

                    return ListView.builder(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 96.0),
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        final task = tasks[index];
                        return Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 0.0, 0.0, 12.0),
                          child: _TaskCard(
                            task: task,
                            onTap: () => _openTaskForm(existingTask: task),
                            onToggleComplete: () => _toggleComplete(task),
                            onDelete: () => _confirmDelete(task),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              wrapWithModel(
                model: _model.bottomNavModel,
                updateCallback: () => safeSetState(() {}),
                child: BottomNav5Widget(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.0),
      child: Container(
        padding: EdgeInsetsDirectional.fromSTEB(14.0, 8.0, 14.0, 8.0),
        decoration: BoxDecoration(
          color: selected
              ? FlutterFlowTheme.of(context).primary10
              : FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(
            color: selected
                ? FlutterFlowTheme.of(context).primary
                : FlutterFlowTheme.of(context).alternate,
          ),
        ),
        child: Text(
          label,
          style: FlutterFlowTheme.of(context).labelMedium.override(
                font: GoogleFonts.outfit(),
                color: selected
                    ? FlutterFlowTheme.of(context).primary
                    : FlutterFlowTheme.of(context).primaryText,
                letterSpacing: 0.0,
              ),
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
        padding: EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: FlutterFlowTheme.of(context).secondaryText,
              size: 40.0,
            ),
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 4.0),
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

class _TaskCard extends StatelessWidget {
  const _TaskCard({
    required this.task,
    required this.onTap,
    required this.onToggleComplete,
    required this.onDelete,
  });

  final TasksRecord task;
  final VoidCallback onTap;
  final VoidCallback onToggleComplete;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final isDone = task.status == 'completada';
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24.0),
      child: Container(
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(24.0),
        ),
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: onToggleComplete,
                child: Icon(
                  isDone
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: isDone
                      ? FlutterFlowTheme.of(context).success
                      : FlutterFlowTheme.of(context).secondaryText,
                  size: 26.0,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(12.0, 0.0, 12.0, 0.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title.isEmpty ? 'Sin título' : task.title,
                        style: FlutterFlowTheme.of(context)
                            .titleMedium
                            .override(
                              font: GoogleFonts.outfit(
                                  fontWeight: FontWeight.w600),
                              color: isDone
                                  ? FlutterFlowTheme.of(context).secondaryText
                                  : FlutterFlowTheme.of(context).primaryText,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.w600,
                              decoration: isDone
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                      ),
                      if (task.description.isNotEmpty)
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 4.0, 0.0, 0.0),
                          child: Text(
                            task.description,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  font: GoogleFonts.outfit(),
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryText,
                                  letterSpacing: 0.0,
                                ),
                          ),
                        ),
                      Padding(
                        padding:
                            EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 0.0),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  8.0, 4.0, 8.0, 4.0),
                              decoration: BoxDecoration(
                                color: _statusColor(context, task.status)
                                    .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Text(
                                _statusLabel(task.status),
                                style: FlutterFlowTheme.of(context)
                                    .labelSmall
                                    .override(
                                      font: GoogleFonts.outfit(
                                          fontWeight: FontWeight.bold),
                                      color: _statusColor(context, task.status),
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                            if (task.dueDate != null)
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    8.0, 0.0, 0.0, 0.0),
                                child: Text(
                                  formatDateEs(task.dueDate!),
                                  style: FlutterFlowTheme.of(context)
                                      .labelSmall
                                      .override(
                                        font: GoogleFonts.outfit(),
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryText,
                                        letterSpacing: 0.0,
                                      ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              InkWell(
                onTap: onDelete,
                child: Icon(
                  Icons.delete_outline_rounded,
                  color: FlutterFlowTheme.of(context).secondaryText,
                  size: 22.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TaskFormSheet extends StatefulWidget {
  const _TaskFormSheet({this.existingTask});

  final TasksRecord? existingTask;

  @override
  State<_TaskFormSheet> createState() => _TaskFormSheetState();
}

class _TaskFormSheetState extends State<_TaskFormSheet> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  DateTime? _dueDate;
  late String _status;
  bool _isSaving = false;
  String? _errorText;

  bool get _isEditing => widget.existingTask != null;

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: widget.existingTask?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.existingTask?.description ?? '');
    _dueDate = widget.existingTask?.dueDate;
    _status = widget.existingTask?.status ?? 'pendiente';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime(DateTime.now().year - 1),
      lastDate: DateTime(DateTime.now().year + 5),
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() => _errorText = 'El título es obligatorio.');
      return;
    }
    setState(() {
      _isSaving = true;
      _errorText = null;
    });
    try {
      final description = _descriptionController.text.trim();
      if (_isEditing) {
        await widget.existingTask!.reference.update(createTasksRecordData(
          title: title,
          description: description,
          dueDate: _dueDate,
          status: _status,
        ));
      } else {
        await TasksRecord.collection.doc().set(createTasksRecordData(
              title: title,
              description: description,
              dueDate: _dueDate,
              status: _status,
              userRef: currentUserReference,
              createdTime: getCurrentTimestamp,
            ));
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorText = 'No se pudo guardar la tarea. Intenta nuevamente.';
        });
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).primaryBackground,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28.0),
            topRight: Radius.circular(28.0),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40.0,
                  height: 4.0,
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).alternate,
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 0.0, 16.0),
                child: Text(
                  _isEditing ? 'Editar tarea' : 'Nueva tarea',
                  style: FlutterFlowTheme.of(context).titleMedium.override(
                        font: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                        color: FlutterFlowTheme.of(context).primaryText,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              Text(
                'Título',
                style: FlutterFlowTheme.of(context).labelMedium.override(
                      font: GoogleFonts.outfit(),
                      color: FlutterFlowTheme.of(context).primaryText,
                      letterSpacing: 0.0,
                    ),
              ),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0.0, 4.0, 0.0, 12.0),
                child: TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    hintText: 'Ej. Practicar respiración diafragmática',
                    isDense: true,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(
                          color: FlutterFlowTheme.of(context).alternate),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(
                          color: FlutterFlowTheme.of(context).primary),
                    ),
                  ),
                ),
              ),
              Text(
                'Descripción / indicaciones',
                style: FlutterFlowTheme.of(context).labelMedium.override(
                      font: GoogleFonts.outfit(),
                      color: FlutterFlowTheme.of(context).primaryText,
                      letterSpacing: 0.0,
                    ),
              ),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0.0, 4.0, 0.0, 12.0),
                child: TextField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Detalles opcionales...',
                    isDense: true,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(
                          color: FlutterFlowTheme.of(context).alternate),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(
                          color: FlutterFlowTheme.of(context).primary),
                    ),
                  ),
                ),
              ),
              Text(
                'Fecha',
                style: FlutterFlowTheme.of(context).labelMedium.override(
                      font: GoogleFonts.outfit(),
                      color: FlutterFlowTheme.of(context).primaryText,
                      letterSpacing: 0.0,
                    ),
              ),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0.0, 4.0, 0.0, 12.0),
                child: InkWell(
                  onTap: _pickDate,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(
                          color: FlutterFlowTheme.of(context).alternate),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 18.0,
                          color: FlutterFlowTheme.of(context).secondaryText,
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              8.0, 0.0, 0.0, 0.0),
                          child: Text(
                            _dueDate != null
                                ? formatDateEs(_dueDate!)
                                : 'Sin fecha (toca para elegir)',
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  font: GoogleFonts.outfit(),
                                  color:
                                      FlutterFlowTheme.of(context).primaryText,
                                  letterSpacing: 0.0,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Text(
                'Estado',
                style: FlutterFlowTheme.of(context).labelMedium.override(
                      font: GoogleFonts.outfit(),
                      color: FlutterFlowTheme.of(context).primaryText,
                      letterSpacing: 0.0,
                    ),
              ),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0.0, 4.0, 0.0, 16.0),
                child: Row(
                  children: [
                    for (final status in _kTaskStatuses)
                      Padding(
                        padding:
                            EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 8.0, 0.0),
                        child: _FilterChip(
                          label: _statusLabel(status),
                          selected: _status == status,
                          onTap: () => setState(() => _status = status),
                        ),
                      ),
                  ],
                ),
              ),
              if (_errorText != null)
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 12.0),
                  child: Text(
                    _errorText!,
                    style: FlutterFlowTheme.of(context).bodySmall.override(
                          font: GoogleFonts.outfit(),
                          color: FlutterFlowTheme.of(context).error,
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
                    color: FlutterFlowTheme.of(context).primary,
                    borderRadius: BorderRadius.circular(24.0),
                  ),
                  child: _isSaving
                      ? SizedBox(
                          width: 20.0,
                          height: 20.0,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.0,
                            valueColor: AlwaysStoppedAnimation(
                                FlutterFlowTheme.of(context).onPrimary),
                          ),
                        )
                      : Text(
                          _isEditing ? 'Guardar cambios' : 'Crear tarea',
                          style: FlutterFlowTheme.of(context)
                              .labelMedium
                              .override(
                                font: GoogleFonts.outfit(
                                    fontWeight: FontWeight.bold),
                                color: FlutterFlowTheme.of(context).onPrimary,
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
