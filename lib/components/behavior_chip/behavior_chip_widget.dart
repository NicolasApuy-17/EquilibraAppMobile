import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'behavior_chip_model.dart';
export 'behavior_chip_model.dart';

class BehaviorChipWidget extends StatefulWidget {
  const BehaviorChipWidget({
    super.key,
    bool? selected,
    this.onTap,
    this.icon,
    String? label,
  })  : this.selected = selected ?? false,
        this.label = label ?? 'Sueño';

  final bool selected;
  final Future Function()? onTap;
  final Widget? icon;
  final String label;

  @override
  State<BehaviorChipWidget> createState() => _BehaviorChipWidgetState();
}

class _BehaviorChipWidgetState extends State<BehaviorChipWidget> {
  late BehaviorChipModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => BehaviorChipModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 4.0, 8.0),
      child: InkWell(
        splashColor: Colors.transparent,
        focusColor: Colors.transparent,
        hoverColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () async {
          await widget.onTap?.call();
        },
        child: Container(
          child: Container(
            decoration: BoxDecoration(
              color: widget!.selected
                  ? FlutterFlowTheme.of(context).primary10
                  : FlutterFlowTheme.of(context).secondaryBackground,
              borderRadius: BorderRadius.circular(24.0),
              shape: BoxShape.rectangle,
              border: Border.all(
                color: widget!.selected
                    ? FlutterFlowTheme.of(context).primary
                    : FlutterFlowTheme.of(context).alternate,
                width: 1.0,
              ),
            ),
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(8.0, 16.0, 8.0, 16.0),
              child: Container(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    widget!.icon!,
                    Text(
                      valueOrDefault<String>(
                        widget!.label,
                        'Sueño',
                      ),
                      style: FlutterFlowTheme.of(context).labelMedium.override(
                            font: GoogleFonts.outfit(
                              fontWeight: FlutterFlowTheme.of(context)
                                  .labelMedium
                                  .fontWeight,
                              fontStyle: FlutterFlowTheme.of(context)
                                  .labelMedium
                                  .fontStyle,
                            ),
                            color: widget!.selected
                                ? FlutterFlowTheme.of(context).primary
                                : FlutterFlowTheme.of(context).primaryText,
                            letterSpacing: 0.0,
                            fontWeight: FlutterFlowTheme.of(context)
                                .labelMedium
                                .fontWeight,
                            fontStyle: FlutterFlowTheme.of(context)
                                .labelMedium
                                .fontStyle,
                            lineHeight: 1.4,
                          ),
                    ),
                  ].divide(SizedBox(width: 4.0)),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
