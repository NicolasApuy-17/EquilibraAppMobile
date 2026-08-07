import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class TasksRecord extends FirestoreRecord {
  TasksRecord._(
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

  // "dueDate" field.
  DateTime? _dueDate;
  DateTime? get dueDate => _dueDate;
  bool hasDueDate() => _dueDate != null;

  // "status" field.
  String? _status;
  String get status => _status ?? 'pendiente';
  bool hasStatus() => _status != null;

  // "userRef" field.
  DocumentReference? _userRef;
  DocumentReference? get userRef => _userRef;
  bool hasUserRef() => _userRef != null;

  // "createdTime" field.
  DateTime? _createdTime;
  DateTime? get createdTime => _createdTime;
  bool hasCreatedTime() => _createdTime != null;

  // "therapistId" field.
  // Reserved for a future therapist-assigned-tasks feature; empty for now.
  String? _therapistId;
  String get therapistId => _therapistId ?? '';
  bool hasTherapistId() => _therapistId != null;

  // "createdBy" field.
  // Reserved for a future therapist-assigned-tasks feature; empty for now.
  String? _createdBy;
  String get createdBy => _createdBy ?? '';
  bool hasCreatedBy() => _createdBy != null;

  // "assignedDate" field.
  // Reserved for a future therapist-assigned-tasks feature; null for now.
  DateTime? _assignedDate;
  DateTime? get assignedDate => _assignedDate;
  bool hasAssignedDate() => _assignedDate != null;

  void _initializeFields() {
    _title = snapshotData['title'] as String?;
    _description = snapshotData['description'] as String?;
    _dueDate = snapshotData['dueDate'] as DateTime?;
    _status = snapshotData['status'] as String?;
    _userRef = snapshotData['userRef'] as DocumentReference?;
    _createdTime = snapshotData['createdTime'] as DateTime?;
    _therapistId = snapshotData['therapistId'] as String?;
    _createdBy = snapshotData['createdBy'] as String?;
    _assignedDate = snapshotData['assignedDate'] as DateTime?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('tasks');

  static Stream<TasksRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => TasksRecord.fromSnapshot(s));

  static Future<TasksRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => TasksRecord.fromSnapshot(s));

  static TasksRecord fromSnapshot(DocumentSnapshot snapshot) => TasksRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static TasksRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      TasksRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'TasksRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is TasksRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createTasksRecordData({
  String? title,
  String? description,
  DateTime? dueDate,
  String? status,
  DocumentReference? userRef,
  DateTime? createdTime,
  String? therapistId,
  String? createdBy,
  DateTime? assignedDate,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'title': title,
      'description': description,
      'dueDate': dueDate,
      'status': status,
      'userRef': userRef,
      'createdTime': createdTime,
      'therapistId': therapistId,
      'createdBy': createdBy,
      'assignedDate': assignedDate,
    }.withoutNulls,
  );

  return firestoreData;
}

class TasksRecordDocumentEquality implements Equality<TasksRecord> {
  const TasksRecordDocumentEquality();

  @override
  bool equals(TasksRecord? e1, TasksRecord? e2) {
    return e1?.title == e2?.title &&
        e1?.description == e2?.description &&
        e1?.dueDate == e2?.dueDate &&
        e1?.status == e2?.status &&
        e1?.userRef == e2?.userRef &&
        e1?.createdTime == e2?.createdTime &&
        e1?.therapistId == e2?.therapistId &&
        e1?.createdBy == e2?.createdBy &&
        e1?.assignedDate == e2?.assignedDate;
  }

  @override
  int hash(TasksRecord? e) => const ListEquality().hash([
        e?.title,
        e?.description,
        e?.dueDate,
        e?.status,
        e?.userRef,
        e?.createdTime,
        e?.therapistId,
        e?.createdBy,
        e?.assignedDate,
      ]);

  @override
  bool isValidKey(Object? o) => o is TasksRecord;
}
