import 'package:sentry/src/transport/rate_limit_parser.dart';
import 'package:sentry/src/transport/rate_limit_category.dart';
import 'package:test/test.dart';

void main() {
  group('parseRateLimitHeader', () {
    test('single rate limit with single category', () {
      final sut = RateLimitParser('50:transaction').parseRateLimitHeader();

      expect(sut.length, 1);
      expect(sut[RateLimitCategory.transaction], 50000);
    });

    test('single rate limit with multiple categories', () {
      final sut = RateLimitParser('50:transaction;session').parseRateLimitHeader();

      expect(sut.length, 2);
      expect(sut[RateLimitCategory.transaction], 50000);
      expect(sut[RateLimitCategory.session], 50000);
    });

    test('don`t apply rate limit for unknown categories ', () {
      final sut = RateLimitParser('50:somethingunknown').parseRateLimitHeader();

      expect(sut.length, 0);
    });

    test('apply all if there are no categories', () {
      final sut = RateLimitParser('50').parseRateLimitHeader();

      expect(sut.length, 1);
      expect(sut[RateLimitCategory.all], 50000);
    });

    test('multiple rate limits', () {
      final sut = RateLimitParser('50:transaction, 70:session').parseRateLimitHeader();

      expect(sut.length, 2);
      expect(sut[RateLimitCategory.transaction], 50000);
      expect(sut[RateLimitCategory.session], 70000);
    });

    test('ignore case', () {
      final sut = RateLimitParser('50:TRANSACTION').parseRateLimitHeader();

      expect(sut.length, 1);
      expect(sut[RateLimitCategory.transaction], 50000);
    });

    test('un-parseable returns default duration', () {
      final sut = RateLimitParser('foobar:transaction').parseRateLimitHeader();

      expect(sut.length, 1);
      expect(sut[RateLimitCategory.transaction], RateLimitParser.HTTP_RETRY_AFTER_DEFAULT_DELAY_MILLIS);
    });
  });

  group('parseRetryAfterHeader', () {
    test('null returns default category all with default duration', () {
      final sut = RateLimitParser(null).parseRetryAfterHeader();

      expect(sut.length, 1);
      expect(sut[RateLimitCategory.all], RateLimitParser.HTTP_RETRY_AFTER_DEFAULT_DELAY_MILLIS);
    });

    test('parseable returns default category with duration in millis', () {
      final sut = RateLimitParser('8').parseRetryAfterHeader();

      expect(sut.length, 1);
      expect(sut[RateLimitCategory.all], 8000);
    });

    test('un-parseable returns default category with default duration', () {
      final sut = RateLimitParser('foobar').parseRetryAfterHeader();

      expect(sut.length, 1);
      expect(sut[RateLimitCategory.all], RateLimitParser.HTTP_RETRY_AFTER_DEFAULT_DELAY_MILLIS);
    });
  });
}