import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class UsersRecord extends FirestoreRecord {
  UsersRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "email" field.
  String? _email;
  String get email => _email ?? '';
  bool hasEmail() => _email != null;

  // "display_name" field.
  String? _displayName;
  String get displayName => _displayName ?? '';
  bool hasDisplayName() => _displayName != null;

  // "photo_url" field.
  String? _photoUrl;
  String get photoUrl => _photoUrl ?? '';
  bool hasPhotoUrl() => _photoUrl != null;

  // "uid" field.
  String? _uid;
  String get uid => _uid ?? '';
  bool hasUid() => _uid != null;

  // "created_time" field.
  DateTime? _createdTime;
  DateTime? get createdTime => _createdTime;
  bool hasCreatedTime() => _createdTime != null;

  // "phone_number" field.
  String? _phoneNumber;
  String get phoneNumber => _phoneNumber ?? '';
  bool hasPhoneNumber() => _phoneNumber != null;

  // "role" field. One of 'paciente' (default), 'psicologo' or 'admin'.
  String? _role;
  String get role => _role ?? '';
  bool hasRole() => _role != null;

  // "specialty" field. Only meaningful for role == 'psicologo': a short
  // description shown to patients choosing a psychologist.
  String? _specialty;
  String get specialty => _specialty ?? '';
  bool hasSpecialty() => _specialty != null;

  // "psychologistRef" field. Only meaningful for role == 'paciente': the
  // psychologist this patient currently has assigned, if any. Only ever
  // written server-side (see the `linkPsychologistByCode` /
  // `adminAssignPsychologist` Cloud Functions).
  DocumentReference? _psychologistRef;
  DocumentReference? get psychologistRef => _psychologistRef;
  bool hasPsychologistRef() => _psychologistRef != null;

  // "linkCode" field. Only meaningful for role == 'psicologo': the unique
  // code (e.g. "FABRIZZIO-4821") patients enter to link to this
  // psychologist. Generated once by the `createPsychologist` Cloud
  // Function; never written by a client.
  String? _linkCode;
  String get linkCode => _linkCode ?? '';
  bool hasLinkCode() => _linkCode != null;

  // "psychologistLinkedAt" field. Only meaningful for role == 'paciente':
  // when this patient was linked to their current psychologist. Only ever
  // written server-side.
  DateTime? _psychologistLinkedAt;
  DateTime? get psychologistLinkedAt => _psychologistLinkedAt;
  bool hasPsychologistLinkedAt() => _psychologistLinkedAt != null;

  // "lastActivityAt" field. Only meaningful for role == 'paciente': the
  // most recent time this patient created/updated a record, behavioral
  // record or task. Maintained by Firestore triggers, never written by a
  // client directly.
  DateTime? _lastActivityAt;
  DateTime? get lastActivityAt => _lastActivityAt;
  bool hasLastActivityAt() => _lastActivityAt != null;

  // "active" field. Defaults to true (absent == active). Only ever set by
  // the `setAccountActive` Cloud Function, which also disables/enables the
  // underlying Firebase Auth account -- this field is a read-only mirror
  // of that for the UI, never a client write path.
  bool? _active;
  bool get active => _active ?? true;
  bool hasActive() => _active != null;

  void _initializeFields() {
    _email = snapshotData['email'] as String?;
    _displayName = snapshotData['display_name'] as String?;
    _photoUrl = snapshotData['photo_url'] as String?;
    _uid = snapshotData['uid'] as String?;
    _createdTime = snapshotData['created_time'] as DateTime?;
    _phoneNumber = snapshotData['phone_number'] as String?;
    _role = snapshotData['role'] as String?;
    _specialty = snapshotData['specialty'] as String?;
    _psychologistRef =
        snapshotData['psychologistRef'] as DocumentReference?;
    _linkCode = snapshotData['linkCode'] as String?;
    _psychologistLinkedAt =
        snapshotData['psychologistLinkedAt'] as DateTime?;
    _lastActivityAt = snapshotData['lastActivityAt'] as DateTime?;
    _active = snapshotData['active'] as bool?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('users');

  static Stream<UsersRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => UsersRecord.fromSnapshot(s));

  static Future<UsersRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => UsersRecord.fromSnapshot(s));

  static UsersRecord fromSnapshot(DocumentSnapshot snapshot) => UsersRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static UsersRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      UsersRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'UsersRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is UsersRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createUsersRecordData({
  String? email,
  String? displayName,
  String? photoUrl,
  String? uid,
  DateTime? createdTime,
  String? phoneNumber,
  String? role,
  String? specialty,
  DocumentReference? psychologistRef,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'email': email,
      'display_name': displayName,
      'photo_url': photoUrl,
      'uid': uid,
      'created_time': createdTime,
      'phone_number': phoneNumber,
      'role': role,
      'specialty': specialty,
      'psychologistRef': psychologistRef,
    }.withoutNulls,
  );

  return firestoreData;
}

class UsersRecordDocumentEquality implements Equality<UsersRecord> {
  const UsersRecordDocumentEquality();

  @override
  bool equals(UsersRecord? e1, UsersRecord? e2) {
    return e1?.email == e2?.email &&
        e1?.displayName == e2?.displayName &&
        e1?.photoUrl == e2?.photoUrl &&
        e1?.uid == e2?.uid &&
        e1?.createdTime == e2?.createdTime &&
        e1?.phoneNumber == e2?.phoneNumber &&
        e1?.role == e2?.role &&
        e1?.specialty == e2?.specialty &&
        e1?.psychologistRef == e2?.psychologistRef;
  }

  @override
  int hash(UsersRecord? e) => const ListEquality().hash([
        e?.email,
        e?.displayName,
        e?.photoUrl,
        e?.uid,
        e?.createdTime,
        e?.phoneNumber,
        e?.role,
        e?.specialty,
        e?.psychologistRef,
      ]);

  @override
  bool isValidKey(Object? o) => o is UsersRecord;
}
