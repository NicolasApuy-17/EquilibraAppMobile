import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'welcome_action_button_model.dart';
export 'welcome_action_button_model.dart';

class WelcomeActionButtonWidget extends StatefulWidget {
  const WelcomeActionButtonWidget({
    super.key,
    Color? bgColor,
    String? borderStyle,
    String? tapAction,
    this.icon,
    Color? textColor,
    String? label,
  })  : this.bgColor = bgColor ?? const Color(0x00000000),
        this.borderStyle = borderStyle ?? '0 transparent',
        this.tapAction = tapAction ?? '',
        this.textColor = textColor ?? const Color(0x00000000),
        this.label = label ?? 'Crear una cuenta';

  final Color bgColor;
  final String borderStyle;
  final String tapAction;
  final Widget? icon;
  final Color textColor;
  final String label;

  @override
  State<WelcomeActionButtonWidget> createState() =>
      _WelcomeActionButtonWidgetState();
}

class _WelcomeActionButtonWidgetState extends State<WelcomeActionButtonWidget> {
  late WelcomeActionButtonModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => WelcomeActionButtonModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 52.0,
      decoration: BoxDecoration(
        color: valueOrDefault<Color>(
          widget!.bgColor,
          FlutterFlowTheme.of(context).primary,
        ),
        borderRadius: BorderRadius.circular(16.0),
        shape: BoxShape.rectangle,
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(24.0, 16.0, 24.0, 16.0),
        child: Container(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              widget!.icon!,
              Text(
                valueOrDefault<String>(
                  widget!.label,
                  'Crear una cuenta',
                ),
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        fontStyle:
                            FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                      ),
                      color: valueOrDefault<Color>(
                        widget!.textColor,
                        FlutterFlowTheme.of(context).onPrimary,
                      ),
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.bold,
                      fontStyle:
                          FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                      lineHeight: 1.6,
                    ),
              ),
            ].divide(SizedBox(width: 16.0)),
          ),
        ),
      ),
    );
  }
}
