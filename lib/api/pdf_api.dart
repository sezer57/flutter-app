import 'dart:io';
import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';

class PdfApi {
  static Future<File> generateExpenseReport({
    required String selectedDate,
    List<dynamic>? warehouseTransfers,
    List<dynamic>? expenses,
    List<dynamic>? purchases,
    List<dynamic>? clients,
    List<dynamic>? stocks,
    required double totalExpenses,
    required double totalPurchases,
    required double totalTransfers,
  }) async {
    final pdf = Document();

    pdf.addPage(MultiPage(
      build: (context) {
        return [
          Header(
            level: 1,
            child: Text('Report - $selectedDate'),
          ),
          SizedBox(height: 12),
          Text('Report',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          if (expenses != null && expenses.isNotEmpty)
            _buildTable('Sales', expenses),
          if (totalExpenses != 0.00)
            Text('Total Sales: \ ${totalExpenses.toStringAsFixed(2)}'),
          SizedBox(height: 30),
          if (purchases != null && purchases.isNotEmpty)
            _buildTable('Purchases', purchases),
          if (totalPurchases != 0.00)
            Text('Total Purchases: \ ${totalPurchases.toStringAsFixed(2)}'),
          SizedBox(height: 30),
          if (warehouseTransfers != null && warehouseTransfers.isNotEmpty)
            _buildTable('Warehouse Transfers', warehouseTransfers),
          if (totalTransfers != 0.00)
            Text('Total Transfers: \ ${totalTransfers.toStringAsFixed(2)}'),
          if (clients != null && clients.isNotEmpty)
            _buildTable('Clients', clients),
          if (stocks != null && stocks.isNotEmpty)
            _buildTable('Stocks', stocks),
        ];
      },
    ));

    return saveDocument(name: 'report_$selectedDate.pdf', pdf: pdf);
  }

  static Widget _buildTable(String title, List<dynamic> data) {
    final headers = data.first.keys.toList();
    final List<List<String>> rows = [];

    for (final entry in data) {
      final List<String> row = [];
      for (final key in entry.keys) {
        row.add(entry[key].toString());
      }
      rows.add(row);
    }

    if (rows.length > 5) {
      List<Widget> tables = [];
      int i = 0;
      int pageNumber = 1;

      while (i < rows.length) {
        List<List<String>> currentRows =
            rows.sublist(i, i + 5 < rows.length ? i + 5 : rows.length);
        tables.add(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$title (Page $pageNumber)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Table.fromTextArray(
                headers: headers,
                data: currentRows,
              ),
              SizedBox(height: 20),
            ],
          ),
        );
        i += 5;
        pageNumber++;
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: tables,
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$title (Page 1)',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          Table.fromTextArray(
            headers: headers,
            data: rows,
          ),
          SizedBox(height: 20),
        ],
      );
    }
  }

  static Future<File> saveDocument({
    required String name,
    required Document pdf,
  }) async {
    final bytes = await pdf.save();

    final Directory? dir = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();

    final file = File('${dir!.path}/$name');

    await file.writeAsBytes(bytes);

    return file;
  }

  static Future openFile(File file) async {
    final url = file.path;

    await OpenFile.open(url);
  }
}
