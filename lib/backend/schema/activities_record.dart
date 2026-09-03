import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

/// One entry in Equilibra's admin-managed catalog of tools/activities a
/// psychologist can assign to a patient (breathing exercises, TIP tools,
/// behavioral activation, etc). Readable by any signed-in user (patients
/// need to see the name/description of what was assigned to them;
/// psychologists need to browse the catalog to assign from it); writable
/// only by an admin.
class ActivitiesRecord extends FirestoreRecord {
  ActivitiesRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "name" field.
  String? _name;
  String get name => _name ?? '';
  bool hasName() => _name != null;

  // "description" field.
  String? _description;
  String get description => _description ?? '';
  bool hasDescription() => _description != null;

  // "category" field, e.g. "Respiración", "TIP", "Activación conductual".
  String? _category;
  String get category => _category ?? '';
  bool hasCategory() => _category != null;

  // "routeName" field. Optional: the app route this activity deep-links to
  // (one of the existing exercise/record screens' `routeName`), so opening
  // an assignment can jump straight to the right tool. Empty means "no
  // specific screen -- just a written indication".
  String? _routeName;
  String get routeName => _routeName ?? '';
  bool hasRouteName() => _routeName != null;

  // "active" field. Inactive activities stay visible on existing
  // assignments but can no longer be newly assigned.
  bool? _active;
  bool get active => _active ?? true;
  bool hasActive() => _active != null;

  // "createdTime" field.
  DateTime? _createdTime;
  DateTime? get createdTime => _createdTime;
  bool hasCreatedTime() => _createdTime != null;

  void _initializeFields() {
    _name = snapshotData['name'] as String?;
    _description = snapshotData['description'] as String?;
    _category = snapshotData['category'] as String?;
    _routeName = snapshotData['routeName'] as String?;
    _active = snapshotData['active'] as bool?;
    _createdTime = snapshotData['createdTime'] as DateTime?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('activities');

  static Stream<ActivitiesRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => ActivitiesRecord.fromSnapshot(s));

  static Future<ActivitiesRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => ActivitiesRecord.fromSnapshot(s));

  static ActivitiesRecord fromSnapshot(DocumentSnapshot snapshot) =>
      ActivitiesRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static ActivitiesRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      ActivitiesRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'ActivitiesRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is ActivitiesRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createActivitiesRecordData({
  String? name,
  String? description,
  String? category,
  String? routeName,
  bool? active,
  DateTime? createdTime,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'name': name,
      'description': description,
      'category': category,
      'routeName': routeName,
      'active': active,
      'createdTime': createdTime,
    }.withoutNulls,
  );

  return firestoreData;
}

class ActivitiesRecordDocumentEquality implements Equality<ActivitiesRecord> {
  const ActivitiesRecordDocumentEquality();

  @override
  bool equals(ActivitiesRecord? e1, ActivitiesRecord? e2) {
    return e1?.name == e2?.name &&
        e1?.description == e2?.description &&
        e1?.category == e2?.category &&
        e1?.routeName == e2?.routeName &&
        e1?.active == e2?.active &&
        e1?.createdTime == e2?.createdTime;
  }

  @override
  int hash(ActivitiesRecord? e) => const ListEquality().hash([
        e?.name,
        e?.description,
        e?.category,
        e?.routeName,
        e?.active,
        e?.createdTime,
      ]);

  @override
  bool isValidKey(Object? o) => o is ActivitiesRecord;
}
