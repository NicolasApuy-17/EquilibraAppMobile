import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

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

  void _initializeFields() {
    _title = snapshotData['title'] as String?;
    _description = snapshotData['description'] as String?;
    _targetDate = snapshotData['targetDate'] as DateTime?;
    _completed = snapshotData['completed'] as bool?;
    _userRef = snapshotData['userRef'] as DocumentReference?;
    _createdTime = snapshotData['createdTime'] as DateTime?;
    _completedTime = snapshotData['completedTime'] as DateTime?;
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
    }.withoutNulls,
  );

  return firestoreData;
}

class GoalsRecordDocumentEquality implements Equality<GoalsRecord> {
  const GoalsRecordDocumentEquality();

  @override
  bool equals(GoalsRecord? e1, GoalsRecord? e2) {
    return e1?.title == e2?.title &&
        e1?.description == e2?.description &&
        e1?.targetDate == e2?.targetDate &&
        e1?.completed == e2?.completed &&
        e1?.userRef == e2?.userRef &&
        e1?.createdTime == e2?.createdTime &&
        e1?.completedTime == e2?.completedTime;
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
      ]);

  @override
  bool isValidKey(Object? o) => o is GoalsRecord;
}
