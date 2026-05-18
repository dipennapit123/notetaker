import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:db_notes/models/note.dart';
import 'package:db_notes/theme/note_accents.dart';

class NotesRepository {
  NotesRepository(this._uid);

  final String _uid;

  CollectionReference<Map<String, dynamic>> get _col =>
      FirebaseFirestore.instance.collection('users').doc(_uid).collection('notes');

  Stream<List<Note>> watchNotes() {
    return _col.orderBy('updatedAt', descending: true).snapshots().map(
          (snap) => snap.docs.map(Note.fromDoc).toList(),
        );
  }

  Future<String> createNote({
    required String title,
    required String body,
    required int accentIndex,
    bool isFavorite = false,
    List<String>? labels,
  }) async {
    final now = DateTime.now();
    final doc = _col.doc();
    final ai = noteAccentIndex(accentIndex);
    final ls = labels ?? <String>[noteAccentLabel(ai)];
    await doc.set({
      'title': title,
      'body': body,
      'createdAt': Timestamp.fromDate(now),
      'updatedAt': Timestamp.fromDate(now),
      'accentIndex': ai,
      'isFavorite': isFavorite,
      'labels': ls,
    });
    return doc.id;
  }

  Future<void> updateNote(Note note) async {
    await _col.doc(note.id).update(note.toMap());
  }

  Future<void> setFavorite(String noteId, bool isFavorite) async {
    await _col.doc(noteId).update({
      'isFavorite': isFavorite,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  Future<void> deleteNote(String id) async {
    await _col.doc(id).delete();
  }
}
