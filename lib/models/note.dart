import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:db_notes/theme/note_accents.dart';

class Note {
  Note({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.updatedAt,
    required this.accentIndex,
    this.isFavorite = false,
    List<String>? explicitLabels,
  }) : labels = List<String>.from(explicitLabels ?? <String>[]);

  final String id;
  final String title;
  final String body;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int accentIndex;
  final bool isFavorite;
  final List<String> labels;

  String get preview {
    final t = body.trim();
    if (t.isEmpty) return 'Empty note';
    return t.length > 120 ? '${t.substring(0, 120)}…' : t;
  }

  factory Note.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final accentIndex = noteAccentIndex((data['accentIndex'] as num?)?.toInt() ?? 0);
    final labels = _readLabels(data['labels']);
    final resolvedLabels =
        labels.isEmpty ? <String>[noteAccentLabel(accentIndex)] : labels;

    return Note(
      id: doc.id,
      title: (data['title'] as String?) ?? '',
      body: (data['body'] as String?) ?? '',
      createdAt: _readTimestamp(data['createdAt']),
      updatedAt: _readTimestamp(data['updatedAt']),
      accentIndex: accentIndex,
      isFavorite: data['isFavorite'] as bool? ?? false,
      explicitLabels: resolvedLabels,
    );
  }

  static List<String> _readLabels(dynamic value) {
    if (value is List) {
      return value.map((e) => e.toString().trim()).where((s) => s.isNotEmpty).toList();
    }
    return [];
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'accentIndex': accentIndex,
      'isFavorite': isFavorite,
      'labels': labels,
    };
  }

  static DateTime _readTimestamp(dynamic value) {
    if (value is Timestamp) return value.toDate();
    return DateTime.now();
  }
}
