import 'dart:io';
import 'package:flutter_application_1/api/pdf_api.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:flutter_application_1/model/client.dart';
import 'package:flutter_application_1/pages/utils.dart';

class PdfClientApi {
  static Future<File> generate(Client clients) async {
    final pdf = pw.Document();
   
    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          _buildHeader(clients),
          pw.SizedBox(height: 3 * PdfPageFormat.cm),
          _buildTitle(),
          _buildInvoice(clients),
          pw.Divider(),
        ],
        footer: (context) => _buildFooter(clients),
      ),
    );

    return PdfApi.saveDocument(name: 'clientList.pdf', pdf: pdf);
  }

  static pw.Widget _buildHeader(Client client) => pw.Column(
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
            'Client List',
            style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 0.8 * PdfPageFormat.cm),
          // İsterseniz ek açıklamalar veya bilgiler ekleyebilirsiniz.
        ],
      );

  static pw.Widget _buildInvoice(Client invoice) {
    final headers = [
      'Client Code',
      'Name',
      'Surname',
      'Gsm',
      'Phone',
      'Address',
      'Commercial Title',
      'Registration Date',
      'Balance',
      'Comment',
      'Debit Credit Status'
    ];
    final data = invoice.items.map((item) {
      return [
        '${item.clientCode}',
        '${item.name}',
        '${item.surname}',
        '${item.gsm}',
        '${item.phone}',
        '${item.address}',
        '${item.commercialTitle}',
        '${Utils.formatDate(item.registrationDate)}', // Tarih formatlama gerekebilir
        '${item.balance}',
        '${item.comment}',
        '${item.debitCreditStatus}',
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
        8: pw.Alignment.centerRight,
        9: pw.Alignment.centerRight,
        10: pw.Alignment.centerRight,
        11: pw.Alignment.centerRight,
      },
    );
  }
  static pw.Widget _buildFooter(Client invoice) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Divider(),
          pw.SizedBox(height: 2 * PdfPageFormat.mm),
          // Buraya firma bilgileri veya iletişim bilgileri ekleyebilirsiniz.
        ],
      );
}
