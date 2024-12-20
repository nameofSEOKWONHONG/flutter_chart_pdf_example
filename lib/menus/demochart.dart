
import 'dart:math';
import 'dart:typed_data';

import 'package:flu_example/menus/chart_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'chart_model.dart';
import 'demochart_body_left.dart';
import 'demochart_header.dart';



class DemoChart extends StatelessWidget {
  ChartMember member;
  ChartSleepStage sleepStage;
  EventInfo eventInfo;
  TrendInfo trendInfo;
  SleepReview sleepReview;

  DemoChart(this.member, this.sleepStage, this.eventInfo, this.trendInfo, this.sleepReview);

  Future<pw.Font> loadKoreanFont() async {
    // 폰트 파일 로드
    final fontData = await rootBundle.load('assets/NanumGothic.ttf');
    return pw.Font.ttf(fontData);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('demo'),
      ),
      body: PdfPreview(
        maxPageWidth: 700,
        build: (format) => _makePDF(format),
      ),
    );
  }

  Future<Uint8List> _makePDF(PdfPageFormat format) async {
    final doc = pw.Document();
    final Uint8List headerImage = await _loadImageFromAssets('assets/logo.png');
    final font = await loadKoreanFont();

    final svgString = await rootBundle.loadString('assets/report.svg');

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          // SVG를 배경으로 설정
          return pw.Stack(
            children: [
              pw.Positioned.fill(
                child: pw.SvgImage(
                  svg: svgString,
                  fit: pw.BoxFit.cover,
                ),
              ),
              //----------------측정 인사 정보--------------//
              //프로필
              pw.Positioned(
                left: 300,  // X 좌표
                top: 30,  // Y 좌표
                child: ChartUtil.defaultText(pw.Alignment.centerLeft, member.name, 7, pw.FontWeight.bold, font, 8),
              ),
              //성별
              pw.Positioned(
                left: 355,  // X 좌표
                top: 30,  // Y 좌표
                child: ChartUtil.defaultText(pw.Alignment.centerLeft, member.gender, 7, pw.FontWeight.bold, font, 8),
              ),
              //생년월일
              pw.Positioned(
                left: 410,  // X 좌표
                top: 30,  // Y 좌표
                child: ChartUtil.defaultText(pw.Alignment.centerLeft, member.birth, 7, pw.FontWeight.bold, font, 8),
              ),
              //측정일시
              pw.Positioned(
                left: 300,  // X 좌표
                top: 50,  // Y 좌표
                child: ChartUtil.defaultText(pw.Alignment.centerLeft, member.date, 7, pw.FontWeight.bold, font, 8),
              ),
              
              //---------------수면 정보-----------------------//
              //수면 시간
              pw.Positioned(
                left: 0,  // X 좌표
                top: 104,  // Y 좌표
                child: ChartUtil.defaultText(pw.Alignment.centerLeft, sleepStage.sleepTime, 12, pw.FontWeight.bold, font, 8),
              ),
              //취침 시간
              pw.Positioned(
                left: 196,  // X 좌표
                top: 110,  // Y 좌표
                child: ChartUtil.defaultText(pw.Alignment.centerLeft, sleepStage.startSleepTime, 7, pw.FontWeight.bold, font, 8),
              ),
              //기상 시간
              pw.Positioned(
                left: 291,  // X 좌표
                top: 110,  // Y 좌표
                child: ChartUtil.defaultText(pw.Alignment.centerLeft, sleepStage.endSleepTime, 7, pw.FontWeight.bold, font, 8),
              ),
              
              //수면 단계
              pw.Positioned(
                left:100,
                top: 130,
                child: pw.CustomPaint(
                    size: const PdfPoint(280, 50),
                    painter: (canvas, point) {
                      canvas
                        ..setStrokeColor(PdfColors.black)
                        ..setLineWidth(0.01)
                        ..moveTo(10, 40)
                        ..lineTo(210, 40)
                      ;

                      DateTime startTime = DateTime(
                        sleepStage.stages[0].date.year
                      , sleepStage.stages[0].date.month
                      , sleepStage.stages[0].date.day
                      , 22
                      , 0
                      , 0);
                      DateTime endTime = DateTime(
                            sleepStage.stages[sleepStage.stages.length - 1].date.year
                          , sleepStage.stages[sleepStage.stages.length - 1].date.month
                          , sleepStage.stages[sleepStage.stages.length - 1].date.day
                          , 09
                          , 0
                          , 0
                      );   // 종료 시간
                      Duration interval = const Duration(minutes: 10);           // 10분 간격

                      DateTime currentTime = startTime;
                      double x = 10;
                      double y1 = 40;
                      double y2 = 35;
                      while (currentTime.isBefore(endTime) || currentTime.isAtSameMomentAs(endTime)) {
                        canvas
                          ..setColor(PdfColors.black)
                          ..setLineWidth(0.1)
                          ..drawLine(x, y1, x, y2)
                          ..strokePath();

                        if (currentTime.minute == 0) {
                          canvas.drawString(PdfFont.courier(PdfDocument()), 4, "${currentTime.hour.toString().padLeft(2, "0")}", x-2, y2 - 5);
                        }

                        var item = sleepStage.stages.where((m) => m.date.isAfter(currentTime)).firstOrNull;
                        if(item?.type == "0") {
                          canvas
                            ..setLineWidth(0.1)
                            ..setFillColor(PdfColors.orange)
                            ..drawRect(x, y2 - 18, 8, 10)
                            ..fillPath();
                        }
                        else if(item?.type == "1") {
                          canvas
                            ..setLineWidth(0.1)
                            ..setFillColor(PdfColors.blueGrey200)
                            ..drawRect(x, y2 - 35, 8, 10)
                            ..fillPath();
                        }
                        else if(item?.type == "2") {
                          canvas
                            ..setLineWidth(0.1)
                            ..setFillColor(PdfColors.blue)
                            ..drawRect(x, y2 - 50, 8, 10)
                            ..fillPath();
                        }
                        else if(item?.type == "3") {
                          canvas
                            ..setLineWidth(0.1)
                            ..setFillColor(PdfColors.purple)
                            ..drawRect(x, y2 - 65, 8, 10)
                            ..fillPath();
                        }


                        x = x+3;

                        currentTime = currentTime.add(interval);  // 10분 추가
                      }
                    }
                ),
              ),
              //수면 단계 통계
              pw.Positioned(
                left: 80,
                top: 235,
                child: pw.Table(
                  children: [
                    pw.TableRow(
                        children: [
                          pw.Table(
                              border: const pw.TableBorder(
                                  top: pw.BorderSide(color: PdfColors.grey, width: 1),
                                  verticalInside: pw.BorderSide(color: PdfColors.grey, width: 1)
                              ),
                              children: [
                                for(int i=0; i<sleepStage.tables.length; i++)
                                  pw.TableRow(
                                      children: [
                                        pw.CustomPaint(
                                            size: const PdfPoint(100, 10),
                                            painter: (canvas, point) {
                                              canvas
                                                ..setStrokeColor(sleepStage.tables[i].color)
                                                ..setLineWidth(5)
                                                ..moveTo(0, 4)
                                                ..lineTo(sleepStage.tables[i].count, 4)
                                                ..strokePath()
                                              ;
                                            }
                                        ),
                                        ChartUtil.defaultText(pw.Alignment.centerLeft, sleepStage.tables[i].title, 5, pw.FontWeight.bold, font, 2),
                                        ChartUtil.defaultText(pw.Alignment.centerLeft, sleepStage.tables[i].time, 5, pw.FontWeight.bold, font, 2),
                                        ChartUtil.defaultText(pw.Alignment.centerLeft, "${sleepStage.tables[i].count.toInt()}%", 5, pw.FontWeight.bold, font, 2),
                                      ]
                                  )
                              ]
                          ),
                        ]
                    )
                  ]
                )
              ),
              //---------------이벤트 발생 정보----------------------//
              //무호흡
              pw.Positioned(
                left:100,
                top: 315,
                child: ChartUtil.drawEventBarChart(this.eventInfo.apneaCounts, PdfColors.blue200)
              ),
              //불규칙한 심장박동
              pw.Positioned(
                  left:100,
                  top: 372,
                  child: ChartUtil.drawEventBarChart(this.eventInfo.arrhythmiaCounts, PdfColors.red)
              ),
              //뒤척임
              pw.Positioned(
                  left:100,
                  top: 430,
                  child: ChartUtil.drawEventBarChart(this.eventInfo.arrhythmia2Counts, PdfColors.blue700)
              ),
              //-----------------트랜드 정보-----------------------//
              //호흡수
              pw.Positioned(
                left:100,
                top: 498,
                child: ChartUtil.drawTimeLine()
              ),
              pw.Positioned(
                  left:100,
                  top: 514,
                  child: ChartUtil.drawTrendBreathLineChart(this.trendInfo.breathCounts)
              ),
              //산소포화도
              pw.Positioned(
                  left:100,
                  top: 544,
                  child: ChartUtil.drawTimeLine()
              ),
              pw.Positioned(
                  left:100,
                  top: 650,
                  child: ChartUtil.drawTrendOxygenLineChart(this.trendInfo.oxygenCounts)
              ),
              //심박수
              pw.Positioned(
                  left:100,
                  top: 589,
                  child: ChartUtil.drawTimeLine()
              ),
              pw.Positioned(
                  left:100,
                  top: 610,
                  child: ChartUtil.drawTrendHeartRateLineChart(this.trendInfo.heartrateCounts)
              ),
              //체온
              pw.Positioned(
                  left:100,
                  top: 635,
                  child: ChartUtil.drawTimeLine()
              ),
              pw.Positioned(
                  left:100,
                  top: 1000,
                  child: ChartUtil.drawTrendTemperatureLineChart(this.trendInfo.temperatureCounts)
              ),
              //------------ 수면 측정 점수-----------------//
              pw.Positioned(
                left: 370,
                top: 100,
                child: ChartUtil.defaultText(pw.Alignment.topLeft, this.sleepReview.point, 12, pw.FontWeight.bold, font, 0)
              ),
              //------------수면 상태 평가-----------------//
              pw.Positioned(
                left: 440,
                top: 224,
                child: ChartUtil.defaultText(pw.Alignment.centerLeft, this.sleepReview.sleepTime, 7, pw.FontWeight.bold, font, 0)
              ),
              pw.Positioned(
                  left: 456,
                  top: 240,
                  child: ChartUtil.defaultText(pw.Alignment.centerLeft, this.sleepReview.toSleepTime, 7, pw.FontWeight.bold, font, 0)
              ),
              pw.Positioned(
                  left: 456,
                  top: 252,
                  child: ChartUtil.defaultText(pw.Alignment.centerLeft, this.sleepReview.arrhythmiaCount, 7, pw.FontWeight.bold, font, 0)
              ),
              pw.Positioned(
                  left: 456,
                  top: 266,
                  child: ChartUtil.defaultText(pw.Alignment.centerLeft, this.sleepReview.apneaCount, 7, pw.FontWeight.bold, font, 0)
              ),
              pw.Positioned(
                  left: 456,
                  top: 282,
                  child: ChartUtil.defaultText(pw.Alignment.centerLeft, this.sleepReview.arrhythmia2Count, 7, pw.FontWeight.bold, font, 0)
              ),
              //--------------------생체 정보---------------------//
              //호흡수
              pw.Positioned(
                  left: 450,
                  top: 324,
                  child: ChartUtil.defaultText(pw.Alignment.centerLeft, "평균 16회/분", 5, pw.FontWeight.bold, font, 0)
              ),
              pw.Positioned(
                left: 340,
                top:356,
                child: ChartUtil.drawReviewChart()
              ),
              pw.Positioned(
                  left: 456,
                  top: 382,
                  child: ChartUtil.defaultText(pw.Alignment.centerLeft, "2건 발생", 5, pw.FontWeight.bold, font, 0)
              ),
              pw.Positioned(
                  left: 456,
                  top: 390,
                  child: ChartUtil.defaultText(pw.Alignment.centerLeft, "4건 발생", 5, pw.FontWeight.bold, font, 0)
              ),
              //산소포화도
              pw.Positioned(
                  left: 450,
                  top: 410,
                  child: ChartUtil.defaultText(pw.Alignment.centerLeft, "평균 98%", 5, pw.FontWeight.bold, font, 0)
              ),
              pw.Positioned(
                  left: 340,
                  top:446,
                  child: ChartUtil.drawReviewChart()
              ),
              pw.Positioned(
                  left: 454,
                  top: 473,
                  child: ChartUtil.defaultText(pw.Alignment.centerLeft, "2건 발생", 5, pw.FontWeight.bold, font, 0)
              ),
              //심박수
              pw.Positioned(
                  left: 450,
                  top: 494,
                  child: ChartUtil.defaultText(pw.Alignment.centerLeft, "평균 92bpm", 5, pw.FontWeight.bold, font, 0)
              ),
              pw.Positioned(
                  left: 340,
                  top:528,
                  child: ChartUtil.drawReviewChart()
              ),
              pw.Positioned(
                  left: 454,
                  top: 548,
                  child: ChartUtil.defaultText(pw.Alignment.centerLeft, "2건 발생", 5, pw.FontWeight.bold, font, 0)
              ),
              pw.Positioned(
                  left: 454,
                  top: 556,
                  child: ChartUtil.defaultText(pw.Alignment.centerLeft, "2건 발생", 5, pw.FontWeight.bold, font, 0)
              ),
              //체온
              pw.Positioned(
                  left: 450,
                  top: 575,
                  child: ChartUtil.defaultText(pw.Alignment.centerLeft, "평균 36.5℃", 5, pw.FontWeight.bold, font, 0)
              ),
              pw.Positioned(
                  left: 340,
                  top:608,
                  child: ChartUtil.drawReviewChart()
              ),
              pw.Positioned(
                  left: 454,
                  top: 630,
                  child: ChartUtil.defaultText(pw.Alignment.centerLeft, "2건 발생", 5, pw.FontWeight.bold, font, 0)
              ),
              pw.Positioned(
                  left: 454,
                  top: 638,
                  child: ChartUtil.defaultText(pw.Alignment.centerLeft, "2건 발생", 5, pw.FontWeight.bold, font, 0)
              ),
            ],
          );
        },
      ),
    );

    return await doc.save();
  }

  Future<Uint8List> _loadImageFromAssets(String path) async {
    final ByteData data = await rootBundle.load(path);
    return data.buffer.asUint8List();
  }

}



