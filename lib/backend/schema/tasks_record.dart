import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

/// A task/indication. Either self-created by the patient (`createdByRef ==
/// userRef`) or assigned by their psychologist (`createdByRef` is the
/// psychologist's own ref) -- see `isAssignedPsychologist` in
/// firestore.rules, which is what actually enforces who may create which.
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

  // "description" field. Doubles as "instrucciones" when assigned by a
  // psychologist.
  String? _description;
  String get description => _description ?? '';
  bool hasDescription() => _description != null;

  // "dueDate" field.
  DateTime? _dueDate;
  DateTime? get dueDate => _dueDate;
  bool hasDueDate() => _dueDate != null;

  // "status" field. One of `kTaskStatuses` (lib/utils/task_status.dart).
  String? _status;
  String get status => _status ?? 'pendiente';
  bool hasStatus() => _status != null;

  // "userRef" field. The patient this task belongs to.
  DocumentReference? _userRef;
  DocumentReference? get userRef => _userRef;
  bool hasUserRef() => _userRef != null;

  // "createdTime" field.
  DateTime? _createdTime;
  DateTime? get createdTime => _createdTime;
  bool hasCreatedTime() => _createdTime != null;

  // "createdByRef" field. Who created this task: the patient themself, or
  // their assigned psychologist. Never written by the client for anyone
  // other than the caller -- see firestore.rules.
  DocumentReference? _createdByRef;
  DocumentReference? get createdByRef => _createdByRef;
  bool hasCreatedByRef() => _createdByRef != null;

  // "assignedDate" field. Meaningful when `createdByRef != userRef`.
  DateTime? _assignedDate;
  DateTime? get assignedDate => _assignedDate;
  bool hasAssignedDate() => _assignedDate != null;

  // "frequency" field. One of `kTaskFrequencies`, only meaningful for
  // psychologist-assigned tasks.
  String? _frequency;
  String get frequency => _frequency ?? '';
  bool hasFrequency() => _frequency != null;

  // "responseType" field. One of `kTaskResponseTypes`, only meaningful for
  // psychologist-assigned tasks: what kind of response the patient gives
  // beyond just marking status.
  String? _responseType;
  String get responseType => _responseType ?? 'completado';
  bool hasResponseType() => _responseType != null;

  // "responseText" field. Set by the patient when responseType == 'texto'.
  String? _responseText;
  String get responseText => _responseText ?? '';
  bool hasResponseText() => _responseText != null;

  // "responseValue" field. Set by the patient when responseType == 'escala'.
  double? _responseValue;
  double? get responseValue => _responseValue;
  bool hasResponseValue() => _responseValue != null;

  // "responseAt" field.
  DateTime? _responseAt;
  DateTime? get responseAt => _responseAt;
  bool hasResponseAt() => _responseAt != null;

  // "completedTime" field. When status became 'completada' or
  // 'no_realizada' -- lets the dashboard/historial show real completion
  // dates instead of approximating from `createdTime`.
  DateTime? _completedTime;
  DateTime? get completedTime => _completedTime;
  bool hasCompletedTime() => _completedTime != null;

  // "feedback" field. Set only by the patient's assigned psychologist, on
  // the patient's response.
  String? _feedback;
  String? get feedback => _feedback;
  bool hasFeedback() => _feedback != null;

  // "feedbackAt" field.
  DateTime? _feedbackAt;
  DateTime? get feedbackAt => _feedbackAt;
  bool hasFeedbackAt() => _feedbackAt != null;

  void _initializeFields() {
    _title = snapshotData['title'] as String?;
    _description = snapshotData['description'] as String?;
    _dueDate = snapshotData['dueDate'] as DateTime?;
    _status = snapshotData['status'] as String?;
    _userRef = snapshotData['userRef'] as DocumentReference?;
    _createdTime = snapshotData['createdTime'] as DateTime?;
    _createdByRef = snapshotData['createdByRef'] as DocumentReference?;
    _assignedDate = snapshotData['assignedDate'] as DateTime?;
    _frequency = snapshotData['frequency'] as String?;
    _responseType = snapshotData['responseType'] as String?;
    _responseText = snapshotData['responseText'] as String?;
    _responseValue =
        safeGet<double?>(() => castToType<double>(snapshotData['responseValue']));
    _responseAt = snapshotData['responseAt'] as DateTime?;
    _completedTime = snapshotData['completedTime'] as DateTime?;
    _feedback = snapshotData['feedback'] as String?;
    _feedbackAt = snapshotData['feedbackAt'] as DateTime?;
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
  DocumentReference? createdByRef,
  DateTime? assignedDate,
  String? frequency,
  String? responseType,
  String? responseText,
  double? responseValue,
  DateTime? responseAt,
  DateTime? completedTime,
  String? feedback,
  DateTime? feedbackAt,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'title': title,
      'description': description,
      'dueDate': dueDate,
      'status': status,
      'userRef': userRef,
      'createdTime': createdTime,
      'createdByRef': createdByRef,
      'assignedDate': assignedDate,
      'frequency': frequency,
      'responseType': responseType,
      'responseText': responseText,
      'responseValue': responseValue,
      'responseAt': responseAt,
      'completedTime': completedTime,
      'feedback': feedback,
      'feedbackAt': feedbackAt,
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
        e1?.createdByRef == e2?.createdByRef &&
        e1?.assignedDate == e2?.assignedDate &&
        e1?.frequency == e2?.frequency &&
        e1?.responseType == e2?.responseType &&
        e1?.responseText == e2?.responseText &&
        e1?.responseValue == e2?.responseValue &&
        e1?.responseAt == e2?.responseAt &&
        e1?.completedTime == e2?.completedTime &&
        e1?.feedback == e2?.feedback &&
        e1?.feedbackAt == e2?.feedbackAt;
  }

  @override
  int hash(TasksRecord? e) => const ListEquality().hash([
        e?.title,
        e?.description,
        e?.dueDate,
        e?.status,
        e?.userRef,
        e?.createdTime,
        e?.createdByRef,
        e?.assignedDate,
        e?.frequency,
        e?.responseType,
        e?.responseText,
        e?.responseValue,
        e?.responseAt,
        e?.completedTime,
        e?.feedback,
        e?.feedbackAt,
      ]);

  @override
  bool isValidKey(Object? o) => o is TasksRecord;
}
