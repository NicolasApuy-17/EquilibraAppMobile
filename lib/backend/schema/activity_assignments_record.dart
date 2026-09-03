import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

/// One activity/tool assigned by a psychologist to a patient. Readable by
/// both (the patient sees it as "Actividad recomendada por tu psicólogo");
/// only the patient may update `status`/`openedAt`/`completedAt` -- the
/// assignment's own fields are immutable once created (see
/// firestore.rules).
class ActivityAssignmentsRecord extends FirestoreRecord {
  ActivityAssignmentsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "patientRef" field.
  DocumentReference? _patientRef;
  DocumentReference? get patientRef => _patientRef;
  bool hasPatientRef() => _patientRef != null;

  // "psychologistRef" field.
  DocumentReference? _psychologistRef;
  DocumentReference? get psychologistRef => _psychologistRef;
  bool hasPsychologistRef() => _psychologistRef != null;

  // "activityRef" field.
  DocumentReference? _activityRef;
  DocumentReference? get activityRef => _activityRef;
  bool hasActivityRef() => _activityRef != null;

  // "activityName" field. A snapshot of the activity's name at assignment
  // time, so this still reads fine even if the catalog entry is edited or
  // deactivated later.
  String? _activityName;
  String get activityName => _activityName ?? '';
  bool hasActivityName() => _activityName != null;

  // "routeName" field. Snapshot of the activity's deep-link route, if any.
  String? _routeName;
  String get routeName => _routeName ?? '';
  bool hasRouteName() => _routeName != null;

  // "instructions" field.
  String? _instructions;
  String get instructions => _instructions ?? '';
  bool hasInstructions() => _instructions != null;

  // "frequency" field. One of `kTaskFrequencies`.
  String? _frequency;
  String get frequency => _frequency ?? '';
  bool hasFrequency() => _frequency != null;

  // "status" field: 'pendiente' | 'abierta' | 'completada'.
  String? _status;
  String get status => _status ?? 'pendiente';
  bool hasStatus() => _status != null;

  // "assignedTime" field.
  DateTime? _assignedTime;
  DateTime? get assignedTime => _assignedTime;
  bool hasAssignedTime() => _assignedTime != null;

  // "openedAt" field.
  DateTime? _openedAt;
  DateTime? get openedAt => _openedAt;
  bool hasOpenedAt() => _openedAt != null;

  // "completedAt" field.
  DateTime? _completedAt;
  DateTime? get completedAt => _completedAt;
  bool hasCompletedAt() => _completedAt != null;

  void _initializeFields() {
    _patientRef = snapshotData['patientRef'] as DocumentReference?;
    _psychologistRef = snapshotData['psychologistRef'] as DocumentReference?;
    _activityRef = snapshotData['activityRef'] as DocumentReference?;
    _activityName = snapshotData['activityName'] as String?;
    _routeName = snapshotData['routeName'] as String?;
    _instructions = snapshotData['instructions'] as String?;
    _frequency = snapshotData['frequency'] as String?;
    _status = snapshotData['status'] as String?;
    _assignedTime = snapshotData['assignedTime'] as DateTime?;
    _openedAt = snapshotData['openedAt'] as DateTime?;
    _completedAt = snapshotData['completedAt'] as DateTime?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('activity_assignments');

  static Stream<ActivityAssignmentsRecord> getDocument(
          DocumentReference ref) =>
      ref.snapshots().map((s) => ActivityAssignmentsRecord.fromSnapshot(s));

  static Future<ActivityAssignmentsRecord> getDocumentOnce(
          DocumentReference ref) =>
      ref.get().then((s) => ActivityAssignmentsRecord.fromSnapshot(s));

  static ActivityAssignmentsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      ActivityAssignmentsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static ActivityAssignmentsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      ActivityAssignmentsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'ActivityAssignmentsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is ActivityAssignmentsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createActivityAssignmentsRecordData({
  DocumentReference? patientRef,
  DocumentReference? psychologistRef,
  DocumentReference? activityRef,
  String? activityName,
  String? routeName,
  String? instructions,
  String? frequency,
  String? status,
  DateTime? assignedTime,
  DateTime? openedAt,
  DateTime? completedAt,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'patientRef': patientRef,
      'psychologistRef': psychologistRef,
      'activityRef': activityRef,
      'activityName': activityName,
      'routeName': routeName,
      'instructions': instructions,
      'frequency': frequency,
      'status': status,
      'assignedTime': assignedTime,
      'openedAt': openedAt,
      'completedAt': completedAt,
    }.withoutNulls,
  );

  return firestoreData;
}

class ActivityAssignmentsRecordDocumentEquality
    implements Equality<ActivityAssignmentsRecord> {
  const ActivityAssignmentsRecordDocumentEquality();

  @override
  bool equals(ActivityAssignmentsRecord? e1, ActivityAssignmentsRecord? e2) {
    return e1?.patientRef == e2?.patientRef &&
        e1?.psychologistRef == e2?.psychologistRef &&
        e1?.activityRef == e2?.activityRef &&
        e1?.activityName == e2?.activityName &&
        e1?.routeName == e2?.routeName &&
        e1?.instructions == e2?.instructions &&
        e1?.frequency == e2?.frequency &&
        e1?.status == e2?.status &&
        e1?.assignedTime == e2?.assignedTime &&
        e1?.openedAt == e2?.openedAt &&
        e1?.completedAt == e2?.completedAt;
  }

  @override
  int hash(ActivityAssignmentsRecord? e) => const ListEquality().hash([
        e?.patientRef,
        e?.psychologistRef,
        e?.activityRef,
        e?.activityName,
        e?.routeName,
        e?.instructions,
        e?.frequency,
        e?.status,
        e?.assignedTime,
        e?.openedAt,
        e?.completedAt,
      ]);

  @override
  bool isValidKey(Object? o) => o is ActivityAssignmentsRecord;
}
