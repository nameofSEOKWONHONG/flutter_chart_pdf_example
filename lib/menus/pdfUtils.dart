import 'dart:math';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'chart_model.dart';

class PdfUtils {
  static pw.CustomPaint drawTimeLine() {
    return pw.CustomPaint(
        size: const PdfPoint(0, 0),
        painter: (canvas, point) {
          //region [debug]
          // canvas
          //   ..setColor(PdfColors.red)
          //   ..drawString(PdfFont.courier(PdfDocument()), 5, "(0,0)", -5, -5)
          //   ..strokePath();
          // for(int x=0; x<60; x+=5) {
          //   for(int y=0; y<55; y+=5) {
          //     canvas
          //       ..setColor(PdfColors.grey)
          //       ..setLineWidth(0.1)
          //       ..drawLine(x.toDouble(), y.toDouble(), x.toDouble(), y.toDouble() + 5)
          //       ..strokePath();
          //   }
          // }
          //
          // for(int x=0; x<55; x+=5) {
          //   for(int y=0; y<60; y+=5) {
          //     canvas
          //       ..setColor(PdfColors.grey)
          //       ..setLineWidth(0.1)
          //       ..drawLine(x.toDouble(), y.toDouble(), x.toDouble() + 5, y.toDouble())
          //       ..strokePath();
          //   }
          // }
          //endregion

          double x1 = 10;
          double x2 = 210;
          double y1 = 40;
          double y2 = 35;

          canvas
            ..setStrokeColor(PdfColors.black)
            ..setLineWidth(0.01)
            ..moveTo(x1, y1)
            ..lineTo(x2, y1)
            ..strokePath()
          ;

          DateTime startTime = DateTime(2024, 12, 30, 22, 0, 0); // 시작 시간
          DateTime endTime = DateTime(2024, 12, 31, 9, 0, 0);   // 종료 시간
          Duration interval = const Duration(minutes: 10);           // 10분 간격

          DateTime currentTime = startTime;

          while (currentTime.isBefore(endTime) || currentTime.isAtSameMomentAs(endTime)) {
            canvas
              ..setColor(PdfColors.black)
              ..setLineWidth(0.1)
              ..drawLine(x1, y1, x1, y2)
              ..strokePath();

            if (currentTime.minute == 0) {
              canvas.drawString(PdfFont.courier(PdfDocument()), 4, currentTime.hour.toString().padLeft(2, "0"), x1-3, y2 - 5);
            }

            x1 = x1+3;

            currentTime = currentTime.add(interval);  // 10분 추가
          }
        }
    );
  }

  static pw.CustomPaint drawSleepStageBarChart(List<PdfSleepStage> items) {
    return pw.CustomPaint(
        size: const PdfPoint(0, 0),
        painter: (canvas, point) {
          var d1 = 0;
          if(items[0].date.day - items[items.length - 1].date.day == 0) {
            d1 = 1;
          }
          DateTime startTime = DateTime(
              items[0].date.year,
              items[0].date.month,
              items[0].date.day - d1,
              22,
              0,
              0
          ); // 시작 시간
          DateTime endTime = DateTime(
              items[items.length - 1].date.year,
              items[items.length - 1].date.month,
              items[items.length - 1].date.day,
              9,
              0,
              0
          );   // 종료 시간
          Duration interval = const Duration(minutes: 10);           // 10분 간격

          DateTime currentTime = startTime;
          double x = 13;
          double y = 0;
          while (currentTime.isBefore(endTime) || currentTime.isAtSameMomentAs(endTime)) {
            var item = items.where((m) => m.date.isAfter(currentTime)).firstOrNull;
            if(item?.type == 0) {
              canvas
                ..setLineWidth(0.1)
                ..setFillColor(item?.color)
                ..drawRect(x, y - 34, 3, 10)
                ..fillPath();
            }
            else if(item?.type == 1) {
              canvas
                ..setLineWidth(0.1)
                ..setFillColor(item?.color)
                ..drawRect(x, y - 50, 3, 10)
                ..fillPath();
            }
            else if(item?.type == 2) {
              canvas
                ..setLineWidth(0.1)
                ..setFillColor(item?.color)
                ..drawRect(x, y - 65, 3, 10)
                ..fillPath();
            }
            else if(item?.type == 3) {
              canvas
                ..setLineWidth(0.1)
                ..setFillColor(item?.color)
                ..drawRect(x, y - 81, 3, 10)
                ..fillPath();
            }

            x = x+3;

            currentTime = currentTime.add(interval);  // 10분 추가
          }
        }
    );
  }

  static pw.CustomPaint drawEventBarChart(List<DateTimeCount> items, PdfColor color, int maxValue) {
    return pw.CustomPaint(
        size: const PdfPoint(280, 50),
        painter: (canvas, point) {
          double x1 = 10;
          double x2 = 210;
          double y1 = 40;
          double y2 = 35;

          canvas
            ..setStrokeColor(PdfColors.black)
            ..setLineWidth(0.1)
            ..moveTo(x1, y1)
            ..lineTo(x2, y1)
            ..strokePath()
          ;


          var d1 = 0;
          if(items[0].date.day - items[items.length - 1].date.day == 0) {
            d1 = 1;
          }
          DateTime startTime = DateTime(
              items[0].date.year,
              items[0].date.month,
              items[0].date.day - d1,
              22,
              0,
              0
          ); // 시작 시간
          DateTime endTime = DateTime(
              items[items.length - 1].date.year,
              items[items.length - 1].date.month,
              items[items.length - 1].date.day,
              9,
              0,
              0
          );
          Duration interval = const Duration(minutes: 10);           // 10분 간격

          DateTime currentTime = startTime;

          canvas
            ..setColor(PdfColors.grey)
            ..setLineWidth(0.1)
            ..drawLine(x1-30, y1 - 40, x2, y1 - 40)
            ..strokePath();

          canvas
            ..setColor(PdfColors.grey)
            ..setLineWidth(0.1)
            ..drawLine(x1-30, y2 - 15.5, x2, y2 - 15.5)
            ..strokePath();

          canvas
            ..setColor(PdfColors.black)
            ..drawString(PdfFont.courier(PdfDocument()), 5, "0", -20, 5);
          canvas
            ..setColor(PdfColors.black)
            ..drawString(PdfFont.courier(PdfDocument()), 5, ">=${maxValue}", -20, y2 - 10);

          while (currentTime.isBefore(endTime) || currentTime.isAtSameMomentAs(endTime)) {
            canvas
              ..setColor(PdfColors.black)
              ..setLineWidth(0.1)
              ..drawLine(x1, y1, x1, y2)
              ..strokePath();

            if (currentTime.minute == 0) {
              canvas.drawString(PdfFont.courier(PdfDocument()), 4, currentTime.hour.toString().padLeft(2, "0"), x1-2, y2 - 5);
            }

            var item = items.where((e) => e.date == currentTime).firstOrNull;
            if(item != null) {
              if(item.count > 0) {
                double v = normalizeY(item.count, 0, maxValue.toDouble(), 0, 20);
                canvas
                  ..setColor(color)
                  ..setLineWidth(1)
                  ..drawLine(x1, (y1 - 40), x1, v)
                  ..strokePath();
              }
            }

            x1 = x1+3;

            currentTime = currentTime.add(interval);  // 10분 추가
          }
        }
    );
  }

  static pw.CustomPaint drawTrendLineChart(List<DateTimeCount> items, double yMin, double yMax, double rangeMin, double rangeMax) {
    return pw.CustomPaint(
        size: const PdfPoint(0, 0),
        painter: (canvas, point) {
          double x1 = 10;

          //22시부터 익일 09시까지 시간
          var d1 = 0;
          if(items[0].date.day - items[items.length - 1].date.day == 0) {
            d1 = 1;
          }
          DateTime startTime = DateTime(
            items[0].date.year,
            items[0].date.month,
            items[0].date.day - d1,
            22,
            0,
            0
          ); // 시작 시간
          DateTime endTime = DateTime(
              items[items.length - 1].date.year,
              items[items.length - 1].date.month,
              items[items.length - 1].date.day,
              9,
              0,
              0
          ); // 종료 시간
          Duration interval = const Duration(minutes: 60);           // 10분 간격
          DateTime currentTime = startTime;

          //라인 포인트 리스트
          List<ValuePoint> points = [];
          var xInterval = 18;
          while (currentTime.isBefore(endTime) || currentTime.isAtSameMomentAs(endTime)) {
            var item = items.where((m) => m.date == currentTime).firstOrNull;
            if(item != null) {
              var y = normalizeY(item.count, yMin, yMax, rangeMin, rangeMax);
              //var y = normalizeY(item.count, 10, 30, 10, 20);
              points.add(ValuePoint(x1, y, item.count));
            }

            x1 = x1+xInterval;

            currentTime = currentTime.add(interval);  // 10분 추가
          }

          var font = PdfFont.courier(PdfDocument());
          for(int i=0; i<points.length; i++) {
            if(i == points.length - 1) {
              var point = points[i];
              canvas
                ..setColor(PdfColors.black)
                ..drawString(font, 4, "${point.v.toInt()}", point.x - 2, point.y - 8);
              canvas
                ..setFillColor(PdfColors.blue)
                ..setColor(PdfColors.blue)
                ..setLineWidth(0.5)
                ..drawEllipse(point.x, point.y - 10, 0.5, 0.5)
                ..strokePath();
              break;
            }

            var current = points[i];
            var next = points[i + 1];
            canvas
              ..setColor(PdfColors.black)
              ..drawString(font, 4, "${current.v.toInt()}", current.x - 2, current.y -8);
            canvas
              ..setFillColor(PdfColors.blue)
              ..setColor(PdfColors.blue)
              ..setLineWidth(1)
              ..drawEllipse(current.x, current.y -10, 0.5, 0.5);
            canvas
              ..setColor(PdfColors.blue)
              ..setLineWidth(0.5)
              ..drawLine(current.x, current.y - 10, next.x, next.y - 10)
              ..strokePath();
          }
        }
    );
  }

  static pw.CustomPaint drawTrendMinimalLineChart(List<DateTimeCount> items, double yMin, double yMax, double rangeMin, double rangeMax, double limitValue1, double limitValue2, bool isSpo2) {
    return pw.CustomPaint(
        size: const PdfPoint(0, 0),
        painter: (canvas, point) {
          double x1 = 10;

          var d1 = 0;
          if(items[0].date.day - items[items.length - 1].date.day == 0) {
            d1 = 1;
          }
          DateTime startTime = DateTime(
              items[0].date.year,
              items[0].date.month,
              items[0].date.day - d1,
              22,
              0,
              0
          );
          DateTime endTime = DateTime(
              items[items.length - 1].date.year,
              items[items.length - 1].date.month,
              items[items.length - 1].date.day,
              9,
              0,
              0
          );
          Duration interval = const Duration(minutes: 10);

          DateTime currentTime = startTime;

          if(isSpo2) {
            var minY = normalizeY(limitValue2, yMin, yMax, rangeMin, rangeMax);
            canvas
              ..setColor(PdfColors.blue)
              ..setLineWidth(0.1)
              ..drawLine(x1, minY - 10, 140, minY - 10)
              ..strokePath();
          }
          else {
            var maxY = normalizeY(limitValue1, yMin, yMax, rangeMin, rangeMax);
            var minY = normalizeY(limitValue2, yMin, yMax, rangeMin, rangeMax);
            canvas
              ..setColor(PdfColors.red)
              ..setLineWidth(0.1)
              ..drawLine(x1, maxY - 10, 140, maxY - 10)
              ..strokePath();
            canvas
              ..setColor(PdfColors.grey)
              ..setLineWidth(0.1)
              ..drawLine(x1, minY - 10, 140, minY - 10)
              ..strokePath();
          }


          List<ValuePoint> points = [];
          var xInterval = 2;
          while (currentTime.isBefore(endTime) || currentTime.isAtSameMomentAs(endTime)) {
            if(currentTime.minute == 0 &&
                currentTime.second == 0) {
              var item = items.where((m) => m.date == currentTime).firstOrNull;
              if(item != null) {
                var y = normalizeY(item.count, yMin, yMax, rangeMin, rangeMax);
                points.add(ValuePoint(x1, y, item.count));
              }
            }

            x1 = x1+xInterval;

            currentTime = currentTime.add(interval);
          }

          for(int i=0; i<points.length; i++) {
            if(i == points.length - 1) {
              break;
            }

            var current = points[i];
            var next = points[i + 1];
            canvas
              ..setColor(PdfColors.black)
              ..setLineWidth(0.1)
              ..drawLine(current.x, current.y - 10, next.x, next.y - 10)
              ..strokePath();
          }
        }
    );
  }

  static pw.Container defaultText(pw.Alignment alignment, String text, double fontSize, pw.FontWeight weight, pw.Font font, double padding) {
    return pw.Container(
        alignment: alignment,
        padding: pw.EdgeInsets.all(padding),
        child: pw.Text(text,
            style: pw.TextStyle(
                fontSize: fontSize,
                fontWeight: weight,
                font: font
            )
        )
    );
  }

  static int getRandomNumber(int min, int max) {
    final random = Random();
    return min + random.nextInt(max - min + 1); // +1 to include max
  }

  static double normalizeY(double yInput, double yMin, double yMax, double rangeMin, double rangeMax) {
    yInput = min(yInput, yMax);
    return ((yInput - yMin) / (yMax - yMin)) * (rangeMax - rangeMin) + rangeMin;
  }

  static double getRandomDouble(double from, double to) {
    final random = Random();
    return from + (random.nextDouble() * (to - from));
  }
}

