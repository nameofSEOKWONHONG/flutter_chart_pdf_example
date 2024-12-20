import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'chart_model.dart';



class ChartUtil {
  static pw.CustomPaint drawTimeLine() {
    return pw.CustomPaint(
        size: const PdfPoint(0, 0),
        painter: (canvas, point) {
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
              canvas.drawString(PdfFont.courier(PdfDocument()), 4, "${currentTime.hour.toString().padLeft(2, "0")}", x1-2, y2 - 5);
            }

            x1 = x1+3;

            currentTime = currentTime.add(interval);  // 10분 추가
          }
        }
    );
  }

  static pw.CustomPaint drawSleepStageLineChart(ChartSleepStage sleepStage) {
    return pw.CustomPaint(
        size: const PdfPoint(0, 0),
        painter: (canvas, point) {
          DateTime startTime = DateTime(
              sleepStage.stages[0].date.year
              , sleepStage.stages[0].date.month
              , sleepStage.stages[0].date.day
              , 22
              , 0
              , 0);
          DateTime endTime = DateTime(
              sleepStage.stages[sleepStage.stages.length - 1].date.year
              , sleepStage.stages[sleepStage.stages.length - 1].date.month
              , sleepStage.stages[sleepStage.stages.length - 1].date.day
              , 09
              , 0
              , 0
          );   // 종료 시간
          Duration interval = const Duration(minutes: 10);           // 10분 간격

          DateTime currentTime = startTime;
          double x = 10;
          double y = 0;
          while (currentTime.isBefore(endTime) || currentTime.isAtSameMomentAs(endTime)) {
            var item = sleepStage.stages.where((m) => m.date.isAfter(currentTime)).firstOrNull;
            if(item?.type == "0") {
              canvas
                ..setLineWidth(0.1)
                ..setFillColor(PdfColors.orange)
                ..drawRect(x, y - 34, 3, 10)
                ..fillPath();
            }
            else if(item?.type == "1") {
              canvas
                ..setLineWidth(0.1)
                ..setFillColor(PdfColors.blueGrey200)
                ..drawRect(x, y - 50, 3, 10)
                ..fillPath();
            }
            else if(item?.type == "2") {
              canvas
                ..setLineWidth(0.1)
                ..setFillColor(PdfColors.blue)
                ..drawRect(x, y - 65, 3, 10)
                ..fillPath();
            }
            else if(item?.type == "3") {
              canvas
                ..setLineWidth(0.1)
                ..setFillColor(PdfColors.purple)
                ..drawRect(x, y - 81, 3, 10)
                ..fillPath();
            }

            x = x+3;

            currentTime = currentTime.add(interval);  // 10분 추가
          }
        }
    );
  }

  static pw.CustomPaint drawEventBarChart(List<DateTimeCount> items, PdfColor color) {
    return pw.CustomPaint(
        size: const PdfPoint(280, 50),
        painter: (canvas, point) {
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

          // DateTime startTime = DateTime(2024, 12, 30, 22, 0, 0); // 시작 시간
          // DateTime endTime = DateTime(2024, 12, 31, 9, 0, 0);   // 종료 시간
          DateTime startTime = DateTime(
              items[0].date.year,
              items[0].date.month,
              items[0].date.day,
              22,
              00,
              00
          );
          DateTime endTime = DateTime(
              items[items.length - 1].date.year,
              items[items.length - 1].date.month,
              items[items.length - 1].date.day,
              09,
              00,
              00
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
            ..drawLine(x1-30, y2 - 15, x2, y2 - 15)
            ..strokePath();

          canvas
            ..setColor(PdfColors.black)
            ..drawString(PdfFont.courier(PdfDocument()), 5, "0", -20, 5);
          canvas
            ..setColor(PdfColors.black)
            ..drawString(PdfFont.courier(PdfDocument()), 5, ">=50", -20, y2 - 10);

          while (currentTime.isBefore(endTime) || currentTime.isAtSameMomentAs(endTime)) {
            canvas
              ..setColor(PdfColors.black)
              ..setLineWidth(0.1)
              ..drawLine(x1, y1, x1, y2)
              ..strokePath();

            if (currentTime.minute == 0) {
              canvas.drawString(PdfFont.courier(PdfDocument()), 4, "${currentTime.hour.toString().padLeft(2, "0")}", x1-2, y2 - 5);
            }

            var item = items.where((e) => e.date == currentTime).firstOrNull;
            if(item != null) {
              double v = normalizeY(item.count, 0, 100, 0, 20);
              canvas
                ..setColor(color)
                ..setLineWidth(0.1)
                ..drawLine(x1, (y1 - 40), x1, v)
                ..strokePath();
            }

            x1 = x1+3;

            currentTime = currentTime.add(interval);  // 10분 추가
          }
        }
    );
  }

  static pw.CustomPaint drawTrendBreathLineChart(List<DateTimeCount> items) {
    return pw.CustomPaint(
        size: const PdfPoint(0, 0),
        painter: (canvas, point) {
          double x1 = 10;
          double x2 = 210;
          double y1 = 40;
          double y2 = 35;

          DateTime startTime = DateTime(
            items[0].date.year,
            items[0].date.month,
            items[0].date.day,
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
          Duration interval = const Duration(minutes: 10);           // 10분 간격

          DateTime currentTime = startTime;

          List<ValuePoint> points = [];
          while (currentTime.isBefore(endTime) || currentTime.isAtSameMomentAs(endTime)) {
            if(currentTime.minute == 0 &&
                currentTime.second == 0) {
              //var y = getRandomNumber(10, 28).toDouble();
              //var n = normalizeY(y, 10, 30, 10, 28);

              var item = items.where((m) => m.date == currentTime).firstOrNull;
              if(item != null) {
                var y = normalizeY(item.count, 10, 30, 10, 28);
                points.add(ValuePoint(x1, y, item.count));
              }
            }

            x1 = x1+3;

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

  static pw.CustomPaint drawTrendOxygenLineChart(List<DateTimeCount> items) {
    return pw.CustomPaint(
        size: const PdfPoint(0, 0),
        painter: (canvas, point) {
          double x1 = 10;
          double x2 = 210;
          double y1 = 40;
          double y2 = 35;

          DateTime startTime = DateTime(
              items[0].date.year,
              items[0].date.month,
              items[0].date.day,
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

          List<ValuePoint> points = [];
          while (currentTime.isBefore(endTime) || currentTime.isAtSameMomentAs(endTime)) {
            if(currentTime.minute == 0 &&
                currentTime.second == 0) {
              var item = items.where((m) => m.date == currentTime).firstOrNull;
              if(item != null) {
                var y = normalizeY(item.count, 0, 100, 90, 110);
                points.add(ValuePoint(x1, y, item.count));
              }
            }

            x1 = x1+3;

            currentTime = currentTime.add(interval);  // 10분 추가
          }

          var font = PdfFont.courier(PdfDocument());
          for(int i=0; i<points.length; i++) {
            if(i == points.length - 1) {
              var point = points[i];
              canvas
                ..setColor(PdfColors.black)
                ..drawString(font, 4, "${point.v}", point.x - 2, point.y - 8);
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
              ..drawString(font, 4, "${current.v}", current.x - 2, current.y -8);
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

  static pw.CustomPaint drawTrendHeartRateLineChart(List<DateTimeCount> items) {
    return pw.CustomPaint(
        size: const PdfPoint(0, 0),
        painter: (canvas, point) {
          double x1 = 10;
          double x2 = 210;
          double y1 = 40;
          double y2 = 35;

          DateTime startTime = DateTime(
              items[0].date.year,
              items[0].date.month,
              items[0].date.day,
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

          List<ValuePoint> points = [];
          while (currentTime.isBefore(endTime) || currentTime.isAtSameMomentAs(endTime)) {
            if(currentTime.minute == 0 &&
                currentTime.second == 0) {
              var item = items.where((m) => m.date == currentTime).firstOrNull;
              if(item != null) {
                var y = normalizeY(item.count, 0, 100, 10, 28);
                points.add(ValuePoint(x1, y, item.count));
              }
            }

            x1 = x1+3;

            currentTime = currentTime.add(interval);  // 10분 추가
          }

          var font = PdfFont.courier(PdfDocument());
          for(int i=0; i<points.length; i++) {
            if(i == points.length - 1) {
              var point = points[i];
              canvas
                ..setColor(PdfColors.black)
                ..drawString(font, 4, "${point.v}", point.x - 2, point.y - 8);
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
              ..drawString(font, 4, "${current.v}", current.x - 2, current.y -8);
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

  static pw.CustomPaint drawTrendTemperatureLineChart(List<DateTimeCount> items) {
    return pw.CustomPaint(
        size: const PdfPoint(0, 0),
        painter: (canvas, point) {
          double x1 = 10;
          double x2 = 210;
          double y1 = 40;
          double y2 = 35;

          DateTime startTime = DateTime(
              items[0].date.year,
              items[0].date.month,
              items[0].date.day,
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

          List<ValuePoint> points = [];
          while (currentTime.isBefore(endTime) || currentTime.isAtSameMomentAs(endTime)) {
            if(currentTime.minute == 0 &&
                currentTime.second == 0) {
              // var n = getRandomNumber(94, 100).toDouble();
              // var y = normalizeY(n, 0, 100, 10, 28);

              var item = items.where((m) => m.date == currentTime).firstOrNull;
              if(item != null) {
                var y = normalizeY(item.count * 1, 30, 40, 30, 40);
                points.add(ValuePoint(x1, y, (item.count * 0.1)));
              }
            }

            x1 = x1+3;

            currentTime = currentTime.add(interval);  // 10분 추가
          }

          var font = PdfFont.courier(PdfDocument());
          for(int i=0; i<points.length; i++) {
            if(i == points.length - 1) {
              var point = points[i];
              canvas
                ..setColor(PdfColors.black)
                ..drawString(font, 4, "${point.v.toStringAsFixed(1)}", point.x - 2, point.y - 8);
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
              ..drawString(font, 4, "${current.v.toStringAsFixed(1)}", current.x - 2, current.y -8);
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

  static pw.CustomPaint drawReviewChart() {
    return pw.CustomPaint(
        size: const PdfPoint(0, 0),
        painter: (canvas, point) {
          double x1 = 10;

          DateTime startTime = DateTime(
            2024,12,30,
              22,
              0,
              0
          ); // 시작 시간
          DateTime endTime = DateTime(
            2024,12,31,
              9,
              0,
              0
          );
          Duration interval = const Duration(minutes: 10);           // 10분 간격

          DateTime currentTime = startTime;

          List<NoneValuePoint> points = [];
          while (currentTime.isBefore(endTime) || currentTime.isAtSameMomentAs(endTime)) {
            var n = 94.toDouble();
            var y = normalizeY(n, 94, 120, 10, 30);
            points.add(NoneValuePoint(x1, y));

            x1 = x1+2;

            currentTime = currentTime.add(interval);  // 10분 추가
          }

          for(int i=0; i<points.length; i++) {
            if(i == points.length - 1) {
              var point = points[i];
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
}

