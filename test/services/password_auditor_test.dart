import 'package:flutter_test/flutter_test.dart';
import 'package:dev_vault/services/password_auditor.dart';
import 'package:dev_vault/models/vault_item.dart';

void main() {
  group('PasswordAuditor.scorePassword', () {
    test('should return 0 for empty password', () {
      expect(PasswordAuditor.scorePassword(''), 0);
    });

    test('should give low score for short password', () {
      final score = PasswordAuditor.scorePassword('abc');

      expect(score, 20);
    });

    test('should give points for length >= 8', () {
      final score = PasswordAuditor.scorePassword('abcdefgh');

      expect(score, greaterThanOrEqualTo(10));
    });

    test('should give points for length >= 10', () {
      final score = PasswordAuditor.scorePassword('abcdefghij');

      expect(score, greaterThanOrEqualTo(15));
    });

    test('should give points for length >= 12', () {
      final score = PasswordAuditor.scorePassword('abcdefghijkl');

      expect(score, greaterThanOrEqualTo(20));
    });

    test('should give max length points for length >= 16', () {
      final score = PasswordAuditor.scorePassword('abcdefghijklmnop');

      expect(score, greaterThanOrEqualTo(25));
    });

    test('should give points for uppercase', () {
      final base = PasswordAuditor.scorePassword('abcdefgh');
      final withUpper = PasswordAuditor.scorePassword('Abcdefgh');

      expect(withUpper, greaterThan(base));
    });

    test('should give points for digits', () {
      final base = PasswordAuditor.scorePassword('abcdefgh');
      final withDigits = PasswordAuditor.scorePassword('abcdefg1');

      expect(withDigits, greaterThan(base));
    });

    test('should give points for symbols', () {
      final base = PasswordAuditor.scorePassword('abcdefgh');
      final withSymbol = PasswordAuditor.scorePassword('abcdefg!');

      expect(withSymbol, greaterThan(base));
    });

    test('should give high score for strong password', () {
      final score = PasswordAuditor.scorePassword('MyStr0ng!Pass#2024');

      expect(score, greaterThanOrEqualTo(80));
    });

    test('should penalize common patterns', () {
      final score = PasswordAuditor.scorePassword('password123');

      expect(score, lessThan(PasswordAuditor.scorePassword('Xy9#mK2!pLqR')));
    });

    test('should penalize repeated characters', () {
      final score = PasswordAuditor.scorePassword('aaaaaa123!');

      expect(score, lessThan(PasswordAuditor.scorePassword('abcxyz123!')));
    });

    test('should clamp score to minimum 0', () {
      final score = PasswordAuditor.scorePassword('aaa');

      expect(score, greaterThanOrEqualTo(0));
    });

    test('should clamp score to maximum 100', () {
      final score = PasswordAuditor.scorePassword(
        'VeryL0ng!Str0ng#Passw0rd\$2024',
      );

      expect(score, lessThanOrEqualTo(100));
    });

    test('should detect "123456" as common pattern', () {
      final score = PasswordAuditor.scorePassword('123456');

      expect(score, lessThan(30));
    });

    test('should detect "qwerty" as common pattern', () {
      final score = PasswordAuditor.scorePassword('Qwerty123!');

      expect(score, lessThan(PasswordAuditor.scorePassword('Xy9#mK2!pL')));
    });
  });

  group('PasswordAuditor.strengthLabel', () {
    test('should return "Excelente" for score >= 80', () {
      expect(PasswordAuditor.strengthLabel(80), 'Excelente');
      expect(PasswordAuditor.strengthLabel(90), 'Excelente');
      expect(PasswordAuditor.strengthLabel(100), 'Excelente');
    });

    test('should return "Fuerte" for score 60-79', () {
      expect(PasswordAuditor.strengthLabel(60), 'Fuerte');
      expect(PasswordAuditor.strengthLabel(70), 'Fuerte');
      expect(PasswordAuditor.strengthLabel(79), 'Fuerte');
    });

    test('should return "Regular" for score 40-59', () {
      expect(PasswordAuditor.strengthLabel(40), 'Regular');
      expect(PasswordAuditor.strengthLabel(50), 'Regular');
      expect(PasswordAuditor.strengthLabel(59), 'Regular');
    });

    test('should return "Débil" for score < 40', () {
      expect(PasswordAuditor.strengthLabel(0), 'Débil');
      expect(PasswordAuditor.strengthLabel(20), 'Débil');
      expect(PasswordAuditor.strengthLabel(39), 'Débil');
    });
  });

  group('PasswordAuditor.findWeakPasswords', () {
    test('should return empty list for no items', () {
      final result = PasswordAuditor.findWeakPasswords([]);

      expect(result, isEmpty);
    });

    test('should return empty list when all passwords are strong', () {
      final items = [
        VaultItem(
          id: '1',
          title: 'Strong',
          updatedAt: DateTime.now(),
          createdAt: DateTime.now(),
          password: 'Str0ng!Pass#2024',
        ),
      ];

      final result = PasswordAuditor.findWeakPasswords(items);

      expect(result, isEmpty);
    });

    test('should identify weak passwords (less than 8 chars)', () {
      final items = [
        VaultItem(
          id: '1',
          title: 'Weak Account',
          updatedAt: DateTime.now(),
          createdAt: DateTime.now(),
          password: 'short',
        ),
        VaultItem(
          id: '2',
          title: 'Strong Account',
          updatedAt: DateTime.now(),
          createdAt: DateTime.now(),
          password: 'Str0ng!Pass#2024',
        ),
      ];

      final result = PasswordAuditor.findWeakPasswords(items);

      expect(result, contains('Weak Account'));
      expect(result, isNot(contains('Strong Account')));
    });

    test('should ignore items with no password', () {
      final items = [
        VaultItem(
          id: '1',
          title: 'No Password',
          updatedAt: DateTime.now(),
          createdAt: DateTime.now(),
        ),
      ];

      final result = PasswordAuditor.findWeakPasswords(items);

      expect(result, isEmpty);
    });
  });

  group('PasswordAuditor.findDuplicatePasswords', () {
    test('should return empty list for no items', () {
      final result = PasswordAuditor.findDuplicatePasswords([]);

      expect(result, isEmpty);
    });

    test('should return empty list when no duplicates', () {
      final items = [
        VaultItem(
          id: '1',
          title: 'Account A',
          updatedAt: DateTime.now(),
          createdAt: DateTime.now(),
          password: 'Pass1!',
        ),
        VaultItem(
          id: '2',
          title: 'Account B',
          updatedAt: DateTime.now(),
          createdAt: DateTime.now(),
          password: 'Pass2@',
        ),
      ];

      final result = PasswordAuditor.findDuplicatePasswords(items);

      expect(result, isEmpty);
    });

    test('should identify duplicate passwords', () {
      final items = [
        VaultItem(
          id: '1',
          title: 'Account A',
          updatedAt: DateTime.now(),
          createdAt: DateTime.now(),
          password: 'SamePass1!',
        ),
        VaultItem(
          id: '2',
          title: 'Account B',
          updatedAt: DateTime.now(),
          createdAt: DateTime.now(),
          password: 'SamePass1!',
        ),
        VaultItem(
          id: '3',
          title: 'Account C',
          updatedAt: DateTime.now(),
          createdAt: DateTime.now(),
          password: 'Different!',
        ),
      ];

      final result = PasswordAuditor.findDuplicatePasswords(items);

      expect(result, hasLength(1));
      expect(result.first, containsAll(['Account A', 'Account B']));
    });

    test('should ignore items with no password', () {
      final items = [
        VaultItem(
          id: '1',
          title: 'Account A',
          updatedAt: DateTime.now(),
          createdAt: DateTime.now(),
          password: 'Same!',
        ),
        VaultItem(
          id: '2',
          title: 'Account B',
          updatedAt: DateTime.now(),
          createdAt: DateTime.now(),
        ),
      ];

      final result = PasswordAuditor.findDuplicatePasswords(items);

      expect(result, isEmpty);
    });

    test('should find multiple duplicate groups', () {
      final items = [
        VaultItem(
          id: '1',
          title: 'A1',
          updatedAt: DateTime.now(),
          createdAt: DateTime.now(),
          password: 'Pass1!',
        ),
        VaultItem(
          id: '2',
          title: 'A2',
          updatedAt: DateTime.now(),
          createdAt: DateTime.now(),
          password: 'Pass1!',
        ),
        VaultItem(
          id: '3',
          title: 'B1',
          updatedAt: DateTime.now(),
          createdAt: DateTime.now(),
          password: 'Pass2!',
        ),
        VaultItem(
          id: '4',
          title: 'B2',
          updatedAt: DateTime.now(),
          createdAt: DateTime.now(),
          password: 'Pass2!',
        ),
      ];

      final result = PasswordAuditor.findDuplicatePasswords(items);

      expect(result, hasLength(2));
    });
  });

  group('PasswordAuditor.calculateOverallSecurityScore', () {
    test('should return 100 for empty list', () {
      expect(PasswordAuditor.calculateOverallSecurityScore([]), 100);
    });

    test('should return 100 when no items have passwords', () {
      final items = [
        VaultItem(
          id: '1',
          title: 'No Pass',
          updatedAt: DateTime.now(),
          createdAt: DateTime.now(),
        ),
      ];

      expect(PasswordAuditor.calculateOverallSecurityScore(items), 100);
    });

    test('should calculate average score for items with passwords', () {
      final items = [
        VaultItem(
          id: '1',
          title: 'Strong',
          updatedAt: DateTime.now(),
          createdAt: DateTime.now(),
          password: 'Str0ng!Pass#2024',
        ),
        VaultItem(
          id: '2',
          title: 'Weak',
          updatedAt: DateTime.now(),
          createdAt: DateTime.now(),
          password: 'weak',
        ),
      ];

      final score = PasswordAuditor.calculateOverallSecurityScore(items);

      expect(score, inInclusiveRange(0, 100));
    });
  });
}
