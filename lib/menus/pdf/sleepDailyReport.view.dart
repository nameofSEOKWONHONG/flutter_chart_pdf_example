import 'package:darq/darq.dart';
import 'package:flu_example/menus/pdf/model.dart';
import 'package:flu_example/menus/pdf/pdf.converter.dart';
import 'package:flu_example/menus/pdf/pdfUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'chart_model.dart';

class SleepDailyReport extends StatefulWidget {
  DateTime start;
  DateTime end;
  PdfUserInfo user;
  List<Stage> stages;
  List<Apnea> apneas;
  List<Arrhythmia> arrhythmias;
  List<ArrhythmiaBeat> arrhythmiaBeats;
  List<Motion> motions;
  List<TrendData> trendDatum;

  SleepDailyReport(this.start, this.end, this.user, this.stages,
    this.apneas, this.arrhythmias, this.arrhythmiaBeats, this.motions,
      this.trendDatum,
      {super.key});

  @override
  State<SleepDailyReport> createState() {
    return _SleepDailyReportState();
  }
}

class _SleepDailyReportState extends State<SleepDailyReport> {
  late String _gender;
  late String _birthDate;
  late String _estimateDate;

  late PdfSleepInfo _sleepInfo;
  late List<DateTimeCount> _apneaCounts;
  late List<DateTimeCount> _arrhythmiaCounts;
  late List<DateTimeCount> _motionCounts;
  late List<DateTimeCount> _breathCounts;
  late List<DateTimeCount> _spo2Counts;
  late List<DateTimeCount> _heartRateCounts;
  late List<DateTimeCount> _temperatureCounts;
  late SleepStateReview _sleepReview;
  late BioEstimate _bioEstimate;

  Future<pw.Font> loadKoreanFont() async {
    // 폰트 파일 로드
    final fontData = await rootBundle.load('assets/fonts/NanumGothic.ttf');
    return pw.Font.ttf(fontData);
  }

  @override
  void initState() {
    DateTime sd = DateTime(widget.start.year, widget.start.month, widget.start.day, widget.start.hour, 00, 00);
    DateTime ed = DateTime(widget.end.year, widget.end.month, widget.end.day, 09, 00, 00);

    _gender = widget.user.gender.substring(0, 1).toUpperCase();
    int year = int.parse(widget.user.birth.substring(0, 4));
    int month = int.parse(widget.user.birth.substring(4, 6));
    int day = int.parse(widget.user.birth.substring(6, 8));
    DateTime birthDate = DateTime(year, month, day);
    _birthDate = PdfUtils.formatDateTime(birthDate, true);
    _estimateDate = "${PdfUtils.formatDateTime(sd, true)} - ${PdfUtils.formatDateTime(ed, true)}";

    var converter = PdfDataConverter();
    var sleepStage = converter.stageToPdfSleepStage(sd, ed, widget.stages);
    var sleepTable = converter.stageToPdfSleepStageTable(sleepStage);
    var map = converter.stageToSleepInfo(sleepStage);
    _sleepInfo = PdfSleepInfo(map["totalSleepTime"].toString(), map["sleepTime"].toString(), map["wakeTime"].toString(), sleepStage, sleepTable);

    _apneaCounts = converter.apneaToDateTimeCount(sd, ed, widget.apneas);
    _arrhythmiaCounts = converter.arrhythmiaToDateTimeCount(sd, ed, widget.arrhythmias, widget.arrhythmiaBeats);
    _motionCounts = converter.motionToDateTimeCount(sd, ed, widget.motions);

    _breathCounts = converter.trendDataToDateTimeCount(sd, ed, widget.trendDatum, 0);
    _spo2Counts = converter.trendDataToDateTimeCount(sd, ed, widget.trendDatum, 1);
    _heartRateCounts = converter.trendDataToDateTimeCount(sd, ed, widget.trendDatum, 2);
    _temperatureCounts = converter.trendDataToDateTimeCount(sd, ed, widget.trendDatum, 3);

    var point = 100 - _apneaCounts.length;
    var motionCount = 0;
    for(var item in _motionCounts) {
      motionCount += item.count.toInt();
    }
    var apneaCount = 0;
    for(var item in _apneaCounts) {
      apneaCount += item.count.toInt();
    }

    _sleepReview = SleepStateReview(point.toString(),
        "${map["totalSleepTime"].toString()}",
        "${map["sleepInterval"]}",
        "${_arrhythmiaCounts.length} times",
        "${apneaCount} times",
        "${motionCount} times");

    var rrAvg = _breathCounts.average((m) => m.count);
    var rrUp = _breathCounts.where((m) => m.count > 25).toList();
    var rrDown = _breathCounts.where((m) => m.count < 10).toList();
    var spo2Avg = _spo2Counts.average((m) => m.count);
    var spo2Down = _spo2Counts.where((m) => m.count < 94).toList();
    var hrAvg = _heartRateCounts.average((m) => m.count);
    var hrUp = _heartRateCounts.where((m) => m.count > 100).toList();
    var hrDown = _heartRateCounts.where((m) => m.count < 60).toList();
    var tempAvg = _temperatureCounts.average((m) => m.count);
    var tempUp = _temperatureCounts.where((m) => m.count > 37.5).toList();
    var tempDown = _temperatureCounts.where((m) => m.count < 36.5).toList();

    _bioEstimate = BioEstimate(
        "Average:\r\n${rrAvg.toStringAsFixed(0)}\r\nbreaths per\r\nminute"
        , "${rrUp.length} occurrences"
        , "${rrDown.length} occurrences"
        , "Average:\r\n${spo2Avg.toStringAsFixed(1)}%"
        , "${spo2Down.length} occurrences"
        , "Average:\r\n${hrAvg.toStringAsFixed(1)}bpm"
        , "${hrUp.length} occurrences"
        , "${hrDown.length} occurrences"
        , "Average:\r\n${tempAvg.toStringAsFixed(1)}℃"
        , "${tempUp.length} occurrences"
        , "${tempDown.length} occurrences");
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

    final svgString = await rootBundle.loadString('assets/images/report.svg');

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
                child: PdfUtils.defaultText(pw.Alignment.centerLeft,  widget.user.name, 7, pw.FontWeight.bold, font, 8),
              ),
              //성별
              pw.Positioned(
                left: 368,  // X 좌표
                top: 30,  // Y 좌표
                child: PdfUtils.defaultText(pw.Alignment.centerLeft,  _gender, 7, pw.FontWeight.bold, font, 8),
              ),
              //생년월일
              pw.Positioned(
                left: 410,  // X 좌표
                top: 34,  // Y 좌표
                child: PdfUtils.defaultText(pw.Alignment.centerLeft,  _birthDate, 7, pw.FontWeight.bold, font, 8),
              ),
              //측정일시
              pw.Positioned(
                left: 340,  // X 좌표
                top: 52,  // Y 좌표
                child: PdfUtils.defaultText(pw.Alignment.centerLeft,  _estimateDate, 6, pw.FontWeight.bold, font, 8),
              ),
              //endregion

              //region 수면 정보
              //수면 시간
              pw.Positioned(
                left: 0,  // X 좌표
                top: 104,  // Y 좌표
                child: PdfUtils.defaultText(pw.Alignment.centerLeft,  _sleepInfo.sleepTime, 12, pw.FontWeight.bold, font, 8),
              ),
              //취침 시간
              pw.Positioned(
                left: 196,  // X 좌표
                top: 110,  // Y 좌표
                child: PdfUtils.defaultText(pw.Alignment.centerLeft,  _sleepInfo.startSleepTime, 7, pw.FontWeight.bold, font, 8),
              ),
              //기상 시간
              pw.Positioned(
                left: 291,  // X 좌표
                top: 110,  // Y 좌표
                child: PdfUtils.defaultText(pw.Alignment.centerLeft,  _sleepInfo.endSleepTime, 7, pw.FontWeight.bold, font, 8),
              ),


              //수면 단계
              pw.Positioned(
                left:100,
                top: 178,
                child: PdfUtils.drawTimeLine()
              ),
              pw.Positioned(
                left:100,
                top: 130,
                child: PdfUtils.drawSleepStageBarChart( _sleepInfo.stages),
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
                                for(int i=0; i< _sleepInfo.tables.length; i++)
                                  pw.TableRow(
                                      children: [
                                        pw.CustomPaint(
                                            size: const PdfPoint(100, 10),
                                            painter: (canvas, point) {
                                              canvas
                                                ..setStrokeColor( _sleepInfo.tables[i].color)
                                                ..setLineWidth(5)
                                                ..moveTo(0, 4)
                                                ..lineTo( _sleepInfo.tables[i].count, 4)
                                                ..strokePath()
                                              ;
                                            }
                                        ),
                                        PdfUtils.defaultText(pw.Alignment.centerLeft,  _sleepInfo.tables[i].title, 5, pw.FontWeight.bold, font, 2),
                                        PdfUtils.defaultText(pw.Alignment.centerLeft,  _sleepInfo.tables[i].time, 5, pw.FontWeight.bold, font, 2),
                                        PdfUtils.defaultText(pw.Alignment.centerLeft, "${ _sleepInfo.tables[i].count.toStringAsFixed(0)}%", 5, pw.FontWeight.bold, font, 2),
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
                  top: 364,
                  child: PdfUtils.drawTimeLine()
              ),
              pw.Positioned(
                left:100,
                top: 315,
                child: PdfUtils.drawEventBarChart( _apneaCounts, PdfColors.blue200, 3)
              ),
              pw.Positioned(
                  left:100,
                  top: 420,
                  child: PdfUtils.drawTimeLine()
              ),
              //불규칙한 심장박동
              pw.Positioned(
                  left:100,
                  top: 372,
                  child: PdfUtils.drawEventBarChart( _arrhythmiaCounts, PdfColors.red, 15)
              ),
              pw.Positioned(
                  left:100,
                  top: 476,
                  child: PdfUtils.drawTimeLine()
              ),
              //뒤척임
              pw.Positioned(
                  left:100,
                  top: 430,
                  child: PdfUtils.drawEventBarChart( _motionCounts, PdfColors.blue700, 15)
              ),
              //endregion

              //region [트랜드 정보]
              //호흡수
              pw.Positioned(
                left:100,
                top: 550,
                child: PdfUtils.drawTimeLine()
              ),
              pw.Positioned(
                  left:100,
                  top: 540,
                  child: PdfUtils.drawTrendLineChart( _breathCounts, 10, 30, 10, 20, false)
              ),
              //산소포화도
              pw.Positioned(
                  left:100,
                  top: 596,
                  child: PdfUtils.drawTimeLine()
              ),
              pw.Positioned(
                  left:100,
                  top: 576,
                  child: PdfUtils.drawTrendLineChart( _spo2Counts, 0, 100, 0, 10, false)
              ),
              //심박수
              pw.Positioned(
                  left:100,
                  top: 640,
                  child: PdfUtils.drawTimeLine()
              ),
              pw.Positioned(
                  left:100,
                  top: 630,
                  child: PdfUtils.drawTrendLineChart( _heartRateCounts, 50, 200, 10, 28, false)
              ),
              //체온
              pw.Positioned(
                  left:100,
                  top: 686,
                  child: PdfUtils.drawTimeLine()
              ),
              pw.Positioned(
                  left:100,
                  top: 674,
                  child: PdfUtils.drawTrendLineChart(_temperatureCounts, 30, 40, 0, 30, true)
              ),
              //endregion

              //region 수면 측정 점수
              pw.Positioned(
                left: 378,
                top: 100,
                child: PdfUtils.defaultText(pw.Alignment.topLeft,  _sleepReview.point, 12, pw.FontWeight.bold, font, 0)
              ),
              pw.Positioned(
                left: 370,
                top: 150,
                child: PdfUtils.drawPoint(double.parse(_sleepReview.point), 0, 100, 0, 50)
              ),
              //endregion

              //region [수면 상태 평가]
              pw.Positioned(
                left: 456,
                top: 226,
                child: PdfUtils.defaultText(pw.Alignment.centerLeft,  _sleepReview.sleepTime, 6, pw.FontWeight.bold, font, 0)
              ),
              pw.Positioned(
                  left: 456,
                  top: 240,
                  child: PdfUtils.defaultText(pw.Alignment.centerLeft,  _sleepReview.toSleepTime, 6, pw.FontWeight.bold, font, 0)
              ),
              pw.Positioned(
                  left: 456,
                  top: 252,
                  child: PdfUtils.defaultText(pw.Alignment.centerLeft,  _sleepReview.arrhythmiaCount, 6, pw.FontWeight.bold, font, 0)
              ),
              pw.Positioned(
                  left: 456,
                  top: 266,
                  child: PdfUtils.defaultText(pw.Alignment.centerLeft,  _sleepReview.apneaCount, 6, pw.FontWeight.bold, font, 0)
              ),
              pw.Positioned(
                  left: 456,
                  top: 282,
                  child: PdfUtils.defaultText(pw.Alignment.centerLeft,  _sleepReview.arrhythmia2Count, 6, pw.FontWeight.bold, font, 0)
              ),
              //endregion

              //region [생체 정보]

              //region [호흡수]
              pw.Positioned(
                  left: 450,
                  top: 324,
                  child: PdfUtils.defaultText(pw.Alignment.centerLeft,  _bioEstimate.breathCount, 5, pw.FontWeight.bold, font, 0)
              ),
              pw.Positioned(
                left: 334,
                top:356,
                child: PdfUtils.drawTrendMinimalLineChart( _breathCounts, 10, 30, 10, 20, 25, 10, false)
              ),

              pw.Positioned(
                  left: 346,
                  top: 370,
                  child: PdfUtils.defaultText(pw.Alignment.centerLeft,  "PM 10:00", 5, pw.FontWeight.bold, font, 0)
              ),
              pw.Positioned(
                  left: 400,
                  top: 370,
                  child: PdfUtils.defaultText(pw.Alignment.centerLeft,  "AM 2:00", 5, pw.FontWeight.bold, font, 0)
              ),
              pw.Positioned(
                  left: 454,
                  top: 370,
                  child: PdfUtils.defaultText(pw.Alignment.centerLeft,  "AM 9:00", 5, pw.FontWeight.bold, font, 0)
              ),

              pw.Positioned(
                  left: 453,
                  top: 382,
                  child: PdfUtils.defaultText(pw.Alignment.centerLeft,  _bioEstimate.breathUp, 5, pw.FontWeight.bold, font, 0)
              ),
              pw.Positioned(
                  left: 453,
                  top: 390,
                  child: PdfUtils.defaultText(pw.Alignment.centerLeft,  _bioEstimate.breathDown, 5, pw.FontWeight.bold, font, 0)
              ),
              //endregion

              //region [산소포화도]
              pw.Positioned(
                  left: 450,
                  top: 410,
                  child: PdfUtils.defaultText(pw.Alignment.centerLeft,  _bioEstimate.oxygenRate, 5, pw.FontWeight.bold, font, 0)
              ),
              pw.Positioned(
                  left: 334,
                  top:440,
                  child: PdfUtils.drawTrendMinimalLineChart( _spo2Counts, 90, 100, 0, 10, 100, 94, true)
              ),

              pw.Positioned(
                  left: 346,
                  top: 460,
                  child: PdfUtils.defaultText(pw.Alignment.centerLeft,  "PM 10:00", 5, pw.FontWeight.bold, font, 0)
              ),
              pw.Positioned(
                  left: 400,
                  top: 460,
                  child: PdfUtils.defaultText(pw.Alignment.centerLeft,  "AM 2:00", 5, pw.FontWeight.bold, font, 0)
              ),
              pw.Positioned(
                  left: 454,
                  top: 460,
                  child: PdfUtils.defaultText(pw.Alignment.centerLeft,  "AM 9:00", 5, pw.FontWeight.bold, font, 0)
              ),

              pw.Positioned(
                  left: 453,
                  top: 473,
                  child: PdfUtils.defaultText(pw.Alignment.centerLeft,  _bioEstimate.oxygenDown, 5, pw.FontWeight.bold, font, 0)
              ),
              //endregion

              //region [심박수]
              pw.Positioned(
                  left: 450,
                  top: 494,
                  child: PdfUtils.defaultText(pw.Alignment.centerLeft,  _bioEstimate.heartRateCount, 5, pw.FontWeight.bold, font, 0)
              ),
              pw.Positioned(
                  left: 334,
                  top:528,
                  child: PdfUtils.drawTrendMinimalLineChart( _heartRateCounts, 50, 200, 10, 28, 100, 60, false)
              ),

              pw.Positioned(
                  left: 346,
                  top: 536,
                  child: PdfUtils.defaultText(pw.Alignment.centerLeft,  "PM 10:00", 5, pw.FontWeight.bold, font, 0)
              ),
              pw.Positioned(
                  left: 400,
                  top: 536,
                  child: PdfUtils.defaultText(pw.Alignment.centerLeft,  "AM 2:00", 5, pw.FontWeight.bold, font, 0)
              ),
              pw.Positioned(
                  left: 454,
                  top: 536,
                  child: PdfUtils.defaultText(pw.Alignment.centerLeft,  "AM 9:00", 5, pw.FontWeight.bold, font, 0)
              ),

              pw.Positioned(
                  left: 453,
                  top: 548,
                  child: PdfUtils.defaultText(pw.Alignment.centerLeft,  _bioEstimate.heartRateUp, 5, pw.FontWeight.bold, font, 0)
              ),
              pw.Positioned(
                  left: 453,
                  top: 556,
                  child: PdfUtils.defaultText(pw.Alignment.centerLeft,  _bioEstimate.heartRateDown, 5, pw.FontWeight.bold, font, 0)
              ),
              //endregion

              //region [체온]
              pw.Positioned(
                  left: 450,
                  top: 575,
                  child: PdfUtils.defaultText(pw.Alignment.centerLeft,  _bioEstimate.temperature, 5, pw.FontWeight.bold, font, 0)
              ),
              pw.Positioned(
                  left: 334,
                  top: 618,
                  child: PdfUtils.drawTrendMinimalLineChart(_temperatureCounts, 30, 40, 0, 40, 37.5, 36.5, false)
              ),

              pw.Positioned(
                  left: 346,
                  top: 620,
                  child: PdfUtils.defaultText(pw.Alignment.centerLeft,  "PM 10:00", 5, pw.FontWeight.bold, font, 0)
              ),
              pw.Positioned(
                  left: 400,
                  top: 620,
                  child: PdfUtils.defaultText(pw.Alignment.centerLeft,  "AM 2:00", 5, pw.FontWeight.bold, font, 0)
              ),
              pw.Positioned(
                  left: 454,
                  top: 620,
                  child: PdfUtils.defaultText(pw.Alignment.centerLeft,  "AM 9:00", 5, pw.FontWeight.bold, font, 0)
              ),

              pw.Positioned(
                  left: 453,
                  top: 630,
                  child: PdfUtils.defaultText(pw.Alignment.centerLeft,  _bioEstimate.temperatureUp, 5, pw.FontWeight.bold, font, 0)
              ),
              pw.Positioned(
                  left: 453,
                  top: 638,
                  child: PdfUtils.defaultText(pw.Alignment.centerLeft,  _bioEstimate.temperatureDown, 5, pw.FontWeight.bold, font, 0)
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



