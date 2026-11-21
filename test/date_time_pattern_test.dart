import "package:test/test.dart";
import "package:date_time_pattern/date_time_pattern.dart";

void main() {
  group("[UnitTest] DateTimePattern", () {
    /// ---------- 正常系 ---------- ///

    group("日付フォーマット", () {
      test("[Positive] yyyy.hyphen.MM でyyyy-MM形式になる", () {
        // 準備
        final dt = DateTime(2025, 1, 15);

        // 実行
        final result = yyyy.hyphen.MM.format(dt);

        // 検証
        expect(result, "2025-01");
      });

      test("[Positive] yyyy.hyphen.MM.hyphen.dd でyyyy-MM-dd形式になる", () {
        // 準備
        final dt = DateTime(2025, 1, 15);

        // 実行
        final result = yyyy.hyphen.MM.hyphen.dd.format(dt);

        // 検証
        expect(result, "2025-01-15");
      });

      test("[Positive] yyyy.slash.MM.slash.dd でyyyy/MM/dd形式になる", () {
        // 準備
        final dt = DateTime(2025, 12, 31);

        // 実行
        final result = yyyy.slash.MM.slash.dd.format(dt);

        // 検証
        expect(result, "2025/12/31");
      });

      test("[Positive] yyyy.none.MM.none.dd で区切りなし形式になる", () {
        // 準備
        final dt = DateTime(2025, 12, 31);

        // 実行
        final result = yyyy.none.MM.none.dd.format(dt);

        // 検証
        expect(result, "20251231");
      });
    });

    group("時刻フォーマット", () {
      test("[Positive] HH.colon.mm.colon.ss でHH:mm:ss形式になる", () {
        // 準備
        final dt = DateTime(2025, 1, 1, 9, 30, 45);

        // 実行
        final result = HH.colon.mm.colon.ss.format(dt);

        // 検証
        expect(result, "09:30:45");
      });

      test("[Positive] HH.colon.mm.colon.ss.dot.SSS でミリ秒付き形式になる", () {
        // 準備
        final dt = DateTime(2025, 1, 1, 13, 42, 51, 786);

        // 実行
        final result = HH.colon.mm.colon.ss.dot.SSS.format(dt);

        // 検証
        expect(result, "13:42:51.786");
      });

      test("[Positive] HH.none.mm.none.ss で区切りなし形式になる", () {
        // 準備
        final dt = DateTime(2025, 1, 1, 9, 5, 3);

        // 実行
        final result = HH.none.mm.none.ss.format(dt);

        // 検証
        expect(result, "090503");
      });
    });

    group("日時フォーマット", () {
      test("[Positive] yyyy.hyphen.MM.hyphen.dd.space.HH.colon.mm.colon.ss.dot.SSS で完全形式になる", () {
        // 準備
        final dt = DateTime(2025, 12, 31, 13, 42, 51, 786);

        // 実行
        final result = yyyy
            .hyphen
            .MM
            .hyphen
            .dd
            .space
            .HH
            .colon
            .mm
            .colon
            .ss
            .dot
            .SSS
            .format(dt);

        // 検証
        expect(result, "2025-12-31 13:42:51.786");
      });

      test(
        "[Positive] yyyy.hyphen.MM.hyphen.dd.T.HH.colon.mm.colon.ss でT区切り形式になる",
        () {
          // 準備
          final dt = DateTime(2025, 12, 31, 13, 42, 51);

          // 実行
          final result = yyyy.hyphen.MM.hyphen.dd.T.HH.colon.mm.colon.ss.format(
            dt,
          );

          // 検証
          expect(result, "2025-12-31T13:42:51");
        },
      );

      test("[Positive] yyyy.none.MM.none.dd.none.HH.none.mm.none.ss.none.SSS で完全区切りなし形式になる", () {
        // 準備
        final dt = DateTime(2025, 12, 31, 13, 42, 51, 787);

        // 実行
        final result = yyyy.none.MM.none.dd.none.HH.none.mm.none.ss.none.SSS
            .format(dt);

        // 検証
        expect(result, "20251231134251787");
      });
    });

    group("ゼロパディング", () {
      test("[Positive] 月が1桁でもゼロパディングされる", () {
        // 準備
        final dt = DateTime(2025, 1, 5);

        // 実行
        final result = yyyy.hyphen.MM.hyphen.dd.format(dt);

        // 検証
        expect(result, "2025-01-05");
      });

      test("[Positive] 時分秒が1桁でもゼロパディングされる", () {
        // 準備
        final dt = DateTime(2025, 1, 1, 1, 2, 3);

        // 実行
        final result = HH.colon.mm.colon.ss.format(dt);

        // 検証
        expect(result, "01:02:03");
      });

      test("[Positive] ミリ秒が1桁でもゼロパディングされる", () {
        // 準備
        final dt = DateTime(2025, 1, 1, 0, 0, 0, 7);

        // 実行
        final result = HH.colon.mm.colon.ss.dot.SSS.format(dt);

        // 検証
        expect(result, "00:00:00.007");
      });
    });

    group("日付パース", () {
      test("[Positive] yyyy-MM-dd形式をパースできる", () {
        // 準備
        const input = "2025-01-15";

        // 実行
        final result = yyyy.hyphen.MM.hyphen.dd.parse(input);

        // 検証
        expect(result, DateTime(2025, 1, 15));
      });

      test("[Positive] yyyy/MM/dd形式をパースできる", () {
        // 準備
        const input = "2025/12/31";

        // 実行
        final result = yyyy.slash.MM.slash.dd.parse(input);

        // 検証
        expect(result, DateTime(2025, 12, 31));
      });

      test("[Positive] yyyyMMdd形式をパースできる", () {
        // 準備
        const input = "20251231";

        // 実行
        final result = yyyy.none.MM.none.dd.parse(input);

        // 検証
        expect(result, DateTime(2025, 12, 31));
      });

      test("[Positive] yyyy-MM形式をパースできる（日は1日）", () {
        // 準備
        const input = "2025-02";

        // 実行
        final result = yyyy.hyphen.MM.parse(input);

        // 検証
        expect(result, DateTime(2025, 2, 1));
      });

      test("[Positive] yyyyMM形式をパースできる（日は1日）", () {
        // 準備
        const input = "202503";

        // 実行
        final result = yyyy.none.MM.parse(input);

        // 検証
        expect(result, DateTime(2025, 3, 1));
      });
    });

    group("時刻パース", () {
      test("[Positive] HH:mm:ss形式をパースできる", () {
        // 準備
        const input = "09:30:45";

        // 実行
        final result = HH.colon.mm.colon.ss.parse(input);

        // 検証
        expect(result.hour, 9);
        expect(result.minute, 30);
        expect(result.second, 45);
      });

      test("[Positive] HH:mm:ss.SSS形式をパースできる", () {
        // 準備
        const input = "13:42:51.786";

        // 実行
        final result = HH.colon.mm.colon.ss.dot.SSS.parse(input);

        // 検証
        expect(result.hour, 13);
        expect(result.minute, 42);
        expect(result.second, 51);
        expect(result.millisecond, 786);
      });

      test("[Positive] HHmmss形式をパースできる", () {
        // 準備
        const input = "093045";

        // 実行
        final result = HH.none.mm.none.ss.parse(input);

        // 検証
        expect(result.hour, 9);
        expect(result.minute, 30);
        expect(result.second, 45);
      });
    });

    group("日時パース", () {
      test("[Positive] yyyy-MM-dd HH:mm:ss.SSS形式をパースできる", () {
        // 準備
        const input = "2025-12-31 13:42:51.786";

        // 実行
        final result = yyyy
            .hyphen
            .MM
            .hyphen
            .dd
            .space
            .HH
            .colon
            .mm
            .colon
            .ss
            .dot
            .SSS
            .parse(input);

        // 検証
        expect(result, DateTime(2025, 12, 31, 13, 42, 51, 786));
      });

      test("[Positive] yyyy-MM-ddTHH:mm:ss形式をパースできる", () {
        // 準備
        const input = "2025-12-31T13:42:51";

        // 実行
        final result = yyyy.hyphen.MM.hyphen.dd.T.HH.colon.mm.colon.ss.parse(
          input,
        );

        // 検証
        expect(result, DateTime(2025, 12, 31, 13, 42, 51));
      });

      test("[Positive] yyyyMMddHHmmssSSS形式をパースできる", () {
        // 準備
        const input = "20251231134251787";

        // 実行
        final result = yyyy.none.MM.none.dd.none.HH.none.mm.none.ss.none.SSS
            .parse(input);

        // 検証
        expect(result, DateTime(2025, 12, 31, 13, 42, 51, 787));
      });
    });

    /// ---------- 異常系 ---------- ///

    group("パースエラー", () {
      test("[Negative] 不正なセパレーターでFormatExceptionがthrowされる", () {
        // 準備
        const input = "2025/01/15";

        // 実行・検証
        expect(
          () => yyyy.hyphen.MM.hyphen.dd.parse(input),
          throwsFormatException,
        );
      });

      test("[Negative] 文字列が短すぎるとFormatExceptionがthrowされる", () {
        // 準備
        const input = "2025-01";

        // 実行・検証
        expect(
          () => yyyy.hyphen.MM.hyphen.dd.parse(input),
          throwsFormatException,
        );
      });

      test("[Negative] 文字列が長すぎるとFormatExceptionがthrowされる", () {
        // 準備
        const input = "2025-01-15-extra";

        // 実行・検証
        expect(
          () => yyyy.hyphen.MM.hyphen.dd.parse(input),
          throwsFormatException,
        );
      });

      test("[Negative] 数値でない文字列でFormatExceptionがthrowされる", () {
        // 準備
        const input = "abcd-01-15";

        // 実行・検証
        expect(
          () => yyyy.hyphen.MM.hyphen.dd.parse(input),
          throwsFormatException,
        );
      });
    });
  });
}
