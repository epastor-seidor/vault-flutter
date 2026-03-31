import 'package:flutter_test/flutter_test.dart';
import 'package:dev_vault/models/note.dart';

void main() {
  group('Note', () {
    final now = DateTime(2024, 3, 15, 14, 0, 0);
    final yesterday = DateTime(2024, 3, 14, 14, 0, 0);

    test('should create a Note with required fields', () {
      final note = Note(
        id: '1',
        title: 'Test Note',
        content: 'Hello World',
        createdAt: yesterday,
        updatedAt: now,
      );

      expect(note.id, '1');
      expect(note.title, 'Test Note');
      expect(note.content, 'Hello World');
      expect(note.tags, isEmpty);
      expect(note.createdAt, yesterday);
      expect(note.updatedAt, now);
    });

    test('should create a Note with tags', () {
      final note = Note(
        id: '2',
        title: 'Tagged Note',
        content: 'Content',
        createdAt: yesterday,
        updatedAt: now,
        tags: ['work', 'important'],
      );

      expect(note.tags, ['work', 'important']);
    });

    test('should convert to map correctly', () {
      final note = Note(
        id: '3',
        title: 'Map Test',
        content: '# Heading\n\nBody text',
        createdAt: yesterday,
        updatedAt: now,
        tags: ['dev', 'notes'],
      );

      final map = note.toMap();

      expect(map['id'], '3');
      expect(map['title'], 'Map Test');
      expect(map['content'], '# Heading\n\nBody text');
      expect(map['tags'], ['dev', 'notes']);
      expect(map['createdAt'], yesterday.toIso8601String());
      expect(map['updatedAt'], now.toIso8601String());
    });

    test('should create from map correctly', () {
      final map = {
        'id': '4',
        'title': 'From Map',
        'content': '## Subheading\n\nParagraph',
        'createdAt': yesterday.toIso8601String(),
        'updatedAt': now.toIso8601String(),
        'tags': ['personal', 'ideas'],
      };

      final note = Note.fromMap(map);

      expect(note.id, '4');
      expect(note.title, 'From Map');
      expect(note.content, '## Subheading\n\nParagraph');
      expect(note.tags, ['personal', 'ideas']);
      expect(note.createdAt, yesterday);
      expect(note.updatedAt, now);
    });

    test('should handle null tags in fromMap', () {
      final map = {
        'id': '5',
        'title': 'No Tags',
        'content': 'Content',
        'createdAt': yesterday.toIso8601String(),
        'updatedAt': now.toIso8601String(),
        'tags': null,
      };

      final note = Note.fromMap(map);

      expect(note.tags, isEmpty);
    });

    test('copyWith should update specified fields', () {
      final original = Note(
        id: '6',
        title: 'Original',
        content: 'Original content',
        createdAt: yesterday,
        updatedAt: now,
        tags: ['old'],
      );

      final updated = original.copyWith(
        title: 'Updated Title',
        content: 'Updated content',
        updatedAt: DateTime(2024, 3, 16),
        tags: ['new', 'updated'],
      );

      expect(updated.id, '6');
      expect(updated.title, 'Updated Title');
      expect(updated.content, 'Updated content');
      expect(updated.updatedAt, DateTime(2024, 3, 16));
      expect(updated.tags, ['new', 'updated']);
      expect(updated.createdAt, yesterday);
    });

    test('copyWith with no arguments should preserve all fields', () {
      final original = Note(
        id: '7',
        title: 'Test',
        content: 'Content',
        createdAt: yesterday,
        updatedAt: now,
        tags: ['tag1'],
      );

      final copy = original.copyWith();

      expect(copy.id, original.id);
      expect(copy.title, original.title);
      expect(copy.content, original.content);
      expect(copy.createdAt, original.createdAt);
      expect(copy.updatedAt, original.updatedAt);
      expect(copy.tags, original.tags);
    });

    test('round-trip serialization should preserve all data', () {
      final original = Note(
        id: '8',
        title: 'Round Trip',
        content: '# Markdown\n\n**Bold** and *italic*',
        createdAt: yesterday,
        updatedAt: now,
        tags: ['markdown', 'test'],
      );

      final restored = Note.fromMap(original.toMap());

      expect(restored.id, original.id);
      expect(restored.title, original.title);
      expect(restored.content, original.content);
      expect(restored.tags, original.tags);
      expect(restored.createdAt, original.createdAt);
      expect(restored.updatedAt, original.updatedAt);
    });

    test('should handle empty content', () {
      final note = Note(
        id: '9',
        title: 'Empty',
        content: '',
        createdAt: yesterday,
        updatedAt: now,
      );

      expect(note.content, '');
      expect(note.toMap()['content'], '');
    });

    test('should handle markdown content with special characters', () {
      final note = Note(
        id: '10',
        title: 'Special Chars',
        content: '```dart\nvoid main() {\n  print("Hello");\n}\n```',
        createdAt: yesterday,
        updatedAt: now,
      );

      final restored = Note.fromMap(note.toMap());

      expect(restored.content, note.content);
    });
  });
}
