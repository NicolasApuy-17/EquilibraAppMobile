import '/components/nav_item/nav_item_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'bottom_nav4_model.dart';
export 'bottom_nav4_model.dart';

class BottomNav4Widget extends StatefulWidget {
  const BottomNav4Widget({super.key});

  @override
  State<BottomNav4Widget> createState() => _BottomNav4WidgetState();
}

class _BottomNav4WidgetState extends State<BottomNav4Widget> {
  late BottomNav4Model _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => BottomNav4Model());
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        shape: BoxShape.rectangle,
        border: Border.all(
          color: FlutterFlowTheme.of(context).alternate,
          width: 1.0,
        ),
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(16.0, 8.0, 16.0, 8.0),
        child: Container(
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    wrapWithModel(
                      model: _model.navItemModel1,
                      updateCallback: () => safeSetState(() {}),
                      child: NavItemWidget(
                        label: 'Inicio',
                        icon: Icon(
                          Icons.home_rounded,
                          color: FlutterFlowTheme.of(context).primaryText,
                          size: 24.0,
                        ),
                        target: 'home_screen',
                        selected: false,
                      ),
                    ),
                    wrapWithModel(
                      model: _model.navItemModel2,
                      updateCallback: () => safeSetState(() {}),
                      child: NavItemWidget(
                        label: 'Registrar',
                        icon: Icon(
                          Icons.add_circle_outline_rounded,
                          color: FlutterFlowTheme.of(context).primaryText,
                          size: 24.0,
                        ),
                        target: 'emotional_record',
                        selected: false,
                      ),
                    ),
                    wrapWithModel(
                      model: _model.navItemModel3,
                      updateCallback: () => safeSetState(() {}),
                      child: NavItemWidget(
                        label: 'Progreso',
                        icon: Icon(
                          Icons.bar_chart_rounded,
                          color: FlutterFlowTheme.of(context).primaryText,
                          size: 24.0,
                        ),
                        target: 'weekly_progress',
                        selected: true,
                      ),
                    ),
                    wrapWithModel(
                      model: _model.navItemModel4,
                      updateCallback: () => safeSetState(() {}),
                      child: NavItemWidget(
                        label: 'Regularme',
                        icon: Icon(
                          Icons.self_improvement_rounded,
                          color: FlutterFlowTheme.of(context).primaryText,
                          size: 24.0,
                        ),
                        target: 'regulation_tools',
                        selected: false,
                      ),
                    ),
                    wrapWithModel(
                      model: _model.navItemModel5,
                      updateCallback: () => safeSetState(() {}),
                      child: NavItemWidget(
                        label: 'Perfil',
                        icon: Icon(
                          Icons.person_rounded,
                          color: FlutterFlowTheme.of(context).primaryText,
                          size: 24.0,
                        ),
                        target: 'user_profile',
                        selected: false,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
