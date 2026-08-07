import '/backend/backend.dart';
import '/components/bottom_nav3/bottom_nav3_widget.dart';
import '/components/button/button_widget.dart';
import '/components/profile_menu_item/profile_menu_item_widget.dart';
import '/components/profile_stat/profile_stat_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'user_profile_widget.dart' show UserProfileWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class UserProfileModel extends FlutterFlowModel<UserProfileWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for ProfileStat.
  late ProfileStatModel profileStatModel1;
  // Model for ProfileStat.
  late ProfileStatModel profileStatModel2;
  // Model for ProfileStat.
  late ProfileStatModel profileStatModel3;
  // Model for ProfileMenuItem.
  late ProfileMenuItemModel profileMenuItemModel1;
  // Model for ProfileMenuItem.
  late ProfileMenuItemModel profileMenuItemModel2;
  // Model for ProfileMenuItem.
  late ProfileMenuItemModel profileMenuItemModel3;
  // Model for ProfileMenuItem.
  late ProfileMenuItemModel profileMenuItemModel4;
  // Model for ProfileMenuItem.
  late ProfileMenuItemModel profileMenuItemModel5;
  // Model for Button.
  late ButtonModel buttonModel;
  // Model for BottomNav.
  late BottomNav3Model bottomNavModel;

  @override
  void initState(BuildContext context) {
    profileStatModel1 = createModel(context, () => ProfileStatModel());
    profileStatModel2 = createModel(context, () => ProfileStatModel());
    profileStatModel3 = createModel(context, () => ProfileStatModel());
    profileMenuItemModel1 = createModel(context, () => ProfileMenuItemModel());
    profileMenuItemModel2 = createModel(context, () => ProfileMenuItemModel());
    profileMenuItemModel3 = createModel(context, () => ProfileMenuItemModel());
    profileMenuItemModel4 = createModel(context, () => ProfileMenuItemModel());
    profileMenuItemModel5 = createModel(context, () => ProfileMenuItemModel());
    buttonModel = createModel(context, () => ButtonModel());
    bottomNavModel = createModel(context, () => BottomNav3Model());
  }

  @override
  void dispose() {
    profileStatModel1.dispose();
    profileStatModel2.dispose();
    profileStatModel3.dispose();
    profileMenuItemModel1.dispose();
    profileMenuItemModel2.dispose();
    profileMenuItemModel3.dispose();
    profileMenuItemModel4.dispose();
    profileMenuItemModel5.dispose();
    buttonModel.dispose();
    bottomNavModel.dispose();
  }
}
