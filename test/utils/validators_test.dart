import 'package:flutter_test/flutter_test.dart';

import 'package:equilibra/utils/validators.dart';

void main() {
  group('validateFullName', () {
    test('accepts a normal name with accents and ñ', () {
      expect(validateFullName('María José Ñañez'), isNull);
    });

    test('trims leading/trailing spaces before validating', () {
      expect(validateFullName('  Ana Torres  '), isNull);
    });

    test('rejects empty or whitespace-only input', () {
      expect(validateFullName(''), isNotNull);
      expect(validateFullName('   '), isNotNull);
      expect(validateFullName(null), isNotNull);
    });

    test('rejects names with digits', () {
      expect(validateFullName('Maria2'), isNotNull);
    });

    test('rejects names with symbols', () {
      expect(validateFullName('María!'), isNotNull);
      expect(validateFullName('Ana-Torres'), isNotNull);
    });

    test('rejects names shorter than 2 characters', () {
      expect(validateFullName('A'), isNotNull);
    });

    test('rejects names longer than 60 characters', () {
      expect(validateFullName('A' * 61), isNotNull);
    });

    test('rejects double spaces between words', () {
      expect(validateFullName('María  José'), isNotNull);
    });
  });

  group('validateEmail', () {
    test('accepts a valid email', () {
      expect(validateEmail('user@example.com'), isNull);
    });

    test('rejects empty input', () {
      expect(validateEmail(''), isNotNull);
      expect(validateEmail(null), isNotNull);
    });

    test('rejects malformed emails', () {
      expect(validateEmail('not-an-email'), isNotNull);
      expect(validateEmail('user@'), isNotNull);
    });
  });

  group('validatePassword', () {
    test('accepts an 8+ character password', () {
      expect(validatePassword('abcdefgh'), isNull);
    });

    test('rejects empty input', () {
      expect(validatePassword(''), isNotNull);
      expect(validatePassword(null), isNotNull);
    });

    test('rejects passwords shorter than 8 characters', () {
      expect(validatePassword('short'), isNotNull);
    });
  });

  group('validatePasswordConfirmation', () {
    test('accepts a matching confirmation', () {
      expect(validatePasswordConfirmation('secret123', 'secret123'), isNull);
    });

    test('rejects empty confirmation', () {
      expect(validatePasswordConfirmation('', 'secret123'), isNotNull);
    });

    test('rejects a non-matching confirmation', () {
      expect(validatePasswordConfirmation('other456', 'secret123'), isNotNull);
    });
  });

  group('validatePhone', () {
    test('accepts a valid phone with country code, spaces and dashes', () {
      expect(validatePhone('+51 987-654-321'), isNull);
    });

    test('treats empty as valid when not required', () {
      expect(validatePhone(''), isNull);
      expect(validatePhone(null), isNull);
    });

    test('rejects empty when required', () {
      expect(validatePhone('', required: true), isNotNull);
    });

    test('rejects letters', () {
      expect(validatePhone('abc1234567'), isNotNull);
    });

    test('rejects too few digits', () {
      expect(validatePhone('12345'), isNotNull);
    });

    test('rejects too many digits', () {
      expect(validatePhone('1234567890123456'), isNotNull);
    });
  });

  group('validateQuantity', () {
    test('treats empty as valid when not required', () {
      expect(validateQuantity(''), isNull);
      expect(validateQuantity(null), isNull);
    });

    test('rejects empty when required', () {
      expect(validateQuantity('', required: true), isNotNull);
    });

    test('accepts integers and decimals with "." or ","', () {
      expect(validateQuantity('7', min: 0, max: 16), isNull);
      expect(validateQuantity('7.5', min: 0, max: 16), isNull);
      expect(validateQuantity('7,5', min: 0, max: 16), isNull);
    });

    test('rejects non-numeric input', () {
      expect(validateQuantity('abc', min: 0, max: 16), isNotNull);
    });

    test('rejects negative values', () {
      expect(validateQuantity('-1', min: 0, max: 16), isNotNull);
    });

    test('rejects values above the max', () {
      expect(validateQuantity('20', min: 0, max: 16), isNotNull);
    });
  });

  group('validateFreeText', () {
    test('rejects empty when required', () {
      expect(validateFreeText('', maxLength: 80, required: true), isNotNull);
    });

    test('treats whitespace-only as empty', () {
      expect(validateFreeText('   ', maxLength: 80, required: true), isNotNull);
    });

    test('accepts empty when not required', () {
      expect(validateFreeText('', maxLength: 80, required: false), isNull);
    });

    test('accepts text within the max length', () {
      expect(validateFreeText('Meditar 10 minutos', maxLength: 80), isNull);
    });

    test('rejects text longer than the max length', () {
      expect(validateFreeText('A' * 81, maxLength: 80), isNotNull);
    });
  });

  group('validateGoalDate', () {
    test('accepts null (optional field)', () {
      expect(validateGoalDate(null), isNull);
    });

    test('accepts today', () {
      final now = DateTime.now();
      expect(validateGoalDate(DateTime(now.year, now.month, now.day)), isNull);
    });

    test('accepts a future date', () {
      expect(
        validateGoalDate(DateTime.now().add(const Duration(days: 30))),
        isNull,
      );
    });

    test('rejects a past date', () {
      expect(
        validateGoalDate(DateTime.now().subtract(const Duration(days: 1))),
        isNotNull,
      );
    });
  });

  group('validateDescription', () {
    test('accepts a normal sentence, even with numbers in it', () {
      expect(
        validateDescription('Dormí 7 horas y me sentí mejor', maxLength: 300),
        isNull,
      );
    });

    test('treats empty as valid when not required', () {
      expect(validateDescription('', maxLength: 300, required: false), isNull);
    });

    test('rejects empty when required', () {
      expect(validateDescription('', maxLength: 300, required: true),
          isNotNull);
    });

    test('rejects a description that is only a number', () {
      expect(validateDescription('123', maxLength: 300), isNotNull);
      expect(validateDescription('2024', maxLength: 300), isNotNull);
    });

    test('rejects a description that is only symbols', () {
      expect(validateDescription('!!!???', maxLength: 300), isNotNull);
    });

    test('rejects text shorter than 3 letters', () {
      expect(validateDescription('a1', maxLength: 300), isNotNull);
    });

    test('rejects a single character repeated (gibberish)', () {
      expect(validateDescription('aaaaaaaa', maxLength: 300), isNotNull);
    });

    test('rejects text longer than the max length', () {
      expect(validateDescription('Palabra ' * 100, maxLength: 300),
          isNotNull);
    });
  });

  group('validateLabel', () {
    test('accepts a normal word', () {
      expect(validateLabel('Ansioso'), isNull);
      expect(validateLabel('Meditación'), isNull);
    });

    test('rejects empty input', () {
      expect(validateLabel(''), isNotNull);
      expect(validateLabel(null), isNotNull);
    });

    test('rejects numbers', () {
      expect(validateLabel('123'), isNotNull);
      expect(validateLabel('Ansioso2'), isNotNull);
    });

    test('rejects symbols', () {
      expect(validateLabel('Ansioso!'), isNotNull);
    });

    test('rejects a single character', () {
      expect(validateLabel('A'), isNotNull);
    });

    test('rejects text longer than the max length', () {
      expect(validateLabel('A' * 31), isNotNull);
    });
  });

  group('normalizeWhitespace', () {
    test('trims and collapses internal spaces', () {
      expect(normalizeWhitespace('  María   José  '), 'María José');
    });
  });
}
