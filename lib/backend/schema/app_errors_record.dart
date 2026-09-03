import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

/// One logged app error/incident, written by `logAppError`
/// (lib/utils/error_logging.dart) whenever an unhandled error reaches the
/// global handlers wired in main.dart. Complements Crashlytics (which gets
/// the same error with its full native stack trace) by being readable from
/// inside the admin panel itself -- Crashlytics reports are only viewable
/// in the Firebase Console.
class AppErrorsRecord extends FirestoreRecord {
  AppErrorsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "context" field: what was happening when the error was caught, e.g.
  // "Flutter framework error" or "Uncaught async error".
  String? _context;
  String get context => _context ?? '';
  bool hasContext() => _context != null;

  // "message" field: the error's own string representation.
  String? _message;
  String get message => _message ?? '';
  bool hasMessage() => _message != null;

  // "stackTrace" field: truncated to a handful of lines -- just enough to
  // recognize the failure at a glance; the full trace lives in Crashlytics.
  String? _stackTrace;
  String get stackTrace => _stackTrace ?? '';
  bool hasStackTrace() => _stackTrace != null;

  // "userRef" field. Null if the error happened before/without sign-in.
  DocumentReference? _userRef;
  DocumentReference? get userRef => _userRef;
  bool hasUserRef() => _userRef != null;

  // "role" field: the signed-in user's role at the time, if any.
  String? _role;
  String get role => _role ?? '';
  bool hasRole() => _role != null;

  // "createdTime" field.
  DateTime? _createdTime;
  DateTime? get createdTime => _createdTime;
  bool hasCreatedTime() => _createdTime != null;

  void _initializeFields() {
    _context = snapshotData['context'] as String?;
    _message = snapshotData['message'] as String?;
    _stackTrace = snapshotData['stackTrace'] as String?;
    _userRef = snapshotData['userRef'] as DocumentReference?;
    _role = snapshotData['role'] as String?;
    _createdTime = snapshotData['createdTime'] as DateTime?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('app_errors');

  static Stream<AppErrorsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => AppErrorsRecord.fromSnapshot(s));

  static Future<AppErrorsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => AppErrorsRecord.fromSnapshot(s));

  static AppErrorsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      AppErrorsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static AppErrorsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      AppErrorsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'AppErrorsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is AppErrorsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createAppErrorsRecordData({
  String? context,
  String? message,
  String? stackTrace,
  DocumentReference? userRef,
  String? role,
  DateTime? createdTime,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'context': context,
      'message': message,
      'stackTrace': stackTrace,
      'userRef': userRef,
      'role': role,
      'createdTime': createdTime,
    }.withoutNulls,
  );

  return firestoreData;
}

class AppErrorsRecordDocumentEquality implements Equality<AppErrorsRecord> {
  const AppErrorsRecordDocumentEquality();

  @override
  bool equals(AppErrorsRecord? e1, AppErrorsRecord? e2) {
    return e1?.context == e2?.context &&
        e1?.message == e2?.message &&
        e1?.stackTrace == e2?.stackTrace &&
        e1?.userRef == e2?.userRef &&
        e1?.role == e2?.role &&
        e1?.createdTime == e2?.createdTime;
  }

  @override
  int hash(AppErrorsRecord? e) => const ListEquality().hash([
        e?.context,
        e?.message,
        e?.stackTrace,
        e?.userRef,
        e?.role,
        e?.createdTime,
      ]);

  @override
  bool isValidKey(Object? o) => o is AppErrorsRecord;
}
