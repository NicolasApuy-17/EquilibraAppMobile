import '/backend/backend.dart';
import '/components/bottom_nav4/bottom_nav4_widget.dart';
import '/components/progress_stat_card/progress_stat_card_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'weekly_progress_widget.dart' show WeeklyProgressWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class WeeklyProgressModel extends FlutterFlowModel<WeeklyProgressWidget> {
  ///  State fields for stateful widgets in this page.

  // Models for ProgressStatCard (Emoción principal, Registros, Promedio,
  // Conducta principal, % Positivas, % Negativas).
  late ProgressStatCardModel progressStatCardModel1;
  late ProgressStatCardModel progressStatCardModel2;
  late ProgressStatCardModel progressStatCardModel3;
  late ProgressStatCardModel progressStatCardModel4;
  late ProgressStatCardModel progressStatCardModel5;
  late ProgressStatCardModel progressStatCardModel6;
  // Model for BottomNav.
  late BottomNav4Model bottomNavModel;

  @override
  void initState(BuildContext context) {
    progressStatCardModel1 =
        createModel(context, () => ProgressStatCardModel());
    progressStatCardModel2 =
        createModel(context, () => ProgressStatCardModel());
    progressStatCardModel3 =
        createModel(context, () => ProgressStatCardModel());
    progressStatCardModel4 =
        createModel(context, () => ProgressStatCardModel());
    progressStatCardModel5 =
        createModel(context, () => ProgressStatCardModel());
    progressStatCardModel6 =
        createModel(context, () => ProgressStatCardModel());
    bottomNavModel = createModel(context, () => BottomNav4Model());
  }

  @override
  void dispose() {
    progressStatCardModel1.dispose();
    progressStatCardModel2.dispose();
    progressStatCardModel3.dispose();
    progressStatCardModel4.dispose();
    progressStatCardModel5.dispose();
    progressStatCardModel6.dispose();
    bottomNavModel.dispose();
  }
}
