import '/components/bottom_nav2/bottom_nav2_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'regulation_tools_widget.dart' show RegulationToolsWidget;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class RegulationToolsModel extends FlutterFlowModel<RegulationToolsWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for BottomNav.
  late BottomNav2Model bottomNavModel;

  @override
  void initState(BuildContext context) {
    bottomNavModel = createModel(context, () => BottomNav2Model());
  }

  @override
  void dispose() {
    bottomNavModel.dispose();
  }
}
