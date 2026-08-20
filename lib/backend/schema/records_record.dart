import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class RecordsRecord extends FirestoreRecord {
  RecordsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "emotion" field.
  String? _emotion;
  String get emotion => _emotion ?? '';
  bool hasEmotion() => _emotion != null;

  // "description" field.
  String? _description;
  String get description => _description ?? '';
  bool hasDescription() => _description != null;

  // "behaviors" field.
  List<String>? _behaviors;
  List<String> get behaviors => _behaviors ?? const [];
  bool hasBehaviors() => _behaviors != null;

  // "timestamp" field.
  DateTime? _timestamp;
  DateTime? get timestamp => _timestamp;
  bool hasTimestamp() => _timestamp != null;

  // "intensity" field.
  double? _intensity;
  double get intensity => _intensity ?? 0.0;
  bool hasIntensity() => _intensity != null;

  // "userRef" field.
  DocumentReference? _userRef;
  DocumentReference? get userRef => _userRef;
  bool hasUserRef() => _userRef != null;

  void _initializeFields() {
    _emotion = safeGet(() => snapshotData['emotion'] as String?);
    _description = safeGet(() => snapshotData['description'] as String?);
    _behaviors = safeGet(() => getDataList(snapshotData['behaviors']));
    _timestamp = safeGet(() => snapshotData['timestamp'] as DateTime?) ??
        safeGet(() {
          final raw = snapshotData['timestamp'];
          return raw is Timestamp ? raw.toDate() : null;
        });
    _intensity = safeGet(() => castToType<double>(snapshotData['intensity']));
    _userRef =
        safeGet(() => snapshotData['userRef'] as DocumentReference?);
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('records');

  static Stream<RecordsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => RecordsRecord.fromSnapshot(s));

  static Future<RecordsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => RecordsRecord.fromSnapshot(s));

  static RecordsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      RecordsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static RecordsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      RecordsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'RecordsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is RecordsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createRecordsRecordData({
  String? emotion,
  String? description,
  DateTime? timestamp,
  double? intensity,
  DocumentReference? userRef,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'emotion': emotion,
      'description': description,
      'timestamp': timestamp,
      'intensity': intensity,
      'userRef': userRef,
    }.withoutNulls,
  );

  return firestoreData;
}

class RecordsRecordDocumentEquality implements Equality<RecordsRecord> {
  const RecordsRecordDocumentEquality();

  @override
  bool equals(RecordsRecord? e1, RecordsRecord? e2) {
    const listEquality = ListEquality();
    return e1?.emotion == e2?.emotion &&
        e1?.description == e2?.description &&
        listEquality.equals(e1?.behaviors, e2?.behaviors) &&
        e1?.timestamp == e2?.timestamp &&
        e1?.intensity == e2?.intensity &&
        e1?.userRef == e2?.userRef;
  }

  @override
  int hash(RecordsRecord? e) => const ListEquality().hash([
        e?.emotion,
        e?.description,
        e?.behaviors,
        e?.timestamp,
        e?.intensity,
        e?.userRef
      ]);

  @override
  bool isValidKey(Object? o) => o is RecordsRecord;
}
