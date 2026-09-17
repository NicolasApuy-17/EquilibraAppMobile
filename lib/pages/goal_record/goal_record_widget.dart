import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/utils/date_format_es.dart';
import '/utils/error_messages.dart';
import '/utils/validators.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Full-screen "Registrar objetivo": the third option from the "Registrar"
/// hub, alongside registering an emotion or a behavior. A goal is defined
/// once here -- title, optional description/target date, and the ordered
/// list of steps needed to reach it -- and afterwards only lives on in
/// "Mis registros" > Objetivos, where each step gets checked off
/// individually (see `_GoalRecordCard` in `my_records_widget.dart`).
class GoalRecordWidget extends StatefulWidget {
  const GoalRecordWidget({super.key});

  static String routeName = 'GoalRecord';
  static String routePath = '/goalRecord';

  @override
  State<GoalRecordWidget> createState() => _GoalRecordWidgetState();
}

class _GoalRecordWidgetState extends State<GoalRecordWidget> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final List<TextEditingController> _stepControllers = [
    TextEditingController(),
  ];
  DateTime? _targetDate;
  bool _isSaving = false;
  String? _errorText;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    for (final controller in _stepControllers) {
      controller.dispose();
    }
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
    if (picked != null) setState(() => _targetDate = picked);
  }

  void _addStep() {
    setState(() => _stepControllers.add(TextEditingController()));
  }

  void _removeStep(int index) {
    setState(() => _stepControllers.removeAt(index).dispose());
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
    final descriptionError = validateFreeText(
      _descriptionController.text,
      maxLength: 500,
      required: false,
    );
    if (descriptionError != null) {
      setState(() => _errorText = descriptionError);
      return;
    }
    final dateError = validateGoalDate(_targetDate);
    if (dateError != null) {
      setState(() => _errorText = dateError);
      return;
    }
    final stepTitles = _stepControllers
        .map((c) => normalizeWhitespace(c.text))
        .where((t) => t.isNotEmpty)
        .toList();
    if (stepTitles.isEmpty) {
      setState(() =>
          _errorText = 'Agrega al menos un paso para llegar a tu objetivo.');
      return;
    }

    setState(() {
      _isSaving = true;
      _errorText = null;
    });
    try {
      await GoalsRecord.collection.doc().set(createGoalsRecordData(
            title: normalizeWhitespace(_titleController.text),
            description: _descriptionController.text.trim(),
            targetDate: _targetDate,
            completed: false,
            userRef: currentUserReference,
            createdTime: getCurrentTimestamp,
            steps: stepTitles.map((t) => GoalStep(title: t)).toList(),
          ));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Objetivo registrado.')),
      );
      setState(() {
        _titleController.clear();
        _descriptionController.clear();
        _targetDate = null;
        for (final controller in _stepControllers) {
          controller.dispose();
        }
        _stepControllers
          ..clear()
          ..add(TextEditingController());
      });
    } catch (_) {
      if (mounted) {
        setState(
            () => _errorText = genericSaveErrorMessage('registrar el objetivo'));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        backgroundColor: theme.primaryBackground,
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
                      icon: Icon(Icons.arrow_back_rounded,
                          color: theme.primaryText, size: 24.0),
                      onPressed: () => context.safePop(),
                    ),
                    Expanded(
                      child: Text(
                        'Registrar objetivo',
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.titleLarge.override(
                          font: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                          color: theme.primaryText,
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
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Título',
                        style: theme.labelMedium.override(
                          font: GoogleFonts.outfit(),
                          color: theme.primaryText,
                          letterSpacing: 0.0,
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(0.0, 4.0, 0.0, 12.0),
                        child: TextField(
                          controller: _titleController,
                          decoration: InputDecoration(
                            hintText: 'Ej. Meditar 10 minutos cada mañana',
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12.0, vertical: 10.0),
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
                      Text(
                        'Descripción (opcional)',
                        style: theme.labelMedium.override(
                          font: GoogleFonts.outfit(),
                          color: theme.primaryText,
                          letterSpacing: 0.0,
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(0.0, 4.0, 0.0, 12.0),
                        child: TextField(
                          controller: _descriptionController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: 'Detalles opcionales sobre tu meta...',
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12.0, vertical: 10.0),
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
                      Text(
                        'Fecha objetivo (opcional)',
                        style: theme.labelMedium.override(
                          font: GoogleFonts.outfit(),
                          color: theme.primaryText,
                          letterSpacing: 0.0,
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(0.0, 4.0, 0.0, 20.0),
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
                                Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      8.0, 0.0, 0.0, 0.0),
                                  child: Text(
                                    _targetDate != null
                                        ? formatDateEs(_targetDate!)
                                        : 'Sin fecha (toca para elegir)',
                                    style: theme.bodyMedium.override(
                                      font: GoogleFonts.outfit(),
                                      color: theme.primaryText,
                                      letterSpacing: 0.0,
                                    ),
                                  ),
                                ),
                                if (_targetDate != null) ...[
                                  const Spacer(),
                                  InkWell(
                                    onTap: () =>
                                        setState(() => _targetDate = null),
                                    child: Icon(Icons.close_rounded,
                                        size: 18.0, color: theme.secondaryText),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                      Text(
                        'Pasos para lograrlo',
                        style: theme.labelMedium.override(
                          font: GoogleFonts.outfit(),
                          color: theme.primaryText,
                          letterSpacing: 0.0,
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(0.0, 4.0, 0.0, 4.0),
                        child: Text(
                          'Divide tu meta en pasos concretos; podrás ir '
                          'marcándolos como cumplidos desde "Mis registros".',
                          style: theme.bodySmall.override(
                            font: GoogleFonts.outfit(),
                            color: theme.secondaryText,
                            letterSpacing: 0.0,
                          ),
                        ),
                      ),
                      for (var i = 0; i < _stepControllers.length; i++)
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              0.0, 8.0, 0.0, 0.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _stepControllers[i],
                                  decoration: InputDecoration(
                                    hintText: 'Paso ${i + 1}',
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 12.0, vertical: 10.0),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                      borderSide:
                                          BorderSide(color: theme.alternate),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                      borderSide:
                                          BorderSide(color: theme.primary),
                                    ),
                                  ),
                                ),
                              ),
                              if (_stepControllers.length > 1)
                                IconButton(
                                  onPressed: () => _removeStep(i),
                                  icon: Icon(Icons.remove_circle_outline_rounded,
                                      color: theme.secondaryText, size: 20.0),
                                ),
                            ],
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            0.0, 8.0, 0.0, 20.0),
                        child: OutlinedButton.icon(
                          onPressed: _addStep,
                          icon: const Icon(Icons.add_rounded, size: 18.0),
                          label: const Text('Agregar paso'),
                        ),
                      ),
                      if (_errorText != null)
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              0.0, 0.0, 0.0, 12.0),
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
                                    valueColor:
                                        AlwaysStoppedAnimation(theme.onPrimary),
                                  ),
                                )
                              : Text(
                                  'Registrar objetivo',
                                  style: theme.labelMedium.override(
                                    font: GoogleFonts.outfit(
                                        fontWeight: FontWeight.bold),
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
            ],
          ),
        ),
      ),
    );
  }
}
