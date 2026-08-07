import '/auth/firebase_auth/auth_util.dart';
import '/components/feature_card/feature_card_widget.dart';
import '/components/quick_action/quick_action_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'home_screen_widget.dart' show HomeScreenWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class HomeScreenModel extends FlutterFlowModel<HomeScreenWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for FeatureCard.
  late FeatureCardModel featureCardModel1;
  // Model for FeatureCard.
  late FeatureCardModel featureCardModel2;
  // Model for FeatureCard.
  late FeatureCardModel featureCardModel3;
  // Model for FeatureCard.
  late FeatureCardModel featureCardModel4;
  // Model for QuickAction.
  late QuickActionModel quickActionModel1;
  // Model for QuickAction.
  late QuickActionModel quickActionModel2;

  @override
  void initState(BuildContext context) {
    featureCardModel1 = createModel(context, () => FeatureCardModel());
    featureCardModel2 = createModel(context, () => FeatureCardModel());
    featureCardModel3 = createModel(context, () => FeatureCardModel());
    featureCardModel4 = createModel(context, () => FeatureCardModel());
    quickActionModel1 = createModel(context, () => QuickActionModel());
    quickActionModel2 = createModel(context, () => QuickActionModel());
  }

  @override
  void dispose() {
    featureCardModel1.dispose();
    featureCardModel2.dispose();
    featureCardModel3.dispose();
    featureCardModel4.dispose();
    quickActionModel1.dispose();
    quickActionModel2.dispose();
  }
}
