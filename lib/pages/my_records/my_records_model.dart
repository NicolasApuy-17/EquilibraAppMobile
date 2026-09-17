import '/components/bottom_nav5/bottom_nav5_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'my_records_widget.dart' show MyRecordsWidget;
import 'package:flutter/material.dart';

/// Which of the three record types "Mis registros" is currently showing.
enum RecordsTab { emotions, behaviors, goals }

class MyRecordsModel extends FlutterFlowModel<MyRecordsWidget> {
  ///  Local state fields for this page.

  String searchQuery = '';

  String? emotionFilter;

  bool sortAscending = false;

  // Which tab is selected: "Emociones" (RecordsRecord), "Conductas"
  // (BehavioralRecordsRecord), or "Objetivos" (GoalsRecord, with their
  // per-step checklist). The patient's own behavioral records had no view
  // at all before "Conductas" was added; only their psychologist could see
  // them.
  RecordsTab tab = RecordsTab.emotions;

  ///  State fields for stateful widgets in this page.

  final searchController = TextEditingController();

  // Model for BottomNav.
  late BottomNav5Model bottomNavModel;

  @override
  void initState(BuildContext context) {
    bottomNavModel = createModel(context, () => BottomNav5Model());
  }

  @override
  void dispose() {
    searchController.dispose();
    bottomNavModel.dispose();
  }
}
