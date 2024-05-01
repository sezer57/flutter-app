import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/api/pdf_api.dart';
import 'package:flutter_application_1/model/customer.dart';
import 'package:flutter_application_1/model/invoice.dart';
import 'package:flutter_application_1/model/supplier.dart';
import 'package:flutter_application_1/pages/utils.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfInvoiceApi {
  static Future<File> generate(Invoice invoice) async {
    final pdf = pw.Document();

    // Arapça fontunu yükleyelim
    final ByteData fontData = await rootBundle.load("assets/fonts/IBMPlexSansArabic-Medium.ttf");
    final pw.Font arabicFont = pw.Font.ttf(fontData.buffer.asByteData());

     pdf.addPage(pw.MultiPage(
      build: (context) => [
        _buildHeader(invoice, arabicFont),
        pw.SizedBox(height: 1 * PdfPageFormat.cm),
        _buildMail(),
        pw.SizedBox(height: 20), // 20px yatay boşluk ekleyelim
        _buildInvoice(invoice),
        pw.Divider(),
        _buildTotal(invoice),
      ],
      footer: (context) => _buildFooter(invoice),
    ));

    return PdfApi.saveDocument(
        name: 'invoice${invoice.info.number + invoice.type}.pdf', pdf: pdf);
  }



static pw.Widget _buildHeader(Invoice invoice, pw.Font arabicFont) => pw.Padding(
  padding: pw.EdgeInsets.only(top: 20.0),
  child: pw.Center(
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        _buildTitle(invoice, arabicFont), // Title moved up by 20px
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Padding(
                  padding: pw.EdgeInsets.only(bottom: 15.0, right: 10.0), // 10px horizontal padding
                  child: _buildSupplierAddress(invoice.supplier),
                ),
                _buildCustomerAddress(invoice.customer),
              ],
            ),
            pw.SizedBox(width: 10.0), // 10px horizontal space
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _buildSupplierAddressArabic(arabicFont), // Arabic address
                pw.SizedBox(height: 10.0), // 10px vertical space
              
              ],
            ),
          ],
        ),
      ],
    ),
  ),
);


  static pw.Widget _buildSupplierAddress(Supplier supplier) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(height: 1 * PdfPageFormat.mm),
          pw.Text('Tel: ${supplier.Tel}'),
          pw.Text('WhatsApp: ${supplier.WhatsApp}'),
          pw.Text('PO Box: ${supplier.POBox}'),
          pw.Text(supplier.name),
          pw.Text(supplier.name2),
          pw.Text(supplier.address),
        ],
      );

  static pw.Widget _buildCustomerAddress(Customer customer) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Customer :',
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(customer.name),
          pw.Text(customer.address),
          pw.Text(customer.number),
        ],
      );

  static pw.Widget _buildTitle(Invoice invoice, pw.Font arabicFont) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Text(
            'CEKIR TRADING CO.( L.L.C.)',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(
            'م.م.د ةيراجتلا ريكش ةكرش',
            style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold, font: arabicFont),
          ),
          pw.Text(
            'Wholasale for Readymade Garments',
            style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(
            'TAX INVOICE',
            style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(
            'TRN: 100008260000003',
            style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 0.8 * PdfPageFormat.cm),
          pw.Text(invoice.info.description),
          pw.SizedBox(height: 0.8 * PdfPageFormat.cm),
        ],
      );
      
static pw.Widget _buildMail() => pw.Row(
  mainAxisAlignment: pw.MainAxisAlignment.center,
  children: [
    pw.Text(
            'E-Mail  :',
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
          ),
    pw.Link(
      child: pw.Text(
        'cekir@hotmail.com',
      ),
      destination: 'mailto:cekir@hotmail.com',
    ),
    pw.SizedBox(width: 20), // Araya boşluk ekleyebilirsiniz
    pw.Link(
      child: pw.Text(
        'info@akdenizmensucat.com',
      ),
      destination: 'mailto:info@akdenizmensucat.com',
    ),
    pw.SizedBox(width: 20), // Araya boşluk ekleyebilirsiniz
    pw.Link(
      child: pw.Text(
        'www.akdenizmensucat.com',
      ),
      destination: 'http://www.akdenizmensucat.com',
    ),
  ],
);


static pw.Widget _buildSupplierAddressArabic(pw.Font arabicFont) => pw.Column(
  crossAxisAlignment: pw.CrossAxisAlignment.start,
  children: [
    pw.SizedBox(height: 1 * PdfPageFormat.mm),
    pw.Text(
      '٠٩٧١٤٢٢٦٦١١٤نوفلت',
      style: pw.TextStyle(font: arabicFont),
    ),
    pw.Text(
      '٤ :با ستاو',
      style: pw.TextStyle(font: arabicFont),
    ),
    pw.Text(
      '٦٥١٢٧ :ب.ص',
      style: pw.TextStyle(font: arabicFont),
    ),
    pw.Text(
      'رازاب دشرم',
      style: pw.TextStyle(font: arabicFont),
    ),
    pw.Text(
      'رايامع ديبع ءانبلا',
      style: pw.TextStyle(font: arabicFont),
    ),
    pw.Text(
      'م.ع.ا - يبد :١مقررجتم',
      style: pw.TextStyle(font: arabicFont),
    ),
  ],
);



  static pw.Widget _buildInvoice(Invoice invoice) {
    if (invoice.items.isEmpty) {
      return pw.Center(child: pw.Text('No items'));
    }

    final headers = [
      'Description',
      'Ctns.',
      'Quantity',
      'VAT',
      'Rate Dhs.',
      'Amount Dhs'
    ];
    final data = invoice.items.map((item) {
      final total = item.unitPrice * item.quantity * (1 + item.vat);

      return [
        item.description,
        Utils.formatDate(item.date),
        '${item.quantity}',
        '\$ ${item.unitPrice}',
        '${item.vat} %',
        '\$ ${total.toStringAsFixed(2)}',
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
      },
    );
  }



  static pw.Widget _buildTotal(Invoice invoice) {
    if (invoice.items.isEmpty) {
      return pw.SizedBox(); // Return empty widget if there are no items
    }

    final netTotal = invoice.items
        .map((item) => item.unitPrice * item.quantity)
        .reduce((item1, item2) => item1 + item2);

    final vatPercent = invoice.items.first.vat;
    final vat = netTotal * vatPercent;
    final total = netTotal + vat;

    return pw.Container(
      alignment: pw.Alignment.centerRight,
      child: pw.Row(
        children: [
          pw.Spacer(flex: 6),
          pw.Expanded(
            flex: 4,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _buildText(
                  title: 'Net total',
                  value: Utils.formatPrice(netTotal),
                  unite: true,
                ),
                _buildText(
                  title: 'Vat ${vatPercent*100} %',
                  value: Utils.formatPrice(vat),
                  unite: true,
                ),
                pw.Divider(),
                _buildText(
                  title: 'Total Dhs',
                  titleStyle: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                  value: Utils.formatPrice(total),
                  unite: true,
                ),
                pw.SizedBox(height: 2 * PdfPageFormat.mm),
                pw.Container(height: 1, color: PdfColors.grey400),
                pw.SizedBox(height: 0.5 * PdfPageFormat.mm),
                pw.Container(height: 1, color: PdfColors.grey400),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildFooter(Invoice invoice) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Divider(),
          pw.SizedBox(height: 2 * PdfPageFormat.mm),
          _buildSimpleText(title: 'Address', value: invoice.supplier.address),
          pw.SizedBox(height: 1 * PdfPageFormat.mm),
        ],
      );

  static pw.Widget _buildSimpleText({
    required String title,
    required String value,
  }) {
    final style = pw.TextStyle(fontWeight: pw.FontWeight.bold);

    return pw.Row(
      mainAxisSize: pw.MainAxisSize.min,
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Text(title, style: style),
        pw.SizedBox(width: 2 * PdfPageFormat.mm),
        pw.Text(value),
      ],
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
          pw.Expanded(child: pw.Text(title, style: style)),
          pw.Text(value, style: unite ? style : null),
        ],
      ),
    );
  }
}
