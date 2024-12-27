import 'dart:collection';

import 'package:flu_example/menus/pdf/pdfUtils.dart';
import 'package:pdf/pdf.dart';

import 'chart_model.dart';
import 'model.dart';
import 'package:darq/darq.dart';

class PdfDataConverter {
  List<PdfSleepStage> stageToPdfSleepStage(DateTime start, DateTime end, List<Stage> items) {
    if(items.isEmpty) return [];

    List<PdfSleepStage> result = [];
    DateTime currentTime = start;
    Duration interval = const Duration(minutes: 10);

    while (currentTime.isBefore(end) || currentTime.isAtSameMomentAs(end)) {
      var closest = items
          .where((item) =>
      item.timestamp.isAtSameMomentAs(currentTime) ||
          item.timestamp.isAfter(currentTime) &&
              (item.timestamp.isAtSameMomentAs(currentTime.add(interval)) ||
                  item.timestamp.isBefore(currentTime.add(interval))))
          .toList();

      if (closest.count() > 0) {
        HashSet<int> types = HashSet();
        HashSet<DateTime> times = HashSet();
        for(var item in closest) {
          if(types.add(item.type) && times.add(currentTime)) {
            PdfColor color = PdfColors.red;
            if(item.type == 0) {
              color = PdfColor.fromHex("FF8A73");
            }
            else if(item.type == 1) {
              color = PdfColor.fromHex("A1D4EB");
            }
            else if(item.type == 2) {
              color = PdfColor.fromHex("3478F6");
            }
            else if(item.type == 3) {
              color = PdfColor.fromHex("6946CD");
            }
            var addItem = PdfSleepStage(item.type, currentTime, color);
            result.add(addItem);
          }
        }
      } else {
        // 기본값 처리 (필요 시)
        result.add(PdfSleepStage(-1, currentTime, PdfColors.red)); // type 0은 기본값 예시
      }

      currentTime = currentTime.add(interval); // 10분 추가
    }

    return result;
  }

  List<PdfSleepStageTable> stageToPdfSleepStageTable(List<PdfSleepStage> items) {
    if(items.isEmpty) return [];

    List<PdfSleepStageTable> result = [];

    List<PdfSleepStage> type0 = [];
    List<PdfSleepStage> type1 = [];
    List<PdfSleepStage> type2 = [];
    List<PdfSleepStage> type3 = [];
    for(PdfSleepStage item in items) {
      if(item.type == 0) {
        type0.add(item);
      }
      else if(item.type == 1) {
        type1.add(item);
      }
      else if(item.type == 2) {
        type2.add(item);
      }
      else if(item.type == 3) {
        type3.add(item);
      }
    }

    int totalLength = type0.length + type1.length + type2.length + type3.length;
    double calculatePercentage(int length, int total) {
      if (total <= 0) return 0.0;
      double percentage = (length / total) * 100;
      return percentage > 100 ? 100.0 : percentage;
    }
    result.add(PdfSleepStageTable("Non-sleep",
        calculatePercentage(type0.length, totalLength),
        PdfUtils.formatMinutesToHoursAndMinutes(type0.length * 10),
        PdfColor.fromHex("FF8A73")));
    result.add(PdfSleepStageTable("REM sleep",
        calculatePercentage(type1.length, totalLength),
        PdfUtils.formatMinutesToHoursAndMinutes(type1.length * 10),
        PdfColor.fromHex("A1D4EB")));
    result.add(PdfSleepStageTable("Light sleep",
        calculatePercentage(type2.length, totalLength),
        PdfUtils.formatMinutesToHoursAndMinutes(type2.length * 10),
        PdfColor.fromHex("3478F6")));
    result.add(PdfSleepStageTable("Deep sleep",
        calculatePercentage(type3.length, totalLength),
        PdfUtils.formatMinutesToHoursAndMinutes(type3.length * 10),
        PdfColor.fromHex("6946CD")));

    return result;
  }

  Map<String, String> stageToSleepInfo(List<PdfSleepStage> items) {
    Map<String, String> result = {};

    List<PdfSleepStage> type0 = [];
    List<PdfSleepStage> type1 = [];
    List<PdfSleepStage> type2 = [];
    List<PdfSleepStage> type3 = [];
    for(PdfSleepStage item in items) {
      if(item.type == 0) {
        type0.add(item);
      }
      else if(item.type == 1) {
        type1.add(item);
      }
      else if(item.type == 2) {
        type2.add(item);
      }
      else if(item.type == 3) {
        type3.add(item);
      }
    }

    int totalLength = type1.length + type2.length + type3.length;
    result["totalSleepTime"] = PdfUtils.formatMinutesToHoursAndMinutes(totalLength * 10);
    result["sleepTime"] = "${type1.first.date.hour.toString().padLeft(2, '0')}:${type1.first.date.minute.toString().padLeft(2, '0')}";
    result["wakeTime"] = "${type0.last.date.hour.toString().padLeft(2, '0')}:${type0.last.date.minute.toString().padLeft(2, '0')}";
    result["sleepInterval"] = "${type1[0].date.difference(type0[0].date).inMinutes}m";

    return result;
  }

  List<DateTimeCount> apneaToDateTimeCount(DateTime start, DateTime end, List<Apnea> items) {
    List<DateTimeCount> result = [];

    DateTime currentTime = start;
    Duration interval = const Duration(minutes: 10);

    while (currentTime.isBefore(end) || currentTime.isAtSameMomentAs(end)) {
      var closest = items
          .where((item) =>
      item.timestamp.isAtSameMomentAs(currentTime) ||
          item.timestamp.isAfter(currentTime) &&
              (item.timestamp.isAtSameMomentAs(currentTime.add(interval)) ||
                  item.timestamp.isBefore(currentTime.add(interval)))).toList();

      if(closest.isNotEmpty) {
        result.add(DateTimeCount(closest.length.toDouble(), currentTime));
      }
      currentTime = currentTime.add(interval);
    }
    return result;
  }

  List<DateTimeCount> arrhythmiaToDateTimeCount(DateTime start, DateTime end, List<Arrhythmia> items, List<ArrhythmiaBeat> items2) {
    List<DateTimeCount> result = [];

    DateTime currentTime = start;
    Duration interval = const Duration(minutes: 10);

    while (currentTime.isBefore(end) || currentTime.isAtSameMomentAs(end)) {
      var closest1 = items
          .where((item) =>
      item.timestamp.isAtSameMomentAs(currentTime) ||
          item.timestamp.isAfter(currentTime) &&
              (item.timestamp.isAtSameMomentAs(currentTime.add(interval)) ||
                  item.timestamp.isBefore(currentTime.add(interval)))).toList();

      var closest2 = items2
          .where((item) =>
      item.timestamp.isAfter(currentTime) &&
          item.timestamp.isBefore(currentTime.add(interval))).toList();

      if(closest1.isNotEmpty || closest2.isNotEmpty) {
        result.add(DateTimeCount((closest1.length + closest2.length).toDouble(), currentTime));
      }
      currentTime = currentTime.add(interval);
    }
    return result;
  }

  List<DateTimeCount> motionToDateTimeCount(DateTime start, DateTime end, List<Motion> items) {
    List<DateTimeCount> result = [];

    DateTime currentTime = start;
    Duration interval = const Duration(minutes: 10);

    while (currentTime.isBefore(end) || currentTime.isAtSameMomentAs(end)) {
      var closest = items
          .where((item) =>
      item.timestamp.isAtSameMomentAs(currentTime) ||
          item.timestamp.isAfter(currentTime) &&
              (item.timestamp.isAtSameMomentAs(currentTime.add(interval)) ||
                  item.timestamp.isBefore(currentTime.add(interval)))).toList();

      if(closest.isNotEmpty) {
        var count = 0;
        for(Motion item in closest) {
          count += item.type;
        }

        result.add(DateTimeCount(count.toDouble(), currentTime));
      }
      currentTime = currentTime.add(interval);
    }

    return result;
  }

  List<DateTimeCount> trendDataToDateTimeCount(DateTime start, DateTime end, List<TrendData> items, int type) {
    List<DateTimeCount> result = [];

    DateTime currentTime = start;
    Duration interval = const Duration(minutes: 60);

    while (currentTime.isBefore(end) || currentTime.isAtSameMomentAs(end)) {
      var closest = items
          .where((item) =>
      item.date.isAtSameMomentAs(currentTime) ||
          item.date.isAfter(currentTime) &&
              (item.date.isAtSameMomentAs(currentTime.add(interval)) ||
                  item.date.isBefore(currentTime.add(interval)))).toList();
      if(closest.isNotEmpty) {
        double avg = 0;

        if(type == 0) {
          avg = closest.average((m) => m.rrAvg!);
        }
        else if(type == 1) {
          avg = closest.average((m) => m.spo2Avg!);
        }
        else if(type == 2) {
          avg = closest.average((m) => m.hrAvg!);
        }
        else if(type == 3) {
          avg = closest.average((m) => m.tempAvg!);
          avg = PdfUtils.roundToDecimalPlace(avg, 1);
        }

        result.add(DateTimeCount(avg, currentTime));
      }
      currentTime = currentTime.add(interval); // 10분 추가
    }

    return result;
  }


}