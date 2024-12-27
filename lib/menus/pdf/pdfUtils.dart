import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'chart_model.dart';

class PdfUtils {
  static pw.CustomPaint drawTimeLine(PdfTtfFont font) {
    return pw.CustomPaint(
        size: const PdfPoint(0, 0),
        painter: (canvas, point) {
          //region [debug]
          // canvas
          //   ..setColor(PdfColors.red)
          //   ..drawString(PdfFont.courier(PdfDocument()), 5, "(0,0)", -5, -5)
          //   ..strokePath();
          // for(int x=0; x<225; x+=5) {
          //   for(int y=0; y<55; y+=5) {
          //     canvas
          //       ..setColor(PdfColors.red)
          //       ..setLineWidth(0.1)
          //       ..drawLine(x.toDouble(), y.toDouble(), x.toDouble(), y.toDouble() + 5)
          //       ..strokePath();
          //   }
          // }
          //
          // for(int x=0; x<220; x+=5) {
          //   for(int y=0; y<60; y+=5) {
          //     canvas
          //       ..setColor(PdfColors.red)
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
              canvas.drawString(font, 4, currentTime.hour.toString().padLeft(2, "0"), x1-3, y2 - 5);
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
          if(items.isEmpty) return;

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

  static pw.CustomPaint drawEventBarChart(PdfTtfFont font, List<DateTimeCount> items, PdfColor color, int maxValue) {
    return pw.CustomPaint(
        size: const PdfPoint(280, 50),
        painter: (canvas, point) {
          double x1 = 10;
          double x2 = 210;
          double y1 = 40;
          double y2 = 35;

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
            ..drawString(font, 5, "0", -20, 5);
          canvas
            ..setColor(PdfColors.black)
            ..drawString(font, 5, ">=${maxValue}", -20, y2 - 10);

          if(items.isEmpty) return;

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

          while (currentTime.isBefore(endTime) || currentTime.isAtSameMomentAs(endTime)) {
            if(items.isNotEmpty) {
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
            }
            x1 = x1+3;

            currentTime = currentTime.add(interval);  // 10분 추가
          }
        }
    );
  }

  static pw.CustomPaint drawTrendLineChart(PdfTtfFont font, List<DateTimeCount> items, double yMin, double yMax, double rangeMin, double rangeMax, bool isPoint) {
    return pw.CustomPaint(
        size: const PdfPoint(0, 0),
        painter: (canvas, point) {
          if(items.isEmpty) return;

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
              if(item.count > 0) {
                var y = normalizeY(item.count, yMin, yMax, rangeMin, rangeMax);
                //var y = normalizeY(item.count, 10, 30, 10, 20);
                points.add(ValuePoint(x1, y, item.count));
              }
            }

            x1 = x1+xInterval;

            currentTime = currentTime.add(interval);  // 10분 추가
          }

          for(int i=0; i<points.length; i++) {
            if(i == points.length - 1) {
              var point = points[i];
              if(isPoint) {
                canvas
                  ..setColor(PdfColors.black)
                  ..drawString(font, 4, "${point.v.toStringAsFixed(1)}", point.x - 2, point.y - 8);
              }
              else {
                canvas
                  ..setColor(PdfColors.black)
                  ..drawString(font, 4, "${point.v.toInt()}", point.x - 2, point.y - 8);
              }

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
            if(isPoint) {
              canvas
                ..setColor(PdfColors.black)
                ..drawString(font, 4, "${current.v.toStringAsFixed(1)}", current.x - 2, current.y -8);
            }
            else {
              canvas
                ..setColor(PdfColors.black)
                ..drawString(font, 4, "${current.v.toInt()}", current.x - 2, current.y -8);
            }

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

  static pw.CustomPaint drawPoint(double p, double yMin, double yMax, double rangeMin, double rangeMax) {
    return pw.CustomPaint(
        size: const PdfPoint(0, 30),
        painter: (canvas, point) {
          double x1 = -24;

          var y = PdfUtils.normalizeY(p, yMin, yMax, rangeMin, rangeMax);
          var color = "f9c871";

          PdfPoint rotatePoint(double x, double y, double cx, double cy, double angle) {
            final double dx = x - cx;
            final double dy = y - cy;
            final double rotatedX = dx * cos(angle) - dy * sin(angle) + cx;
            final double rotatedY = dx * sin(angle) + dy * cos(angle) + cy;
            return PdfPoint(rotatedX, rotatedY);
          }

          // 사각형 원래 좌표
          final double cx = 54; // 회전 중심 x좌표
          final double cy = y - 0.5; // 회전 중심 y좌표
          final double width = 10; // 사각형 너비
          final double height = 10; // 사각형 높이
          final double angle = 45 * pi / 180; // 회전 각도 (라디안 단위)

          // 사각형 꼭짓점 계산
          List<PdfPoint> points = [
            rotatePoint(cx - width / 2, cy - height / 2, cx, cy, angle), // 왼쪽 상단
            rotatePoint(cx + width / 2, cy - height / 2, cx, cy, angle), // 오른쪽 상단
            rotatePoint(cx + width / 2, cy + height / 2, cx, cy, angle), // 오른쪽 하단
            rotatePoint(cx - width / 2, cy + height / 2, cx, cy, angle), // 왼쪽 하단
          ];

          // 사각형 그리기
          canvas
            ..setFillColor(PdfColor.fromHex(color)) // 채우기 색상
            ..moveTo(points[0].x, points[0].y)
            ..lineTo(points[1].x, points[1].y)
            ..lineTo(points[2].x, points[2].y)
            ..lineTo(points[3].x, points[3].y)
            ..closePath()
            ..fillPath(); // 채우기

          canvas
            ..setColor(PdfColor.fromHex(color))
            ..setLineWidth(1)
            ..drawLine(x1, y-0.4, x1 + 78, y-0.4)
            ..closePath()
            ..strokePath();
          canvas
            ..setColor(PdfColor.fromHex(color))
            ..setStrokeColor(PdfColor.fromHex(color))
            ..setFillColor(PdfColor.fromHex(color))
            ..drawRect(x1 + 78, y-6, 24, 11)
            ..closePath()
            ..fillPath();
          canvas
            ..setColor(PdfColors.black)
            ..drawString(PdfFont.helvetica(PdfDocument()), 7, "Point", x1 + 82, y-4)
            ..closePath()
            ..strokePath();
        }
    );
  }

  static pw.CustomPaint drawTrendMinimalLineChart(List<DateTimeCount> items, double yMin, double yMax, double rangeMin, double rangeMax, double limitValue1, double limitValue2, bool isSpo2) {
    return pw.CustomPaint(
        size: const PdfPoint(0, 0),
        painter: (canvas, point) {
          if(items.isEmpty) return;

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
                if(item.count > 0) {
                  var y = normalizeY(item.count, yMin, yMax, rangeMin, rangeMax);
                  points.add(ValuePoint(x1, y, item.count));
                }
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
              ..setLineWidth(0.4)
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
    if (yInput < yMin) {
      yInput = yMin;
    }
    if (yInput > yMax) {
      yInput = yMax;
    }
    return ((yInput - yMin) / (yMax - yMin)) * (rangeMax - rangeMin) + rangeMin;
  }

  static double getRandomDouble(double from, double to) {
    final random = Random();
    return from + (random.nextDouble() * (to - from));
  }

  static String formatDateTime(DateTime dateTime, bool isDateOnly) {
    // 날짜 포맷
    String date = DateFormat('MMMM d, y', "en_US").format(dateTime); // September 24, 2024

    if(isDateOnly) return date;

    // 시간 포맷 (12시간제, AM/PM 소문자)
    String time = DateFormat('h').format(dateTime); // 시간
    String amPm = DateFormat('a').format(dateTime).toLowerCase(); // pm 또는 am

    // 최종 조합
    return "$date at ${time}${amPm}";
  }

  static String formatMinutesToHoursAndMinutes(int totalMinutes) {
    int hours = totalMinutes ~/ 60; // 몫을 이용해 시간을 계산
    int minutes = totalMinutes % 60; // 나머지를 이용해 분을 계산

    if(hours <= 0) {
      return "${minutes.toString().padLeft(2, '0')}m";
    }

    return '${hours}h ${minutes.toString().padLeft(2, '0')}m';
  }

  static double roundToDecimalPlace(double value, int places) {
    double factor = 10;
    return double.parse((value / factor).toStringAsFixed(places));
  }
}