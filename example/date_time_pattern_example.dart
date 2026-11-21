import 'package:date_time_pattern/date_time_pattern.dart';

void main() {
  final timestamp = yyyy.hyphen.MM.hyphen.dd.T.HH.colon.mm.colon.ss.dot.SSS;
  final instant = timestamp.parse('2028-02-29T09:30:45.123', utc: true);
  print(timestamp.format(instant));

  final clockTime = HH.colon.mm;
  final meeting = clockTime.parse(
    '09:30',
    referenceDate: DateTime(2028, 2, 29),
  );
  print(yyyy.slash.MM.slash.dd.space.HH.colon.mm.format(meeting));
}
