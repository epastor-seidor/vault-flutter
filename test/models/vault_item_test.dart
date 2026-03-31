import 'package:flutter_test/flutter_test.dart';
import 'package:dev_vault/models/vault_item.dart';

void main() {
  group('VaultItem', () {
    final now = DateTime(2024, 1, 15, 10, 30, 0);
    final yesterday = DateTime(2024, 1, 14, 10, 30, 0);

    test('should create a VaultItem with required fields', () {
      final item = VaultItem(
        id: '1',
        title: 'Test Credential',
        updatedAt: now,
        createdAt: yesterday,
      );

      expect(item.id, '1');
      expect(item.title, 'Test Credential');
      expect(item.url, isNull);
      expect(item.username, isNull);
      expect(item.password, isNull);
      expect(item.category, isNull);
      expect(item.notes, isNull);
      expect(item.isFavorite, isFalse);
      expect(item.updatedAt, now);
      expect(item.createdAt, yesterday);
    });

    test('should create a VaultItem with all fields', () {
      final item = VaultItem(
        id: '2',
        title: 'GitHub',
        url: 'https://github.com',
        username: 'user@example.com',
        password: 'securePass123!',
        category: 'Development',
        updatedAt: now,
        createdAt: yesterday,
        notes: 'Personal account',
        isFavorite: true,
      );

      expect(item.url, 'https://github.com');
      expect(item.username, 'user@example.com');
      expect(item.password, 'securePass123!');
      expect(item.category, 'Development');
      expect(item.notes, 'Personal account');
      expect(item.isFavorite, isTrue);
    });

    test('should convert to map correctly', () {
      final item = VaultItem(
        id: '3',
        title: 'Email',
        url: 'https://mail.google.com',
        username: 'test@gmail.com',
        password: 'password123',
        category: 'Personal',
        updatedAt: now,
        createdAt: yesterday,
        notes: 'Main email',
        isFavorite: true,
      );

      final map = item.toMap();

      expect(map['id'], '3');
      expect(map['title'], 'Email');
      expect(map['url'], 'https://mail.google.com');
      expect(map['username'], 'test@gmail.com');
      expect(map['password'], 'password123');
      expect(map['category'], 'Personal');
      expect(map['notes'], 'Main email');
      expect(map['isFavorite'], isTrue);
      expect(map['updatedAt'], now.toIso8601String());
      expect(map['createdAt'], yesterday.toIso8601String());
    });

    test('should create from map correctly', () {
      final map = {
        'id': '4',
        'title': 'Bank',
        'url': 'https://bank.com',
        'username': 'user1',
        'password': 'bankPass',
        'category': 'Finance',
        'updatedAt': now.toIso8601String(),
        'createdAt': yesterday.toIso8601String(),
        'notes': 'Savings account',
        'isFavorite': false,
      };

      final item = VaultItem.fromMap(map);

      expect(item.id, '4');
      expect(item.title, 'Bank');
      expect(item.url, 'https://bank.com');
      expect(item.username, 'user1');
      expect(item.password, 'bankPass');
      expect(item.category, 'Finance');
      expect(item.notes, 'Savings account');
      expect(item.isFavorite, isFalse);
      expect(item.updatedAt, now);
      expect(item.createdAt, yesterday);
    });

    test('should handle missing createdAt in fromMap', () {
      final map = {
        'id': '5',
        'title': 'No CreatedAt',
        'updatedAt': now.toIso8601String(),
      };

      final item = VaultItem.fromMap(map);

      expect(item.id, '5');
      expect(item.title, 'No CreatedAt');
      expect(item.createdAt, now);
      expect(item.isFavorite, isFalse);
    });

    test('should handle null optional fields in fromMap', () {
      final map = {
        'id': '6',
        'title': 'Minimal',
        'updatedAt': now.toIso8601String(),
        'createdAt': yesterday.toIso8601String(),
        'isFavorite': null,
      };

      final item = VaultItem.fromMap(map);

      expect(item.url, isNull);
      expect(item.username, isNull);
      expect(item.password, isNull);
      expect(item.category, isNull);
      expect(item.notes, isNull);
      expect(item.isFavorite, isFalse);
    });

    test('copyWith should update specified fields', () {
      final original = VaultItem(
        id: '7',
        title: 'Original',
        updatedAt: now,
        createdAt: yesterday,
      );

      final updated = original.copyWith(
        title: 'Updated',
        password: 'newPass',
        isFavorite: true,
        notes: 'Added notes',
      );

      expect(updated.id, '7');
      expect(updated.title, 'Updated');
      expect(updated.password, 'newPass');
      expect(updated.isFavorite, isTrue);
      expect(updated.notes, 'Added notes');
      expect(updated.updatedAt, now);
      expect(updated.createdAt, yesterday);
    });

    test('copyWith with no arguments should return identical item', () {
      final original = VaultItem(
        id: '8',
        title: 'Test',
        url: 'https://example.com',
        updatedAt: now,
        createdAt: yesterday,
        isFavorite: true,
      );

      final copy = original.copyWith();

      expect(copy.id, original.id);
      expect(copy.title, original.title);
      expect(copy.url, original.url);
      expect(copy.isFavorite, original.isFavorite);
      expect(copy.updatedAt, original.updatedAt);
      expect(copy.createdAt, original.createdAt);
    });

    test('round-trip serialization should preserve all data', () {
      final original = VaultItem(
        id: '9',
        title: 'Round Trip',
        url: 'https://test.com',
        username: 'user',
        password: 'pass',
        category: 'Test',
        updatedAt: now,
        createdAt: yesterday,
        notes: 'Notes here',
        isFavorite: true,
      );

      final restored = VaultItem.fromMap(original.toMap());

      expect(restored.id, original.id);
      expect(restored.title, original.title);
      expect(restored.url, original.url);
      expect(restored.username, original.username);
      expect(restored.password, original.password);
      expect(restored.category, original.category);
      expect(restored.notes, original.notes);
      expect(restored.isFavorite, original.isFavorite);
      expect(restored.updatedAt, original.updatedAt);
      expect(restored.createdAt, original.createdAt);
    });
  });
}
