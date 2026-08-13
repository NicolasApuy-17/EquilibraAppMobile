import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';

import '/flutter_flow/flutter_flow_theme.dart';
import 'exercise_controls.dart';

class _AmbientSound {
  const _AmbientSound(this.name, this.assetPath, this.icon);
  final String name;
  final String assetPath;
  final IconData icon;
}

const _kAmbientSounds = [
  _AmbientSound(
      'Lluvia', 'assets/audios/ambient/rain.wav', Icons.water_drop_rounded),
  _AmbientSound(
      'Bosque', 'assets/audios/ambient/forest.wav', Icons.forest_rounded),
  _AmbientSound('Mar', 'assets/audios/ambient/sea.wav', Icons.waves_rounded),
  _AmbientSound('Viento', 'assets/audios/ambient/wind.wav', Icons.air_rounded),
];

class SoundFocusWidget extends StatefulWidget {
  const SoundFocusWidget({super.key});

  static String routeName = 'SoundFocus';
  static String routePath = '/soundFocus';

  @override
  State<SoundFocusWidget> createState() => _SoundFocusWidgetState();
}

class _SoundFocusWidgetState extends State<SoundFocusWidget> {
  final _player = AudioPlayer();
  _AmbientSound _selected = _kAmbientSounds.first;
  bool _isPlaying = false;
  bool _isLoading = false;
  String? _errorText;
  Duration _position = Duration.zero;
  Duration? _duration;

  @override
  void initState() {
    super.initState();
    _player.playerStateStream.listen((state) {
      if (!mounted) return;
      setState(() => _isPlaying = state.playing);
    });
    _player.positionStream.listen((position) {
      if (!mounted) return;
      setState(() => _position = position);
    });
    _player.durationStream.listen((duration) {
      if (!mounted) return;
      setState(() => _duration = duration);
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _selectSound(_AmbientSound sound) async {
    setState(() {
      _selected = sound;
      _errorText = null;
      _position = Duration.zero;
      _duration = null;
    });
    await _player.stop();
  }

  Future<void> _togglePlay() async {
    if (_isPlaying) {
      await _player.pause();
      return;
    }
    setState(() {
      _isLoading = true;
      _errorText = null;
    });
    try {
      if (_player.audioSource == null || _errorText != null) {
        await _player.setAsset(_selected.assetPath);
        await _player.setLoopMode(LoopMode.one);
      }
      await _player.play();
    } catch (e) {
      setState(() {
        _errorText =
            'No se pudo cargar "${_selected.name}". Agrega el archivo de audio en ${_selected.assetPath}.';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _reset() async {
    await _player.stop();
    await _player.seek(Duration.zero);
    setState(() {
      _position = Duration.zero;
      _errorText = null;
    });
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final duration = _duration;
    final progress = (duration != null && duration.inMilliseconds > 0)
        ? _position.inMilliseconds / duration.inMilliseconds
        : null;

    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      body: SafeArea(
        child: Column(
          children: [
            ExerciseHeader(title: 'Atención auditiva'),
            Expanded(
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Elige un sonido y cierra los ojos. Presta atención solo a lo que escuchas.',
                      textAlign: TextAlign.center,
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.outfit(),
                            color: FlutterFlowTheme.of(context).secondaryText,
                            letterSpacing: 0.0,
                          ),
                    ),
                    Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(0.0, 24.0, 0.0, 24.0),
                      child: Wrap(
                        spacing: 12.0,
                        runSpacing: 12.0,
                        alignment: WrapAlignment.center,
                        children: [
                          for (final sound in _kAmbientSounds)
                            InkWell(
                              onTap: () => _selectSound(sound),
                              borderRadius: BorderRadius.circular(20.0),
                              child: Container(
                                width: 96.0,
                                padding: EdgeInsets.symmetric(vertical: 16.0),
                                decoration: BoxDecoration(
                                  color: _selected.name == sound.name
                                      ? FlutterFlowTheme.of(context).primary10
                                      : FlutterFlowTheme.of(context)
                                          .secondaryBackground,
                                  borderRadius: BorderRadius.circular(20.0),
                                  border: Border.all(
                                    color: _selected.name == sound.name
                                        ? FlutterFlowTheme.of(context).primary
                                        : FlutterFlowTheme.of(context)
                                            .alternate,
                                  ),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      sound.icon,
                                      color: _selected.name == sound.name
                                          ? FlutterFlowTheme.of(context).primary
                                          : FlutterFlowTheme.of(context)
                                              .secondaryText,
                                      size: 28.0,
                                    ),
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          0.0, 8.0, 0.0, 0.0),
                                      child: Text(
                                        sound.name,
                                        style: FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .override(
                                              font: GoogleFonts.outfit(),
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primaryText,
                                              letterSpacing: 0.0,
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
                    if (_isLoading)
                      Padding(
                        padding:
                            EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 16.0),
                        child: SizedBox(
                          width: 24.0,
                          height: 24.0,
                          child: CircularProgressIndicator(strokeWidth: 2.0),
                        ),
                      ),
                    if (_errorText != null)
                      Padding(
                        padding:
                            EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 16.0),
                        child: Text(
                          _errorText!,
                          textAlign: TextAlign.center,
                          style:
                              FlutterFlowTheme.of(context).bodySmall.override(
                                    font: GoogleFonts.outfit(),
                                    color: FlutterFlowTheme.of(context).error,
                                    letterSpacing: 0.0,
                                  ),
                        ),
                      )
                    else if (duration != null)
                      Text(
                        '${_formatDuration(_position)} / ${_formatDuration(duration)}',
                        style: FlutterFlowTheme.of(context)
                            .labelMedium
                            .override(
                              font: GoogleFonts.outfit(),
                              color: FlutterFlowTheme.of(context).secondaryText,
                              letterSpacing: 0.0,
                            ),
                      ),
                  ],
                ),
              ),
            ),
            ExerciseControlBar(
              isRunning: _isPlaying,
              progress: progress,
              progressLabel: _errorText != null
                  ? 'Sonido no disponible'
                  : (duration != null
                      ? '${_formatDuration(_position)} / ${_formatDuration(duration)}'
                      : 'Toca "Iniciar" para reproducir'),
              onToggle: _togglePlay,
              onReset: _reset,
            ),
          ],
        ),
      ),
    );
  }
}
