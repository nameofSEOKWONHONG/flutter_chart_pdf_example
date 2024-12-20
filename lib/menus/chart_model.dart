import 'package:pdf/pdf.dart';

class SleepReview {
  final String point;
  final String sleepTime;
  final String toSleepTime;
  final String arrhythmiaCount;
  final String apneaCount;
  final String arrhythmia2Count;

  SleepReview(this.point, this.sleepTime, this.toSleepTime, this.arrhythmiaCount,
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
  List<DateTimeCount> arrhythmia2Counts;

  EventInfo(this.apneaCounts, this.arrhythmiaCounts, this.arrhythmia2Counts);
}

class TrendInfo {
  List<DateTimeCount> breathCounts;
  List<DateTimeCount> oxygenCounts;
  List<DateTimeCount> heartrateCounts;
  List<DateTimeCount> temperatureCounts;

  TrendInfo(this.breathCounts, this.oxygenCounts, this.heartrateCounts, this.temperatureCounts);
}

class ChartSleepStage {
  final String sleepTime;
  final String startSleepTime;
  final String endSleepTime;

  final List<ChartStage> stages;
  final List<ChartStageTable> tables;

  ChartSleepStage(this.sleepTime, this.startSleepTime, this.endSleepTime, this.stages, this.tables);
}

class ChartStage {
  final String type;
  final DateTime date;

  ChartStage(this.type, this.date);
}

class ChartStageTable {
  final String title;
  final double count;
  final String time;
  final PdfColor color;

  ChartStageTable(this.title, this.count, this.time, this.color);
}

class ChartMember {
  final String name;
  final String gender;
  final String birth;
  final String date;

  ChartMember(this.name, this.gender, this.birth, this.date);
}

class NoneValuePoint {
  final double x;
  final double y;
  NoneValuePoint(this.x, this.y);
}
class ValuePoint {
  final double x;
  final double y;
  final double v;

  ValuePoint(this.x, this.y, this.v);
}