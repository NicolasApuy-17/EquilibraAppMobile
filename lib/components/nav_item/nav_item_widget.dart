import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'nav_item_model.dart';
export 'nav_item_model.dart';

void _navigateToNavTarget(BuildContext context, String target) {
  switch (target) {
    case 'home_screen':
      context.goNamed(HomeScreenWidget.routeName);
      break;
    case 'emotional_record':
      context.goNamed(EmotionalRecordWidget.routeName);
      break;
    case 'register_hub':
      context.goNamed(RegisterHubWidget.routeName);
      break;
    case 'weekly_progress':
      context.goNamed(WeeklyProgressWidget.routeName);
      break;
    case 'regulation_tools':
      context.goNamed(RegulationToolsWidget.routeName);
      break;
    case 'user_profile':
      context.goNamed(UserProfileWidget.routeName);
      break;
    case 'my_records':
      context.goNamed(MyRecordsWidget.routeName);
      break;
    case 'tasks':
      context.goNamed(TasksWidget.routeName);
      break;
  }
}

class NavItemWidget extends StatefulWidget {
  const NavItemWidget({
    super.key,
    String? label,
    this.icon,
    String? target,
    bool? selected,
  })  : this.label = label ?? 'Inicio',
        this.target = target ?? 'home_screen',
        this.selected = selected ?? false;

  final String label;
  final Widget? icon;
  final String target;
  final bool selected;

  @override
  State<NavItemWidget> createState() => _NavItemWidgetState();
}

class _NavItemWidgetState extends State<NavItemWidget> {
  late NavItemModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => NavItemModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () => _navigateToNavTarget(context, widget!.target),
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(2.0, 4.0, 2.0, 4.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            widget!.icon!,
            Text(
              valueOrDefault<String>(
                widget!.label,
                'Inicio',
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.outfit(
                      fontWeight:
                          FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                      fontStyle:
                          FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                    ),
                    color: valueOrDefault<Color>(
                      valueOrDefault<bool>(
                        widget!.selected,
                        false,
                      )
                          ? FlutterFlowTheme.of(context).primary
                          : FlutterFlowTheme.of(context).secondaryText,
                      FlutterFlowTheme.of(context).secondaryText,
                    ),
                    fontSize: 11.0,
                    letterSpacing: 0.0,
                    fontWeight:
                        FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                    fontStyle:
                        FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                    lineHeight: 1.2,
                  ),
            ),
          ].divide(SizedBox(height: 2.0)),
        ),
      ),
    );
  }
}
