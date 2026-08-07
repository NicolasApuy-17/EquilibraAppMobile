import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/flutter_flow/flutter_flow_theme.dart';
import 'exercise_controls.dart';

class _GroundingStep {
  const _GroundingStep(this.count, this.sense, this.icon, this.instruction);
  final int count;
  final String sense;
  final IconData icon;
  final String instruction;
}

const _kGroundingSteps = [
  _GroundingStep(5, 'ves', Icons.visibility_rounded,
      'Nombra 5 cosas que puedes ver a tu alrededor.'),
  _GroundingStep(
      4, 'tocas', Icons.pan_tool_rounded, 'Nombra 4 cosas que puedes tocar.'),
  _GroundingStep(3, 'escuchas', Icons.hearing_rounded,
      'Nombra 3 cosas que puedes escuchar.'),
  _GroundingStep(2, 'hueles', Icons.local_florist_rounded,
      'Nombra 2 cosas que puedes oler.'),
  _GroundingStep(1, 'saboreas', Icons.restaurant_rounded,
      'Nombra 1 cosa que puedes saborear.'),
];

class Grounding54321Widget extends StatefulWidget {
  const Grounding54321Widget({super.key});

  static String routeName = 'Grounding54321';
  static String routePath = '/grounding54321';

  @override
  State<Grounding54321Widget> createState() => _Grounding54321WidgetState();
}

class _Grounding54321WidgetState extends State<Grounding54321Widget> {
  int _stepIndex = 0;
  late List<bool> _marked;
  bool _isRunning = false;
  int _elapsedSeconds = 0;
  Timer? _timer;
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    _marked = List<bool>.filled(_kGroundingSteps[0].count, false);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (_) {
      setState(() => _elapsedSeconds++);
    });
  }

  void _toggleRunning() {
    setState(() => _isRunning = !_isRunning);
    if (_isRunning) {
      _startTimer();
    } else {
      _timer?.cancel();
    }
  }

  void _reset() {
    _timer?.cancel();
    setState(() {
      _stepIndex = 0;
      _marked = List<bool>.filled(_kGroundingSteps[0].count, false);
      _isRunning = false;
      _elapsedSeconds = 0;
      _completed = false;
    });
  }

  void _mark(int index) {
    if (!_isRunning || _completed) return;
    setState(() => _marked[index] = !_marked[index]);
  }

  void _next() {
    if (_stepIndex == _kGroundingSteps.length - 1) {
      setState(() => _completed = true);
      _timer?.cancel();
      setState(() => _isRunning = false);
      return;
    }
    setState(() {
      _stepIndex++;
      _marked = List<bool>.filled(_kGroundingSteps[_stepIndex].count, false);
    });
  }

  double get _progress {
    final totalSlots = _kGroundingSteps.fold<int>(0, (sum, s) => sum + s.count);
    final priorSlots = _kGroundingSteps
        .take(_stepIndex)
        .fold<int>(0, (sum, s) => sum + s.count);
    final currentDone = _marked.where((m) => m).length;
    return (priorSlots + currentDone) / totalSlots;
  }

  @override
  Widget build(BuildContext context) {
    final step = _kGroundingSteps[_stepIndex];
    final allMarked = _marked.every((m) => m);

    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      body: SafeArea(
        child: Column(
          children: [
            ExerciseHeader(title: 'Técnica 5-4-3-2-1'),
            Expanded(
              child: _completed
                  ? _buildCompletedState(context)
                  : _buildStepState(context, step, allMarked),
            ),
            ExerciseControlBar(
              isRunning: _isRunning,
              progress: _completed ? 1.0 : _progress,
              progressLabel: _completed
                  ? 'Completado en ${_elapsedSeconds}s'
                  : 'Paso ${_stepIndex + 1} de ${_kGroundingSteps.length} · ${_elapsedSeconds}s',
              onToggle: _toggleRunning,
              onReset: _reset,
              toggleEnabled: !_completed,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepState(
      BuildContext context, _GroundingStep step, bool allMarked) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(step.icon,
              color: FlutterFlowTheme.of(context).primary, size: 56.0),
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(0.0, 24.0, 0.0, 8.0),
            child: Text(
              step.instruction,
              textAlign: TextAlign.center,
              style: FlutterFlowTheme.of(context).headlineSmall.override(
                    font: GoogleFonts.comfortaa(fontWeight: FontWeight.bold),
                    color: FlutterFlowTheme.of(context).primaryText,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 32.0),
            child: Text(
              _isRunning
                  ? 'Toca cada número a medida que identifiques algo que ${step.sense}.'
                  : 'Toca "Iniciar" para comenzar.',
              textAlign: TextAlign.center,
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.outfit(),
                    color: FlutterFlowTheme.of(context).secondaryText,
                    letterSpacing: 0.0,
                  ),
            ),
          ),
          Wrap(
            spacing: 12.0,
            runSpacing: 12.0,
            alignment: WrapAlignment.center,
            children: List.generate(step.count, (index) {
              final marked = _marked[index];
              return InkWell(
                onTap: () => _mark(index),
                borderRadius: BorderRadius.circular(28.0),
                child: Container(
                  width: 56.0,
                  height: 56.0,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: marked
                        ? FlutterFlowTheme.of(context).primary
                        : FlutterFlowTheme.of(context).secondaryBackground,
                    border: Border.all(
                      color: marked
                          ? FlutterFlowTheme.of(context).primary
                          : FlutterFlowTheme.of(context).alternate,
                      width: 1.5,
                    ),
                  ),
                  child: marked
                      ? Icon(Icons.check_rounded,
                          color: FlutterFlowTheme.of(context).onPrimary)
                      : Text(
                          '${index + 1}',
                          style: FlutterFlowTheme.of(context)
                              .titleMedium
                              .override(
                                font: GoogleFonts.outfit(
                                    fontWeight: FontWeight.bold),
                                color: FlutterFlowTheme.of(context).primaryText,
                                letterSpacing: 0.0,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                ),
              );
            }),
          ),
          if (allMarked)
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(0.0, 24.0, 0.0, 0.0),
              child: ElevatedButton(
                onPressed: _next,
                style: ElevatedButton.styleFrom(
                  backgroundColor: FlutterFlowTheme.of(context).primary,
                  padding:
                      EdgeInsets.symmetric(horizontal: 32.0, vertical: 14.0),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24.0)),
                  elevation: 0,
                ),
                child: Text(
                  _stepIndex == _kGroundingSteps.length - 1
                      ? 'Finalizar'
                      : 'Siguiente',
                  style: FlutterFlowTheme.of(context).labelMedium.override(
                        font: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                        color: FlutterFlowTheme.of(context).onPrimary,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCompletedState(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.self_improvement_rounded,
              color: FlutterFlowTheme.of(context).success, size: 56.0),
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 0.0, 8.0),
            child: Text(
              '¡Bien hecho!',
              style: FlutterFlowTheme.of(context).headlineSmall.override(
                    font: GoogleFonts.comfortaa(fontWeight: FontWeight.bold),
                    color: FlutterFlowTheme.of(context).primaryText,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          Text(
            'Recorriste tus 5 sentidos para volver al presente.',
            textAlign: TextAlign.center,
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.outfit(),
                  color: FlutterFlowTheme.of(context).secondaryText,
                  letterSpacing: 0.0,
                ),
          ),
        ],
      ),
    );
  }
}
