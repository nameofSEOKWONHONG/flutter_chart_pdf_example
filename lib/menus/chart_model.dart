import 'package:pdf/pdf.dart';

class SleepStateReview {
  final String point;
  final String sleepTime;
  final String toSleepTime;
  final String arrhythmiaCount;
  final String apneaCount;
  final String arrhythmia2Count;

  SleepStateReview(this.point, this.sleepTime, this.toSleepTime, this.arrhythmiaCount,
      this.apneaCount, this.arrhythmia2Count);
}

class DateTimeCount {
  final double count;
  final DateTime date;

  DateTimeCount(this.count, this.date);
}

class EventInfo {
  List<DateTimeCount> apneaCounts;
  List<DateTimeCount> arrhythmiaCounts;
  List<DateTimeCount> motionCounts;

  EventInfo(this.apneaCounts, this.arrhythmiaCounts, this.motionCounts);
}

class TrendInfo {
  List<DateTimeCount> breathCounts;
  List<DateTimeCount> spo2Counts;
  List<DateTimeCount> heartRateCounts;
  List<DateTimeCount> temperatureCounts;

  TrendInfo(this.breathCounts, this.spo2Counts, this.heartRateCounts, this.temperatureCounts);
}


class PdfSleepStage {
  final int type;
  final DateTime date;
  final PdfColor? color;
  PdfSleepStage(this.type, this.date, this.color);
}

class PdfSleepInfo {
  final String sleepTime;
  final String startSleepTime;
  final String endSleepTime;

  final List<PdfSleepStage> stages;
  final List<PdfSleepStageTable> tables;

  PdfSleepInfo(this.sleepTime, this.startSleepTime, this.endSleepTime,
      this.stages, this.tables);
}

class PdfSleepStageTable {
  final String title;
  final double count;
  final String time;
  final PdfColor color;

  PdfSleepStageTable(this.title, this.count, this.time, this.color);
}

class PdfUserInfo {
  final String name;
  final String gender;
  final String birth;
  final String date;

  PdfUserInfo(this.name, this.gender, this.birth, this.date);
}

class ValuePoint {
  final double x;
  final double y;
  final double v;

  ValuePoint(this.x, this.y, this.v);
}

class BioEstimate {
  final String breathCount;
  final String breathUp;
  final String breathDown;
  final String oxygenRate;
  final String oxygenDown;
  final String heartRateCount;
  final String heartRateUp;
  final String heartRateDown;
  final String temperature;
  final String temperatureUp;
  final String temperatureDown;

  BioEstimate(
      this.breathCount,
      this.breathUp,
      this.breathDown,
      this.oxygenRate,
      this.oxygenDown,
      this.heartRateCount,
      this.heartRateUp,
      this.heartRateDown,
      this.temperature,
      this.temperatureUp,
      this.temperatureDown);
}