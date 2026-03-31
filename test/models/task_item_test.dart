import 'package:flutter_test/flutter_test.dart';
import 'package:dev_vault/models/task_item.dart';

void main() {
  group('TaskStep', () {
    test('should create a TaskStep with required fields', () {
      final step = TaskStep(id: '1', title: 'Step 1', isCompleted: false);

      expect(step.id, '1');
      expect(step.title, 'Step 1');
      expect(step.isCompleted, isFalse);
    });

    test('should convert to map correctly', () {
      final step = TaskStep(id: '2', title: 'Map Step', isCompleted: true);

      final map = step.toMap();

      expect(map['id'], '2');
      expect(map['title'], 'Map Step');
      expect(map['isCompleted'], isTrue);
    });

    test('should create from map correctly', () {
      final map = {'id': '3', 'title': 'From Map Step', 'isCompleted': false};

      final step = TaskStep.fromMap(map);

      expect(step.id, '3');
      expect(step.title, 'From Map Step');
      expect(step.isCompleted, isFalse);
    });

    test('should handle missing title in fromMap', () {
      final map = {'id': '4', 'isCompleted': true};

      final step = TaskStep.fromMap(map);

      expect(step.title, '');
      expect(step.isCompleted, isTrue);
    });

    test('copyWith should update specified fields', () {
      final original = TaskStep(id: '5', title: 'Original', isCompleted: false);

      final updated = original.copyWith(title: 'Updated', isCompleted: true);

      expect(updated.id, '5');
      expect(updated.title, 'Updated');
      expect(updated.isCompleted, isTrue);
    });

    test('copyWith with no arguments should preserve all fields', () {
      final original = TaskStep(id: '6', title: 'Test', isCompleted: true);

      final copy = original.copyWith();

      expect(copy.id, original.id);
      expect(copy.title, original.title);
      expect(copy.isCompleted, original.isCompleted);
    });
  });

  group('TaskItem', () {
    final now = DateTime(2024, 4, 10, 9, 0, 0);
    final yesterday = DateTime(2024, 4, 9, 9, 0, 0);
    final tomorrow = DateTime(2024, 4, 11, 9, 0, 0);

    test('should create a TaskItem with required fields', () {
      final task = TaskItem(
        id: '1',
        title: 'Test Task',
        isCompleted: false,
        isImportant: false,
        createdAt: yesterday,
        updatedAt: now,
      );

      expect(task.id, '1');
      expect(task.title, 'Test Task');
      expect(task.isCompleted, isFalse);
      expect(task.isImportant, isFalse);
      expect(task.dueAt, isNull);
      expect(task.notes, '');
      expect(task.steps, isEmpty);
      expect(task.createdAt, yesterday);
      expect(task.updatedAt, now);
    });

    test('should create a TaskItem with all fields', () {
      final steps = [
        TaskStep(id: 's1', title: 'Step 1', isCompleted: false),
        TaskStep(id: 's2', title: 'Step 2', isCompleted: true),
      ];

      final task = TaskItem(
        id: '2',
        title: 'Full Task',
        isCompleted: false,
        isImportant: true,
        createdAt: yesterday,
        updatedAt: now,
        dueAt: tomorrow,
        notes: 'Important notes here',
        steps: steps,
      );

      expect(task.dueAt, tomorrow);
      expect(task.notes, 'Important notes here');
      expect(task.steps, hasLength(2));
      expect(task.isImportant, isTrue);
    });

    test('should convert to map correctly', () {
      final steps = [TaskStep(id: 's1', title: 'Step 1', isCompleted: true)];

      final task = TaskItem(
        id: '3',
        title: 'Map Task',
        isCompleted: false,
        isImportant: true,
        createdAt: yesterday,
        updatedAt: now,
        dueAt: tomorrow,
        notes: 'Notes',
        steps: steps,
      );

      final map = task.toMap();

      expect(map['id'], '3');
      expect(map['title'], 'Map Task');
      expect(map['isCompleted'], isFalse);
      expect(map['isImportant'], isTrue);
      expect(map['dueAt'], tomorrow.toIso8601String());
      expect(map['notes'], 'Notes');
      expect(map['steps'], hasLength(1));
    });

    test('should handle null dueAt in toMap', () {
      final task = TaskItem(
        id: '4',
        title: 'No Due Date',
        isCompleted: false,
        isImportant: false,
        createdAt: yesterday,
        updatedAt: now,
      );

      final map = task.toMap();

      expect(map['dueAt'], isNull);
    });

    test('should create from map correctly', () {
      final map = {
        'id': '5',
        'title': 'From Map Task',
        'isCompleted': true,
        'isImportant': false,
        'createdAt': yesterday.toIso8601String(),
        'updatedAt': now.toIso8601String(),
        'dueAt': tomorrow.toIso8601String(),
        'notes': 'Restored notes',
        'steps': [
          {'id': 's1', 'title': 'Restored Step', 'isCompleted': false},
        ],
      };

      final task = TaskItem.fromMap(map);

      expect(task.id, '5');
      expect(task.title, 'From Map Task');
      expect(task.isCompleted, isTrue);
      expect(task.isImportant, isFalse);
      expect(task.dueAt, tomorrow);
      expect(task.notes, 'Restored notes');
      expect(task.steps, hasLength(1));
      expect(task.steps.first.title, 'Restored Step');
    });

    test('should handle null dueAt in fromMap', () {
      final map = {
        'id': '6',
        'title': 'No Due',
        'isCompleted': false,
        'isImportant': false,
        'createdAt': yesterday.toIso8601String(),
        'updatedAt': now.toIso8601String(),
        'dueAt': null,
        'notes': '',
        'steps': [],
      };

      final task = TaskItem.fromMap(map);

      expect(task.dueAt, isNull);
    });

    test('should handle missing optional fields in fromMap', () {
      final map = {
        'id': '7',
        'title': 'Minimal Task',
        'isCompleted': false,
        'isImportant': false,
        'createdAt': yesterday.toIso8601String(),
        'updatedAt': now.toIso8601String(),
      };

      final task = TaskItem.fromMap(map);

      expect(task.notes, '');
      expect(task.steps, isEmpty);
      expect(task.dueAt, isNull);
    });

    test('copyWith should update specified fields', () {
      final original = TaskItem(
        id: '8',
        title: 'Original',
        isCompleted: false,
        isImportant: false,
        createdAt: yesterday,
        updatedAt: now,
      );

      final updated = original.copyWith(
        title: 'Updated',
        isCompleted: true,
        isImportant: true,
        dueAt: tomorrow,
        notes: 'Updated notes',
        updatedAt: DateTime(2024, 4, 11),
      );

      expect(updated.id, '8');
      expect(updated.title, 'Updated');
      expect(updated.isCompleted, isTrue);
      expect(updated.isImportant, isTrue);
      expect(updated.dueAt, tomorrow);
      expect(updated.notes, 'Updated notes');
      expect(updated.updatedAt, DateTime(2024, 4, 11));
      expect(updated.createdAt, yesterday);
    });

    test('copyWith should update steps', () {
      final original = TaskItem(
        id: '9',
        title: 'Task',
        isCompleted: false,
        isImportant: false,
        createdAt: yesterday,
        updatedAt: now,
      );

      final newSteps = [
        TaskStep(id: 's1', title: 'New Step', isCompleted: false),
      ];

      final updated = original.copyWith(steps: newSteps);

      expect(updated.steps, hasLength(1));
      expect(updated.steps.first.title, 'New Step');
    });

    test('round-trip serialization should preserve all data', () {
      final steps = [
        TaskStep(id: 's1', title: 'Step 1', isCompleted: false),
        TaskStep(id: 's2', title: 'Step 2', isCompleted: true),
      ];

      final original = TaskItem(
        id: '10',
        title: 'Round Trip',
        isCompleted: false,
        isImportant: true,
        createdAt: yesterday,
        updatedAt: now,
        dueAt: tomorrow,
        notes: 'Round trip notes',
        steps: steps,
      );

      final restored = TaskItem.fromMap(original.toMap());

      expect(restored.id, original.id);
      expect(restored.title, original.title);
      expect(restored.isCompleted, original.isCompleted);
      expect(restored.isImportant, original.isImportant);
      expect(restored.dueAt, original.dueAt);
      expect(restored.notes, original.notes);
      expect(restored.steps.length, original.steps.length);
      expect(restored.steps.first.title, original.steps.first.title);
      expect(restored.steps.last.isCompleted, original.steps.last.isCompleted);
    });
  });
}
