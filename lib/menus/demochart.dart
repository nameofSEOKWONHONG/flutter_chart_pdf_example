import 'package:flu_example/menus/chart_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'chart_model.dart';

class DemoChart extends StatefulWidget {
  ChartMember _member;
  ChartSleepStage _sleepStage;
  EventInfo _eventInfo;
  TrendInfo _trendInfo;
  SleepStateReview _sleepReview;
  BioEstimate _bioEstimate;

  DemoChart(this._member, this._sleepStage, this._eventInfo, this._trendInfo, this._sleepReview, this._bioEstimate, {super.key});

  @override
  State<DemoChart> createState() => _DemoChartState();
}

class _DemoChartState extends State<DemoChart> {
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
    final font = await loadKoreanFont();

    final svgString = await rootBundle.loadString('assets/report.svg');

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Stack(
            children: [
              pw.Positioned.fill(
                child: pw.SvgImage(
                  svg: svgString,
                  fit: pw.BoxFit.cover,
                ),
              ),
              //region [debug]
              // pw.Positioned(
              //     left: 0,  // X 좌표
              //     top: 0,
              //     child :pw.CustomPaint(
              //         size: const PdfPoint(0, 0),
              //         painter: (canvas, size) {
              //           canvas
              //             ..setColor(PdfColors.red)
              //             ..drawString(PdfFont.courier(PdfDocument()), 5, "(0,0)", 0, 0)
              //             ..strokePath();
              //           for(int x=0; x<500; x+=10) {
              //             for(int y=0; y>=-728; y-=10) {
              //               canvas
              //                 ..setColor(PdfColors.red)
              //                 ..setLineWidth(0.1)
              //                 ..drawLine(x.toDouble(), y.toDouble(), x.toDouble(), y.toDouble() + 10)
              //                 ..strokePath();
              //             }
              //           }
              //
              //           for(int x=0; x<500; x+=10) {
              //             for(int y=0; y>=-728; y-=10) {
              //               canvas
              //                 ..setColor(PdfColors.red)
              //                 ..setLineWidth(0.1)
              //                 ..drawLine(x.toDouble(), y.toDouble(), x.toDouble() + 10, y.toDouble())
              //                 ..strokePath();
              //             }
              //           }
              //         }
              //     )
              // ),
              //endregion

              //region [사용자 정보]
              //프로필
              pw.Positioned(
                left: 300,  // X 좌표
                top: 30,  // Y 좌표
                child: ChartUtil.defaultText(pw.Alignment.centerLeft, widget._member.name, 7, pw.FontWeight.bold, font, 8),
              ),
              //성별
              pw.Positioned(
                left: 355,  // X 좌표
                top: 30,  // Y 좌표
                child: ChartUtil.defaultText(pw.Alignment.centerLeft, widget._member.gender, 7, pw.FontWeight.bold, font, 8),
              ),
              //생년월일
              pw.Positioned(
                left: 410,  // X 좌표
                top: 30,  // Y 좌표
                child: ChartUtil.defaultText(pw.Alignment.centerLeft, widget._member.birth, 7, pw.FontWeight.bold, font, 8),
              ),
              //측정일시
              pw.Positioned(
                left: 300,  // X 좌표
                top: 50,  // Y 좌표
                child: ChartUtil.defaultText(pw.Alignment.centerLeft, widget._member.date, 7, pw.FontWeight.bold, font, 8),
              ),
              //endregion

              //region 수면 정보
              //수면 시간
              pw.Positioned(
                left: 0,  // X 좌표
                top: 104,  // Y 좌표
                child: ChartUtil.defaultText(pw.Alignment.centerLeft, widget._sleepStage.sleepTime, 12, pw.FontWeight.bold, font, 8),
              ),
              //취침 시간
              pw.Positioned(
                left: 196,  // X 좌표
                top: 110,  // Y 좌표
                child: ChartUtil.defaultText(pw.Alignment.centerLeft, widget._sleepStage.startSleepTime, 7, pw.FontWeight.bold, font, 8),
              ),
              //기상 시간
              pw.Positioned(
                left: 291,  // X 좌표
                top: 110,  // Y 좌표
                child: ChartUtil.defaultText(pw.Alignment.centerLeft, widget._sleepStage.endSleepTime, 7, pw.FontWeight.bold, font, 8),
              ),


              //수면 단계
              pw.Positioned(
                left:100,
                top: 178,
                child: ChartUtil.drawTimeLine()
              ),
              pw.Positioned(
                left:100,
                top: 130,
                child: ChartUtil.drawSleepStageLineChart(widget._sleepStage),
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
                                for(int i=0; i<widget._sleepStage.tables.length; i++)
                                  pw.TableRow(
                                      children: [
                                        pw.CustomPaint(
                                            size: const PdfPoint(100, 10),
                                            painter: (canvas, point) {
                                              canvas
                                                ..setStrokeColor(widget._sleepStage.tables[i].color)
                                                ..setLineWidth(5)
                                                ..moveTo(0, 4)
                                                ..lineTo(widget._sleepStage.tables[i].count, 4)
                                                ..strokePath()
                                              ;
                                            }
                                        ),
                                        ChartUtil.defaultText(pw.Alignment.centerLeft, widget._sleepStage.tables[i].title, 5, pw.FontWeight.bold, font, 2),
                                        ChartUtil.defaultText(pw.Alignment.centerLeft, widget._sleepStage.tables[i].time, 5, pw.FontWeight.bold, font, 2),
                                        ChartUtil.defaultText(pw.Alignment.centerLeft, "${widget._sleepStage.tables[i].count.toInt()}%", 5, pw.FontWeight.bold, font, 2),
                                      ]
                                  )
                              ]
                          ),
                        ]
                    )
                  ]
                )
              ),
              //endregion

              //region [이벤트 발생 정보]
              //무호흡
              pw.Positioned(
                left:100,
                top: 315,
                child: ChartUtil.drawEventBarChart(widget._eventInfo.apneaCounts, PdfColors.blue200)
              ),
              //불규칙한 심장박동
              pw.Positioned(
                  left:100,
                  top: 372,
                  child: ChartUtil.drawEventBarChart(widget._eventInfo.arrhythmiaCounts, PdfColors.red)
              ),
              //뒤척임
              pw.Positioned(
                  left:100,
                  top: 430,
                  child: ChartUtil.drawEventBarChart(widget._eventInfo.arrhythmia2Counts, PdfColors.blue700)
              ),
              //endregion

              //region [트랜드 정보]
              //호흡수
              pw.Positioned(
                left:100,
                top: 550,
                child: ChartUtil.drawTimeLine()
              ),
              pw.Positioned(
                  left:100,
                  top: 542,
                  child: ChartUtil.drawTrendLineChart(widget._trendInfo.breathCounts, 10, 30, 10, 20)
              ),
              //산소포화도
              pw.Positioned(
                  left:100,
                  top: 596,
                  child: ChartUtil.drawTimeLine()
              ),
              pw.Positioned(
                  left:100,
                  top: 576,
                  child: ChartUtil.drawTrendLineChart(widget._trendInfo.oxygenCounts, 90, 100, 0, 10)
              ),
              //심박수
              pw.Positioned(
                  left:100,
                  top: 640,
                  child: ChartUtil.drawTimeLine()
              ),
              pw.Positioned(
                  left:100,
                  top: 640,
                  child: ChartUtil.drawTrendLineChart(widget._trendInfo.heartrateCounts, 50, 200, 10, 28)
              ),
              //체온
              pw.Positioned(
                  left:100,
                  top: 686,
                  child: ChartUtil.drawTimeLine()
              ),
              pw.Positioned(
                  left:100,
                  top: 680,
                  child: ChartUtil.drawTrendLineChart(widget._trendInfo.temperatureCounts, 350, 400, 0, 50)
              ),
              //endregion

              //region 수면 측정 점수
              pw.Positioned(
                left: 370,
                top: 100,
                child: ChartUtil.defaultText(pw.Alignment.topLeft, widget._sleepReview.point, 12, pw.FontWeight.bold, font, 0)
              ),
              //endregion

              //region [수면 상태 평가]
              pw.Positioned(
                left: 440,
                top: 224,
                child: ChartUtil.defaultText(pw.Alignment.centerLeft, widget._sleepReview.sleepTime, 7, pw.FontWeight.bold, font, 0)
              ),
              pw.Positioned(
                  left: 456,
                  top: 240,
                  child: ChartUtil.defaultText(pw.Alignment.centerLeft, widget._sleepReview.toSleepTime, 7, pw.FontWeight.bold, font, 0)
              ),
              pw.Positioned(
                  left: 456,
                  top: 252,
                  child: ChartUtil.defaultText(pw.Alignment.centerLeft, widget._sleepReview.arrhythmiaCount, 7, pw.FontWeight.bold, font, 0)
              ),
              pw.Positioned(
                  left: 456,
                  top: 266,
                  child: ChartUtil.defaultText(pw.Alignment.centerLeft, widget._sleepReview.apneaCount, 7, pw.FontWeight.bold, font, 0)
              ),
              pw.Positioned(
                  left: 456,
                  top: 282,
                  child: ChartUtil.defaultText(pw.Alignment.centerLeft, widget._sleepReview.arrhythmia2Count, 7, pw.FontWeight.bold, font, 0)
              ),
              //endregion

              //region [생체 정보]

              //region [호흡수]
              pw.Positioned(
                  left: 450,
                  top: 324,
                  child: ChartUtil.defaultText(pw.Alignment.centerLeft, widget._bioEstimate.breathCount, 5, pw.FontWeight.bold, font, 0)
              ),
              pw.Positioned(
                left: 334,
                top:356,
                child: ChartUtil.drawTrendMinimalLineChart(widget._trendInfo.breathCounts, 10, 30, 10, 20, 25, 10, false)
              ),
              pw.Positioned(
                  left: 456,
                  top: 382,
                  child: ChartUtil.defaultText(pw.Alignment.centerLeft, widget._bioEstimate.breathUp, 5, pw.FontWeight.bold, font, 0)
              ),
              pw.Positioned(
                  left: 456,
                  top: 390,
                  child: ChartUtil.defaultText(pw.Alignment.centerLeft, widget._bioEstimate.breathDown, 5, pw.FontWeight.bold, font, 0)
              ),
              //endregion

              //region [산소포화도]
              pw.Positioned(
                  left: 450,
                  top: 410,
                  child: ChartUtil.defaultText(pw.Alignment.centerLeft, widget._bioEstimate.oxygenRate, 5, pw.FontWeight.bold, font, 0)
              ),
              pw.Positioned(
                  left: 334,
                  top:440,
                  child: ChartUtil.drawTrendMinimalLineChart(widget._trendInfo.oxygenCounts, 90, 100, 0, 10, 100, 94, true)
              ),
              pw.Positioned(
                  left: 454,
                  top: 473,
                  child: ChartUtil.defaultText(pw.Alignment.centerLeft, widget._bioEstimate.oxygenDown, 5, pw.FontWeight.bold, font, 0)
              ),
              //endregion

              //region [심박수]
              pw.Positioned(
                  left: 450,
                  top: 494,
                  child: ChartUtil.defaultText(pw.Alignment.centerLeft, widget._bioEstimate.heartRateCount, 5, pw.FontWeight.bold, font, 0)
              ),
              pw.Positioned(
                  left: 334,
                  top:528,
                  child: ChartUtil.drawTrendMinimalLineChart(widget._trendInfo.heartrateCounts, 50, 200, 10, 28, 100, 60, false)
              ),
              pw.Positioned(
                  left: 454,
                  top: 548,
                  child: ChartUtil.defaultText(pw.Alignment.centerLeft, widget._bioEstimate.heartRateUp, 5, pw.FontWeight.bold, font, 0)
              ),
              pw.Positioned(
                  left: 454,
                  top: 556,
                  child: ChartUtil.defaultText(pw.Alignment.centerLeft, widget._bioEstimate.heartRateDown, 5, pw.FontWeight.bold, font, 0)
              ),
              //endregion

              //region [체온]
              pw.Positioned(
                  left: 450,
                  top: 575,
                  child: ChartUtil.defaultText(pw.Alignment.centerLeft, widget._bioEstimate.temperature, 5, pw.FontWeight.bold, font, 0)
              ),
              pw.Positioned(
                  left: 334,
                  top:608,
                  child: ChartUtil.drawTrendMinimalLineChart(widget._trendInfo.temperatureCounts, 350, 400, 0, 50, 375, 365, false)
              ),
              pw.Positioned(
                  left: 454,
                  top: 630,
                  child: ChartUtil.defaultText(pw.Alignment.centerLeft, widget._bioEstimate.temperatureUp, 5, pw.FontWeight.bold, font, 0)
              ),
              pw.Positioned(
                  left: 454,
                  top: 638,
                  child: ChartUtil.defaultText(pw.Alignment.centerLeft, widget._bioEstimate.temperatureDown, 5, pw.FontWeight.bold, font, 0)
              ),
              //endregion

              //endregion
            ],
          );
        },
      ),
    );

    return await doc.save();
  }
}



