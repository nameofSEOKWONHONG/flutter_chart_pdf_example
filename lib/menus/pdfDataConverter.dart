import 'dart:collection';

import 'package:pdf/pdf.dart';

import 'chart_model.dart';
import 'model.dart';
import 'package:darq/darq.dart';

class PdfDataConverter {
  List<PdfSleepStage> stageToPdfSleepStage(DateTime start, DateTime end, List<Stage> items) {
    List<PdfSleepStage> result = [];
    DateTime currentTime = start;
    Duration interval = const Duration(minutes: 10);

    while (currentTime.isBefore(end) || currentTime.isAtSameMomentAs(end)) {
      var closest = items
          .where((item) =>
          item.timestamp.isAfter(currentTime) &&
          item.timestamp.isBefore(currentTime.add(interval)))
          .toList();

      if (closest.count() > 0) {
        HashSet<int> types = HashSet();
        HashSet<DateTime> times = HashSet();
        for(var item in closest) {
          if(types.add(item.type) && times.add(currentTime)) {
            PdfColor color = PdfColors.red;
            if(item.type == 0) {
              color = PdfColors.orange;
            }
            else if(item.type == 1) {
              color = PdfColors.blueGrey200;
            }
            else if(item.type == 2) {
              color = PdfColors.blue;
            }
            else if(item.type == 3) {
              color = PdfColors.purple;
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
      return total > 0 ? (length / total) * 100 : 0.0;
    }
    result.add(PdfSleepStageTable("비수면",
        calculatePercentage(type0.length, totalLength),
        _formatMinutesToHoursAndMinutes(type0.length * 10),
        PdfColors.orange));
    result.add(PdfSleepStageTable("램(REM) 수면",
        calculatePercentage(type1.length, totalLength),
        _formatMinutesToHoursAndMinutes(type1.length * 10),
        PdfColors.blueGrey200));
    result.add(PdfSleepStageTable("얕은 수면",
        calculatePercentage(type2.length, totalLength),
        _formatMinutesToHoursAndMinutes(type2.length * 10),
        PdfColors.blue));
    result.add(PdfSleepStageTable("깊은 수면",
        calculatePercentage(type2.length, totalLength),
        _formatMinutesToHoursAndMinutes(type3.length * 10),
        PdfColors.purple));

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

    int totalLength = type0.length + type1.length + type2.length + type3.length;
    result["totalSleepTime"] = _formatMinutesToHoursAndMinutes(totalLength * 10);
    result["sleepTime"] = "${type1.first.date.hour.toString().padLeft(2, '0')}:${type1.first.date.minute.toString().padLeft(2, '0')}";
    result["wakeTime"] = "${type0.last.date.hour.toString().padLeft(2, '0')}:${type0.last.date.minute.toString().padLeft(2, '0')}";
    result["sleepInterval"] = "${type1[0].date.difference(type0[0].date).inMinutes}분";

    return result;
  }

  List<DateTimeCount> apneaToDateTimeCount(DateTime start, DateTime end, List<Apnea> items) {
    List<DateTimeCount> result = [];

    DateTime currentTime = start;
    Duration interval = const Duration(minutes: 10);

    while (currentTime.isBefore(end) || currentTime.isAtSameMomentAs(end)) {
      var closest = items
          .where((item) =>
            item.timestamp.isAfter(currentTime) &&
            item.timestamp.isBefore(currentTime.add(interval))).toList();

      result.add(DateTimeCount(closest.length.toDouble(), currentTime));
      currentTime = currentTime.add(interval); // 10분 추가
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
      item.timestamp.isAfter(currentTime) &&
          item.timestamp.isBefore(currentTime.add(interval))).toList();

      var closest2 = items2
          .where((item) =>
      item.timestamp.isAfter(currentTime) &&
          item.timestamp.isBefore(currentTime.add(interval))).toList();

      result.add(DateTimeCount((closest1.length + closest2.length).toDouble(), currentTime));
      currentTime = currentTime.add(interval); // 10분 추가
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
      item.timestamp.isAfter(currentTime) &&
          item.timestamp.isBefore(currentTime.add(interval))).toList();

      var count = 0;
      for(Motion item in closest) {
        count += item.type;
      }

      result.add(DateTimeCount(count.toDouble(), currentTime));
      currentTime = currentTime.add(interval); // 10분 추가
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
          item.date.isAfter(currentTime) &&
          item.date.isBefore(currentTime.add(interval))).toList();
      if(closest.count() > 0) {
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
        }

        result.add(DateTimeCount(avg, currentTime));
      }
      currentTime = currentTime.add(interval); // 10분 추가
    }

    return result;
  }

  String _formatMinutesToHoursAndMinutes(int totalMinutes) {
    int hours = totalMinutes ~/ 60; // 몫을 이용해 시간을 계산
    int minutes = totalMinutes % 60; // 나머지를 이용해 분을 계산

    if(hours <= 0) {
      return "${minutes.toString().padLeft(2, '0')}분";
    }

    return '${hours}시간 ${minutes.toString().padLeft(2, '0')}분';
  }
}