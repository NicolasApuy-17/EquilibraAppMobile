import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'emotion_pill_clean_model.dart';
export 'emotion_pill_clean_model.dart';

class EmotionPillCleanWidget extends StatefulWidget {
  const EmotionPillCleanWidget({
    super.key,
    String? label,
    bool? isSelected,
    required this.onTap,
  })  : this.label = label ?? 'Tranquilo',
        this.isSelected = isSelected ?? false;

  final String label;
  final bool isSelected;
  final Future Function()? onTap;

  @override
  State<EmotionPillCleanWidget> createState() => _EmotionPillCleanWidgetState();
}

class _EmotionPillCleanWidgetState extends State<EmotionPillCleanWidget> {
  late EmotionPillCleanModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => EmotionPillCleanModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional(0.0, 0.0),
      child: InkWell(
        splashColor: Colors.transparent,
        focusColor: Colors.transparent,
        hoverColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () async {
          await widget.onTap?.call();
        },
        child: Container(
          width: 88.0,
          height: 40.0,
          decoration: BoxDecoration(
            color: widget!.isSelected
                ? FlutterFlowTheme.of(context).primary
                : FlutterFlowTheme.of(context).tertiary,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
              bottomLeft: Radius.circular(20.0),
              bottomRight: Radius.circular(20.0),
            ),
            border: Border.all(
              color: Color(0xFFD9DEE7),
            ),
          ),
          child: Align(
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Text(
              widget!.label,
              textAlign: TextAlign.center,
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.outfit(
                      fontWeight: FontWeight.w500,
                      fontStyle:
                          FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                    ),
                    color: widget!.isSelected
                        ? FlutterFlowTheme.of(context).tertiary
                        : Color(0xFF2D3440),
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w500,
                    fontStyle:
                        FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
