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
    required double totalExpenses,
    required double totalPurchases,
    required double totalTransfers,
  }) async {
    final pdf = Document();

    pdf.addPage(Page(
      build: (context) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Header(
              level: 1,
              child: Text('Expense Report - $selectedDate'),
            ),
            SizedBox(height: 10),
            Text('Daily Raport',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            if (expenses != null && expenses.isNotEmpty)
              _buildTable('Expenses', expenses),
            if (totalExpenses != 0.00)
              Text('Total Expenses: \$${totalExpenses.toStringAsFixed(2)}'),
            SizedBox(height: 30),
            if (purchases != null && purchases.isNotEmpty)
              _buildTable('Purchases', purchases),
            if (totalPurchases != 0.00)
              Text('Total Purchases: \$${totalPurchases.toStringAsFixed(2)}'),
            SizedBox(height: 30),
            if (warehouseTransfers != null && warehouseTransfers.isNotEmpty)
              _buildTable('Warehouse Transfers', warehouseTransfers),
            if (totalTransfers != 0.00)
              Text('Total Transfers: \$${totalTransfers.toStringAsFixed(2)}'),
          ],
        );
      },
    ));

    return saveDocument(name: 'expense_report_$selectedDate.pdf', pdf: pdf);
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        Table.fromTextArray(
          headers: headers,
          data: rows,
        ),
        SizedBox(height: 20),
      ],
    );
  }

  static Future<File> saveDocument({
    required String name,
    required Document pdf,
  }) async {
    final bytes = await pdf.save();

    final dir =
        await getExternalStorageDirectory(); // Use getExternalStorageDirectory instead
    final file = File('${dir!.path}/$name');

    await file.writeAsBytes(bytes);

    return file;
  }

  static Future openFile(File file) async {
    final url = file.path;

    await OpenFile.open(url);
  }
}
