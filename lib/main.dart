import 'package:flu_example/menus/barchart.dart';
import 'package:flu_example/menus/barchart2.dart';
import 'package:flu_example/menus/demochart.dart';
import 'package:flu_example/menus/linechart.dart';
import 'package:flutter/material.dart';

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
                  builder: (context) => DemoChart(),
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