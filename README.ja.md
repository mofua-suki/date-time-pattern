# Date Time Pattern

[English](https://github.com/mofua-suki/date-time-pattern/blob/main/README.md) · [pub.dev](https://pub.dev/packages/date_time_pattern)

Dart の型を使って、桁数が固定された日時パターンを組み立てます。各段階で選べるフィールドと区切り文字は、その直前のフィールドで決まります。同じパターンで `DateTime` の書式化と文字列の解析ができます。

## インストール

対応する Dart SDK は 3.14.0 以上 4.0.0 未満です。

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

## パターンを組み立てる

Dart のゲッターをつないでパターンを定義すると、同じ形式の書式化と解析に繰り返し使えます。フィールド同士を区切るには、`yyyy.hyphen.MM` のように区切り文字の後ろに次のフィールドを続けます。区切り文字をパターンの末尾に置くこともできます。たとえば `yyyy.hyphen` では、2028年の日付を `2028-` と書式化し、`2028-` を2028年1月1日として解析します。

| パターン | 文字列の例 |
| --- | --- |
| `yyyy.hyphen.MM` | `2028-02` |
| `yyyy.slash.MM.slash.dd` | `2028/02/29` |
| `yyyy.MM.dd` | `20280229` |
| `HH.colon.mm` | `09:30` |
| `HH.mm.ss.none.SSS` | `093045123` |
| `yyyy.hyphen.MM.hyphen.dd.space.HH.colon.mm` | `2028-02-29 09:30` |

`yyyy`、`MM`、`dd` は年・月・日、`HH` は24時間制の時、`mm`、`ss`、`SSS` は分・秒・ミリ秒です。年月日の後に時刻を続けるには `.T`、`.space`、`.none` を使います。時・分・秒の間には `.colon` または `.none`、ミリ秒の前には `.dot` または `.none` を使えます。扱えるのは数値フィールドと定義済みの区切り文字です。ロケール固有の名称、UTC オフセット、任意の書式文字列はサポートしていません。

## 外部からの入力を解析する

解析時は入力全体がパターンと一致し、各数値が指定桁数の ASCII 数字である必要があります。区切り文字の違い、末尾の空白、存在しない日付や時刻は `FormatException` になります。

```dart
final date = yyyy.hyphen.MM.hyphen.dd;
try {
  date.parse('2027-02-29', utc: true); // この年に2月29日はありません。
} on FormatException catch (error) {
  print(error.message);
}
```

- 年と月だけなら日は1日になり、省略した時刻フィールドはゼロになります。
- `parse()` は既定でローカル時刻を返します。UTC として解釈するには `utc: true` を指定します。区切り文字の `T` はタイムゾーンに影響しません。
- 時刻だけのパターンでは、`referenceDate` の年月日をそのまま使います。結果のタイムゾーンと異なる場合も同じです。省略すると結果のタイムゾーンでの今日の日付を使います。再現可能なテストには `referenceDate` と `utc` の両方を指定してください。

基準日と時刻を組み合わせた結果が Dart の `DateTime` の表現範囲を超える場合も、`FormatException` になります。

## 日時を書式化する

`format()` は渡された `DateTime` の各フィールドをそのまま読み取ります。UTC の年月日や時刻が必要な場合は、先に `.toUtc()` で変換してください。年を含むパターンで年が `0000`〜`9999` の範囲外なら `RangeError` が発生します。文字列からは省略したフィールドや元のタイムゾーンを復元できません。`SSS` はミリ秒までを保持し、マイクロ秒を省略します。

`now()` は現在のローカル時刻を書式化します。`clockTime.now(clock: () => instant)` のように時計を渡すと出力を再現できます。時計が UTC の `DateTime` を返す場合は UTC の各フィールドを使います。

## 開発

このリポジトリのルートで次のコマンドを実行します。

```sh
dart pub get
dart analyze
dart test
```

使用例は `dart run example/date_time_pattern_example.dart` で実行できます。
