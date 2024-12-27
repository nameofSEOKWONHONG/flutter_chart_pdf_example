import 'dart:typed_data';
import 'package:flu_example/menus/pdf/pdfUtils.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class DemoChartBodyLeft {
  pw.Partition buildBody(pw.Font font) {
    return pw.Partition(
        child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: <pw.Widget> [
              pw.Container(
                  child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: <pw.Widget> [
                        pw.Container(height: 5),
                        pw.Text("수면 정보",
                            style: pw.TextStyle(
                                fontSize: 8,
                                fontWeight: pw.FontWeight.bold,
                                font: font
                            )
                        ),
                        pw.Container(height: 5),
                        pw.Container(
                          height: 1, // 라인의 높이
                          color: PdfColors.black, // 라인의 색상
                        ),
                        pw.Container(height: 5),
                        pw.Table(
                            defaultVerticalAlignment: pw.TableCellVerticalAlignment.bottom,
                            children: [
                              pw.TableRow(
                                children: [
                                  PdfUtils.defaultText(pw.Alignment.centerLeft, "수면 시간", 7, pw.FontWeight.bold, font, 0),
                                  PdfUtils.defaultText(pw.Alignment.center, "취침 시간", 7, pw.FontWeight.bold, font, 0),
                                  PdfUtils.defaultText(pw.Alignment.centerRight, "기상 시간", 7, pw.FontWeight.bold, font, 0),
                                ]
                              ),
                              pw.TableRow(
                                  children: [
                                    PdfUtils.defaultText(pw.Alignment.centerLeft, "8시간 00분", 10, pw.FontWeight.bold, font, 0),
                                    PdfUtils.defaultText(pw.Alignment.center, "22:00", 7, pw.FontWeight.bold, font, 0),
                                    PdfUtils.defaultText(pw.Alignment.centerRight, "06:00", 7, pw.FontWeight.bold, font, 0),
                                  ]
                              ),
                            ]
                        ),
                        pw.Container(height: 5),
                        pw.Table(
                            border: const pw.TableBorder(
                              top: pw.BorderSide(color: PdfColors.grey, width: 1),
                              bottom: pw.BorderSide(color: PdfColors.grey, width: 1),
                            ),
                            children: [
                              pw.TableRow(
                                  children: [
                                    PdfUtils.defaultText(pw.Alignment.center, "수면 단계\r\nSleep Stage", 7, pw.FontWeight.bold, font, 8),
                                    pw.CustomPaint(
                                        size: const PdfPoint(280, 50),
                                        painter: (canvas, point) {
                                          canvas
                                            ..setStrokeColor(PdfColors.black)
                                            ..setLineWidth(0.1)
                                            ..moveTo(15, 40)
                                            ..lineTo(350, 40)
                                          ;

                                          DateTime startTime = DateTime(2024, 12, 30, 22, 0, 0); // 시작 시간
                                          DateTime endTime = DateTime(2024, 12, 31, 9, 0, 0);   // 종료 시간
                                          Duration interval = const Duration(minutes: 10);           // 10분 간격

                                          List<TypeA> items = [];
                                          items.add(TypeA("A", DateTime(2024, 12, 30, 22, 59, 59)));
                                          items.add(TypeA("B", DateTime(2024, 12, 30, 23, 59, 59)));
                                          items.add(TypeA("C", DateTime(2024, 12, 31, 00, 59, 59)));
                                          items.add(TypeA("D", DateTime(2024, 12, 31, 01, 59, 59)));
                                          items.add(TypeA("C", DateTime(2024, 12, 31, 02, 59, 59)));
                                          items.add(TypeA("B", DateTime(2024, 12, 31, 03, 59, 59)));
                                          items.add(TypeA("B", DateTime(2024, 12, 31, 04, 59, 59)));
                                          items.add(TypeA("C", DateTime(2024, 12, 31, 05, 59, 59)));
                                          items.add(TypeA("C", DateTime(2024, 12, 31, 06, 59, 59)));
                                          items.add(TypeA("B", DateTime(2024, 12, 31, 07, 59, 59)));
                                          items.add(TypeA("A", DateTime(2024, 12, 31, 08, 59, 59)));

                                          DateTime currentTime = startTime;
                                          double x = 15;
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

                                            var item = items.where((m) => m.date.isAfter(currentTime)).firstOrNull;
                                            if(item?.type == "A") {
                                              canvas
                                                ..setLineWidth(0.1)
                                                ..setFillColor(PdfColors.orange)
                                                ..drawRect(x, y2 - 15, 5, 5)
                                                ..fillPath();
                                            }
                                            else if(item?.type == "B") {
                                              canvas
                                                ..setLineWidth(0.1)
                                                ..setFillColor(PdfColors.blueGrey200)
                                                ..drawRect(x, y2 - 20, 5, 5)
                                                ..fillPath();
                                            }
                                            else if(item?.type == "C") {
                                              canvas
                                                ..setLineWidth(0.1)
                                                ..setFillColor(PdfColors.blue)
                                                ..drawRect(x, y2 - 25, 5, 5)
                                                ..fillPath();
                                            }
                                            else if(item?.type == "D") {
                                              canvas
                                                ..setLineWidth(0.1)
                                                ..setFillColor(PdfColors.purple)
                                                ..drawRect(x, y2 - 30, 5, 5)
                                                ..fillPath();
                                            }


                                            x = x+5;

                                            currentTime = currentTime.add(interval);  // 10분 추가
                                          }
                                        }
                                    )
                                  ]
                              ),
                              pw.TableRow(
                                  children: [
                                    pw.Container(),
                                    pw.Table(
                                        children: [
                                          pw.TableRow(
                                              children: [
                                                PdfUtils.defaultText(pw.Alignment.centerLeft, "수면 단계 통계", 7, pw.FontWeight.bold, font, 8),
                                              ]
                                          ),
                                          pw.TableRow(
                                              children: [
                                                pw.Table(
                                                    border: const pw.TableBorder(
                                                        top: pw.BorderSide(color: PdfColors.grey, width: 1),
                                                        verticalInside: pw.BorderSide(color: PdfColors.grey, width: 1)
                                                    ),
                                                    children: [
                                                      pw.TableRow(
                                                          children: [
                                                            PdfUtils.defaultText(pw.Alignment.centerLeft, "비수면", 7, pw.FontWeight.bold, font, 8),
                                                            PdfUtils.defaultText(pw.Alignment.centerLeft, "48분", 7, pw.FontWeight.bold, font, 8),
                                                            PdfUtils.defaultText(pw.Alignment.centerLeft, "10%", 7, pw.FontWeight.bold, font, 8),
                                                          ]
                                                      ),
                                                      pw.TableRow(
                                                          children: [
                                                            PdfUtils.defaultText(pw.Alignment.centerLeft, "램(REM) 수면", 7, pw.FontWeight.bold, font, 8),
                                                            PdfUtils.defaultText(pw.Alignment.centerLeft, "1시간 36분", 7, pw.FontWeight.bold, font, 8),
                                                            PdfUtils.defaultText(pw.Alignment.centerLeft, "20%", 7, pw.FontWeight.bold, font, 8),
                                                          ]
                                                      ),
                                                      pw.TableRow(
                                                          children: [
                                                            PdfUtils.defaultText(pw.Alignment.centerLeft, "얕은 수면", 7, pw.FontWeight.bold, font, 8),
                                                            PdfUtils.defaultText(pw.Alignment.centerLeft, "3시간 12분", 7, pw.FontWeight.bold, font, 8),
                                                            PdfUtils.defaultText(pw.Alignment.centerLeft, "40%", 7, pw.FontWeight.bold, font, 8),
                                                          ]
                                                      ),
                                                      pw.TableRow(
                                                          children: [
                                                            PdfUtils.defaultText(pw.Alignment.centerLeft, "깊은 수면", 7, pw.FontWeight.bold, font, 8),
                                                            PdfUtils.defaultText(pw.Alignment.centerLeft, "2시간 24분", 7, pw.FontWeight.bold, font, 8),
                                                            PdfUtils.defaultText(pw.Alignment.centerLeft, "30%", 7, pw.FontWeight.bold, font, 8),
                                                          ]
                                                      ),
                                                    ]
                                                ),
                                              ]
                                          )
                                        ]
                                    ),
                                  ]
                              )
                            ]
                        ),
                        pw.Container(
                            height: 5
                        ),
                        PdfUtils.defaultText(pw.Alignment.centerLeft, "* 램(REM) 수면은 정신의 피로를 회복하는데 중요한 수면 단계이며, 얕은 수면과 깊은 수면은 신체적인 회복에 필요한 수면 단계입니다.", 6, pw.FontWeight.bold, font, 2),
                      ]
                  )
              )
            ]
        )
    );
  }


}

class TypeA {
  final String type;
  final DateTime date;
  TypeA(this.type, this.date);
}