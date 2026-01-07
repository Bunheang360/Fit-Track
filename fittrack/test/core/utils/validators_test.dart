import 'package:flutter_test/flutter_test.dart';
import 'package:fittrack/core/utils/validators.dart';

void main() {
  group('Validators', () {
    // =========================================================================
    // validateEmail Tests
    // =========================================================================
    group('validateEmail', () {
      test('returns error when email is null', () {
        expect(Validators.validateEmail(null), 'Email cannot be empty');
      });

      test('returns error when email is empty', () {
        expect(Validators.validateEmail(''), 'Email cannot be empty');
      });

      test('returns error when email is whitespace only', () {
        expect(Validators.validateEmail('   '), 'Email cannot be empty');
      });

      test('returns error when email has no @ symbol', () {
        expect(Validators.validateEmail('testgmail.com'), 'Invalid email format');
      });

      test('returns error when email has no dot', () {
        expect(Validators.validateEmail('test@gmailcom'), 'Invalid email format');
      });

      test('returns null for valid email', () {
        expect(Validators.validateEmail('test@gmail.com'), isNull);
      });

      test('uses custom empty message when provided', () {
        expect(
          Validators.validateEmail(null, emptyMessage: 'Please enter email'),
          'Please enter email',
        );
      });
    });

    // =========================================================================
    // validatePassword Tests
    // =========================================================================
    group('validatePassword', () {
      test('returns error when password is null', () {
        expect(Validators.validatePassword(null), 'Password cannot be empty');
      });

      test('returns error when password is empty', () {
        expect(Validators.validatePassword(''), 'Password cannot be empty');
      });

      test('returns error when password is less than 8 characters', () {
        expect(
          Validators.validatePassword('1234567'),
          'Password must be at least 8 characters',
        );
      });

      test('returns null for password with exactly 8 characters', () {
        expect(Validators.validatePassword('12345678'), isNull);
      });

      test('returns null for password longer than 8 characters', () {
        expect(Validators.validatePassword('securepassword123'), isNull);
      });

      test('uses custom minLength when provided', () {
        expect(
          Validators.validatePassword('12345', minLength: 6),
          'Password must be at least 6 characters',
        );
        expect(Validators.validatePassword('123456', minLength: 6), isNull);
      });
    });

    // =========================================================================
    // validatePasswordMatch Tests
    // =========================================================================
    group('validatePasswordMatch', () {
      test('returns error when confirm password is null', () {
        expect(
          Validators.validatePasswordMatch('password123', null),
          'Please confirm password',
        );
      });

      test('returns error when confirm password is empty', () {
        expect(
          Validators.validatePasswordMatch('password123', ''),
          'Please confirm password',
        );
      });

      test('returns error when passwords do not match', () {
        expect(
          Validators.validatePasswordMatch('password123', 'password456'),
          'Passwords do not match',
        );
      });

      test('returns null when passwords match', () {
        expect(
          Validators.validatePasswordMatch('password123', 'password123'),
          isNull,
        );
      });
    });

    // =========================================================================
    // validateUsername Tests
    // =========================================================================
    group('validateUsername', () {
      test('returns error when username is null', () {
        expect(Validators.validateUsername(null), 'Username cannot be empty');
      });

      test('returns error when username is empty', () {
        expect(Validators.validateUsername(''), 'Username cannot be empty');
      });

      test('returns null for valid username', () {
        expect(Validators.validateUsername('john_doe'), isNull);
      });
    });

    // =========================================================================
    // validateName Tests
    // =========================================================================
    group('validateName', () {
      test('returns error when name is null', () {
        expect(Validators.validateName(null), 'Name cannot be empty');
      });

      test('returns error when name is whitespace only', () {
        expect(Validators.validateName('   '), 'Name cannot be empty');
      });

      test('returns null for valid name', () {
        expect(Validators.validateName('John Doe'), isNull);
      });
    });

    // =========================================================================
    // validateRegistration Tests
    // =========================================================================
    group('validateRegistration', () {
      test('returns username error first when username is empty', () {
        expect(
          Validators.validateRegistration(
            username: '',
            email: 'test@gmail.com',
            password: 'password123',
            confirmPassword: 'password123',
          ),
          'Username cannot be empty',
        );
      });

      test('returns email error when email is invalid', () {
        expect(
          Validators.validateRegistration(
            username: 'john_doe',
            email: 'invalid-email',
            password: 'password123',
            confirmPassword: 'password123',
          ),
          'Invalid email format',
        );
      });

      test('returns password error when password is too short', () {
        expect(
          Validators.validateRegistration(
            username: 'john_doe',
            email: 'test@gmail.com',
            password: '123',
            confirmPassword: '123',
          ),
          'Password must be at least 8 characters',
        );
      });

      test('returns match error when passwords do not match', () {
        expect(
          Validators.validateRegistration(
            username: 'john_doe',
            email: 'test@gmail.com',
            password: 'password123',
            confirmPassword: 'password456',
          ),
          'Passwords do not match',
        );
      });

      test('returns null when all fields are valid', () {
        expect(
          Validators.validateRegistration(
            username: 'john_doe',
            email: 'test@gmail.com',
            password: 'password123',
            confirmPassword: 'password123',
          ),
          isNull,
        );
      });
    });
  });
}
