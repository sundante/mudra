import 'package:flutter_test/flutter_test.dart';
import 'package:mudra/data/database.dart';

void main() {
  test('user database names scope local finance records by identity', () {
    expect(userDatabaseName('user-123'), 'mudra_user_user_123');
    expect(
        userDatabaseName('other@example.com'), 'mudra_user_other_example_com');
  });

  group('bootstrapWithRecovery', () {
    test('returns normal startup result when open and validate succeed',
        () async {
      var resetCalled = false;
      var validateCalls = 0;

      final result = await bootstrapWithRecovery<String>(
        open: () async => 'primary-db',
        validate: (_) async {
          validateCalls++;
        },
        reset: () async {
          resetCalled = true;
        },
      );

      expect(result.resource, 'primary-db');
      expect(result.didRecover, isFalse);
      expect(validateCalls, 1);
      expect(resetCalled, isFalse);
    });

    test('resets and reopens when initial validation fails', () async {
      var openCalls = 0;
      var resetCalls = 0;

      final result = await bootstrapWithRecovery<String>(
        open: () async {
          openCalls++;
          return openCalls == 1 ? 'stale-db' : 'recovered-db';
        },
        validate: (db) async {
          if (db == 'stale-db') {
            throw StateError('stale local data');
          }
        },
        reset: () async {
          resetCalls++;
        },
      );

      expect(openCalls, 2);
      expect(resetCalls, 1);
      expect(result.resource, 'recovered-db');
      expect(result.didRecover, isTrue);
    });
  });
}
