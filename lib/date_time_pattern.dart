/// Typed patterns for fixed-width date and time formatting and parsing.
///
/// Start with [yyyy] or [HH] and use the exposed getters to add fields and
/// separators. For example, `yyyy.hyphen.MM.hyphen.dd` represents `2028-02-29`.
library;

// ignore_for_file: constant_identifier_names
// ignore_for_file: non_constant_identifier_names

// ============================
// Public tokens (entry points)
// ============================
/// The entry token for a four-digit year. Use [yyyy] to start a date pattern.
class const YyyyToken();

/// The entry token for a two-digit hour. Use [HH] to start a time pattern.
class const HHToken();

/// The start of a date pattern, such as `yyyy.hyphen.MM.hyphen.dd`.
const yyyy = YyyyToken();

/// The start of a time pattern, such as `HH.colon.mm.colon.ss`.
const HH = HHToken();

// ============================
// Public interfaces (returned types)
// ============================
/// A pattern that formats and parses the same fixed-width representation.
///
/// The text carries the specified numeric fields and separators. It does not
/// carry a time zone. Parsing supplies defaults for omitted fields, so text
/// produced by [format] may represent less information than its input value.
abstract interface class DateTimePattern() {
  /// Formats the calendar and clock fields of [dateTime] in its own zone.
  ///
  /// Convert [dateTime] with [DateTime.toUtc] first to format UTC fields.
  /// Millisecond fields omit microseconds.
  /// Throws [RangeError] if a year field is requested outside 0000–9999.
  String format(DateTime dateTime);

  /// Parses [input] strictly as local time, or as UTC when [utc] is true.
  ///
  /// A time-only pattern uses the calendar date of [referenceDate], without
  /// converting it to the result's zone. When omitted, the current date in
  /// the result's zone is used. A year-and-month pattern defaults to day 1,
  /// and missing time fields default to zero.
  ///
  /// Numeric fields must have the exact width and use ASCII digits. The entire
  /// input must match, including separators. Throws [FormatException] for a
  /// shape mismatch or an invalid date or time.
  DateTime parse(String input, {DateTime? referenceDate, bool utc = false});

  /// Formats the current local time, or the value supplied by [clock].
  ///
  /// Supply a fixed clock for deterministic output. A clock that returns a UTC
  /// value produces UTC fields without conversion.
  String now({DateTime Function()? clock});
}

// ---- Date chain ----

/// A date pattern after its year. Append a month, optionally with a separator.
abstract interface class DateAfterYyyy() extends DateTimePattern {
  DateAfterMonthSeparator get hyphen;
  DateAfterMonthSeparator get slash;
  DateAfterMonthSeparator get none;
  DateAfterMM get MM;
}

/// A date pattern awaiting a two-digit month after a separator.
abstract interface class DateAfterMonthSeparator() extends DateTimePattern {
  DateAfterMM get MM;
}

/// A year-and-month pattern. Append a day when it is part of the input.
abstract interface class DateAfterMM() extends DateTimePattern {
  DateAfterDaySeparator get hyphen;
  DateAfterDaySeparator get slash;
  DateAfterDaySeparator get none;

  DateAfterDd get dd;
}

/// A date pattern awaiting a two-digit day after a separator.
abstract interface class DateAfterDaySeparator() extends DateTimePattern {
  DateAfterDd get dd;
}

/// A complete date pattern that can be followed by a 24-hour time.
abstract interface class DateAfterDd() extends DateTimePattern {
  DateAfterDdJoin get space;
  DateAfterDdJoin get T;
  DateAfterDdJoin get none;

  TimeAfterHH get HH;
}

/// A date followed by its date–time separator, awaiting an hour.
abstract interface class DateAfterDdJoin() extends DateTimePattern {
  TimeAfterHH get HH;
}

// ---- Time chain ----

/// A pattern through its 24-hour field, with an optional minute field next.
abstract interface class TimeAfterHH() extends DateTimePattern {
  TimeAfterMinuteSeparator get colon;
  TimeAfterMinuteSeparator get none;
  TimeAfterMm get mm;
}

/// A time pattern awaiting a two-digit minute after a separator.
abstract interface class TimeAfterMinuteSeparator() extends DateTimePattern {
  TimeAfterMm get mm;
}

/// A pattern through its minute field, with an optional second field next.
abstract interface class TimeAfterMm() extends DateTimePattern {
  TimeAfterSecondSeparator get colon;
  TimeAfterSecondSeparator get none;
  TimeAfterSs get ss;
}

/// A time pattern awaiting a two-digit second after a separator.
abstract interface class TimeAfterSecondSeparator() extends DateTimePattern {
  TimeAfterSs get ss;
}

/// A pattern through its second field, with an optional millisecond field next.
abstract interface class TimeAfterSs() extends DateTimePattern {
  TimeAfterMillisSeparator get dot;
  TimeAfterMillisSeparator get none;
}

/// A time pattern awaiting three-digit milliseconds after a separator.
abstract interface class TimeAfterMillisSeparator() extends DateTimePattern {
  TimeAfterSSS get SSS;
}

/// A complete time pattern through milliseconds.
abstract interface class TimeAfterSSS() extends DateTimePattern;

// ============================
// Public start extensions (entry sugar)
// ============================

/// Starts building a date pattern from [yyyy].
extension YyyyStart on YyyyToken {
  DateAfterYyyy get _start =>
      _DateAfterYyyyImpl(const [_TokenPart(_Part.yyyy)]);

  DateAfterMonthSeparator get hyphen => _start.hyphen;
  DateAfterMonthSeparator get slash => _start.slash;
  DateAfterMonthSeparator get none => _start.none;
  DateAfterMM get MM => _start.MM;
}

/// Starts building a time pattern from [HH].
extension HHStart on HHToken {
  TimeAfterHH get _start => _TimeAfterHHImpl(const [_TokenPart(_Part.HH)]);

  TimeAfterMinuteSeparator get colon => _start.colon;
  TimeAfterMinuteSeparator get none => _start.none;
  TimeAfterMm get mm => _start.mm;
}

// ============================
// Private implementation
// ============================

enum _Part() {
  yyyy,
  MM,
  dd,
  HH,
  mm,
  ss,
  SSS,
}

sealed class const _Token();

final class const _TokenPart(final _Part part) extends _Token;

final class const _TokenSeparator(final String s) extends _Token;

String _render(DateTime dateTime, List<_Token> tokens) {
  final b = StringBuffer();
  for (final t in tokens) {
    if (t is _TokenSeparator) {
      b.write(t.s);
      continue;
    }
    final p = (t as _TokenPart).part;
    switch (p) {
      case .yyyy:
        final year = RangeError.checkValueInInterval(
          dateTime.year,
          0,
          9999,
          "dateTime.year",
        );
        b.write(year.toString().padLeft(4, "0"));
      case .MM:
        b.write(dateTime.month.toString().padLeft(2, "0"));
      case .dd:
        b.write(dateTime.day.toString().padLeft(2, "0"));
      case .HH:
        b.write(dateTime.hour.toString().padLeft(2, "0"));
      case .mm:
        b.write(dateTime.minute.toString().padLeft(2, "0"));
      case .ss:
        b.write(dateTime.second.toString().padLeft(2, "0"));
      case .SSS:
        b.write(dateTime.millisecond.toString().padLeft(3, "0"));
    }
  }
  return b.toString();
}

int _partLength(_Part part) => switch (part) {
  _Part.yyyy => 4,
  _Part.MM => 2,
  _Part.dd => 2,
  _Part.HH => 2,
  _Part.mm => 2,
  _Part.ss => 2,
  _Part.SSS => 3,
};

int _readDigits(String input, int offset, int length) {
  if (offset + length > input.length) {
    throw FormatException("Unexpected end of input", input, input.length);
  }

  var number = 0;
  for (var index = offset; index < offset + length; index++) {
    final digit = input.codeUnitAt(index) - 0x30;
    if (digit < 0 || digit > 9) {
      throw FormatException("Expected an ASCII digit", input, index);
    }
    number = number * 10 + digit;
  }
  return number;
}

DateTime _parse(
  String input,
  List<_Token> tokens, {
  required DateTime? referenceDate,
  required bool utc,
}) {
  var pos = 0;
  int? year;
  int? month;
  int? day;
  int? hour;
  int? minute;
  int? second;
  int? millisecond;

  for (final t in tokens) {
    if (t is _TokenSeparator) {
      final sep = t.s;
      if (!input.startsWith(sep, pos)) {
        throw FormatException("Expected '$sep' at position $pos", input, pos);
      }
      pos += sep.length;
      continue;
    }

    final part = (t as _TokenPart).part;
    final len = _partLength(part);

    final value = _readDigits(input, pos, len);

    switch (part) {
      case .yyyy:
        year = value;
      case .MM:
        month = value;
      case .dd:
        day = value;
      case .HH:
        hour = value;
      case .mm:
        minute = value;
      case .ss:
        second = value;
      case .SSS:
        millisecond = value;
    }
    pos += len;
  }

  if (pos != input.length) {
    throw FormatException(
      "Unexpected characters after position $pos",
      input,
      pos,
    );
  }

  if (year == null) {
    final date =
        referenceDate ?? (utc ? DateTime.now().toUtc() : DateTime.now());
    year = date.year;
    month = date.month;
    day = date.day;
  }
  month ??= 1;
  day ??= 1;
  hour ??= 0;
  minute ??= 0;
  second ??= 0;
  millisecond ??= 0;

  final createDateTime = utc ? DateTime.utc : DateTime.new;
  final DateTime result;
  try {
    result = createDateTime(year, month, day, hour, minute, second, millisecond);
  } on ArgumentError {
    throw FormatException("Date or time is outside the DateTime range", input);
  }
  if (result.year != year ||
      result.month != month ||
      result.day != day ||
      result.hour != hour ||
      result.minute != minute ||
      result.second != second ||
      result.millisecond != millisecond) {
    throw FormatException("Invalid date or time", input);
  }
  return result;
}

abstract class _PatternBase(final List<_Token> _tokens)
    implements DateTimePattern {
  @override
  String format(DateTime dateTime) => _render(dateTime, _tokens);

  @override
  DateTime parse(String input, {DateTime? referenceDate, bool utc = false}) =>
      _parse(input, _tokens, referenceDate: referenceDate, utc: utc);

  @override
  String now({DateTime Function()? clock}) => format((clock ?? DateTime.now)());

  List<_Token> _p(_Part p) => [..._tokens, _TokenPart(p)];
  List<_Token> _s(String s) => [..._tokens, _TokenSeparator(s)];
  List<_Token> _noop() => _tokens;
}

// ---- Date impl ----

final class _DateAfterYyyyImpl(super.tokens)
    extends _PatternBase
    implements DateAfterYyyy {
  @override
  DateAfterMonthSeparator get hyphen => _DateAfterMonthSeparatorImpl(_s("-"));

  @override
  DateAfterMonthSeparator get slash => _DateAfterMonthSeparatorImpl(_s("/"));

  @override
  DateAfterMonthSeparator get none => _DateAfterMonthSeparatorImpl(_noop());

  @override
  DateAfterMM get MM => _DateAfterMMImpl(_p(_Part.MM));
}

final class _DateAfterMonthSeparatorImpl(super.tokens)
    extends _PatternBase
    implements DateAfterMonthSeparator {
  @override
  DateAfterMM get MM => _DateAfterMMImpl(_p(_Part.MM));
}

final class _DateAfterMMImpl(super.tokens)
    extends _PatternBase
    implements DateAfterMM {
  @override
  DateAfterDaySeparator get hyphen => _DateAfterDaySeparatorImpl(_s("-"));

  @override
  DateAfterDaySeparator get slash => _DateAfterDaySeparatorImpl(_s("/"));

  @override
  DateAfterDaySeparator get none => _DateAfterDaySeparatorImpl(_noop());

  @override
  DateAfterDd get dd => _DateAfterDdImpl(_p(_Part.dd));
}

final class _DateAfterDaySeparatorImpl(super.tokens)
    extends _PatternBase
    implements DateAfterDaySeparator {
  @override
  DateAfterDd get dd => _DateAfterDdImpl(_p(_Part.dd));
}

final class _DateAfterDdImpl(super.tokens)
    extends _PatternBase
    implements DateAfterDd {
  @override
  DateAfterDdJoin get space => _DateAfterDdJoinImpl(_s(" "));

  @override
  DateAfterDdJoin get T => _DateAfterDdJoinImpl(_s("T"));

  @override
  DateAfterDdJoin get none => _DateAfterDdJoinImpl(_noop());

  @override
  TimeAfterHH get HH => _TimeAfterHHImpl(_p(_Part.HH));
}

final class _DateAfterDdJoinImpl(super.tokens)
    extends _PatternBase
    implements DateAfterDdJoin {
  @override
  TimeAfterHH get HH => _TimeAfterHHImpl(_p(_Part.HH));
}

// ---- Time impl ----

final class _TimeAfterHHImpl(super.tokens)
    extends _PatternBase
    implements TimeAfterHH {
  @override
  TimeAfterMinuteSeparator get colon => _TimeAfterMinuteSeparatorImpl(_s(":"));

  @override
  TimeAfterMinuteSeparator get none => _TimeAfterMinuteSeparatorImpl(_noop());

  @override
  TimeAfterMm get mm => _TimeAfterMmImpl(_p(_Part.mm));
}

final class _TimeAfterMinuteSeparatorImpl(super.tokens)
    extends _PatternBase
    implements TimeAfterMinuteSeparator {
  @override
  TimeAfterMm get mm => _TimeAfterMmImpl(_p(_Part.mm));
}

final class _TimeAfterMmImpl(super.tokens)
    extends _PatternBase
    implements TimeAfterMm {
  @override
  TimeAfterSecondSeparator get colon => _TimeAfterSecondSeparatorImpl(_s(":"));

  @override
  TimeAfterSecondSeparator get none => _TimeAfterSecondSeparatorImpl(_noop());

  @override
  TimeAfterSs get ss => _TimeAfterSsImpl(_p(_Part.ss));
}

final class _TimeAfterSecondSeparatorImpl(super.tokens)
    extends _PatternBase
    implements TimeAfterSecondSeparator {
  @override
  TimeAfterSs get ss => _TimeAfterSsImpl(_p(_Part.ss));
}

final class _TimeAfterSsImpl(super.tokens)
    extends _PatternBase
    implements TimeAfterSs {
  @override
  TimeAfterMillisSeparator get dot => _TimeAfterMillisSeparatorImpl(_s("."));

  @override
  TimeAfterMillisSeparator get none => _TimeAfterMillisSeparatorImpl(_noop());
}

final class _TimeAfterMillisSeparatorImpl(super.tokens)
    extends _PatternBase
    implements TimeAfterMillisSeparator {
  @override
  TimeAfterSSS get SSS => _TimeAfterSSSImpl(_p(_Part.SSS));
}

final class _TimeAfterSSSImpl(super.tokens)
    extends _PatternBase
    implements TimeAfterSSS;
