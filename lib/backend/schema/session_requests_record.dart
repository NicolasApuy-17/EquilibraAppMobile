import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

/// A patient's request to schedule a session with their assigned
/// psychologist -- separate from `SessionsRecord`, which holds the private
/// clinical notes a psychologist writes about a session that already
/// happened. The patient picks any date/time for now (no availability
/// validation yet, see firestore.rules and schedule_session_widget.dart);
/// the psychologist then confirms or declines it from their "Sesiones" tab.
class SessionRequestsRecord extends FirestoreRecord {
  SessionRequestsRecord._(
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

  // "requestedDate" field: the date/time the patient asked for.
  DateTime? _requestedDate;
  DateTime? get requestedDate => _requestedDate;
  bool hasRequestedDate() => _requestedDate != null;

  // "note" field: an optional short message from the patient about the
  // request (e.g. what they'd like to discuss).
  String? _note;
  String get note => _note ?? '';
  bool hasNote() => _note != null;

  // "status" field: 'pendiente' | 'confirmada' | 'rechazada' | 'cancelada'.
  String? _status;
  String get status => _status ?? 'pendiente';
  bool hasStatus() => _status != null;

  // "createdTime" field.
  DateTime? _createdTime;
  DateTime? get createdTime => _createdTime;
  bool hasCreatedTime() => _createdTime != null;

  // "respondedAt" field: when the psychologist confirmed/declined it.
  DateTime? _respondedAt;
  DateTime? get respondedAt => _respondedAt;
  bool hasRespondedAt() => _respondedAt != null;

  // "psychologistNote" field: optional note from the psychologist, e.g. a
  // reason for declining or a confirmation detail.
  String? _psychologistNote;
  String get psychologistNote => _psychologistNote ?? '';
  bool hasPsychologistNote() => _psychologistNote != null;

  void _initializeFields() {
    _patientRef = snapshotData['patientRef'] as DocumentReference?;
    _psychologistRef = snapshotData['psychologistRef'] as DocumentReference?;
    _requestedDate = snapshotData['requestedDate'] as DateTime?;
    _note = snapshotData['note'] as String?;
    _status = snapshotData['status'] as String?;
    _createdTime = snapshotData['createdTime'] as DateTime?;
    _respondedAt = snapshotData['respondedAt'] as DateTime?;
    _psychologistNote = snapshotData['psychologistNote'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('session_requests');

  static Stream<SessionRequestsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => SessionRequestsRecord.fromSnapshot(s));

  static Future<SessionRequestsRecord> getDocumentOnce(
          DocumentReference ref) =>
      ref.get().then((s) => SessionRequestsRecord.fromSnapshot(s));

  static SessionRequestsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      SessionRequestsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static SessionRequestsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      SessionRequestsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'SessionRequestsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is SessionRequestsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createSessionRequestsRecordData({
  DocumentReference? patientRef,
  DocumentReference? psychologistRef,
  DateTime? requestedDate,
  String? note,
  String? status,
  DateTime? createdTime,
  DateTime? respondedAt,
  String? psychologistNote,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'patientRef': patientRef,
      'psychologistRef': psychologistRef,
      'requestedDate': requestedDate,
      'note': note,
      'status': status,
      'createdTime': createdTime,
      'respondedAt': respondedAt,
      'psychologistNote': psychologistNote,
    }.withoutNulls,
  );

  return firestoreData;
}

class SessionRequestsRecordDocumentEquality
    implements Equality<SessionRequestsRecord> {
  const SessionRequestsRecordDocumentEquality();

  @override
  bool equals(SessionRequestsRecord? e1, SessionRequestsRecord? e2) {
    return e1?.patientRef == e2?.patientRef &&
        e1?.psychologistRef == e2?.psychologistRef &&
        e1?.requestedDate == e2?.requestedDate &&
        e1?.note == e2?.note &&
        e1?.status == e2?.status &&
        e1?.createdTime == e2?.createdTime &&
        e1?.respondedAt == e2?.respondedAt &&
        e1?.psychologistNote == e2?.psychologistNote;
  }

  @override
  int hash(SessionRequestsRecord? e) => const ListEquality().hash([
        e?.patientRef,
        e?.psychologistRef,
        e?.requestedDate,
        e?.note,
        e?.status,
        e?.createdTime,
        e?.respondedAt,
        e?.psychologistNote,
      ]);

  @override
  bool isValidKey(Object? o) => o is SessionRequestsRecord;
}
