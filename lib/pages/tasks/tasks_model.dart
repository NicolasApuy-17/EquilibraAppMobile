import '/components/bottom_nav5/bottom_nav5_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'tasks_widget.dart' show TasksWidget;
import 'package:flutter/material.dart';

class TasksModel extends FlutterFlowModel<TasksWidget> {
  ///  Local state fields for this page.

  String searchQuery = '';

  String? statusFilter;

  bool sortAscending = true;

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
