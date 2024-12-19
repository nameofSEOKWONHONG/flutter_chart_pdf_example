

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ApneaBarChart extends StatelessWidget {
  // 샘플 데이터: 각 10분 구간당 무호흡 횟수
  final List<int> apneaCounts = [5, 8, 12, 3, 7, 4, 6, 10, 5, 9]; // y축 데이터

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Apnea Counts Over Time'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: BarChart(
          BarChartData(
            barGroups: _buildBarGroups(), // Bar 데이터 그룹
            titlesData: _buildTitles(), // x축, y축 라벨
            gridData: FlGridData(show: true),
            borderData: FlBorderData(show: false),
            barTouchData: BarTouchData(enabled: true),
          ),
        ),
      ),
    );
  }

  // Bar 데이터 그룹 생성
  List<BarChartGroupData> _buildBarGroups() {
    return List.generate(apneaCounts.length, (index) {
      return BarChartGroupData(
        x: index, // x축 위치
        barRods: [
          BarChartRodData(
            toY: apneaCounts[index].toDouble(), // y축 값
            color: Colors.blueAccent,
            width: 15, // 막대 너비
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    });
  }

  // x축과 y축의 라벨 설정
  FlTitlesData _buildTitles() {
    return FlTitlesData(
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 40,
          interval: 2, // y축 눈금 간격 설정
          getTitlesWidget: (value, meta) {
            return Text(
              value.toInt().toString(),
              style: TextStyle(fontSize: 12),
            );
          },
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (value, meta) {
            // x축 라벨: 10분 단위로 표시
            final label = '${(value.toInt() + 1) * 10}m';
            return Text(label, style: TextStyle(fontSize: 12));
          },
        ),
      ),
      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }
}