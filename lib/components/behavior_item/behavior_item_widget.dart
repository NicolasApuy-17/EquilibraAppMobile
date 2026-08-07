import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'behavior_item_model.dart';
export 'behavior_item_model.dart';

class BehaviorItemWidget extends StatefulWidget {
  const BehaviorItemWidget({
    super.key,
    this.icon,
    String? label,
    String? status,
    bool? isPositive,
  })  : this.label = label ?? 'Respiración profunda',
        this.status = status ?? 'Cumplido 8/10',
        this.isPositive = isPositive ?? true;

  final Widget? icon;
  final String label;
  final String status;
  final bool isPositive;

  @override
  State<BehaviorItemWidget> createState() => _BehaviorItemWidgetState();
}

class _BehaviorItemWidgetState extends State<BehaviorItemWidget> {
  late BehaviorItemModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => BehaviorItemModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 8.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 40.0,
            height: 40.0,
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).primary10,
              borderRadius: BorderRadius.circular(16.0),
              shape: BoxShape.rectangle,
            ),
            alignment: AlignmentDirectional(0.0, 0.0),
            child: widget!.icon!,
          ),
          Expanded(
            flex: 1,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  valueOrDefault<String>(
                    widget!.label,
                    'Respiración profunda',
                  ),
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.outfit(
                          fontWeight: FontWeight.w500,
                          fontStyle:
                              FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                        ),
                        color: FlutterFlowTheme.of(context).primaryText,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.w500,
                        fontStyle:
                            FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                        lineHeight: 1.6,
                      ),
                ),
                Text(
                  valueOrDefault<String>(
                    widget!.status,
                    'Cumplido 8/10',
                  ),
                  style: FlutterFlowTheme.of(context).labelSmall.override(
                        font: GoogleFonts.outfit(
                          fontWeight: FlutterFlowTheme.of(context)
                              .labelSmall
                              .fontWeight,
                          fontStyle:
                              FlutterFlowTheme.of(context).labelSmall.fontStyle,
                        ),
                        color: FlutterFlowTheme.of(context).secondaryText,
                        letterSpacing: 0.0,
                        fontWeight:
                            FlutterFlowTheme.of(context).labelSmall.fontWeight,
                        fontStyle:
                            FlutterFlowTheme.of(context).labelSmall.fontStyle,
                        lineHeight: 1.4,
                      ),
                ),
              ].divide(SizedBox(height: 4.0)),
            ),
          ),
          if (valueOrDefault<bool>(
            widget!.isPositive,
            true,
          ))
            Icon(
              Icons.check_circle_rounded,
              color: FlutterFlowTheme.of(context).success,
              size: 18.0,
            ),
        ].divide(SizedBox(width: 16.0)),
      ),
    );
  }
}
