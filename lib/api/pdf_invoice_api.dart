import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter_application_1/api/pdf_api.dart';
import 'package:flutter_application_1/model/customer.dart';
import 'package:flutter_application_1/model/invoice.dart';
import 'package:flutter_application_1/model/supplier.dart';
import 'package:flutter_application_1/pages/utils.dart';

class PdfInvoiceApi {
  static Future<File> generate(Invoice invoice) async {
    final pdf = pw.Document();

    final ByteData fontData =
        await rootBundle.load("assets/fonts/IBMPlexSansArabic-Medium.ttf");
    final pw.Font arabicFont = pw.Font.ttf(fontData.buffer.asByteData());

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          _buildHeader(invoice, arabicFont),
          pw.SizedBox(height: 5),
          _buildCustomerandInvoice(invoice),
          pw.SizedBox(height: 10),
          _buildMail(),
          pw.SizedBox(height: 10),
          _buildInvoice(invoice),
          pw.Divider(),
          _buildTotal(invoice),
          pw.SizedBox(height: 10),
          _buildTotalTables(invoice),
        ],
      ),
    );

    return PdfApi.saveDocument(
      name: 'invoice${invoice.info.number + invoice.type}.pdf',
      pdf: pdf,
    );
  }

  static pw.Widget _buildHeader(Invoice invoice, pw.Font arabicFont) {
    return pw.Padding(
      padding: pw.EdgeInsets.only(top: 10.0),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            flex: 1,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _buildSupplierAddress(invoice.supplier),
              ],
            ),
          ),
          pw.Expanded(
            flex: 2,
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                _buildTitle(invoice, arabicFont),
              ],
            ),
          ),
          pw.Expanded(
            flex: 1,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Padding(
                  padding: pw.EdgeInsets.only(right: 10.0),
                  child: _buildSupplierAddressArabic(arabicFont),
                ),
                pw.SizedBox(height: 10.0),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildCustomerandInvoice(Invoice invoice) {
    return pw.Row(
      children: [
        pw.Expanded(
          child: pw.Container(
            padding: pw.EdgeInsets.all(10.0),
            decoration: pw.BoxDecoration(),
            child: _buildCustomerAddress(invoice.customer),
          ),
        ),
        pw.Expanded(
          child: pw.Container(
            padding: pw.EdgeInsets.all(10.0),
            decoration: pw.BoxDecoration(),
            child: _buildInvoiceInfo(invoice),
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildInvoiceInfo(Invoice invoice) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Invoice Number:',
              style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue),
            ),
            pw.Text(
              'Invoice Date:',
              style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue),
            ),
            pw.Text(
              'Invoice Type:',
              style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue),
            ),
            pw.Text(
              'Store:',
              style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue),
            ),
          ],
        ),
        pw.SizedBox(width: 10),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              '${invoice.info.number}',
              style: pw.TextStyle(color: PdfColors.black),
            ),
            pw.Text(
              '${invoice.info.date.year}-${invoice.info.date.month}-${invoice.info.date.day} ${invoice.info.date.hour}:${invoice.info.date.minute}',
              style: pw.TextStyle(color: PdfColors.black),
            ),
            pw.Text(
              '',
              style: pw.TextStyle(color: PdfColors.black),
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildSupplierAddress(Supplier supplier) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(height: 1 * PdfPageFormat.mm),
          pw.Text('Tel: ${supplier.Tel}',
              style: pw.TextStyle(fontSize: 12, color: PdfColors.blue)),
          pw.Text('WhatsApp: ${supplier.WhatsApp}',
              style: pw.TextStyle(fontSize: 12, color: PdfColors.blue)),
          pw.Text(supplier.POBox,
              style: pw.TextStyle(fontSize: 12, color: PdfColors.blue)),
          pw.Text(
            supplier.name,
            style: pw.TextStyle(fontSize: 10, color: PdfColors.blue),
          ),
          pw.Text(
            supplier.name2,
            style: pw.TextStyle(fontSize: 10, color: PdfColors.blue),
          ),
          pw.Text(
            supplier.address,
            style: pw.TextStyle(fontSize: 10, color: PdfColors.blue),
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
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue),
              ),
              pw.Text(
                'Address:',
                style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue),
              ),
              pw.Text(
                'Number:',
                style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue),
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

  static pw.Widget _buildTitle(Invoice invoice, pw.Font arabicFont) =>
      pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Text(
            'CEKIR TRADING CO.( L.L.C.)',
            style: pw.TextStyle(
                fontSize: 15,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue),
          ),
          pw.Text(
            'م.م.د ةيراجتلا ريكش ةكرش',
            style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
                font: arabicFont,
                color: PdfColors.blue),
          ),
          pw.Text(
            'Wholasale for Readymade Garments',
            style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue),
          ),
          pw.Text(
            'TAX INVOICE',
            style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue),
          ),
          pw.Text(
            'TRN: 100008260000003',
            style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue),
          ),
          pw.SizedBox(height: 0.8 * PdfPageFormat.cm),
          pw.SizedBox(height: 0.8 * PdfPageFormat.cm),
        ],
      );

  static pw.Widget _buildMail() => pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: [
          pw.Text(
            'E-Mail  :',
            style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue),
          ),
          pw.Link(
            child: pw.Text(
              'cekir@hotmail.com',
              style: pw.TextStyle(color: PdfColors.blue),
            ),
            destination: 'mailto:cekir@hotmail.com',
          ),
          pw.SizedBox(width: 20),
          pw.Link(
            child: pw.Text(
              'info@akdenizmensucat.com',
              style: pw.TextStyle(color: PdfColors.blue),
            ),
            destination: 'mailto:info@akdenizmensucat.com',
          ),
          pw.SizedBox(width: 20),
          pw.Link(
            child: pw.Text(
              'www.akdenizmensucat.com',
              style: pw.TextStyle(color: PdfColors.blue),
            ),
            destination: 'http://www.akdenizmensucat.com',
          ),
        ],
      );

  static pw.Widget _buildSupplierAddressArabic(pw.Font arabicFont) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.SizedBox(height: 1 * PdfPageFormat.mm),
          pw.Text(
            '٠٩٧١٤٢٢٦٦١١٤نوفلت',
            style: pw.TextStyle(
                fontSize: 10, font: arabicFont, color: PdfColors.blue),
          ),
          pw.Text(
            '٤ :با ستاو',
            style: pw.TextStyle(
                fontSize: 10, font: arabicFont, color: PdfColors.blue),
          ),
          pw.Text(
            '٦٥١٢٧ :ب.ص',
            style: pw.TextStyle(
                fontSize: 10, font: arabicFont, color: PdfColors.blue),
          ),
          pw.Text(
            'رازاب دشرم',
            style: pw.TextStyle(
                fontSize: 10, font: arabicFont, color: PdfColors.blue),
          ),
          pw.Text(
            'رايامع ديبع ءانبلا',
            style: pw.TextStyle(
                fontSize: 10, font: arabicFont, color: PdfColors.blue),
          ),
          pw.Text(
            'م.ع.ا - يبد :١مقررجتم',
            style: pw.TextStyle(
                fontSize: 10, font: arabicFont, color: PdfColors.blue),
          ),
        ],
      );

  static pw.Widget _buildInvoice(Invoice invoice) {
    if (invoice.items.isEmpty) {
      return pw.Center(child: pw.Text('No items'));
    }
    print(invoice.items);

    final headers = [
      'Description',
      'Date.',
      'Quantity',
      'VAT',
      'Rate Dhs.',
      'Amount Dhs'
    ];
    final data = invoice.items.map((item) {
      final total = item.unitPrice * (1 + item.vat);

      return [
        item.description,
        Utils.formatDate(item.date),
        '${item.quantity}',
        '${(item.vat * 100).toStringAsFixed(2)} %',
        '\ ${item.unitPrice.toStringAsFixed(2)}',
        '\ ${total.toStringAsFixed(2)}',
      ];
    }).toList();

    return pw.Table.fromTextArray(
      headers: headers,
      data: data,
      border: null,
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      headerDecoration: pw.BoxDecoration(color: PdfColors.blue50),
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
        .map((item) => item.unitPrice)
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
                  title: 'Vat ${(vatPercent * 100).toStringAsFixed(2)} %',
                  value: Utils.formatPrice(vat),
                  unite: true,
                ),
                pw.Divider(),
                _buildText(
                  title: 'Total ',
                  titleStyle: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.black,
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
              style: style.copyWith(color: PdfColors.blue),
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

  static pw.Widget _buildTotalTables(Invoice invoice) {
    final totalAmount = invoice.items.fold<double>(
      0,
      (previousValue, item) =>
          previousValue + item.unitPrice * item.quantity * (1 + item.vat),
    );

    return pw.Container(
      width: double.infinity,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Table.fromTextArray(
            cellAlignment: pw.Alignment.centerLeft,
            headerAlignment: pw.Alignment.centerLeft,
            headers: ['Amount Dhs:'],
            data: [],
            border: pw.TableBorder.all(color: PdfColors.black),
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue,
            ),
            cellStyle: pw.TextStyle(color: PdfColors.black),
            defaultColumnWidth: pw.FixedColumnWidth(200),
            cellHeight: 40,
          ),
          pw.SizedBox(height: 10),
          pw.Table.fromTextArray(
            cellAlignment: pw.Alignment.centerLeft,
            headerAlignment: pw.Alignment.centerLeft,
            headers: ['Delivery Address:'],
            data: [],
            border: pw.TableBorder.all(color: PdfColors.black),
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue,
            ),
            cellStyle: pw.TextStyle(color: PdfColors.black),
            defaultColumnWidth: pw.FixedColumnWidth(200),
            cellHeight: 40,
          ),
          pw.SizedBox(height: 10),
          pw.Table.fromTextArray(
            cellAlignment: pw.Alignment.centerLeft,
            headerAlignment: pw.Alignment.centerLeft,
            headers: ['Mark:', 'Prepared by:', "Receiver's Signature:"],
            data: [],
            border: pw.TableBorder.all(color: PdfColors.black),
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue,
            ),
            cellStyle: pw.TextStyle(color: PdfColors.black),
            defaultColumnWidth: pw.FixedColumnWidth(200),
            cellHeight: 40,
          ),
        ],
      ),
    );
  }
}
