import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/api/pdf_api.dart';
import 'package:flutter_application_1/pages/Stocks.dart';

class DailyExpensesPage extends StatelessWidget {
  final String selectedDate;
  final List<dynamic>? warehouseTransfers;
  final List<dynamic>? expenses;
  final List<dynamic>? purchases;
  final List<dynamic>? clients;
  final List<dynamic>? stocks;
  double totalExpenses = 0;
  double totalTransfers = 0;
  double totalPurchases = 0;
  DailyExpensesPage(
      {required this.selectedDate,
      this.warehouseTransfers,
      this.expenses,
      this.purchases,
      this.clients,
      this.stocks});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Report - $selectedDate'),
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
                if (stocks != null && stocks!.isNotEmpty) ...[
                  _buildStocksTable(),
                  SizedBox(height: 16),
                ],
                if (clients != null && clients!.isNotEmpty) ...[
                  _buildClientsTable(),
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
      //   totalExpenses = expenses!
      //       .map((expense) => double.parse(expense['price'].toString()))
      //        .reduce((value, element) => value + element);

      for (var i = 0; i < expenses!.length; i++) {
        // Extracting the string value from the map
        String expensespriceString = expenses![i]['price']!.toString();
        // Splitting the string by commas and selecting the first part
        List<String> expensespriceParts = expensespriceString.split(',');
        // Printing the parts for debugging

        for (var x = 0; x < expensespriceParts.length; x++) {
          // Removing unwanted characters
          String cleanString = expensespriceParts[x]
              .replaceAll('[', '')
              .replaceAll(']', '')
              .trim();
          // Checking if the cleaned string is not empty
          if (cleanString.isNotEmpty) {
            try {
              double price = double.parse(cleanString);
              // Adding the price to totalExpenses
              totalExpenses += price;
            } catch (e) {
              // Handling the case where the string cannot be parsed to a double
            }
          }
        }
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Sales:', style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: [
              DataColumn(label: Text('Date')),
              DataColumn(label: Text('Stock Name')),
              DataColumn(label: Text('Quantity')),
              DataColumn(label: Text('Authorized')),
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
                    DataCell(Text(expense['autherized'].toString())),
                    DataCell(Text(expense['clientName'].toString())),
                    DataCell(Text('\ ${expense['price']}')),
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
                  DataCell(Text('')),
                  DataCell(Text('\ $totalExpenses',
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
      for (var i = 0; i < purchases!.length; i++) {
        // Extracting the string value from the map
        String priceString = purchases![i]['price']!.toString();
        // Splitting the string by commas and selecting the first part
        List<String> priceParts = priceString.split(',');
        // Parsing the first part of the split string as a double
        for (var x = 0; x < priceParts!.length; x++) {
          double price = double.parse(
              priceParts[x].replaceAll('[', '').replaceAll(']', ''));
          // Adding the price to totalPurchases
          totalPurchases += price;
        }
      }
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
              DataColumn(label: Text('Authorized')),
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
                    DataCell(Text(purchase['autherized'].toString())),
                    DataCell(Text(purchase['clientName'].toString())),
                    DataCell(Text('\ ${purchase['price'].toString()}')),
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
                  DataCell(Text('')),
                  DataCell(Text('\ $totalPurchases',
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

  Widget _buildClientsTable() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Clients:', style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: [
              DataColumn(label: Text('Registration Date')),
              DataColumn(label: Text('Client ID')),
              DataColumn(label: Text('Name')),
              DataColumn(label: Text('Address')),
              DataColumn(label: Text('Country')),
              DataColumn(label: Text('City')),
              DataColumn(label: Text('Phone')),
              DataColumn(label: Text('Gsm')),
            ],
            rows: [
              ...clients!.map(
                (transfer) => DataRow(
                  cells: [
                    DataCell(Text(transfer['registrationDate'].toString())),
                    DataCell(Text(transfer['clientId'].toString())),
                    DataCell(Text(transfer['name'].toString())),
                    DataCell(Text(transfer['address'].toString())),
                    DataCell(Text(transfer['country'].toString())),
                    DataCell(Text(transfer['city'].toString())),
                    DataCell(Text(transfer['phone'].toString())),
                    DataCell(Text(transfer['gsm'].toString())),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStocksTable() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Stocks:', style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: [
              DataColumn(label: Text('Registration Date')),
              DataColumn(label: Text('Stock ID')),
              DataColumn(label: Text('Stock Code')),
              DataColumn(label: Text('Stock Name')),
              DataColumn(label: Text('Barcode')),
              DataColumn(label: Text('Group Name')),
              DataColumn(label: Text('Middle Group Name')),
              DataColumn(label: Text('Unit')),
              DataColumn(label: Text('Sales Price')),
              DataColumn(label: Text('Purchase Price')),
            ],
            rows: [
              ...stocks!.map(
                (transfer) => DataRow(
                  cells: [
                    DataCell(Text(transfer['registrationDate'].toString())),
                    DataCell(Text(transfer['stockId'].toString())),
                    DataCell(Text(transfer['stockCode'].toString())),
                    DataCell(Text(transfer['stockName'].toString())),
                    DataCell(Text(transfer['barcode'].toString())),
                    DataCell(Text(transfer['groupName'].toString())),
                    DataCell(Text(transfer['middleGroupName'].toString())),
                    DataCell(Text(transfer['unit'].toString())),
                    DataCell(Text(transfer['salesPrice'].toString())),
                    DataCell(Text(transfer['purchasePrice'].toString())),
                  ],
                ),
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
        stocks: stocks,
        clients: clients);

    PdfApi.openFile(pdfFile);
  }
}
