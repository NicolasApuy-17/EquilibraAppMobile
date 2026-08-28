import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

/// Independent behavioral-tracking record. Intentionally does NOT store a
/// reference back to an EmotionalRecord/RecordsRecord: the clinical model
/// treats emotional episodes and daily behaviors as separate observations.
/// Any future correlation between the two must be computed explicitly
/// (e.g. by matching dates), never assumed or stored implicitly here.
class BehavioralRecordsRecord extends FirestoreRecord {
  BehavioralRecordsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "date" field. The day this behavior entry is logged for.
  DateTime? _date;
  DateTime? get date => _date;
  bool hasDate() => _date != null;

  // "behaviorType" field, e.g. "Sueño", "Alimentación", or a custom label.
  String? _behaviorType;
  String get behaviorType => _behaviorType ?? '';
  bool hasBehaviorType() => _behaviorType != null;

  // "value" field. Short status/label for the behavior (e.g. "Bien",
  // "Se aisló", "Cumplido"). Free-form so each behavior type can define
  // its own set of options without changing the schema.
  String? _value;
  String get value => _value ?? '';
  bool hasValue() => _value != null;

  // "quantity" field. Optional numeric amount (hours, minutes, etc.),
  // meaning depends on behaviorType.
  double? _quantity;
  double? get quantity => _quantity;
  bool hasQuantity() => _quantity != null;

  // "notes" field.
  String? _notes;
  String get notes => _notes ?? '';
  bool hasNotes() => _notes != null;

  // "createdAt" field.
  DateTime? _createdAt;
  DateTime? get createdAt => _createdAt;
  bool hasCreatedAt() => _createdAt != null;

  // "userRef" field.
  DocumentReference? _userRef;
  DocumentReference? get userRef => _userRef;
  bool hasUserRef() => _userRef != null;

  // "psychologistComment" field. Set only by the patient's assigned
  // psychologist (see firestore.rules); never written by the patient.
  String? _psychologistComment;
  String? get psychologistComment => _psychologistComment;
  bool hasPsychologistComment() => _psychologistComment != null;

  // "psychologistCommentTime" field.
  DateTime? _psychologistCommentTime;
  DateTime? get psychologistCommentTime => _psychologistCommentTime;
  bool hasPsychologistCommentTime() => _psychologistCommentTime != null;

  void _initializeFields() {
    _date = safeGet<DateTime?>(() => snapshotData['date'] as DateTime?);
    _behaviorType =
        safeGet<String?>(() => snapshotData['behaviorType'] as String?);
    _value = safeGet<String?>(() => snapshotData['value'] as String?);
    _quantity = safeGet<double?>(
        () => castToType<double>(snapshotData['quantity']));
    _notes = safeGet<String?>(() => snapshotData['notes'] as String?);
    _createdAt =
        safeGet<DateTime?>(() => snapshotData['createdAt'] as DateTime?);
    _userRef = safeGet<DocumentReference?>(
        () => snapshotData['userRef'] as DocumentReference?);
    _psychologistComment = safeGet<String?>(
        () => snapshotData['psychologistComment'] as String?);
    _psychologistCommentTime = safeGet<DateTime?>(() =>
            snapshotData['psychologistCommentTime'] as DateTime?) ??
        safeGet<DateTime?>(() {
          final raw = snapshotData['psychologistCommentTime'];
          return raw is Timestamp ? raw.toDate() : null;
        });
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('behavioral_records');

  static Stream<BehavioralRecordsRecord> getDocument(
          DocumentReference ref) =>
      ref.snapshots().map((s) => BehavioralRecordsRecord.fromSnapshot(s));

  static Future<BehavioralRecordsRecord> getDocumentOnce(
          DocumentReference ref) =>
      ref.get().then((s) => BehavioralRecordsRecord.fromSnapshot(s));

  static BehavioralRecordsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      BehavioralRecordsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static BehavioralRecordsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      BehavioralRecordsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'BehavioralRecordsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is BehavioralRecordsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createBehavioralRecordsRecordData({
  DateTime? date,
  String? behaviorType,
  String? value,
  double? quantity,
  String? notes,
  DateTime? createdAt,
  DocumentReference? userRef,
  String? psychologistComment,
  DateTime? psychologistCommentTime,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'date': date,
      'behaviorType': behaviorType,
      'value': value,
      'quantity': quantity,
      'notes': notes,
      'createdAt': createdAt,
      'userRef': userRef,
      'psychologistComment': psychologistComment,
      'psychologistCommentTime': psychologistCommentTime,
    }.withoutNulls,
  );

  return firestoreData;
}

class BehavioralRecordsRecordDocumentEquality
    implements Equality<BehavioralRecordsRecord> {
  const BehavioralRecordsRecordDocumentEquality();

  @override
  bool equals(BehavioralRecordsRecord? e1, BehavioralRecordsRecord? e2) {
    return e1?.date == e2?.date &&
        e1?.behaviorType == e2?.behaviorType &&
        e1?.value == e2?.value &&
        e1?.quantity == e2?.quantity &&
        e1?.notes == e2?.notes &&
        e1?.createdAt == e2?.createdAt &&
        e1?.userRef == e2?.userRef &&
        e1?.psychologistComment == e2?.psychologistComment &&
        e1?.psychologistCommentTime == e2?.psychologistCommentTime;
  }

  @override
  int hash(BehavioralRecordsRecord? e) => const ListEquality().hash([
        e?.date,
        e?.behaviorType,
        e?.value,
        e?.quantity,
        e?.notes,
        e?.createdAt,
        e?.userRef,
        e?.psychologistComment,
        e?.psychologistCommentTime,
      ]);

  @override
  bool isValidKey(Object? o) => o is BehavioralRecordsRecord;
}
