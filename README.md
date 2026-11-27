# Date Time Pattern

[日本語](https://github.com/mofua-suki/date-time-pattern/blob/main/README.ja.md) · [pub.dev](https://pub.dev/packages/date_time_pattern)

Build fixed-width date and time patterns with Dart's type system. Each step exposes the fields and separators that can follow it. Use the same pattern to format a `DateTime` and parse its text representation.

## Installation

Requires Dart SDK 3.14.0 or later, below 4.0.0.

```sh
dart pub add date_time_pattern
```

```dart
import 'package:date_time_pattern/date_time_pattern.dart';

final timestamp = yyyy.hyphen.MM.hyphen.dd.T.HH.colon.mm.colon.ss.dot.SSS;
final instant = timestamp.parse('2028-02-29T09:30:45.123', utc: true);
final text = timestamp.format(instant); // 2028-02-29T09:30:45.123

final clockTime = HH.colon.mm;
final meeting = clockTime.parse('09:30', referenceDate: DateTime(2028, 2, 29));
```

## Build a pattern

Choose a chain in Dart code and reuse it to format or parse the same shape.
Complete a field after adding a separator, for example `.hyphen.MM`.

| Pattern | Example text |
| --- | --- |
| `yyyy.hyphen.MM` | `2028-02` |
| `yyyy.slash.MM.slash.dd` | `2028/02/29` |
| `yyyy.MM.dd` | `20280229` |
| `HH.colon.mm` | `09:30` |
| `HH.mm.ss.none.SSS` | `093045123` |
| `yyyy.hyphen.MM.hyphen.dd.space.HH.colon.mm` | `2028-02-29 09:30` |

`yyyy`, `MM`, and `dd` are the year, month, and day. `HH` uses a 24-hour
clock. `mm` and `ss` are minutes and seconds, and `SSS` is milliseconds.
Use `.T`, `.space`, or `.none` to join a complete date to a time. Within
the time, use `.colon` or `.none` between hours, minutes, and seconds, and
`.dot` or `.none` before milliseconds. The chain is built from Dart getters.
It supports numeric fields and literal separators rather than locale names,
UTC offsets, or arbitrary pattern strings.

## Parse external input

Parsing consumes the entire input and requires fixed-width ASCII digits.
Wrong separators, trailing whitespace, and invalid calendar or clock values
throw `FormatException`.

```dart
final date = yyyy.hyphen.MM.hyphen.dd;
try {
  date.parse('2027-02-29', utc: true); // Invalid leap day.
} on FormatException catch (error) {
  print(error.message);
}
```

- A year and month without a day resolve to day 1. Omitted time fields
  resolve to zero.
- `parse()` produces a local `DateTime` by default. Pass `utc: true` to
  interpret the text as UTC. The `T` separator does not select a zone.
- A time-only pattern takes the calendar fields from `referenceDate` as
  supplied, even if its zone differs from the result zone. Without a
  reference date, it uses today in the result zone. For reproducible tests,
  pass both `referenceDate` and the intended `utc` value.

## Format a value

`format()` reads the fields of the supplied `DateTime` as-is. Call `.toUtc()`
on the value first when you want UTC fields. Formatting a pattern with a
year outside `0000`–`9999` throws `RangeError`. The text carries only the
fields in the pattern, so omitted fields and the original zone do not round
trip. `SSS` retains milliseconds and omits microseconds.

`now()` formats the current local time. Pass a clock for reproducible output,
as in `clockTime.now(clock: () => instant)`. If the supplied clock returns a
UTC `DateTime`, the result uses its UTC fields.

## Development

Run these commands from the repository root.

```sh
dart pub get
dart analyze
dart test
```

Run the example with `dart run example/date_time_pattern_example.dart`.
