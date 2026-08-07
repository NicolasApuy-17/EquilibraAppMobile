import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/flutter_flow/flutter_flow_theme.dart';
import 'exercise_controls.dart';

class _ColorOption {
  const _ColorOption(this.name, this.color);
  final String name;
  final Color color;
}

const _kColorOptions = [
  _ColorOption('Azul', Color(0xFF4A90D9)),
  _ColorOption('Rojo', Color(0xFFE05C5C)),
  _ColorOption('Verde', Color(0xFF5FB878)),
  _ColorOption('Amarillo', Color(0xFFE8C547)),
  _ColorOption('Morado', Color(0xFF9B6FD1)),
  _ColorOption('Naranja', Color(0xFFE8965A)),
  _ColorOption('Rosa', Color(0xFFE07AA8)),
  _ColorOption('Café', Color(0xFF9C7A54)),
];

const _kTargetCount = 3;

class FindTheColorWidget extends StatefulWidget {
  const FindTheColorWidget({super.key});

  static String routeName = 'FindTheColor';
  static String routePath = '/findTheColor';

  @override
  State<FindTheColorWidget> createState() => _FindTheColorWidgetState();
}

class _FindTheColorWidgetState extends State<FindTheColorWidget> {
  final _random = Random();
  late _ColorOption _current;
  int _found = 0;
  bool _isRunning = false;
  int _elapsedSeconds = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _current = _kColorOptions[_random.nextInt(_kColorOptions.length)];
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _toggleRunning() {
    setState(() => _isRunning = !_isRunning);
    if (_isRunning) {
      _timer = Timer.periodic(Duration(seconds: 1), (_) {
        setState(() => _elapsedSeconds++);
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
      _found = 0;
    });
  }

  void _newColor() {
    setState(() {
      _ColorOption next;
      do {
        next = _kColorOptions[_random.nextInt(_kColorOptions.length)];
      } while (next.name == _current.name && _kColorOptions.length > 1);
      _current = next;
      _found = 0;
    });
  }

  void _markFound(int index) {
    if (!_isRunning) return;
    setState(() => _found = index + 1 == _found ? index : index + 1);
  }

  @override
  Widget build(BuildContext context) {
    final completed = _found >= _kTargetCount;

    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      body: SafeArea(
        child: Column(
          children: [
            ExerciseHeader(title: 'Encuentra el color'),
            Expanded(
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 160.0,
                      height: 160.0,
                      decoration: BoxDecoration(
                        color: _current.color,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _current.color.withValues(alpha: 0.4),
                            blurRadius: 24.0,
                            spreadRadius: 4.0,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 8.0),
                      child: Text(
                        _current.name,
                        style: FlutterFlowTheme.of(context)
                            .headlineSmall
                            .override(
                              font: GoogleFonts.comfortaa(
                                  fontWeight: FontWeight.bold),
                              color: FlutterFlowTheme.of(context).primaryText,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 24.0),
                      child: Text(
                        completed
                            ? '¡Encontraste $_kTargetCount objetos de color ${_current.name.toLowerCase()}!'
                            : _isRunning
                                ? 'Busca $_kTargetCount objetos de este color a tu alrededor y márcalos.'
                                : 'Toca "Iniciar" y busca objetos de este color.',
                        textAlign: TextAlign.center,
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              font: GoogleFonts.outfit(),
                              color: FlutterFlowTheme.of(context).secondaryText,
                              letterSpacing: 0.0,
                            ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_kTargetCount, (index) {
                        final marked = index < _found;
                        return Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              6.0, 0.0, 6.0, 0.0),
                          child: InkWell(
                            onTap: () => _markFound(index),
                            borderRadius: BorderRadius.circular(24.0),
                            child: Container(
                              width: 48.0,
                              height: 48.0,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: marked
                                    ? _current.color
                                    : FlutterFlowTheme.of(context)
                                        .secondaryBackground,
                                border: Border.all(
                                  color: marked
                                      ? _current.color
                                      : FlutterFlowTheme.of(context).alternate,
                                  width: 1.5,
                                ),
                              ),
                              child: marked
                                  ? Icon(Icons.check_rounded,
                                      color: Colors.white)
                                  : null,
                            ),
                          ),
                        );
                      }),
                    ),
                    Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(0.0, 24.0, 0.0, 0.0),
                      child: TextButton.icon(
                        onPressed: _newColor,
                        icon: Icon(Icons.refresh_rounded,
                            color: FlutterFlowTheme.of(context).primary),
                        label: Text(
                          'Nuevo color',
                          style:
                              FlutterFlowTheme.of(context).labelMedium.override(
                                    font: GoogleFonts.outfit(),
                                    color: FlutterFlowTheme.of(context).primary,
                                    letterSpacing: 0.0,
                                  ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ExerciseControlBar(
              isRunning: _isRunning,
              progress: _found / _kTargetCount,
              progressLabel:
                  '$_found de $_kTargetCount encontrados · ${_elapsedSeconds}s',
              onToggle: _toggleRunning,
              onReset: _reset,
            ),
          ],
        ),
      ),
    );
  }
}
