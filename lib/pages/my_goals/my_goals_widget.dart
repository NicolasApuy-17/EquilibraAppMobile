import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/utils/date_format_es.dart';
import '/utils/error_messages.dart';
import '/utils/validators.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Full, functional "Mis Objetivos" screen: lets the user create, view,
/// complete, edit, and delete simple self-care goals.
class MyGoalsWidget extends StatefulWidget {
  const MyGoalsWidget({super.key});

  static String routeName = 'MyGoals';
  static String routePath = '/myGoals';

  @override
  State<MyGoalsWidget> createState() => _MyGoalsWidgetState();
}

class _MyGoalsWidgetState extends State<MyGoalsWidget> {
  // null = todas, true = cumplidas, false = pendientes
  bool? _completedFilter;

  Future<void> _openGoalForm({GoalsRecord? existingGoal}) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _GoalFormSheet(existingGoal: existingGoal),
    );
  }

  Future<void> _confirmDelete(GoalsRecord goal) async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (alertDialogContext) => AlertDialog(
            title: Text('Eliminar objetivo'),
            content: Text(
                '¿Deseas eliminar "${goal.title}"? Esta acción no se puede deshacer.'),
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
      try {
        await goal.reference.delete();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(genericSaveErrorMessage('eliminar el objetivo'))),
        );
      }
    }
  }

  Future<void> _toggleComplete(GoalsRecord goal) async {
    final nowCompleted = !goal.completed;
    try {
      if (nowCompleted) {
        await goal.reference.update(createGoalsRecordData(
          completed: true,
          completedTime: getCurrentTimestamp,
        ));
      } else {
        await goal.reference.update({
          'completed': false,
          'completedTime': FieldValue.delete(),
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(genericSaveErrorMessage('actualizar el objetivo'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        floatingActionButton: FloatingActionButton(
          backgroundColor: FlutterFlowTheme.of(context).primary,
          foregroundColor: FlutterFlowTheme.of(context).onPrimary,
          onPressed: () => _openGoalForm(),
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
                      onPressed: () => context.safePop(),
                    ),
                    Expanded(
                      child: Text(
                        'Mis Objetivos',
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            FlutterFlowTheme.of(context).titleLarge.override(
                                  font: GoogleFonts.outfit(
                                      fontWeight: FontWeight.bold),
                                  color: FlutterFlowTheme.of(context)
                                      .primaryText,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ),
                    SizedBox(width: 40.0),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 16.0),
                child: Row(
                  children: [
                    _FilterChip(
                      label: 'Todos',
                      selected: _completedFilter == null,
                      onTap: () => setState(() => _completedFilter = null),
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 0.0, 0.0),
                      child: _FilterChip(
                        label: 'Pendientes',
                        selected: _completedFilter == false,
                        onTap: () => setState(() =>
                            _completedFilter = _completedFilter == false
                                ? null
                                : false),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 0.0, 0.0),
                      child: _FilterChip(
                        label: 'Cumplidos',
                        selected: _completedFilter == true,
                        onTap: () => setState(() =>
                            _completedFilter = _completedFilter == true
                                ? null
                                : true),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: StreamBuilder<List<GoalsRecord>>(
                  stream: queryGoalsRecord(
                    queryBuilder: (goalsRecord) => goalsRecord.where('userRef',
                        isEqualTo: currentUserReference),
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return _StateMessage(
                        icon: Icons.error_outline_rounded,
                        title: 'No se pudieron cargar tus objetivos.',
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
                    final allGoals = snapshot.data!;
                    var goals = allGoals.toList();

                    if (_completedFilter != null) {
                      goals = goals
                          .where((g) => g.completed == _completedFilter)
                          .toList();
                    }
                    goals.sort((a, b) {
                      if (a.completed != b.completed) {
                        return a.completed ? 1 : -1;
                      }
                      final da = a.targetDate ?? a.createdTime ?? DateTime(2100);
                      final db = b.targetDate ?? b.createdTime ?? DateTime(2100);
                      return da.compareTo(db);
                    });

                    if (goals.isEmpty) {
                      return _StateMessage(
                        icon: Icons.flag_outlined,
                        title: allGoals.isEmpty
                            ? 'Aún no tienes objetivos'
                            : 'Sin resultados',
                        subtitle: allGoals.isEmpty
                            ? 'Toca "+" para crear tu primera meta de '
                                'autocuidado.'
                            : 'Prueba con otro filtro.',
                      );
                    }

                    final total = allGoals.length;
                    final done = allGoals.where((g) => g.completed).length;

                    return Column(
                      children: [
                        if (allGoals.isNotEmpty)
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                24.0, 0.0, 24.0, 12.0),
                            child: _ProgressSummary(total: total, done: done),
                          ),
                        Expanded(
                          child: ListView.builder(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                24.0, 0.0, 24.0, 96.0),
                            itemCount: goals.length,
                            itemBuilder: (context, index) {
                              final goal = goals[index];
                              return Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    0.0, 0.0, 0.0, 12.0),
                                child: _GoalCard(
                                  goal: goal,
                                  onTap: () =>
                                      _openGoalForm(existingGoal: goal),
                                  onToggleComplete: () =>
                                      _toggleComplete(goal),
                                  onDelete: () => _confirmDelete(goal),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressSummary extends StatelessWidget {
  const _ProgressSummary({required this.total, required this.done});

  final int total;
  final int done;

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : done / total;
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progreso general',
                style: FlutterFlowTheme.of(context).labelMedium.override(
                      font: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                      color: FlutterFlowTheme.of(context).primaryText,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              Text(
                '$done de $total cumplidos',
                style: FlutterFlowTheme.of(context).labelSmall.override(
                      font: GoogleFonts.outfit(),
                      color: FlutterFlowTheme.of(context).secondaryText,
                      letterSpacing: 0.0,
                    ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(0.0, 10.0, 0.0, 0.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8.0,
                backgroundColor: FlutterFlowTheme.of(context).alternate,
                valueColor: AlwaysStoppedAnimation(
                    FlutterFlowTheme.of(context).primary),
              ),
            ),
          ),
        ],
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

class _GoalCard extends StatelessWidget {
  const _GoalCard({
    required this.goal,
    required this.onTap,
    required this.onToggleComplete,
    required this.onDelete,
  });

  final GoalsRecord goal;
  final VoidCallback onTap;
  final VoidCallback onToggleComplete;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final isDone = goal.completed;
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
                        goal.title.isEmpty ? 'Sin título' : goal.title,
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
                      if (goal.description.isNotEmpty)
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 4.0, 0.0, 0.0),
                          child: Text(
                            goal.description,
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
                                color: (isDone
                                        ? FlutterFlowTheme.of(context).success
                                        : FlutterFlowTheme.of(context).warning)
                                    .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Text(
                                isDone ? 'Cumplido' : 'Pendiente',
                                style: FlutterFlowTheme.of(context)
                                    .labelSmall
                                    .override(
                                      font: GoogleFonts.outfit(
                                          fontWeight: FontWeight.bold),
                                      color: isDone
                                          ? FlutterFlowTheme.of(context).success
                                          : FlutterFlowTheme.of(context)
                                              .warning,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                            if (goal.targetDate != null)
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    8.0, 0.0, 0.0, 0.0),
                                child: Text(
                                  formatDateEs(goal.targetDate!),
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

class _GoalFormSheet extends StatefulWidget {
  const _GoalFormSheet({this.existingGoal});

  final GoalsRecord? existingGoal;

  @override
  State<_GoalFormSheet> createState() => _GoalFormSheetState();
}

class _GoalFormSheetState extends State<_GoalFormSheet> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  DateTime? _targetDate;
  bool _isSaving = false;
  String? _errorText;

  bool get _isEditing => widget.existingGoal != null;

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: widget.existingGoal?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.existingGoal?.description ?? '');
    _targetDate = widget.existingGoal?.targetDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _targetDate ?? now,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() => _targetDate = picked);
    }
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
    final descriptionError =
        validateFreeText(_descriptionController.text, maxLength: 500, required: false);
    if (descriptionError != null) {
      setState(() => _errorText = descriptionError);
      return;
    }
    final dateError = validateGoalDate(_targetDate);
    if (dateError != null) {
      setState(() => _errorText = dateError);
      return;
    }
    final title = normalizeWhitespace(_titleController.text);
    setState(() {
      _isSaving = true;
      _errorText = null;
    });
    try {
      final description = _descriptionController.text.trim();
      if (_isEditing) {
        await widget.existingGoal!.reference.update(createGoalsRecordData(
          title: title,
          description: description,
          targetDate: _targetDate,
        ));
      } else {
        await GoalsRecord.collection.doc().set(createGoalsRecordData(
              title: title,
              description: description,
              targetDate: _targetDate,
              completed: false,
              userRef: currentUserReference,
              createdTime: getCurrentTimestamp,
            ));
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorText = genericSaveErrorMessage('guardar el objetivo');
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
                  _isEditing ? 'Editar objetivo' : 'Nuevo objetivo',
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
                    hintText: 'Ej. Meditar 10 minutos cada mañana',
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
                'Descripción (opcional)',
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
                    hintText: 'Detalles opcionales sobre tu meta...',
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
                'Fecha objetivo (opcional)',
                style: FlutterFlowTheme.of(context).labelMedium.override(
                      font: GoogleFonts.outfit(),
                      color: FlutterFlowTheme.of(context).primaryText,
                      letterSpacing: 0.0,
                    ),
              ),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0.0, 4.0, 0.0, 16.0),
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
                            _targetDate != null
                                ? formatDateEs(_targetDate!)
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
                        if (_targetDate != null) ...[
                          Spacer(),
                          InkWell(
                            onTap: () => setState(() => _targetDate = null),
                            child: Icon(
                              Icons.close_rounded,
                              size: 18.0,
                              color:
                                  FlutterFlowTheme.of(context).secondaryText,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
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
                          _isEditing ? 'Guardar cambios' : 'Crear objetivo',
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
