
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'demochart_body_left.dart';
import 'demochart_header.dart';

class DemoChart extends StatelessWidget {
  const DemoChart({super.key});

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

    final fontData = (await rootBundle.load('assets/NanumGothic.ttf')).buffer.asUint8List();
    final pdfFont = pw.Font.ttf(fontData.buffer.asByteData());
    final header = DemoChartHeader();
    final bodyleft = DemoChartBodyLeft();
    doc.addPage(
      pw.MultiPage(
        pageFormat: format,
        margin: pw.EdgeInsets.all(20),
        header: (context) => header.buildHeader(headerImage, font),
        build: (pw.Context context) => [
          pw.Padding(
            padding: const pw.EdgeInsets.fromLTRB(0, 8, 0, 8),
            child: pw.Container(
              height: 1, // 라인의 높이
              color: PdfColors.blue, // 라인의 색상
            ),
          ),
          pw.Partitions(
            children: [
              bodyleft.buildBody(font),
              pw.Partition(
                width: 10,
                child: pw.Container()
              ),
              pw.Partition(
                width: 150,
                child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: <pw.Widget> [
                      pw.Container(
                          child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: <pw.Widget> [
                                pw.Text("test1")
                              ]
                          )
                      )
                    ]
                )
              )
            ]
          )
        ],
        footer: (pw.Context context) {
          return pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: const pw.EdgeInsets.only(top: 10),
            child: pw.Text(
              'Page ${context.pageNumber} of ${context.pagesCount}',
              style: pw.TextStyle(fontSize: 12, color: PdfColors.grey),
            ),
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

