import 'package:flu_example/menus/barchart.dart';
import 'package:flu_example/menus/barchart2.dart';
import 'package:flu_example/menus/pdfUtils.dart';
import 'package:flu_example/menus/demochart.dart';
import 'package:flu_example/menus/linechart.dart';
import 'package:flu_example/menus/model.dart';
import 'package:flutter/material.dart';
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
    //사용자 정보
    var user = PdfUserInfo("이지은", "female", "19900312");
    DateTime start = DateTime(2024, 12, 31, 00, 21, 00);
    DateTime end = DateTime(2024, 12, 31, 09, 00, 00);

    List<Stage> getTempStage() {
      List<Stage> items = [];
      Duration interval = const Duration(seconds: 330);
      DateTime currentTime = start;

      var i = 0;
      while (currentTime.isBefore(end) || currentTime.isAtSameMomentAs(end)) {
        var item = Stage(profileId: "test", timestamp: currentTime, type: PdfUtils.getRandomNumber(0, 3));
        if(i >= 0 && i < 10) {
          items.add(Stage(profileId: "test", timestamp: currentTime, type: 0));
        }
        else {
          items.add(item);
        }
        i++;
        currentTime = currentTime.add(interval);
      }

      return items;
    }
    List<Apnea> getTempApnea() {
      List<Apnea> items = [];
      Duration interval = const Duration(seconds: 180);
      DateTime currentTime = start;

      while (currentTime.isBefore(end) || currentTime.isAtSameMomentAs(end)) {
        var item = Apnea(profileId: "test", timestamp: currentTime, type: 0);
        var n = PdfUtils.getRandomNumber(0, 1);
        if(n == 0) {
          items.add(item);
        }
        currentTime = currentTime.add(interval);
      }

      return items;
    }
    List<Arrhythmia> getTempArrhythmia(){
      List<Arrhythmia> result = [];
      Duration interval = const Duration(seconds: 10);
      DateTime currentTime = start;

      while (currentTime.isBefore(end) || currentTime.isAtSameMomentAs(end)) {
        var item = Arrhythmia(profileId: "test", timestamp: currentTime, type: 0);
        var n = PdfUtils.getRandomNumber(0, 100);
        if(n == 0) {
          result.add(item);
        }
        currentTime = currentTime.add(interval);
      }

      return result;
    }
    List<ArrhythmiaBeat> getTempArrhythmiaBeat(){
      List<ArrhythmiaBeat> result = [];

      Duration interval = const Duration(seconds: 10);
      DateTime currentTime = start;

      while (currentTime.isBefore(end) || currentTime.isAtSameMomentAs(end)) {
        var item = ArrhythmiaBeat(profileId: "test", timestamp: currentTime, type: 0);
        var n = PdfUtils.getRandomNumber(0, 100);
        if(n == 0) {
          result.add(item);
        }
        currentTime = currentTime.add(interval);
      }

      return result;
    }
    List<Motion> getTempMotion(){
      List<Motion> result = [];

      Duration interval = const Duration(seconds: 180);
      DateTime currentTime = start;

      while (currentTime.isBefore(end) || currentTime.isAtSameMomentAs(end)) {
        var item = Motion(profileId: "test", timestamp: currentTime, type: 1);
        var n = PdfUtils.getRandomNumber(0, 1);
        if(n == 0) {
          result.add(item);
        }
        currentTime = currentTime.add(interval);
      }

      return result;
    }
    List<TrendData> getTempTrendData(){
      List<TrendData> result = [];

      Duration interval = const Duration(minutes: 10);
      DateTime currentTime = start;

      while (currentTime.isBefore(end) || currentTime.isAtSameMomentAs(end)) {
        var item = TrendData(
            profileId: "test",
            sensorNo: "test",
            date: currentTime,
            rrAvg:PdfUtils.getRandomNumber(15, 24).toDouble(),
            spo2Avg: PdfUtils.getRandomDouble(98.0, 99.9),
            hrAvg:  PdfUtils.getRandomNumber(55, 94).toDouble(),
            tempAvg: PdfUtils.getRandomDouble(36.1, 37.6));

        result.add(item);

        currentTime = currentTime.add(interval);
      }

      return result;
    }

    var stages = getTempStage();
    var apneas = getTempApnea();
    var arrhythmias = getTempArrhythmia();
    var arrhythmiaBeats = getTempArrhythmiaBeat();
    var motions = getTempMotion();
    var trendDatum = getTempTrendData();


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
                  builder: (context) => DemoChart(
                      start, end, user, stages, apneas, arrhythmias, arrhythmiaBeats, motions, trendDatum
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

