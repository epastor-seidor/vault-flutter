class TaskItem {
  final String id;
  final String title;
  final bool isCompleted;
  final bool isImportant;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? dueAt;
  final String notes;
  final List<TaskStep> steps;

  TaskItem({
    required this.id,
    required this.title,
    required this.isCompleted,
    required this.isImportant,
    required this.createdAt,
    required this.updatedAt,
    this.dueAt,
    this.notes = '',
    this.steps = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
      'isImportant': isImportant,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'dueAt': dueAt?.toIso8601String(),
      'notes': notes,
      'steps': steps.map((s) => s.toMap()).toList(),
    };
  }

  factory TaskItem.fromMap(Map<dynamic, dynamic> map) {
    return TaskItem(
      id: map['id'],
      title: map['title'] ?? '',
      isCompleted: map['isCompleted'] ?? false,
      isImportant: map['isImportant'] ?? false,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      dueAt: map['dueAt'] == null ? null : DateTime.parse(map['dueAt']),
      notes: map['notes'] ?? '',
      steps: (map['steps'] as List<dynamic>? ?? const [])
          .map((s) => TaskStep.fromMap(Map<String, dynamic>.from(s)))
          .toList(),
    );
  }

  TaskItem copyWith({
    String? title,
    bool? isCompleted,
    bool? isImportant,
    DateTime? updatedAt,
    DateTime? dueAt,
    String? notes,
    List<TaskStep>? steps,
  }) {
    return TaskItem(
      id: id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      isImportant: isImportant ?? this.isImportant,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      dueAt: dueAt ?? this.dueAt,
      notes: notes ?? this.notes,
      steps: steps ?? this.steps,
    );
  }
}

class TaskStep {
  final String id;
  final String title;
  final bool isCompleted;

  TaskStep({
    required this.id,
    required this.title,
    required this.isCompleted,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
    };
  }

  factory TaskStep.fromMap(Map<dynamic, dynamic> map) {
    return TaskStep(
      id: map['id'],
      title: map['title'] ?? '',
      isCompleted: map['isCompleted'] ?? false,
    );
  }

  TaskStep copyWith({String? title, bool? isCompleted}) {
    return TaskStep(
      id: id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

