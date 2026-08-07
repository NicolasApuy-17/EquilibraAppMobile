import '/components/welcome_action_button/welcome_action_button_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'welcome_screen_widget.dart' show WelcomeScreenWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class WelcomeScreenModel extends FlutterFlowModel<WelcomeScreenWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for WelcomeActionButton.
  late WelcomeActionButtonModel welcomeActionButtonModel1;
  // Model for WelcomeActionButton.
  late WelcomeActionButtonModel welcomeActionButtonModel2;

  @override
  void initState(BuildContext context) {
    welcomeActionButtonModel1 =
        createModel(context, () => WelcomeActionButtonModel());
    welcomeActionButtonModel2 =
        createModel(context, () => WelcomeActionButtonModel());
  }

  @override
  void dispose() {
    welcomeActionButtonModel1.dispose();
    welcomeActionButtonModel2.dispose();
  }
}
