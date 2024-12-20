import 'package:flu_example/menus/barchart.dart';
import 'package:flu_example/menus/barchart2.dart';
import 'package:flu_example/menus/chart_util.dart';
import 'package:flu_example/menus/demochart.dart';
import 'package:flu_example/menus/linechart.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';

import 'menus/chart_model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return const MaterialApp(
      debugShowCheckedModeBanner: true,
      home: MainPage(),
    );
  }
}

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    var member = ChartMember("이지은", "여성", "1990.03.12", "2024년 9월 24일 오후 10시 ~ 9월 24일 오전 6시");
    List<ChartStage> stages =[];
    stages.add(ChartStage("0", DateTime(2024, 12, 30, 22, 59, 59)));
    stages.add(ChartStage("1", DateTime(2024, 12, 30, 23, 59, 59)));
    stages.add(ChartStage("2", DateTime(2024, 12, 31, 00, 59, 59)));
    stages.add(ChartStage("3", DateTime(2024, 12, 31, 01, 59, 59)));
    stages.add(ChartStage("2", DateTime(2024, 12, 31, 02, 59, 59)));
    stages.add(ChartStage("1", DateTime(2024, 12, 31, 03, 59, 59)));
    stages.add(ChartStage("1", DateTime(2024, 12, 31, 04, 59, 59)));
    stages.add(ChartStage("2", DateTime(2024, 12, 31, 05, 59, 59)));
    stages.add(ChartStage("3", DateTime(2024, 12, 31, 06, 59, 59)));
    stages.add(ChartStage("2", DateTime(2024, 12, 31, 07, 59, 59)));
    stages.add(ChartStage("0", DateTime(2024, 12, 31, 08, 59, 59)));

    List<ChartStageTable> tables = [];
    tables.add(ChartStageTable("비수면", 10, "48분", PdfColors.orange));
    tables.add(ChartStageTable("램(REM) 수면", 20, "1시간 36분", PdfColors.blueGrey200));
    tables.add(ChartStageTable("얕은 수면", 40, "3시간 12분", PdfColors.blue));
    tables.add(ChartStageTable("깊은 수면", 30, "2시간 24분", PdfColors.purple));

    List<DateTimeCount> apneaCounts = [];
    List<DateTimeCount> arrhythmiaCounts = [];
    List<DateTimeCount> arrhythmia2Counts = [];

    List<DateTimeCount> breathCounts = [];
    List<DateTimeCount> oxygenCounts = [];
    List<DateTimeCount> heartrateCounts = [];
    List<DateTimeCount> tempratureCounts = [];

    DateTime start = DateTime(2024, 12, 30, 22, 00, 00);
    DateTime end = DateTime(2024, 12, 31, 09, 00, 00);
    Duration interval = const Duration(minutes: 10);
    DateTime currentTime = start;

    while (currentTime.isBefore(end) || currentTime.isAtSameMomentAs(end)) {
      apneaCounts.add(DateTimeCount(ChartUtil.getRandomNumber(15, 100).toDouble(), currentTime));
      arrhythmiaCounts.add(DateTimeCount(ChartUtil.getRandomNumber(15, 100).toDouble(), currentTime));
      arrhythmia2Counts.add(DateTimeCount(ChartUtil.getRandomNumber(15, 100).toDouble(), currentTime));

      breathCounts.add(DateTimeCount(ChartUtil.getRandomNumber(15, 25).toDouble(), currentTime));
      oxygenCounts.add(DateTimeCount(ChartUtil.getRandomNumber(90, 100).toDouble(), currentTime));
      heartrateCounts.add(DateTimeCount(ChartUtil.getRandomNumber(90, 100).toDouble(), currentTime));
      tempratureCounts.add(DateTimeCount(ChartUtil.getRandomNumber(365, 370).toDouble(), currentTime));

      currentTime = currentTime.add(interval);  // 10분 추가
    }

    SleepReview sleepReview = SleepReview("68", "7시간 12분", "1시간", "10회", "10회", "10회");

    var sleepStage = ChartSleepStage("8시간 00분", "22:00", "06:00", stages, tables);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Main Page"),
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16.0),
        crossAxisSpacing: 24.0,
        mainAxisSpacing: 24.0,
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LineChartPage(),
                ),
              );
            },
            child: const Text('Page line'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BarChartPage(),
                ),
              );
            },
            child: Text('Page bar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ApneaBarChart(),
                ),
              );
            },
            child: Text('Page bar2'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DemoChart(member, sleepStage,
                    EventInfo(apneaCounts, arrhythmiaCounts, arrhythmia2Counts),
                    TrendInfo(breathCounts, oxygenCounts, heartrateCounts, tempratureCounts),
                    sleepReview
                  ),
                ),
              );
            },
            child: Text('demo chart'),
          ),
        ],
      ),
    );
  }
}

class DetailPage extends StatelessWidget {
  final int pageNumber;
  DetailPage({required this.pageNumber});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("page $pageNumber"),
      ),
      body: Center(
        child: Text(
          'This is page $pageNumber',
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }


}