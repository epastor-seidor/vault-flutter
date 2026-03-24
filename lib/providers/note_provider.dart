import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:dev_vault/models/note.dart';
import 'package:uuid/uuid.dart';

class NoteNotifier extends Notifier<List<Note>> {
  @override
  List<Note> build() {
    final box = Hive.box('notes');
    final List<dynamic> rawNotes = box.values.toList();
    return rawNotes
        .map((note) => Note.fromMap(Map<String, dynamic>.from(note)))
        .toList();
  }

  late final _box = Hive.box('notes');

  Future<void> addNote(Note note) async {
    await _box.put(note.id, note.toMap());
    state = [...state, note];
  }

  Future<void> updateNote(Note note) async {
    await _box.put(note.id, note.toMap());
    state = [
      for (final n in state)
        if (n.id == note.id) note else n
    ];
  }

  Future<void> deleteNote(String id) async {
    await _box.delete(id);
    state = state.where((note) => note.id != id).toList();
  }
}

final noteProvider = NotifierProvider<NoteNotifier, List<Note>>(() {
  return NoteNotifier();
});

const _uuid = Uuid();
String generateNoteId() => _uuid.v4();
