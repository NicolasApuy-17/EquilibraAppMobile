import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

/// One in-app notification, always written by a Cloud Function (chat
/// messages, a psychologist's comment/feedback, a new task/activity
/// assignment, a completed task/activity, a new self-service
/// patient-psychologist link, a logged app error) -- never directly by a
/// client, so `type` is trustworthy for deciding what to show/where to
/// navigate. See firebase/functions/notifications.js for every `type` this
/// can be and exactly when each is created.
class NotificationsRecord extends FirestoreRecord {
  NotificationsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "recipientRef" field: who should see this notification.
  DocumentReference? _recipientRef;
  DocumentReference? get recipientRef => _recipientRef;
  bool hasRecipientRef() => _recipientRef != null;

  // "type" field, e.g. "chat_message", "record_comment", "task_assigned",
  // "task_feedback", "task_completed", "activity_assigned",
  // "activity_completed", "new_link", "app_error".
  String? _type;
  String get type => _type ?? '';
  bool hasType() => _type != null;

  // "title" field.
  String? _title;
  String get title => _title ?? '';
  bool hasTitle() => _title != null;

  // "body" field.
  String? _body;
  String get body => _body ?? '';
  bool hasBody() => _body != null;

  // "read" field.
  bool? _read;
  bool get read => _read ?? false;
  bool hasRead() => _read != null;

  // "createdTime" field.
  DateTime? _createdTime;
  DateTime? get createdTime => _createdTime;
  bool hasCreatedTime() => _createdTime != null;

  // "subjectRef" field: who/what this is about, when relevant -- e.g. the
  // patient a psychologist/admin notification concerns. Lets the UI deep
  // link to that patient's detail screen.
  DocumentReference? _subjectRef;
  DocumentReference? get subjectRef => _subjectRef;
  bool hasSubjectRef() => _subjectRef != null;

  // "conversationId" field: set only on `type == 'chat_message'`, so
  // tapping the notification can open that exact conversation.
  String? _conversationId;
  String get conversationId => _conversationId ?? '';
  bool hasConversationId() => _conversationId != null;

  void _initializeFields() {
    _recipientRef = snapshotData['recipientRef'] as DocumentReference?;
    _type = snapshotData['type'] as String?;
    _title = snapshotData['title'] as String?;
    _body = snapshotData['body'] as String?;
    _read = snapshotData['read'] as bool?;
    _createdTime = snapshotData['createdTime'] as DateTime?;
    _subjectRef = snapshotData['subjectRef'] as DocumentReference?;
    _conversationId = snapshotData['conversationId'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('notifications');

  static Stream<NotificationsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => NotificationsRecord.fromSnapshot(s));

  static Future<NotificationsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => NotificationsRecord.fromSnapshot(s));

  static NotificationsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      NotificationsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static NotificationsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      NotificationsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'NotificationsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is NotificationsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

class NotificationsRecordDocumentEquality
    implements Equality<NotificationsRecord> {
  const NotificationsRecordDocumentEquality();

  @override
  bool equals(NotificationsRecord? e1, NotificationsRecord? e2) {
    return e1?.recipientRef == e2?.recipientRef &&
        e1?.type == e2?.type &&
        e1?.title == e2?.title &&
        e1?.body == e2?.body &&
        e1?.read == e2?.read &&
        e1?.createdTime == e2?.createdTime &&
        e1?.subjectRef == e2?.subjectRef &&
        e1?.conversationId == e2?.conversationId;
  }

  @override
  int hash(NotificationsRecord? e) => const ListEquality().hash([
        e?.recipientRef,
        e?.type,
        e?.title,
        e?.body,
        e?.read,
        e?.createdTime,
        e?.subjectRef,
        e?.conversationId,
      ]);

  @override
  bool isValidKey(Object? o) => o is NotificationsRecord;
}
