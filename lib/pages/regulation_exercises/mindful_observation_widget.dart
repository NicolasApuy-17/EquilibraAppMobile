import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/flutter_flow/flutter_flow_theme.dart';
import 'exercise_controls.dart';

class _SceneItem {
  const _SceneItem(this.icon, this.align, this.color, this.isTarget);
  final IconData icon;
  final Alignment align;
  final Color color;
  final bool isTarget;
}

class MindfulObservationWidget extends StatefulWidget {
  const MindfulObservationWidget({super.key});

  static String routeName = 'MindfulObservation';
  static String routePath = '/mindfulObservation';

  @override
  State<MindfulObservationWidget> createState() =>
      _MindfulObservationWidgetState();
}

class _MindfulObservationWidgetState extends State<MindfulObservationWidget> {
  final List<_SceneItem> _scene = const [
    _SceneItem(Icons.wb_sunny_rounded, Alignment(0.75, -0.85),
        Color(0xFFF4C15C), true),
    _SceneItem(Icons.cloud_rounded, Alignment(-0.6, -0.7), Colors.white, true),
    _SceneItem(Icons.cloud_rounded, Alignment(0.1, -0.55), Colors.white, true),
    _SceneItem(Icons.cloud_rounded, Alignment(-0.15, -0.9), Colors.white, true),
    _SceneItem(Icons.flutter_dash_rounded, Alignment(0.4, -0.3),
        Color(0xFF6B6B6B), false),
    _SceneItem(Icons.local_florist_rounded, Alignment(-0.7, 0.75),
        Color(0xFFE07AA8), false),
    _SceneItem(Icons.local_florist_rounded, Alignment(-0.3, 0.85),
        Color(0xFFE8C547), false),
    _SceneItem(Icons.local_florist_rounded, Alignment(0.6, 0.8),
        Color(0xFF9B6FD1), false),
  ];

  late Set<int> _targetIndexes;
  final Set<int> _found = {};
  bool _isRunning = false;
  int _elapsedSeconds = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _targetIndexes = {
      for (var i = 0; i < _scene.length; i++)
        if (_scene[i].isTarget) i,
    };
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
      _found.clear();
    });
  }

  void _tap(int index) {
    if (!_isRunning || !_targetIndexes.contains(index)) return;
    setState(() => _found.add(index));
  }

  @override
  Widget build(BuildContext context) {
    final completed = _found.length == _targetIndexes.length;

    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      body: SafeArea(
        child: Column(
          children: [
            ExerciseHeader(title: 'Observación consciente'),
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 12.0),
              child: Text(
                completed
                    ? '¡Encontraste el sol y las ${_targetIndexes.length - 1} nubes!'
                    : _isRunning
                        ? 'Toca el sol y todas las nubes que veas en la escena.'
                        : 'Toca "Iniciar" y observa la escena con calma.',
                textAlign: TextAlign.center,
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.outfit(),
                      color: FlutterFlowTheme.of(context).secondaryText,
                      letterSpacing: 0.0,
                    ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
                child: AspectRatio(
                  aspectRatio: 1.0,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28.0),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFF9FD8E8),
                          Color(0xFFCDEAD3),
                        ],
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Ground / hill.
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            height: 60.0,
                            decoration: BoxDecoration(
                              color: Color(0xFF8FC98F),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(120.0),
                                topRight: Radius.circular(80.0),
                              ),
                            ),
                          ),
                        ),
                        for (var i = 0; i < _scene.length; i++)
                          Align(
                            alignment: _scene[i].align,
                            child: _buildSceneIcon(context, i),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            ExerciseControlBar(
              isRunning: _isRunning,
              progress: _found.length / _targetIndexes.length,
              progressLabel:
                  '${_found.length} de ${_targetIndexes.length} encontrados · ${_elapsedSeconds}s',
              onToggle: _toggleRunning,
              onReset: _reset,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSceneIcon(BuildContext context, int index) {
    final item = _scene[index];
    final isTarget = item.isTarget;
    final isFound = _found.contains(index);

    return InkWell(
      onTap: isTarget ? () => _tap(index) : null,
      customBorder: CircleBorder(),
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Icon(
          item.icon,
          color: isFound ? FlutterFlowTheme.of(context).success : item.color,
          size: item.icon == Icons.wb_sunny_rounded ? 40.0 : 32.0,
        ),
      ),
    );
  }
}
