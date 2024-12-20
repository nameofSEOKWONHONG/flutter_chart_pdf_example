class DailyStatData {
  final String profileId;
  final int year;
  final int month;
  final int day;
  late DateTime starttime;
  late DateTime endtime;
  late int duration;
  late int awake;
  late int rem;
  late int light;
  late int deep;
  late int arrhythmia;

  DailyStatData({required this.profileId, required this.year, required this.month, required this.day}) {
    // TODO: implement DailyStatData
    throw UnimplementedError();
  } // arrhythmia count
}

class Stage {
  final String profileId;
  final DateTime timestamp;
  final int type;

  Stage({required this.profileId, required this.timestamp, required this.type});
}

class Arrhythmia {
  final String profileId;
  final DateTime timestamp;
  final int type;

  Arrhythmia({required this.profileId, required this.timestamp, required this.type});
}

class ArrhythmiaBeat {
  final String profileId;
  final DateTime timestamp;
  final int type;

  ArrhythmiaBeat({required this.profileId, required this.timestamp, required this.type});
}

class Apnea {
  final String profileId;
  final DateTime timestamp;
  final int type;

  Apnea({required this.profileId, required this.timestamp, required this.type});
}

class Motion {
  final String profileId;
  final DateTime timestamp;
  final int type;

  Motion({required this.profileId, required this.timestamp, required this.type});
}

class TrendData {
  late String profileId;
  late String sensorNo;
  late DateTime date;
  double? hrAvg;
  int? hrMax;
  int? hrMin;
  double? rrAvg;
  int? rrMax;
  int? rrMin;
  double? tempAvg;
  int? tempMax;
  int? tempMin;
  double? spo2Avg;
  int? spo2Max;
  int? spo2Min;
  late int n;
}