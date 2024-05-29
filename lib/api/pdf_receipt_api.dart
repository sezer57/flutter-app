import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter_application_1/api/pdf_api.dart';
import 'package:flutter_application_1/model/customer.dart';
import 'package:flutter_application_1/model/receipt.dart';
import 'package:flutter_application_1/pages/utils.dart';
import 'package:flutter_application_1/model/supplier.dart';

class PdfReceiptApi {
  static Future<File> generate(Receipt receipt) async {
    final pdf = pw.Document();

    final ByteData fontData =
        await rootBundle.load("assets/fonts/IBMPlexSansArabic-Medium.ttf");
    final pw.Font arabicFont = pw.Font.ttf(fontData);

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          _buildHeader(receipt),
          pw.SizedBox(height: 10),
          _buildCustomer(receipt),
          pw.SizedBox(height: 10),
          _buildReceipt(receipt),
          pw.SizedBox(height: 10),
          pw.Divider(),
          _buildTotal(receipt),
        ],
      ),
    );

    return PdfApi.saveDocument(
      name: 'receipt.pdf',
      pdf: pdf,
    );
  }

static pw.Widget _buildCustomer(Receipt receipt) {
  return pw.Row(
    children: [
      pw.Expanded(
        flex: 2,
        child: pw.Column(
          mainAxisAlignment: pw.MainAxisAlignment.end,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _buildSupplierAddress(receipt.supplier),
          ],
        ),
      ),
      pw.Expanded(
        child: pw.Container(
          padding: pw.EdgeInsets.all(10.0),
          decoration: pw.BoxDecoration(),
          child: _buildCustomerAddress(receipt.customer),
        ),
      ),
    ],
  );
}


  static pw.Widget _buildHeader(Receipt receipt) {
    return pw.Padding(
      padding: pw.EdgeInsets.only(top: 10.0),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            flex: 2,
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                _buildTitle(receipt),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildTitle(Receipt receipt) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Text(
            'RECEIPT VOUCHER',
            style: pw.TextStyle(
                fontSize: 15,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.black),
          ),
        ],
      );
      
 static pw.Widget _buildSupplierAddress(Supplier supplier) => pw.Column(
  crossAxisAlignment: pw.CrossAxisAlignment.start,
  children: [
    pw.SizedBox(height: 1 * PdfPageFormat.mm),
    pw.Row(
      children: [
        pw.Text(
          'Tel: ',
          style: pw.TextStyle(
            fontSize: 12,
            color: PdfColors.black,
            fontWeight: pw.FontWeight.bold, // 'Tel' kısmını bold yapar
          ),
        ),
        pw.Text(
          '${supplier.Tel}',
          style: pw.TextStyle(
            fontSize: 12,
            color: PdfColors.black,
          ),
        ),
      ],
    ),
    pw.Row(
      children: [
        pw.Text(
          'Name: ',
          style: pw.TextStyle(
            fontSize: 12,
            color: PdfColors.black,
            fontWeight: pw.FontWeight.bold, // 'Name' kısmını bold yapar
          ),
        ),
        pw.Text(
          '${supplier.name}',
          style: pw.TextStyle(
            fontSize: 12,
            color: PdfColors.black,
          ),
        ),
      ],
    ),
    pw.Row(
      children: [
        pw.Text(
          'Address: ',
          style: pw.TextStyle(
            fontSize: 12,
            color: PdfColors.black,
            fontWeight: pw.FontWeight.bold, // 'Address' kısmını bold yapar
          ),
        ),
        pw.Text(
          '${supplier.address}',
          style: pw.TextStyle(
            fontSize: 12,
            color: PdfColors.black,
          ),
        ),
      ],
    ),
  ],
);





  static pw.Widget _buildCustomerAddress(Customer customer) => pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Name:',
                style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.black),
              ),
              pw.Text(
                'Surname:',
                style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.black),
              ),
              pw.Text(
                'Commercial:',
                style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.black),
              ),
            ],
          ),
          pw.SizedBox(width: 10),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                customer.name,
                style: pw.TextStyle(color: PdfColors.black),
              ),
              pw.Text(
                customer.address,
                style: pw.TextStyle(color: PdfColors.black),
              ),
              pw.Text(
                customer.number,
                style: pw.TextStyle(color: PdfColors.black),
              ),
            ],
          ),
        ],
      );

  static pw.Widget _buildReceipt(Receipt receipt) {
    if (receipt.items.isEmpty) {
      return pw.Center(child: pw.Text('No items'));
    }

    final headers = ['Payment Type', 'Balance', 'Payment Amount', 'Date'];
    final data = receipt.items.map((item) {
      return [
        item.description,
        '${item.balance + item.amount} AED',
        '${item.amount} AED',
        Utils.formatDate(item.date),
      ];
    }).toList();

    return pw.Table.fromTextArray(
      headers: headers,
      data: data,
      border: null,
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      headerDecoration: pw.BoxDecoration(color: PdfColors.grey200),
      cellHeight: 30,
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerRight,
        2: pw.Alignment.centerRight,
        3: pw.Alignment.centerRight,
      },
    );
  }

static pw.Widget _buildTotal(Receipt receipt) {
  if (receipt.items.isEmpty) {
    return pw.SizedBox(); // Return empty widget if there are no items
  }

  final netTotal =
      receipt.items.map((item) => item.balance).reduce((a, b) => a + b);

  return pw.Container(
    alignment: pw.Alignment.centerLeft, // Sol tarafa hizala
    child: pw.Row(
      children: [
        pw.Expanded(
          flex: 4,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
             pw.Text(
                      'Amount mentioned above AED has been reflected in your balance',
                     softWrap: false,
                    ), 
                    pw.SizedBox(height: 5),
              _buildText(
                title: 'Last Balance',
                value: Utils.formatPrice(netTotal),
                unite: true,
              ),
        
            ],
          ),
        ),
        pw.Spacer(flex: 6),
      ],
    ),
  );
}


  static pw.Widget _buildText({
    required String title,
    required String value,
    double width = double.infinity,
    pw.TextStyle? titleStyle,
    bool unite = false,
  }) {
    final style = titleStyle ?? pw.TextStyle(fontWeight: pw.FontWeight.bold);

    return pw.Container(
      width: width,
      child: pw.Row(
        children: [
          pw.Expanded(
            child: pw.Text(
              title,
              style: style.copyWith(color: PdfColors.black),
            ),
          ),
          pw.Text(
            value,
            style: unite ? style.copyWith(color: PdfColors.black) : style,
          ),
        ],
      ),
    );
  }
}
