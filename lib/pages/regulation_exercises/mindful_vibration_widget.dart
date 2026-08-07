import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '/flutter_flow/flutter_flow_theme.dart';
import 'exercise_controls.dart';

const _kPulseCycleMs = 2000;
const _kDurationOptions = [30, 60, 90];

class MindfulVibrationWidget extends StatefulWidget {
  const MindfulVibrationWidget({super.key});

  static String routeName = 'MindfulVibration';
  static String routePath = '/mindfulVibration';

  @override
  State<MindfulVibrationWidget> createState() => _MindfulVibrationWidgetState();
}

class _MindfulVibrationWidgetState extends State<MindfulVibrationWidget> {
  int _totalDuration = 60;
  int _fineElapsedMs = 0;
  bool _isRunning = false;
  Timer? _timer;
  int _lastPulseCycle = -1;

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
        _maybePulse();
        if (_fineElapsedMs ~/ 1000 >= _totalDuration) {
          setState(() => _isRunning = false);
          _timer?.cancel();
        }
      });
    } else {
      _timer?.cancel();
    }
  }

  void _maybePulse() {
    final cycle = _fineElapsedMs ~/ _kPulseCycleMs;
    if (cycle != _lastPulseCycle) {
      _lastPulseCycle = cycle;
      try {
        HapticFeedback.mediumImpact();
      } catch (_) {
        // Haptics unavailable on this device/platform; safe to ignore.
      }
    }
  }

  void _reset() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _fineElapsedMs = 0;
      _lastPulseCycle = -1;
    });
  }

  double get _pulseScale {
    final msInCycle = _fineElapsedMs % _kPulseCycleMs;
    final half = _kPulseCycleMs / 2;
    final t =
        msInCycle < half ? msInCycle / half : 1.0 - (msInCycle - half) / half;
    return 0.75 + 0.25 * t;
  }

  bool get _isFinished => _fineElapsedMs ~/ 1000 >= _totalDuration;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      body: SafeArea(
        child: Column(
          children: [
            ExerciseHeader(title: 'Vibración consciente'),
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
                          label: Text('${seconds}s'),
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
                            scale: _isRunning ? _pulseScale : 0.85,
                            child: Container(
                              width: 180.0,
                              height: 180.0,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: FlutterFlowTheme.of(context)
                                    .info
                                    .withValues(alpha: 0.15),
                                border: Border.all(
                                  color: FlutterFlowTheme.of(context).info,
                                  width: 3.0,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.vibration_rounded,
                                color: FlutterFlowTheme.of(context).info,
                                size: 48.0,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 32.0, 0.0, 0.0),
                            child: Text(
                              _isRunning
                                  ? 'Siente cada pulso y deja que tu respiración lo acompañe.'
                                  : 'Toca "Iniciar" para comenzar las vibraciones suaves.',
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
        Icon(Icons.check_circle_rounded,
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
          'Completaste $_totalDuration segundos de vibración consciente.',
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
