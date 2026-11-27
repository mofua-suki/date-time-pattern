import 'package:date_time_pattern/date_time_pattern.dart';
import 'package:test/test.dart';

void main() {
  final date = yyyy.hyphen.MM.hyphen.dd;
  final time = HH.colon.mm.colon.ss;

  test('validates the calendar and preserves a valid leap day', () {
    expect(date.parse('2028-02-29', utc: true), DateTime.utc(2028, 2, 29));
    for (final input in [
      '2026-02-29',
      '2026-02-30',
      '2026-01-00',
      '2026-13-01',
    ]) {
      expect(
        () => date.parse(input, utc: true),
        throwsFormatException,
        reason: input,
      );
    }
  });

  test('rejects times that roll over when constructing a DateTime', () {
    for (final input in ['24:00:00', '09:60:00', '09:00:60']) {
      expect(
        () => time.parse(input, utc: true),
        throwsFormatException,
        reason: input,
      );
    }
  });

  test('accepts only fixed-width ASCII digits', () {
    for (final input in [
      '+026-02-01',
      '2026- 2-01',
      '2026-02-１1',
      '2026-02-1\n',
    ]) {
      expect(() => date.parse(input), throwsFormatException, reason: input);
    }
  });

  test('supports the four-digit year boundaries', () {
    expect(date.format(date.parse('0000-01-01', utc: true)), '0000-01-01');
    expect(date.format(date.parse('9999-12-31', utc: true)), '9999-12-31');
    expect(() => date.format(DateTime.utc(-1)), throwsRangeError);
    expect(() => date.format(DateTime.utc(10000)), throwsRangeError);
  });

  test('takes calendar fields from the explicit reference date', () {
    final reference = DateTime.utc(2028, 2, 29, 23, 40);
    final local = time.parse('09:30:45', referenceDate: reference);
    final utc = time.parse('09:30:45', referenceDate: reference, utc: true);

    expect(local.isUtc, isFalse);
    expect(local, DateTime(2028, 2, 29, 9, 30, 45));
    expect(utc.isUtc, isTrue);
    expect(utc, DateTime.utc(2028, 2, 29, 9, 30, 45));
  });

  test('rejects a time beyond the DateTime range on the reference day', () {
    final reference = DateTime.utc(275760, 9, 13);
    expect(
      () => HH.colon.mm.parse('00:01', referenceDate: reference, utc: true),
      throwsA(
        isA<FormatException>().having((error) => error.source, 'source', '00:01'),
      ),
    );
    expect(
      HH.colon.mm.parse('00:00', referenceDate: reference, utc: true),
      reference,
    );
  });

  test('ignores the reference date when the pattern itself has a date', () {
    final result = yyyy.hyphen.MM.parse(
      '2028-02',
      referenceDate: DateTime.utc(2026, 1, 10),
      utc: true,
    );
    expect(result, DateTime.utc(2028, 2));
  });

  test('now formats the date and time supplied by the clock', () {
    final fixedValue = DateTime.utc(2028, 2, 29, 9, 30, 45);
    expect(time.now(clock: () => fixedValue), '09:30:45');
  });
}
