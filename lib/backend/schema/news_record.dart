import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

/// One announcement a psychologist publishes for their linked patients (a
/// short text, optionally with an image and/or an external link). Shown as
/// a swipeable card on the patient home screen -- only to the patients
/// whose `psychologistRef` points at this news item's author, never as a
/// global broadcast across every psychologist in the app. Only the
/// authoring psychologist (or an admin) can edit/delete it; see
/// `firebase/firestore.rules`.
class NewsRecord extends FirestoreRecord {
  NewsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "title" field.
  String? _title;
  String get title => _title ?? '';
  bool hasTitle() => _title != null;

  // "content" field.
  String? _content;
  String get content => _content ?? '';
  bool hasContent() => _content != null;

  // "imageUrl" field. Optional: empty means the card shows text only.
  String? _imageUrl;
  String get imageUrl => _imageUrl ?? '';
  bool hasImageUrl() => _imageUrl != null;

  // "linkUrl" field. Optional: empty means there's nothing extra to open.
  String? _linkUrl;
  String get linkUrl => _linkUrl ?? '';
  bool hasLinkUrl() => _linkUrl != null;

  // "psychologistRef" field. The author -- also the field patients' feeds
  // filter by (a patient only sees news from their own assigned
  // psychologist).
  DocumentReference? _psychologistRef;
  DocumentReference? get psychologistRef => _psychologistRef;
  bool hasPsychologistRef() => _psychologistRef != null;

  // "psychologistName" field. Denormalized display name of the author, so
  // the feed doesn't need a second read per card just to show "Publicado
  // por ...".
  String? _psychologistName;
  String get psychologistName => _psychologistName ?? '';
  bool hasPsychologistName() => _psychologistName != null;

  // "createdTime" field.
  DateTime? _createdTime;
  DateTime? get createdTime => _createdTime;
  bool hasCreatedTime() => _createdTime != null;

  void _initializeFields() {
    _title = snapshotData['title'] as String?;
    _content = snapshotData['content'] as String?;
    _imageUrl = snapshotData['imageUrl'] as String?;
    _linkUrl = snapshotData['linkUrl'] as String?;
    _psychologistRef =
        snapshotData['psychologistRef'] as DocumentReference?;
    _psychologistName = snapshotData['psychologistName'] as String?;
    _createdTime = snapshotData['createdTime'] as DateTime?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('news');

  static Stream<NewsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => NewsRecord.fromSnapshot(s));

  static Future<NewsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => NewsRecord.fromSnapshot(s));

  static NewsRecord fromSnapshot(DocumentSnapshot snapshot) => NewsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static NewsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      NewsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'NewsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is NewsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createNewsRecordData({
  String? title,
  String? content,
  String? imageUrl,
  String? linkUrl,
  DocumentReference? psychologistRef,
  String? psychologistName,
  DateTime? createdTime,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'title': title,
      'content': content,
      'imageUrl': imageUrl,
      'linkUrl': linkUrl,
      'psychologistRef': psychologistRef,
      'psychologistName': psychologistName,
      'createdTime': createdTime,
    }.withoutNulls,
  );

  return firestoreData;
}

class NewsRecordDocumentEquality implements Equality<NewsRecord> {
  const NewsRecordDocumentEquality();

  @override
  bool equals(NewsRecord? e1, NewsRecord? e2) {
    return e1?.title == e2?.title &&
        e1?.content == e2?.content &&
        e1?.imageUrl == e2?.imageUrl &&
        e1?.linkUrl == e2?.linkUrl &&
        e1?.psychologistRef == e2?.psychologistRef &&
        e1?.psychologistName == e2?.psychologistName &&
        e1?.createdTime == e2?.createdTime;
  }

  @override
  int hash(NewsRecord? e) => const ListEquality().hash([
        e?.title,
        e?.content,
        e?.imageUrl,
        e?.linkUrl,
        e?.psychologistRef,
        e?.psychologistName,
        e?.createdTime,
      ]);

  @override
  bool isValidKey(Object? o) => o is NewsRecord;
}
