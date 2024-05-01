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
          pw.SizedBox(height: 1 * PdfPageFormat.cm), // Reduced height
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
          pw.SizedBox(height: 0.5 * PdfPageFormat.cm), // Reduced height
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
          pw.SizedBox(height: 0.5 * PdfPageFormat.cm), // Reduced height
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
          pw.SizedBox(height: 0.4 * PdfPageFormat.cm), // Reduced height
          // İsterseniz ek açıklamalar veya bilgiler ekleyebilirsiniz.
        ],
      );

  static pw.Widget _buildInvoice(Client invoice) {
    final headers = [
      'C. Code',
      'Name',
      'Surname',
      'Gsm',
      'Phone',
      'Address',
      'Comm. Title',
      'Reg. Date',
      'Balance',
      'DC Status'
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

        '${item.debitCreditStatus}',
      ];
    }).toList();
    return pw.Table.fromTextArray(
      headers: headers,
      data: data,
      border: null,
      headerStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        fontSize: 9, // Adjust the font size as needed
      ),
      headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
      cellHeight: 10,
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.centerLeft,
        3: pw.Alignment.centerLeft,
        4: pw.Alignment.centerLeft,
        5: pw.Alignment.centerLeft,
        6: pw.Alignment.centerLeft,
        7: pw.Alignment.centerLeft,
        8: pw.Alignment.centerLeft,
        9: pw.Alignment.centerLeft,
        10: pw.Alignment.centerLeft,
      },
    );
  }

  static pw.Widget _buildFooter(Client invoice) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Divider(),
          pw.SizedBox(height: 0.2 * PdfPageFormat.cm), // Reduced height
          // Buraya firma bilgileri veya iletişim bilgileri ekleyebilirsiniz.
        ],
      );
}
