import '/components/bottom_nav5/bottom_nav5_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'my_records_widget.dart' show MyRecordsWidget;
import 'package:flutter/material.dart';

class MyRecordsModel extends FlutterFlowModel<MyRecordsWidget> {
  ///  Local state fields for this page.

  String searchQuery = '';

  String? emotionFilter;

  bool sortAscending = false;

  // Toggles between "Emociones" (RecordsRecord) and "Conductas"
  // (BehavioralRecordsRecord) -- the patient's own behavioral records had
  // no view at all before this; only their psychologist could see them.
  bool showBehaviors = false;

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
