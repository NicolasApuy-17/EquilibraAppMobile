import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

/// One checkable step toward a goal (e.g. "Caminar 20 minutos"), stored as
/// a plain map inside the goal document's `steps` array -- Firestore
/// handles nested maps/lists natively, so this doesn't need its own
/// subcollection or a full `FFFirebaseStruct`. The patient defines the
/// full list once, when registering the goal (see `GoalRecordWidget`);
/// afterwards only each step's `completed` flag changes, from "Mis
/// registros" > Objetivos.
class GoalStep {
  const GoalStep({required this.title, this.completed = false});

  final String title;
  final bool completed;

  factory GoalStep.fromMap(Map<String, dynamic> map) => GoalStep(
        title: map['title'] as String? ?? '',
        completed: map['completed'] as bool? ?? false,
      );

  Map<String, dynamic> toMap() => {'title': title, 'completed': completed};

  GoalStep copyWith({String? title, bool? completed}) => GoalStep(
        title: title ?? this.title,
        completed: completed ?? this.completed,
      );

  @override
  bool operator ==(Object other) =>
      other is GoalStep && title == other.title && completed == other.completed;

  @override
  int get hashCode => Object.hash(title, completed);
}

class GoalsRecord extends FirestoreRecord {
  GoalsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "title" field.
  String? _title;
  String get title => _title ?? '';
  bool hasTitle() => _title != null;

  // "description" field.
  String? _description;
  String get description => _description ?? '';
  bool hasDescription() => _description != null;

  // "targetDate" field.
  DateTime? _targetDate;
  DateTime? get targetDate => _targetDate;
  bool hasTargetDate() => _targetDate != null;

  // "completed" field.
  bool? _completed;
  bool get completed => _completed ?? false;
  bool hasCompleted() => _completed != null;

  // "userRef" field.
  DocumentReference? _userRef;
  DocumentReference? get userRef => _userRef;
  bool hasUserRef() => _userRef != null;

  // "createdTime" field.
  DateTime? _createdTime;
  DateTime? get createdTime => _createdTime;
  bool hasCreatedTime() => _createdTime != null;

  // "completedTime" field.
  DateTime? _completedTime;
  DateTime? get completedTime => _completedTime;
  bool hasCompletedTime() => _completedTime != null;

  // "steps" field. Absent/empty on goals created before this field existed
  // -- those fall back to the plain manual "mark as done" toggle instead of
  // a checklist (see `_GoalRecordCard` in `my_records_widget.dart`).
  List<GoalStep>? _steps;
  List<GoalStep> get steps => _steps ?? const [];
  bool hasSteps() => _steps != null;

  void _initializeFields() {
    _title = snapshotData['title'] as String?;
    _description = snapshotData['description'] as String?;
    _targetDate = snapshotData['targetDate'] as DateTime?;
    _completed = snapshotData['completed'] as bool?;
    _userRef = snapshotData['userRef'] as DocumentReference?;
    _createdTime = snapshotData['createdTime'] as DateTime?;
    _completedTime = snapshotData['completedTime'] as DateTime?;
    _steps = (snapshotData['steps'] as List?)
        ?.whereType<Map>()
        .map((m) => GoalStep.fromMap(m.cast<String, dynamic>()))
        .toList();
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('goals');

  static Stream<GoalsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => GoalsRecord.fromSnapshot(s));

  static Future<GoalsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => GoalsRecord.fromSnapshot(s));

  static GoalsRecord fromSnapshot(DocumentSnapshot snapshot) => GoalsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static GoalsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      GoalsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'GoalsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is GoalsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createGoalsRecordData({
  String? title,
  String? description,
  DateTime? targetDate,
  bool? completed,
  DocumentReference? userRef,
  DateTime? createdTime,
  DateTime? completedTime,
  List<GoalStep>? steps,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'title': title,
      'description': description,
      'targetDate': targetDate,
      'completed': completed,
      'userRef': userRef,
      'createdTime': createdTime,
      'completedTime': completedTime,
      'steps': steps?.map((s) => s.toMap()).toList(),
    }.withoutNulls,
  );

  return firestoreData;
}

class GoalsRecordDocumentEquality implements Equality<GoalsRecord> {
  const GoalsRecordDocumentEquality();

  @override
  bool equals(GoalsRecord? e1, GoalsRecord? e2) {
    const listEquality = ListEquality();
    return e1?.title == e2?.title &&
        e1?.description == e2?.description &&
        e1?.targetDate == e2?.targetDate &&
        e1?.completed == e2?.completed &&
        e1?.userRef == e2?.userRef &&
        e1?.createdTime == e2?.createdTime &&
        e1?.completedTime == e2?.completedTime &&
        listEquality.equals(e1?.steps, e2?.steps);
  }

  @override
  int hash(GoalsRecord? e) => const ListEquality().hash([
        e?.title,
        e?.description,
        e?.targetDate,
        e?.completed,
        e?.userRef,
        e?.createdTime,
        e?.completedTime,
        e?.steps,
      ]);

  @override
  bool isValidKey(Object? o) => o is GoalsRecord;
}
