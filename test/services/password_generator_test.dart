import 'package:flutter_test/flutter_test.dart';
import 'package:dev_vault/services/password_generator.dart';

void main() {
  group('PasswordGenerator', () {
    test('should generate password with default settings', () {
      final password = PasswordGenerator.generate();

      expect(password.length, 16);
    });

    test('should generate password with specified length', () {
      final password = PasswordGenerator.generate(length: 24);

      expect(password.length, 24);
    });

    test('should clamp minimum length to 8', () {
      final password = PasswordGenerator.generate(length: 1);

      expect(password.length, 8);
    });

    test('should clamp maximum length to 64', () {
      final password = PasswordGenerator.generate(length: 100);

      expect(password.length, 64);
    });

    test('should include uppercase when enabled', () {
      final password = PasswordGenerator.generate(
        length: 16,
        includeUppercase: true,
        includeLowercase: false,
        includeDigits: false,
        includeSymbols: false,
      );

      expect(password.contains(RegExp(r'[A-Z]')), isTrue);
    });

    test('should include lowercase when enabled', () {
      final password = PasswordGenerator.generate(
        length: 16,
        includeUppercase: false,
        includeLowercase: true,
        includeDigits: false,
        includeSymbols: false,
      );

      expect(password.contains(RegExp(r'[a-z]')), isTrue);
    });

    test('should include digits when enabled', () {
      final password = PasswordGenerator.generate(
        length: 16,
        includeUppercase: false,
        includeLowercase: false,
        includeDigits: true,
        includeSymbols: false,
      );

      expect(password.contains(RegExp(r'[0-9]')), isTrue);
    });

    test('should include symbols when enabled', () {
      final password = PasswordGenerator.generate(
        length: 16,
        includeUppercase: false,
        includeLowercase: false,
        includeDigits: false,
        includeSymbols: true,
      );

      expect(
        password.contains(RegExp(r'[!@#\$%^&*()_+\-=\[\]{}|;:,.<>?]')),
        isTrue,
      );
    });

    test('should fallback to lowercase+digits when all options disabled', () {
      final password = PasswordGenerator.generate(
        length: 16,
        includeUppercase: false,
        includeLowercase: false,
        includeDigits: false,
        includeSymbols: false,
      );

      expect(password.length, 16);
      expect(password.contains(RegExp(r'[a-z0-9]')), isTrue);
    });

    test('should generate different passwords on subsequent calls', () {
      final password1 = PasswordGenerator.generate();
      final password2 = PasswordGenerator.generate();

      expect(password1, isNot(equals(password2)));
    });

    test('should include at least one of each enabled type', () {
      final password = PasswordGenerator.generate(
        length: 16,
        includeUppercase: true,
        includeLowercase: true,
        includeDigits: true,
        includeSymbols: true,
      );

      expect(
        password.contains(RegExp(r'[A-Z]')),
        isTrue,
        reason: 'Should have uppercase',
      );
      expect(
        password.contains(RegExp(r'[a-z]')),
        isTrue,
        reason: 'Should have lowercase',
      );
      expect(
        password.contains(RegExp(r'[0-9]')),
        isTrue,
        reason: 'Should have digits',
      );
      expect(
        password.contains(RegExp(r'[!@#\$%^&*()_+\-=\[\]{}|;:,.<>?]')),
        isTrue,
        reason: 'Should have symbols',
      );
    });

    test('should generate password with minimum clamped length of 8', () {
      final password = PasswordGenerator.generate(length: 5);

      expect(password.length, 8);
    });

    test('should generate password with maximum clamped length of 64', () {
      final password = PasswordGenerator.generate(length: 128);

      expect(password.length, 64);
    });

    test('should generate password at boundary length of 8', () {
      final password = PasswordGenerator.generate(length: 8);

      expect(password.length, 8);
    });

    test('should generate password at boundary length of 64', () {
      final password = PasswordGenerator.generate(length: 64);

      expect(password.length, 64);
    });
  });
}
