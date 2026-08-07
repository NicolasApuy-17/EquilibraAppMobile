import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/flutter_flow/flutter_flow_theme.dart';

/// Shared header for every grounding-exercise page: back button + title.
class ExerciseHeader extends StatelessWidget {
  const ExerciseHeader({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(8.0, 24.0, 24.0, 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          InkWell(
            onTap: () => Navigator.of(context).maybePop(),
            borderRadius: BorderRadius.circular(20.0),
            child: Container(
              width: 40.0,
              height: 40.0,
              alignment: Alignment.center,
              child: Icon(
                Icons.arrow_back_rounded,
                color: FlutterFlowTheme.of(context).primaryText,
                size: 24.0,
              ),
            ),
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: FlutterFlowTheme.of(context).titleLarge.override(
                    font: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                    color: FlutterFlowTheme.of(context).primaryText,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          SizedBox(width: 40.0),
        ],
      ),
    );
  }
}

/// Shared bottom control bar (Iniciar/Pausar + Reiniciar, with progress and
/// duration) used identically by every timed grounding exercise.
class ExerciseControlBar extends StatelessWidget {
  const ExerciseControlBar({
    super.key,
    required this.isRunning,
    required this.progress,
    required this.progressLabel,
    required this.onToggle,
    required this.onReset,
    this.toggleEnabled = true,
    this.toggleLabelOverride,
  });

  /// Null progress hides the bar (used when progress isn't meaningful yet).
  final bool isRunning;
  final double? progress;
  final String progressLabel;
  final VoidCallback onToggle;
  final VoidCallback onReset;
  final bool toggleEnabled;
  final String? toggleLabelOverride;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (progress != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: LinearProgressIndicator(
                value: progress!.clamp(0.0, 1.0),
                minHeight: 6.0,
                backgroundColor: FlutterFlowTheme.of(context).alternate,
                valueColor: AlwaysStoppedAnimation(
                    FlutterFlowTheme.of(context).primary),
              ),
            ),
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 16.0),
            child: Text(
              progressLabel,
              textAlign: TextAlign.center,
              style: FlutterFlowTheme.of(context).labelMedium.override(
                    font: GoogleFonts.outfit(),
                    color: FlutterFlowTheme.of(context).secondaryText,
                    letterSpacing: 0.0,
                  ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onReset,
                  icon: Icon(Icons.refresh_rounded,
                      color: FlutterFlowTheme.of(context).primaryText),
                  label: Text(
                    'Reiniciar',
                    style: FlutterFlowTheme.of(context).labelMedium.override(
                          font: GoogleFonts.outfit(),
                          color: FlutterFlowTheme.of(context).primaryText,
                          letterSpacing: 0.0,
                        ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14.0),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24.0)),
                    side: BorderSide(
                        color: FlutterFlowTheme.of(context).alternate),
                  ),
                ),
              ),
              SizedBox(width: 12.0),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: toggleEnabled ? onToggle : null,
                  icon: Icon(
                    isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: FlutterFlowTheme.of(context).onPrimary,
                  ),
                  label: Text(
                    toggleLabelOverride ?? (isRunning ? 'Pausar' : 'Iniciar'),
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
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Shared card for listing an exercise inside RegulationToolsWidget.
class ExerciseListItem extends StatelessWidget {
  const ExerciseListItem({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.duration,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  final String duration;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24.0),
      child: Container(
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(24.0),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 48.0,
                height: 48.0,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(16.0),
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: iconColor, size: 24.0),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(12.0, 0.0, 12.0, 0.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: FlutterFlowTheme.of(context).titleSmall.override(
                              font: GoogleFonts.outfit(
                                  fontWeight: FontWeight.bold),
                              color: FlutterFlowTheme.of(context).primaryText,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Padding(
                        padding:
                            EdgeInsetsDirectional.fromSTEB(0.0, 2.0, 0.0, 0.0),
                        child: Text(
                          subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: FlutterFlowTheme.of(context)
                              .bodySmall
                              .override(
                                font: GoogleFonts.outfit(),
                                color:
                                    FlutterFlowTheme.of(context).secondaryText,
                                letterSpacing: 0.0,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    duration,
                    style: FlutterFlowTheme.of(context).labelSmall.override(
                          font: GoogleFonts.outfit(),
                          color: FlutterFlowTheme.of(context).secondaryText,
                          letterSpacing: 0.0,
                        ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: FlutterFlowTheme.of(context).accent3,
                    size: 20.0,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
