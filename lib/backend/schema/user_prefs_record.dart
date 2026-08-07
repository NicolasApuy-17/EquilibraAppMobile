import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class UserPrefsRecord extends FirestoreRecord {
  UserPrefsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "name" field.
  String? _name;
  String get name => _name ?? '';
  bool hasName() => _name != null;

  // "email" field.
  String? _email;
  String get email => _email ?? '';
  bool hasEmail() => _email != null;

  // "dailyReminderEnabled" field.
  bool? _dailyReminderEnabled;
  bool get dailyReminderEnabled => _dailyReminderEnabled ?? false;
  bool hasDailyReminderEnabled() => _dailyReminderEnabled != null;

  // "streakCount" field.
  int? _streakCount;
  int get streakCount => _streakCount ?? 0;
  bool hasStreakCount() => _streakCount != null;

  void _initializeFields() {
    _name = snapshotData['name'] as String?;
    _email = snapshotData['email'] as String?;
    _dailyReminderEnabled = snapshotData['dailyReminderEnabled'] as bool?;
    _streakCount = castToType<int>(snapshotData['streakCount']);
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('user_prefs');

  static Stream<UserPrefsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => UserPrefsRecord.fromSnapshot(s));

  static Future<UserPrefsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => UserPrefsRecord.fromSnapshot(s));

  static UserPrefsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      UserPrefsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static UserPrefsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      UserPrefsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'UserPrefsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is UserPrefsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createUserPrefsRecordData({
  String? name,
  String? email,
  bool? dailyReminderEnabled,
  int? streakCount,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'name': name,
      'email': email,
      'dailyReminderEnabled': dailyReminderEnabled,
      'streakCount': streakCount,
    }.withoutNulls,
  );

  return firestoreData;
}

class UserPrefsRecordDocumentEquality implements Equality<UserPrefsRecord> {
  const UserPrefsRecordDocumentEquality();

  @override
  bool equals(UserPrefsRecord? e1, UserPrefsRecord? e2) {
    return e1?.name == e2?.name &&
        e1?.email == e2?.email &&
        e1?.dailyReminderEnabled == e2?.dailyReminderEnabled &&
        e1?.streakCount == e2?.streakCount;
  }

  @override
  int hash(UserPrefsRecord? e) => const ListEquality()
      .hash([e?.name, e?.email, e?.dailyReminderEnabled, e?.streakCount]);

  @override
  bool isValidKey(Object? o) => o is UserPrefsRecord;
}
