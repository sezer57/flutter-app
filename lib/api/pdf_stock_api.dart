import 'dart:io';
import 'package:flutter_application_1/api/pdf_api.dart';
import 'package:flutter_application_1/model/stock.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:flutter_application_1/pages/utils.dart';

class PdfStockApi {
  static Future<File> generate(Stock stocks) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          _buildHeader(stocks),
          pw.SizedBox(height: 3 * PdfPageFormat.cm),
          _buildTitle(),
          _buildInvoice(stocks),
          pw.Divider(),
        ],
        footer: (context) => _buildFooter(stocks),
      ),
    );

    return PdfApi.saveDocument(name: 'StockList.pdf', pdf: pdf);
  }

  static pw.Widget _buildHeader(Stock stocks) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(height: 1 * PdfPageFormat.cm),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Container(
                height: 50,
                width: 50,
                // Buraya bir logo ekleyebilirsiniz.
              ),
            ],
          ),
          pw.SizedBox(height: 1 * PdfPageFormat.cm),
          // Buraya başlık veya firma adı ekleyebilirsiniz.
        ],
      );

  static pw.Widget _buildTitle() => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Stock List',
            style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 0.8 * PdfPageFormat.cm),
          // İsterseniz ek açıklamalar veya bilgiler ekleyebilirsiniz.
        ],
      );

  static pw.Widget _buildInvoice(Stock stock) {
    final headers = [
       'Stock ID',
      'Name',
      'Code',
      'Barcode',
      'Group',
      'Middle Group',
      'Unit',
      'Sales Price',
      'Purchase Price',
      'Warehouse ID',
      'Registration Date'
    ];
    final data = stock.items.map((item) {
      return [
        '${item.stockId}',
        '${item.stockName}',
        '${item.stockCode}',
        '${item.barcode}',
        '${item.groupName}',
        '${item.middleGroupName}',
        '${item.unit}',
        '${item.salesPrice}',
        '${item.purchasePrice}',
        '${item.warehouseId}',
        '${Utils.formatDate(item.registrationDate)}', // Tarih formatlama gerekebilir
      ];
    }).toList();
    return pw.Table.fromTextArray(
      headers: headers,
      data: data,
      border: null,
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
      cellHeight: 30,
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerRight,
        2: pw.Alignment.centerRight,
        3: pw.Alignment.centerRight,
        4: pw.Alignment.centerRight,
        5: pw.Alignment.centerRight,
        6: pw.Alignment.centerRight,
        7: pw.Alignment.centerRight,
      },
    );
  }
  static pw.Widget _buildFooter(Stock stock) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Divider(),
          pw.SizedBox(height: 2 * PdfPageFormat.mm),
          // Buraya firma bilgileri veya iletişim bilgileri ekleyebilirsiniz.
        ],
      );
}
