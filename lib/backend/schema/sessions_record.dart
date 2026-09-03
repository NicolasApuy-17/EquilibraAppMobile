import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

/// A clinical session record. 100% private to the psychologist who wrote it
/// -- neither the patient nor an admin can ever read this collection (see
/// firestore.rules). Only what the psychologist separately assigns as a
/// Task or an activity is ever visible to the patient.
class SessionsRecord extends FirestoreRecord {
  SessionsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "patientRef" field.
  DocumentReference? _patientRef;
  DocumentReference? get patientRef => _patientRef;
  bool hasPatientRef() => _patientRef != null;

  // "psychologistRef" field. The only writer/reader of this document.
  DocumentReference? _psychologistRef;
  DocumentReference? get psychologistRef => _psychologistRef;
  bool hasPsychologistRef() => _psychologistRef != null;

  // "sessionNumber" field. Sequential per patient (e.g. "Sesión N.º 4").
  int? _sessionNumber;
  int get sessionNumber => _sessionNumber ?? 0;
  bool hasSessionNumber() => _sessionNumber != null;

  // "sessionDate" field.
  DateTime? _sessionDate;
  DateTime? get sessionDate => _sessionDate;
  bool hasSessionDate() => _sessionDate != null;

  // "topic" field.
  String? _topic;
  String get topic => _topic ?? '';
  bool hasTopic() => _topic != null;

  // "summary" field.
  String? _summary;
  String get summary => _summary ?? '';
  bool hasSummary() => _summary != null;

  // "objectives" field.
  String? _objectives;
  String get objectives => _objectives ?? '';
  bool hasObjectives() => _objectives != null;

  // "technique" field.
  String? _technique;
  String get technique => _technique ?? '';
  bool hasTechnique() => _technique != null;

  // "clinicalNotes" field.
  String? _clinicalNotes;
  String get clinicalNotes => _clinicalNotes ?? '';
  bool hasClinicalNotes() => _clinicalNotes != null;

  // "agreements" field.
  String? _agreements;
  String get agreements => _agreements ?? '';
  bool hasAgreements() => _agreements != null;

  // "homework" field.
  String? _homework;
  String get homework => _homework ?? '';
  bool hasHomework() => _homework != null;

  // "nextSessionObjectives" field.
  String? _nextSessionObjectives;
  String get nextSessionObjectives => _nextSessionObjectives ?? '';
  bool hasNextSessionObjectives() => _nextSessionObjectives != null;

  // "nextSessionDate" field.
  DateTime? _nextSessionDate;
  DateTime? get nextSessionDate => _nextSessionDate;
  bool hasNextSessionDate() => _nextSessionDate != null;

  // "createdTime" field.
  DateTime? _createdTime;
  DateTime? get createdTime => _createdTime;
  bool hasCreatedTime() => _createdTime != null;

  // "updatedTime" field.
  DateTime? _updatedTime;
  DateTime? get updatedTime => _updatedTime;
  bool hasUpdatedTime() => _updatedTime != null;

  void _initializeFields() {
    _patientRef = snapshotData['patientRef'] as DocumentReference?;
    _psychologistRef = snapshotData['psychologistRef'] as DocumentReference?;
    _sessionNumber = castToType<int>(snapshotData['sessionNumber']);
    _sessionDate = snapshotData['sessionDate'] as DateTime?;
    _topic = snapshotData['topic'] as String?;
    _summary = snapshotData['summary'] as String?;
    _objectives = snapshotData['objectives'] as String?;
    _technique = snapshotData['technique'] as String?;
    _clinicalNotes = snapshotData['clinicalNotes'] as String?;
    _agreements = snapshotData['agreements'] as String?;
    _homework = snapshotData['homework'] as String?;
    _nextSessionObjectives =
        snapshotData['nextSessionObjectives'] as String?;
    _nextSessionDate = snapshotData['nextSessionDate'] as DateTime?;
    _createdTime = snapshotData['createdTime'] as DateTime?;
    _updatedTime = snapshotData['updatedTime'] as DateTime?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('sessions');

  static Stream<SessionsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => SessionsRecord.fromSnapshot(s));

  static Future<SessionsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => SessionsRecord.fromSnapshot(s));

  static SessionsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      SessionsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static SessionsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      SessionsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'SessionsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is SessionsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createSessionsRecordData({
  DocumentReference? patientRef,
  DocumentReference? psychologistRef,
  int? sessionNumber,
  DateTime? sessionDate,
  String? topic,
  String? summary,
  String? objectives,
  String? technique,
  String? clinicalNotes,
  String? agreements,
  String? homework,
  String? nextSessionObjectives,
  DateTime? nextSessionDate,
  DateTime? createdTime,
  DateTime? updatedTime,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'patientRef': patientRef,
      'psychologistRef': psychologistRef,
      'sessionNumber': sessionNumber,
      'sessionDate': sessionDate,
      'topic': topic,
      'summary': summary,
      'objectives': objectives,
      'technique': technique,
      'clinicalNotes': clinicalNotes,
      'agreements': agreements,
      'homework': homework,
      'nextSessionObjectives': nextSessionObjectives,
      'nextSessionDate': nextSessionDate,
      'createdTime': createdTime,
      'updatedTime': updatedTime,
    }.withoutNulls,
  );

  return firestoreData;
}

class SessionsRecordDocumentEquality implements Equality<SessionsRecord> {
  const SessionsRecordDocumentEquality();

  @override
  bool equals(SessionsRecord? e1, SessionsRecord? e2) {
    return e1?.patientRef == e2?.patientRef &&
        e1?.psychologistRef == e2?.psychologistRef &&
        e1?.sessionNumber == e2?.sessionNumber &&
        e1?.sessionDate == e2?.sessionDate &&
        e1?.topic == e2?.topic &&
        e1?.summary == e2?.summary &&
        e1?.objectives == e2?.objectives &&
        e1?.technique == e2?.technique &&
        e1?.clinicalNotes == e2?.clinicalNotes &&
        e1?.agreements == e2?.agreements &&
        e1?.homework == e2?.homework &&
        e1?.nextSessionObjectives == e2?.nextSessionObjectives &&
        e1?.nextSessionDate == e2?.nextSessionDate &&
        e1?.createdTime == e2?.createdTime &&
        e1?.updatedTime == e2?.updatedTime;
  }

  @override
  int hash(SessionsRecord? e) => const ListEquality().hash([
        e?.patientRef,
        e?.psychologistRef,
        e?.sessionNumber,
        e?.sessionDate,
        e?.topic,
        e?.summary,
        e?.objectives,
        e?.technique,
        e?.clinicalNotes,
        e?.agreements,
        e?.homework,
        e?.nextSessionObjectives,
        e?.nextSessionDate,
        e?.createdTime,
        e?.updatedTime,
      ]);

  @override
  bool isValidKey(Object? o) => o is SessionsRecord;
}
