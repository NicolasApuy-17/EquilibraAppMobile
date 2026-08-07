import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/flutter_flow/flutter_flow_theme.dart';
import 'exercise_controls.dart';

enum _BreathPhase { inhale, hold, exhale }

const _kInhaleSeconds = 4;
const _kHoldSeconds = 4;
const _kExhaleSeconds = 4;
const _kCycleSeconds = _kInhaleSeconds + _kHoldSeconds + _kExhaleSeconds;

const _kDurationOptions = [60, 120, 180];

class BreathingGuidedWidget extends StatefulWidget {
  const BreathingGuidedWidget({super.key});

  static String routeName = 'BreathingGuided';
  static String routePath = '/breathingGuided';

  @override
  State<BreathingGuidedWidget> createState() => _BreathingGuidedWidgetState();
}

class _BreathingGuidedWidgetState extends State<BreathingGuidedWidget> {
  int _totalDuration = 120;
  int _elapsedSeconds = 0;
  bool _isRunning = false;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  int _fineElapsedMs = 0;

  void _toggleRunning() {
    if (_elapsedSeconds >= _totalDuration) return;
    setState(() => _isRunning = !_isRunning);
    if (_isRunning) {
      // Tick at 200ms so the circle animates smoothly, but only advance the
      // whole-second counter every 5th tick (200ms * 5 = 1s).
      var subTick = 0;
      _timer = Timer.periodic(Duration(milliseconds: 200), (_) {
        subTick++;
        setState(() {
          _fineElapsedMs += 200;
          if (subTick % 5 == 0) {
            _elapsedSeconds++;
          }
          if (_elapsedSeconds >= _totalDuration) {
            _isRunning = false;
            _timer?.cancel();
          }
        });
      });
    } else {
      _timer?.cancel();
    }
  }

  void _reset() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _elapsedSeconds = 0;
      _fineElapsedMs = 0;
    });
  }

  _BreathPhase get _phase {
    final secondInCycle = (_fineElapsedMs ~/ 1000) % _kCycleSeconds;
    if (secondInCycle < _kInhaleSeconds) return _BreathPhase.inhale;
    if (secondInCycle < _kInhaleSeconds + _kHoldSeconds) {
      return _BreathPhase.hold;
    }
    return _BreathPhase.exhale;
  }

  double get _phaseProgress {
    final msInCycle = _fineElapsedMs % (_kCycleSeconds * 1000);
    switch (_phase) {
      case _BreathPhase.inhale:
        return msInCycle / (_kInhaleSeconds * 1000);
      case _BreathPhase.hold:
        return (msInCycle - _kInhaleSeconds * 1000) / (_kHoldSeconds * 1000);
      case _BreathPhase.exhale:
        return (msInCycle - (_kInhaleSeconds + _kHoldSeconds) * 1000) /
            (_kExhaleSeconds * 1000);
    }
  }

  double get _circleScale {
    switch (_phase) {
      case _BreathPhase.inhale:
        return 0.55 + 0.45 * _phaseProgress.clamp(0.0, 1.0);
      case _BreathPhase.hold:
        return 1.0;
      case _BreathPhase.exhale:
        return 1.0 - 0.45 * _phaseProgress.clamp(0.0, 1.0);
    }
  }

  String get _phaseLabel {
    switch (_phase) {
      case _BreathPhase.inhale:
        return 'Inhala';
      case _BreathPhase.hold:
        return 'Mantén';
      case _BreathPhase.exhale:
        return 'Exhala';
    }
  }

  bool get _isFinished => _elapsedSeconds >= _totalDuration;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      body: SafeArea(
        child: Column(
          children: [
            ExerciseHeader(title: 'Respiración guiada'),
            if (!_isRunning && _elapsedSeconds == 0)
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
                          label: Text('${seconds ~/ 60} min'),
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
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Transform.scale(
                            scale: _circleScale,
                            child: Container(
                              width: 200.0,
                              height: 200.0,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: FlutterFlowTheme.of(context)
                                    .primary
                                    .withValues(alpha: 0.15),
                                border: Border.all(
                                  color: FlutterFlowTheme.of(context).primary,
                                  width: 3.0,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                _isRunning ? _phaseLabel : 'Lista',
                                style: FlutterFlowTheme.of(context)
                                    .titleLarge
                                    .override(
                                      font: GoogleFonts.outfit(
                                          fontWeight: FontWeight.bold),
                                      color:
                                          FlutterFlowTheme.of(context).primary,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 32.0, 0.0, 0.0),
                            child: Text(
                              _isRunning
                                  ? 'Sigue el ritmo del círculo.'
                                  : 'Toca "Iniciar" para comenzar.',
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
            ExerciseControlBar(
              isRunning: _isRunning,
              progress: _elapsedSeconds / _totalDuration,
              progressLabel: '${_elapsedSeconds}s / ${_totalDuration}s',
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
        Icon(Icons.spa_rounded,
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
          'Respiraste conscientemente durante $_totalDuration segundos.',
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
