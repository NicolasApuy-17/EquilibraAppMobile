import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/components/behavior_chip/behavior_chip_widget.dart';
import '/components/bottom_nav/bottom_nav_widget.dart';
import '/components/button/button_widget.dart';
import '/components/emotion_pill_clean_widget.dart';
import '/components/slider/slider_widget.dart';
import '/components/text_field/text_field_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'emotional_record_widget.dart' show EmotionalRecordWidget;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class EmotionalRecordModel extends FlutterFlowModel<EmotionalRecordWidget> {
  ///  Local state fields for this page.

  List<String> behaviors = [];
  void toggleBehavior(String item) {
    if (behaviors.contains(item)) {
      behaviors.remove(item);
    } else {
      behaviors.add(item);
    }
  }

  String? selectedEmotion;

  double intensityValue = 1.0;

  bool isSaving = false;

  void resetForm() {
    selectedEmotion = null;
    intensityValue = 1.0;
    sliderModel.sliderValue = 1.0;
    behaviors = [];
    textFieldModel.inputTextController?.clear();
  }

  ///  State fields for stateful widgets in this page.

  // Model for EmotionPillClean component.
  late EmotionPillCleanModel emotionPillCleanModel1;
  // Model for EmotionPillClean component.
  late EmotionPillCleanModel emotionPillCleanModel2;
  // Model for EmotionPillClean component.
  late EmotionPillCleanModel emotionPillCleanModel3;
  // Model for EmotionPillClean component.
  late EmotionPillCleanModel emotionPillCleanModel4;
  // Model for EmotionPillClean component.
  late EmotionPillCleanModel emotionPillCleanModel5;
  // Model for EmotionPillClean component.
  late EmotionPillCleanModel emotionPillCleanModel6;
  // Model for Slider.
  late SliderModel sliderModel;
  // Model for TextField.
  late TextFieldModel textFieldModel;
  // Model for BehaviorChip.
  late BehaviorChipModel behaviorChipModel1;
  // Model for BehaviorChip.
  late BehaviorChipModel behaviorChipModel2;
  // Model for BehaviorChip.
  late BehaviorChipModel behaviorChipModel3;
  // Model for BehaviorChip.
  late BehaviorChipModel behaviorChipModel4;
  // Model for BehaviorChip.
  late BehaviorChipModel behaviorChipModel5;
  // Model for Button.
  late ButtonModel buttonModel;
  // Model for BottomNav.
  late BottomNavModel bottomNavModel;

  @override
  void initState(BuildContext context) {
    emotionPillCleanModel1 =
        createModel(context, () => EmotionPillCleanModel());
    emotionPillCleanModel2 =
        createModel(context, () => EmotionPillCleanModel());
    emotionPillCleanModel3 =
        createModel(context, () => EmotionPillCleanModel());
    emotionPillCleanModel4 =
        createModel(context, () => EmotionPillCleanModel());
    emotionPillCleanModel5 =
        createModel(context, () => EmotionPillCleanModel());
    emotionPillCleanModel6 =
        createModel(context, () => EmotionPillCleanModel());
    sliderModel = createModel(context, () => SliderModel());
    textFieldModel = createModel(context, () => TextFieldModel());
    behaviorChipModel1 = createModel(context, () => BehaviorChipModel());
    behaviorChipModel2 = createModel(context, () => BehaviorChipModel());
    behaviorChipModel3 = createModel(context, () => BehaviorChipModel());
    behaviorChipModel4 = createModel(context, () => BehaviorChipModel());
    behaviorChipModel5 = createModel(context, () => BehaviorChipModel());
    buttonModel = createModel(context, () => ButtonModel());
    bottomNavModel = createModel(context, () => BottomNavModel());
  }

  @override
  void dispose() {
    emotionPillCleanModel1.dispose();
    emotionPillCleanModel2.dispose();
    emotionPillCleanModel3.dispose();
    emotionPillCleanModel4.dispose();
    emotionPillCleanModel5.dispose();
    emotionPillCleanModel6.dispose();
    sliderModel.dispose();
    textFieldModel.dispose();
    behaviorChipModel1.dispose();
    behaviorChipModel2.dispose();
    behaviorChipModel3.dispose();
    behaviorChipModel4.dispose();
    behaviorChipModel5.dispose();
    buttonModel.dispose();
    bottomNavModel.dispose();
  }
}
