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

/// One round of the exercise: its own scene, colors and instructions. Each
/// level is a little harder than the last -- more items, and by level 3 a
/// handful of decoys share the target's shape (only the color gives them
/// away), so finding them takes real, sustained attention rather than a
/// single glance.
class _Level {
  const _Level({
    required this.title,
    required this.instruction,
    required this.targetWord,
    required this.skyColors,
    required this.groundColor,
    required this.items,
  });

  final String title;
  final String instruction;
  final String targetWord;
  final List<Color> skyColors;
  final Color groundColor;
  final List<_SceneItem> items;
}

const _kLevels = [
  _Level(
    title: 'Cielo despejado',
    instruction:
        'Respira hondo dos veces. Luego toca el sol y todas las nubes que veas, sin apurarte.',
    targetWord: 'el sol y las nubes',
    skyColors: [Color(0xFF9FD8E8), Color(0xFFCDEAD3)],
    groundColor: Color(0xFF8FC98F),
    items: [
      _SceneItem(Icons.wb_sunny_rounded, Alignment(0.75, -0.85),
          Color(0xFFF4C15C), true),
      _SceneItem(
          Icons.cloud_rounded, Alignment(-0.6, -0.7), Colors.white, true),
      _SceneItem(
          Icons.cloud_rounded, Alignment(0.1, -0.55), Colors.white, true),
      _SceneItem(
          Icons.cloud_rounded, Alignment(-0.15, -0.9), Colors.white, true),
      _SceneItem(Icons.flutter_dash_rounded, Alignment(0.4, -0.3),
          Color(0xFF6B6B6B), false),
      _SceneItem(Icons.local_florist_rounded, Alignment(-0.7, 0.75),
          Color(0xFFE07AA8), false),
      _SceneItem(Icons.local_florist_rounded, Alignment(-0.3, 0.85),
          Color(0xFFE8C547), false),
      _SceneItem(Icons.local_florist_rounded, Alignment(0.6, 0.8),
          Color(0xFF9B6FD1), false),
    ],
  ),
  _Level(
    title: 'Jardín con mariposas',
    instruction:
        'Ahora hay más por observar. Busca las 5 mariposas escondidas entre las flores y las hojas.',
    targetWord: 'las 5 mariposas',
    skyColors: [Color(0xFFFCE9D0), Color(0xFFD8E8CD)],
    groundColor: Color(0xFF7FB77E),
    items: [
      _SceneItem(Icons.flutter_dash_rounded, Alignment(-0.8, -0.8),
          Color(0xFFCB6CE6), true),
      _SceneItem(Icons.flutter_dash_rounded, Alignment(0.7, -0.6),
          Color(0xFFCB6CE6), true),
      _SceneItem(Icons.flutter_dash_rounded, Alignment(-0.2, -0.3),
          Color(0xFFCB6CE6), true),
      _SceneItem(Icons.flutter_dash_rounded, Alignment(0.3, 0.1),
          Color(0xFFCB6CE6), true),
      _SceneItem(Icons.flutter_dash_rounded, Alignment(-0.6, 0.5),
          Color(0xFFCB6CE6), true),
      _SceneItem(Icons.local_florist_rounded, Alignment(0.8, 0.7),
          Color(0xFFE07AA8), false),
      _SceneItem(Icons.local_florist_rounded, Alignment(-0.85, 0.15),
          Color(0xFFE8C547), false),
      _SceneItem(Icons.local_florist_rounded, Alignment(0.15, 0.85),
          Color(0xFF9B6FD1), false),
      _SceneItem(Icons.local_florist_rounded, Alignment(0.6, -0.85),
          Color(0xFFEA8B5C), false),
      _SceneItem(
          Icons.eco_rounded, Alignment(-0.35, 0.75), Color(0xFF4D8B52), false),
      _SceneItem(
          Icons.eco_rounded, Alignment(0.85, -0.1), Color(0xFF4D8B52), false),
    ],
  ),
  _Level(
    title: 'Cielo nocturno',
    instruction:
        'Último nivel. Encuentra las 6 estrellas doradas -- cuidado, algunos destellos son de otro color, no son estrellas.',
    targetWord: 'las 6 estrellas doradas',
    skyColors: [Color(0xFF1B2A4A), Color(0xFF3B4B78)],
    groundColor: Color(0xFF2A3B2E),
    items: [
      _SceneItem(
          Icons.star_rounded, Alignment(-0.8, -0.85), Color(0xFFF5E7A3), true),
      _SceneItem(
          Icons.star_rounded, Alignment(0.2, -0.9), Color(0xFFF5E7A3), true),
      _SceneItem(
          Icons.star_rounded, Alignment(0.75, -0.5), Color(0xFFF5E7A3), true),
      _SceneItem(
          Icons.star_rounded, Alignment(-0.4, -0.3), Color(0xFFF5E7A3), true),
      _SceneItem(
          Icons.star_rounded, Alignment(0.5, 0.1), Color(0xFFF5E7A3), true),
      _SceneItem(
          Icons.star_rounded, Alignment(-0.75, 0.35), Color(0xFFF5E7A3), true),
      _SceneItem(Icons.star_rounded, Alignment(0.05, -0.55),
          Color(0xFFE8935B), false),
      _SceneItem(Icons.star_rounded, Alignment(-0.15, -0.85),
          Color(0xFFE8935B), false),
      _SceneItem(Icons.star_rounded, Alignment(0.85, -0.15),
          Color(0xFFE8935B), false),
      _SceneItem(
          Icons.star_rounded, Alignment(-0.55, 0.05), Color(0xFFE8935B), false),
      _SceneItem(Icons.nightlight_round, Alignment(0.7, 0.75),
          Color(0xFFE7E7EF), false),
      _SceneItem(Icons.flutter_dash_rounded, Alignment(-0.3, 0.7),
          Color(0xFF6B5C99), false),
      _SceneItem(Icons.flutter_dash_rounded, Alignment(0.2, 0.85),
          Color(0xFF6B5C99), false),
    ],
  ),
];

class MindfulObservationWidget extends StatefulWidget {
  const MindfulObservationWidget({super.key});

  static String routeName = 'MindfulObservation';
  static String routePath = '/mindfulObservation';

  @override
  State<MindfulObservationWidget> createState() =>
      _MindfulObservationWidgetState();
}

class _MindfulObservationWidgetState extends State<MindfulObservationWidget> {
  int _levelIndex = 0;
  late Set<int> _targetIndexes;
  final Set<int> _found = {};
  bool _isRunning = false;
  int _elapsedSeconds = 0;
  int _totalElapsedSeconds = 0;
  bool _allLevelsDone = false;
  Timer? _timer;

  _Level get _level => _kLevels[_levelIndex];
  bool get _levelComplete => _found.length == _targetIndexes.length;
  bool get _isLastLevel => _levelIndex == _kLevels.length - 1;

  @override
  void initState() {
    super.initState();
    _targetIndexes = _computeTargets(_level);
  }

  Set<int> _computeTargets(_Level level) => {
        for (var i = 0; i < level.items.length; i++)
          if (level.items[i].isTarget) i,
      };

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

  /// Restarts only the level currently in progress (kept as the plain
  /// "Reiniciar" action, same as every other grounding exercise).
  void _reset() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _elapsedSeconds = 0;
      _found.clear();
    });
  }

  /// Starts over from level 1, used only once every level is done.
  void _restartAll() {
    _timer?.cancel();
    setState(() {
      _levelIndex = 0;
      _targetIndexes = _computeTargets(_level);
      _isRunning = false;
      _elapsedSeconds = 0;
      _totalElapsedSeconds = 0;
      _allLevelsDone = false;
      _found.clear();
    });
  }

  void _nextLevel() {
    _timer?.cancel();
    setState(() {
      _totalElapsedSeconds += _elapsedSeconds;
      if (_isLastLevel) {
        _allLevelsDone = true;
        return;
      }
      _levelIndex++;
      _targetIndexes = _computeTargets(_level);
      _isRunning = false;
      _elapsedSeconds = 0;
      _found.clear();
    });
  }

  void _tap(int index) {
    if (!_isRunning || !_targetIndexes.contains(index)) return;
    setState(() => _found.add(index));
    if (_found.length == _targetIndexes.length) {
      _timer?.cancel();
      setState(() => _isRunning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      body: SafeArea(
        child: Column(
          children: [
            ExerciseHeader(
              title: _allLevelsDone
                  ? 'Observación consciente'
                  : 'Nivel ${_levelIndex + 1} de ${_kLevels.length} · ${_level.title}',
            ),
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 12.0),
              child: Text(
                _allLevelsDone
                    ? '¡Completaste los ${_kLevels.length} niveles! Practicar así, con calma, entrena tu atención plena.'
                    : _levelComplete
                        ? '¡Bien hecho! Encontraste ${_targetIndexes.length} de ${_targetIndexes.length}.'
                        : _isRunning
                            ? 'Busca ${_level.targetWord} en la escena.'
                            : _level.instruction,
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
                child: _allLevelsDone
                    ? _buildCompletionPanel(context)
                    : AspectRatio(
                        aspectRatio: 1.0,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(28.0),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: _level.skyColors,
                            ),
                          ),
                          child: Stack(
                            children: [
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: Container(
                                  height: 60.0,
                                  decoration: BoxDecoration(
                                    color: _level.groundColor,
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(120.0),
                                      topRight: Radius.circular(80.0),
                                    ),
                                  ),
                                ),
                              ),
                              for (var i = 0; i < _level.items.length; i++)
                                Align(
                                  alignment: _level.items[i].align,
                                  child: _buildSceneIcon(context, i),
                                ),
                            ],
                          ),
                        ),
                      ),
              ),
            ),
            if (_allLevelsDone)
              Padding(
                padding:
                    EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 24.0),
                child: ElevatedButton.icon(
                  onPressed: _restartAll,
                  icon: Icon(Icons.refresh_rounded,
                      color: FlutterFlowTheme.of(context).onPrimary),
                  label: Text(
                    'Comenzar de nuevo',
                    style: FlutterFlowTheme.of(context).labelMedium.override(
                          font: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                          color: FlutterFlowTheme.of(context).onPrimary,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: FlutterFlowTheme.of(context).primary,
                    padding: EdgeInsets.symmetric(vertical: 14.0),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24.0)),
                    elevation: 0,
                  ),
                ),
              )
            else
              ExerciseControlBar(
                isRunning: _isRunning,
                progress: _found.length / _targetIndexes.length,
                progressLabel: _levelComplete
                    ? 'Nivel ${_levelIndex + 1} completo · ${_elapsedSeconds}s'
                    : '${_found.length} de ${_targetIndexes.length} encontrados · ${_elapsedSeconds}s',
                onToggle: _levelComplete ? _nextLevel : _toggleRunning,
                onReset: _reset,
                toggleLabelOverride: _levelComplete
                    ? (_isLastLevel ? 'Finalizar' : 'Siguiente nivel')
                    : null,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletionPanel(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(28.0),
      ),
      padding: EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.emoji_events_rounded, size: 56.0, color: theme.primary),
          SizedBox(height: 16.0),
          Text(
            '¡Ejercicio completado!',
            textAlign: TextAlign.center,
            style: theme.titleMedium.override(
              font: GoogleFonts.outfit(fontWeight: FontWeight.bold),
              color: theme.primaryText,
              letterSpacing: 0.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.0),
          Text(
            'Recorriste los ${_kLevels.length} niveles en $_totalElapsedSeconds segundos de observación consciente.',
            textAlign: TextAlign.center,
            style: theme.bodyMedium.override(
              font: GoogleFonts.outfit(),
              color: theme.secondaryText,
              letterSpacing: 0.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSceneIcon(BuildContext context, int index) {
    final item = _level.items[index];
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
