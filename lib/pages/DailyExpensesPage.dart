import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/api/pdf_api.dart';

class DailyExpensesPage extends StatelessWidget {
  final String selectedDate;
  final List<dynamic>? warehouseTransfers;
  final List<dynamic>? expenses;
  final List<dynamic>? purchases;
  double totalExpenses = 0;
  double totalTransfers = 0;
  double totalPurchases = 0;
  DailyExpensesPage({
    required this.selectedDate,
    this.warehouseTransfers,
    this.expenses,
    this.purchases,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daily Expenses - $selectedDate'),
        actions: [
          IconButton(
            icon: Icon(Icons.picture_as_pdf),
            onPressed: () async {
              await _generatePDF(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                if (expenses != null && expenses!.isNotEmpty) ...[
                  _buildExpensesTable(),
                  SizedBox(height: 16),
                ],
                if (purchases != null && purchases!.isNotEmpty) ...[
                  _buildPurchasesTable(),
                  SizedBox(height: 16),
                ],
                if (warehouseTransfers != null &&
                    warehouseTransfers!.isNotEmpty) ...[
                  _buildWarehouseTransfersTable(),
                  SizedBox(height: 16),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpensesTable() {
    if (expenses != null && expenses!.isNotEmpty) {
      totalExpenses = expenses!
          .map((expense) => double.parse(expense['price'].toString()))
          .reduce((value, element) => value + element);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Expenses:', style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: [
              DataColumn(label: Text('Date')),
              DataColumn(label: Text('Stock Name')),
              DataColumn(label: Text('Quantity')),
              DataColumn(label: Text('Client Name')),
              DataColumn(label: Text('Price')),
              DataColumn(label: Text('Expense ID')),
              DataColumn(label: Text('Warehouse Name')),
            ],
            rows: [
              ...expenses!.map(
                (expense) => DataRow(
                  cells: [
                    DataCell(Text(expense['date'].toString())),
                    DataCell(Text(expense['stockName'].toString())),
                    DataCell(Text(expense['quantity'].toString())),
                    DataCell(Text(expense['clientName'].toString())),
                    DataCell(Text('\$${expense['price']}')),
                    DataCell(Text(expense['expense_id'].toString())),
                    DataCell(Text(expense['warehouseName'].toString())),
                  ],
                ),
              ),
              DataRow(
                cells: [
                  DataCell(Text('Total',
                      style: TextStyle(fontWeight: FontWeight.bold))),
                  DataCell(Text('')),
                  DataCell(Text('')),
                  DataCell(Text('')),
                  DataCell(Text('\$$totalExpenses',
                      style: TextStyle(fontWeight: FontWeight.bold))),
                  DataCell(Text('')),
                  DataCell(Text('')),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPurchasesTable() {
    if (purchases != null && purchases!.isNotEmpty) {
      totalPurchases = purchases!
          .map((purchase) => double.parse(purchase['price'].toString()))
          .reduce((value, element) => value + element);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Purchases:', style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: [
              DataColumn(label: Text('Date')),
              DataColumn(label: Text('Stock Name')),
              DataColumn(label: Text('Quantity')),
              DataColumn(label: Text('Client Name')),
              DataColumn(label: Text('Price')),
              DataColumn(label: Text('Purchase ID')),
              DataColumn(label: Text('Warehouse Name')),
            ],
            rows: [
              ...purchases!.map(
                (purchase) => DataRow(
                  cells: [
                    DataCell(Text(purchase['date'].toString())),
                    DataCell(Text(purchase['stockName'].toString())),
                    DataCell(Text(purchase['quantity'].toString())),
                    DataCell(Text(purchase['clientName'].toString())),
                    DataCell(Text('\$${purchase['price']}')),
                    DataCell(Text(purchase['purchase_id'].toString())),
                    DataCell(Text(purchase['warehouseName'].toString())),
                  ],
                ),
              ),
              DataRow(
                cells: [
                  DataCell(Text('Total',
                      style: TextStyle(fontWeight: FontWeight.bold))),
                  DataCell(Text('')),
                  DataCell(Text('')),
                  DataCell(Text('')),
                  DataCell(Text('\$$totalPurchases',
                      style: TextStyle(fontWeight: FontWeight.bold))),
                  DataCell(Text('')),
                  DataCell(Text('')),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWarehouseTransfersTable() {
    if (warehouseTransfers != null && warehouseTransfers!.isNotEmpty) {
      totalTransfers = warehouseTransfers!
          .map((transfer) => double.parse(transfer['quantity'].toString()))
          .reduce((value, element) => value + element);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Warehouse Transfers:',
            style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: [
              DataColumn(label: Text('Date')),
              DataColumn(label: Text('Transfer ID')),
              DataColumn(label: Text('Quantity')),
              DataColumn(label: Text('Approval Status')),
              DataColumn(label: Text('Comment')),
              DataColumn(label: Text('Source')),
              DataColumn(label: Text('Target')),
            ],
            rows: [
              ...warehouseTransfers!.map(
                (transfer) => DataRow(
                  cells: [
                    DataCell(Text(transfer['date'].toString())),
                    DataCell(Text(transfer['warehousetransfer_id'].toString())),
                    DataCell(Text(transfer['quantity'].toString())),
                    DataCell(Text(transfer['approvalstatus'].toString())),
                    DataCell(Text(transfer['comment'].toString())),
                    DataCell(Text(transfer['source'].toString())),
                    DataCell(Text(transfer['target'].toString())),
                  ],
                ),
              ),
              DataRow(
                cells: [
                  DataCell(Text('Total',
                      style: TextStyle(fontWeight: FontWeight.bold))),
                  DataCell(Text('')),
                  DataCell(Text('$totalTransfers',
                      style: TextStyle(fontWeight: FontWeight.bold))),
                  DataCell(Text('')),
                  DataCell(Text('')),
                  DataCell(Text('')),
                  DataCell(Text('')),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _generatePDF(BuildContext context) async {
    final pdfFile = await PdfApi.generateExpenseReport(
      selectedDate: selectedDate,
      expenses: expenses,
      purchases: purchases,
      warehouseTransfers: warehouseTransfers,
      totalExpenses: totalExpenses,
      totalPurchases: totalPurchases,
      totalTransfers: totalTransfers,
    );

    PdfApi.openFile(pdfFile);
  }
}
