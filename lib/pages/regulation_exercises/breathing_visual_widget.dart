import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/flutter_flow/flutter_flow_theme.dart';
import 'exercise_controls.dart';

const _kPhaseSeconds = 4;
const _kBoxCycleSeconds = _kPhaseSeconds * 4;
const _kDurationOptions = [64, 128, 192];
const _kPhaseLabels = ['Inhala', 'Mantén', 'Exhala', 'Mantén'];

class BreathingVisualWidget extends StatefulWidget {
  const BreathingVisualWidget({super.key});

  static String routeName = 'BreathingVisual';
  static String routePath = '/breathingVisual';

  @override
  State<BreathingVisualWidget> createState() => _BreathingVisualWidgetState();
}

class _BreathingVisualWidgetState extends State<BreathingVisualWidget> {
  int _totalDuration = 128;
  int _fineElapsedMs = 0;
  bool _isRunning = false;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _toggleRunning() {
    if (_fineElapsedMs ~/ 1000 >= _totalDuration) return;
    setState(() => _isRunning = !_isRunning);
    if (_isRunning) {
      _timer = Timer.periodic(Duration(milliseconds: 100), (_) {
        setState(() => _fineElapsedMs += 100);
        if (_fineElapsedMs ~/ 1000 >= _totalDuration) {
          setState(() => _isRunning = false);
          _timer?.cancel();
        }
      });
    } else {
      _timer?.cancel();
    }
  }

  void _reset() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _fineElapsedMs = 0;
    });
  }

  int get _phaseIndex =>
      ((_fineElapsedMs ~/ 1000) % _kBoxCycleSeconds) ~/ _kPhaseSeconds;

  double get _phaseProgress {
    final msInPhase = _fineElapsedMs % (_kPhaseSeconds * 1000);
    return msInPhase / (_kPhaseSeconds * 1000);
  }

  Alignment get _dotAlignment {
    final t = _phaseProgress.clamp(0.0, 1.0);
    switch (_phaseIndex) {
      case 0: // left side, bottom -> top
        return Alignment(-1.0, 1.0 - 2.0 * t);
      case 1: // top side, left -> right
        return Alignment(-1.0 + 2.0 * t, -1.0);
      case 2: // right side, top -> bottom
        return Alignment(1.0, -1.0 + 2.0 * t);
      default: // bottom side, right -> left
        return Alignment(1.0 - 2.0 * t, 1.0);
    }
  }

  int get _phaseSecondsLeft =>
      _kPhaseSeconds - (_fineElapsedMs ~/ 1000 % _kPhaseSeconds);

  bool get _isFinished => _fineElapsedMs ~/ 1000 >= _totalDuration;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      body: SafeArea(
        child: Column(
          children: [
            ExerciseHeader(title: 'Respiración cuadrada'),
            if (!_isRunning && _fineElapsedMs == 0)
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (final seconds in _kDurationOptions)
                      Padding(
                        padding:
                            EdgeInsetsDirectional.fromSTEB(4.0, 0.0, 4.0, 0.0),
                        child: ChoiceChip(
                          label: Text('${seconds ~/ _kBoxCycleSeconds} ciclos'),
                          selected: _totalDuration == seconds,
                          onSelected: (_) =>
                              setState(() => _totalDuration = seconds),
                        ),
                      ),
                  ],
                ),
              ),
            Expanded(
              child: Center(
                child: _isFinished
                    ? _buildFinished(context)
                    : Padding(
                        padding: EdgeInsets.symmetric(horizontal: 32.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AspectRatio(
                              aspectRatio: 1.0,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: FlutterFlowTheme.of(context)
                                            .alternate,
                                        width: 2.0,
                                      ),
                                      borderRadius: BorderRadius.circular(16.0),
                                    ),
                                  ),
                                  Text(
                                    _isRunning
                                        ? '${_kPhaseLabels[_phaseIndex]}\n$_phaseSecondsLeft'
                                        : 'Lista',
                                    textAlign: TextAlign.center,
                                    style: FlutterFlowTheme.of(context)
                                        .titleLarge
                                        .override(
                                          font: GoogleFonts.outfit(
                                              fontWeight: FontWeight.bold),
                                          color: FlutterFlowTheme.of(context)
                                              .primary,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  if (_isRunning)
                                    Align(
                                      alignment: _dotAlignment,
                                      child: Container(
                                        width: 20.0,
                                        height: 20.0,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: FlutterFlowTheme.of(context)
                                              .primary,
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primary
                                                      .withValues(alpha: 0.5),
                                              blurRadius: 8.0,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  0.0, 24.0, 0.0, 0.0),
                              child: Text(
                                _isRunning
                                    ? 'Sigue el punto alrededor del cuadrado.'
                                    : 'Toca "Iniciar" para comenzar la respiración cuadrada (4-4-4-4).',
                                textAlign: TextAlign.center,
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
                          ],
                        ),
                      ),
              ),
            ),
            ExerciseControlBar(
              isRunning: _isRunning,
              progress: (_fineElapsedMs / 1000) / _totalDuration,
              progressLabel: '${_fineElapsedMs ~/ 1000}s / ${_totalDuration}s',
              onToggle: _toggleRunning,
              onReset: _reset,
              toggleEnabled: !_isFinished,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinished(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.crop_square_rounded,
            color: FlutterFlowTheme.of(context).success, size: 56.0),
        Padding(
          padding: EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 0.0, 8.0),
          child: Text(
            'Sesión completada',
            style: FlutterFlowTheme.of(context).headlineSmall.override(
                  font: GoogleFonts.comfortaa(fontWeight: FontWeight.bold),
                  color: FlutterFlowTheme.of(context).primaryText,
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        Text(
          'Completaste ${_totalDuration ~/ _kBoxCycleSeconds} ciclos de respiración cuadrada.',
          textAlign: TextAlign.center,
          style: FlutterFlowTheme.of(context).bodyMedium.override(
                font: GoogleFonts.outfit(),
                color: FlutterFlowTheme.of(context).secondaryText,
                letterSpacing: 0.0,
              ),
        ),
      ],
    );
  }
}
