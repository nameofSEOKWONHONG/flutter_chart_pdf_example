import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class DemoChartHeader {
  DemoChartHeader();
  pw.Widget buildHeader(Uint8List headerImage, pw.Font font) {
    return pw.Container(
      alignment: pw.Alignment.centerLeft,
      padding: const pw.EdgeInsets.only(bottom: 10),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Image(
                pw.MemoryImage(headerImage),
                width: 100,
                fit: pw.BoxFit.contain,
              ),
              pw.Text(
                "Daily Sleep Report",
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue,
                ),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Table(
                border: const pw.TableBorder(
                  top: pw.BorderSide(color: PdfColors.grey, width: 1),
                ),
                children: [
                  pw.TableRow(
                    children: [
                      _buildHeaderCell('프로필', font, 5),
                      _buildHeaderCell('이지은', font, 8, isBold: true),
                      _buildHeaderCell('성별', font, 5),
                      _buildHeaderCell('여성', font, 8, isBold: true),
                      _buildHeaderCell('생년월일', font, 5),
                      _buildHeaderCell('1990.3.12', font, 8, isBold: true),
                    ],
                  ),
                ],
              ),
              pw.Table(
                border: const pw.TableBorder(
                  top: pw.BorderSide(color: PdfColors.grey, width: 1),
                ),
                children: [
                  pw.TableRow(
                    children: [
                      _buildHeaderCell('측정 일시', font, 5),
                      _buildHeaderCell('2024년 9월 23일 오후 10시 - 9월 24일 오전 6시', font, 7, isBold: true),
                    ],
                  ),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }

  pw.Widget _buildHeaderCell(String text, pw.Font font, double fontSize, {bool isBold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: fontSize,
          fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
          font: font,
        ),
      ),
    );
  }
}
