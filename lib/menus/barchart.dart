import 'dart:ui';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class BarChartPage extends StatelessWidget {
  BarChartPage({super.key});

  final GlobalKey _repaintKey = GlobalKey();

  final pilateColor = Colors.purple;
  final cyclingColor = Colors.cyan;
  final quickWorkoutColor = Colors.blueAccent;
  final betweenSpace = 0.2;

  BarChartGroupData generateGroupData(
      int x,
      double pilates,
      double quickWorkout,
      double cycling,
      ) {
    return BarChartGroupData(
      x: x,
      groupVertically: true,
      barRods: [
        BarChartRodData(
          fromY: 0,
          toY: pilates,
          color: pilateColor,
          width: 2,
        ),
        BarChartRodData(
          fromY: pilates + betweenSpace,
          toY: pilates + betweenSpace + quickWorkout,
          color: quickWorkoutColor,
          width: 2,
        ),
        BarChartRodData(
          fromY: pilates + betweenSpace + quickWorkout + betweenSpace,
          toY: pilates + betweenSpace + quickWorkout + betweenSpace + cycling,
          color: cyclingColor,
          width: 2,
        ),
      ],
    );
  }

  Widget bottomTitles(double value, TitleMeta meta) {
    const style = TextStyle(fontSize: 5);
    String text;
    switch (value.toInt()) {
      case 0:
        text = 'PM10';
        break;
      case 1:
        text = '11';
        break;
      case 2:
        text = '12';
        break;
      case 3:
        text = 'AM1';
        break;
      case 4:
        text = '2';
        break;
      case 5:
        text = '3';
        break;
      case 6:
        text = '4';
        break;
      case 7:
        text = '5';
        break;
      case 8:
        text = '6';
        break;
      case 9:
        text = '7';
        break;
      case 10:
        text = '8';
        break;
      case 11:
        text = '9';
        break;
      default:
        text = '';
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(text, style: style),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size; // 화면 크기
    final screenWidth = size.width;
    final screenHeight = size.height;

    final screenAspectRatio = screenWidth / screenHeight;
    debugPrint("screenAspectRatio: $screenAspectRatio");

    final List<int> apneaCounts = [5, 8, 12, 3, 7, 4, 6, 10, 5, 9]; // y축 데이터
    List<BarChartGroupData> _buildBarGroups() {
      return List.generate(apneaCounts.length, (index) {
        return BarChartGroupData(
          x: index, // x축 위치
          barRods: [
            BarChartRodData(
              toY: apneaCounts[index].toDouble(), // y축 값
              color: Colors.blueAccent,
              width: 1, // 막대 너비
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
            reservedSize: 10,
            interval: 5, // y축 눈금 간격 설정
            getTitlesWidget: (value, meta) {
              return Text(
                value.toInt().toString(),
                style: TextStyle(fontSize: 5),
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
              return Text(label, style: TextStyle(fontSize: 5));
            },
          ),
        ),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      );
    }

    return RepaintBoundary(
      key: _repaintKey,
      child: Stack(
        children: [
          ElevatedButton(
            onPressed: () => _exportToPDF(context),
            child: const Text("PDF"),
          ),
          // SVG를 전체 화면에 맞추기
          Positioned.fill(
            child: SvgPicture.asset(
              'assets/report.svg',
              fit: BoxFit.contain,
            ),
          ),
          Positioned(
              top: (screenHeight * 0.19),
              left: (screenWidth * 0.62),
              child: const Text(
                '이지은',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 6,
                  fontWeight: FontWeight.bold,
                ),
              )
          ),
          Positioned(
              top: (screenHeight * 0.19),
              left: (screenWidth * 0.74),
              child: const Text(
                '여성',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 6,
                  fontWeight: FontWeight.bold,
                ),
              )
          ),
          Positioned(
              top: (screenHeight * 0.19),
              left: (screenWidth * 0.84),
              child: const Text(
                '1990.03.12',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 6,
                  fontWeight: FontWeight.bold,
                ),
              )
          ),
          Positioned(
              top: (screenHeight * 0.21),
              left: (screenWidth * 0.62),
              child: const Text(
                '2024년 9월 23일 오후 10시 - 9월 24일 오전 6시',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 5,
                  fontWeight: FontWeight.bold,
                ),
              )
          ),
          Positioned(
            top: (screenHeight * 0.456),
            left: (screenWidth * 0.2),
            width: (screenWidth * 0.44),
            height: (screenHeight * 0.06),
            child: AspectRatio(
              aspectRatio: 1,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceBetween,
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(),
                    rightTitles: const AxisTitles(),
                    topTitles: const AxisTitles(),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: bottomTitles,
                        reservedSize: 22,
                      ),
                    ),
                  ),
                  barTouchData: BarTouchData(enabled: false),
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: false),
                  barGroups: [
                    generateGroupData(0, 2, 3, 2),
                    generateGroupData(1, 2, 5, 1.7),
                    generateGroupData(2, 1.3, 3.1, 2.8),
                    generateGroupData(3, 3.1, 4, 3.1),
                    generateGroupData(4, 0.8, 3.3, 3.4),
                    generateGroupData(5, 2, 5.6, 1.8),
                    generateGroupData(6, 1.3, 3.2, 2),
                    generateGroupData(7, 2.3, 3.2, 3),
                    generateGroupData(8, 2, 4.8, 2.5),
                    generateGroupData(9, 1.2, 3.2, 2.5),
                    generateGroupData(10, 1, 4.8, 3),
                    generateGroupData(11, 2, 4.4, 2.8),
                  ],
                  maxY: 11 + (betweenSpace * 3),
                  extraLinesData: ExtraLinesData(
                    horizontalLines: [
                      HorizontalLine(
                        y: 3.3,
                        color: pilateColor,
                        strokeWidth: 1,
                        dashArray: [20, 4],
                      ),
                      HorizontalLine(
                        y: 8,
                        color: quickWorkoutColor,
                        strokeWidth: 1,
                        dashArray: [20, 4],
                      ),
                      HorizontalLine(
                        y: 11,
                        color: cyclingColor,
                        strokeWidth: 1,
                        dashArray: [20, 4],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: (screenHeight * 0.509),
            left: (screenWidth * 0.2),
            width: (screenWidth * 0.44),
            height: (screenHeight * 0.06),
            child: AspectRatio(
              aspectRatio: 2,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceBetween,
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(),
                    rightTitles: const AxisTitles(),
                    topTitles: const AxisTitles(),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: bottomTitles,
                        reservedSize: 20,
                      ),
                    ),
                  ),
                  barTouchData: BarTouchData(enabled: false),
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: false),
                  barGroups: [
                    generateGroupData(0, 2, 3, 2),
                    generateGroupData(1, 2, 5, 1.7),
                    generateGroupData(2, 1.3, 3.1, 2.8),
                    generateGroupData(3, 3.1, 4, 3.1),
                    generateGroupData(4, 0.8, 3.3, 3.4),
                    generateGroupData(5, 2, 5.6, 1.8),
                    generateGroupData(6, 1.3, 3.2, 2),
                    generateGroupData(7, 2.3, 3.2, 3),
                    generateGroupData(8, 2, 4.8, 2.5),
                    generateGroupData(9, 1.2, 3.2, 2.5),
                    generateGroupData(10, 1, 4.8, 3),
                    generateGroupData(11, 2, 4.4, 2.8),
                  ],
                  maxY: 11 + (betweenSpace * 3),
                  extraLinesData: ExtraLinesData(
                    horizontalLines: [
                      HorizontalLine(
                        y: 3.3,
                        color: pilateColor,
                        strokeWidth: 1,
                        dashArray: [20, 4],
                      ),
                      HorizontalLine(
                        y: 8,
                        color: quickWorkoutColor,
                        strokeWidth: 1,
                        dashArray: [20, 4],
                      ),
                      HorizontalLine(
                        y: 11,
                        color: cyclingColor,
                        strokeWidth: 1,
                        dashArray: [20, 4],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: (screenHeight * 0.562),
            left: (screenWidth * 0.2),
            width: (screenWidth * 0.44),
            height: (screenHeight * 0.06),
            child: AspectRatio(
              aspectRatio: 1,
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
          ),
        ],
      ),
    );
  }

  Future<void> _exportToPDF(BuildContext context) async {
    final boundary = _repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return;

    // 캡처 이미지 생성
    final image = await boundary.toImage(pixelRatio: 3.0); // 고해상도
    final byteData = await image.toByteData(format: ImageByteFormat.png);
    if (byteData == null) return;

    final pngBytes = byteData.buffer.asUint8List();

    // PDF 생성
    final pdf = pw.Document();
    final pdfImage = pw.MemoryImage(pngBytes);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Center(
            child: pw.Image(pdfImage),
          );
        },
      ),
    );

    // PDF 출력
    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }
}
