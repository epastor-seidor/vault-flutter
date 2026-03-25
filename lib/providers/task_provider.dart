import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:dev_vault/models/task_item.dart';
import 'package:uuid/uuid.dart';

class TaskNotifier extends Notifier<List<TaskItem>> {
  @override
  List<TaskItem> build() {
    final box = Hive.box('tasks');
    final List<dynamic> raw = box.values.toList();
    return raw
        .map((t) => TaskItem.fromMap(Map<String, dynamic>.from(t)))
        .toList();
  }

  late final _box = Hive.box('tasks');

  Future<void> addTask(TaskItem task) async {
    await _box.put(task.id, task.toMap());
    state = [...state, task];
  }

  Future<void> updateTask(TaskItem task) async {
    await _box.put(task.id, task.toMap());
    state = [
      for (final t in state)
        if (t.id == task.id) task else t
    ];
  }

  Future<void> deleteTask(String id) async {
    await _box.delete(id);
    state = state.where((t) => t.id != id).toList();
  }
}

final taskProvider = NotifierProvider<TaskNotifier, List<TaskItem>>(() {
  return TaskNotifier();
});

const _uuid = Uuid();
String generateTaskId() => _uuid.v4();

