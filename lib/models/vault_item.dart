class VaultItem {
  final String id;
  final String title;
  final String? url;
  final String? username;
  final String? password;
  final String? category;
  final DateTime updatedAt;
  final String? notes;

  VaultItem({
    required this.id,
    required this.title,
    this.url,
    this.username,
    this.password,
    this.category,
    required this.updatedAt,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'url': url,
      'username': username,
      'password': password,
      'category': category,
      'updatedAt': updatedAt.toIso8601String(),
      'notes': notes,
    };
  }

  factory VaultItem.fromMap(Map<dynamic, dynamic> map) {
    return VaultItem(
      id: map['id'],
      title: map['title'],
      url: map['url'],
      username: map['username'],
      password: map['password'],
      category: map['category'],
      updatedAt: DateTime.parse(map['updatedAt']),
      notes: map['notes'],
    );
  }

  VaultItem copyWith({
    String? id,
    String? title,
    String? url,
    String? username,
    String? password,
    String? category,
    DateTime? updatedAt,
    String? notes,
  }) {
    return VaultItem(
      id: id ?? this.id,
      title: title ?? this.title,
      url: url ?? this.url,
      username: username ?? this.username,
      password: password ?? this.password,
      category: category ?? this.category,
      updatedAt: updatedAt ?? this.updatedAt,
      notes: notes ?? this.notes,
    );
  }
}
