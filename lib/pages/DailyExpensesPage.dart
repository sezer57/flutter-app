import 'package:flutter/material.dart';

class DailyExpensesPage extends StatelessWidget {
  final String selectedDate;
  final List<dynamic>? warehouseTransfers;
  final List<dynamic>? expenses;
  final List<dynamic>? purchases;

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
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                if (expenses != null && expenses!.isNotEmpty) ...[
                  Text('Expenses:'),
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
                      rows: expenses!
                          .map(
                            (expense) => DataRow(
                              cells: [
                                DataCell(Text(expense['date'])),
                                DataCell(Text(expense['stockName'])),
                                DataCell(Text(expense['quantity'].toString())),
                                DataCell(Text(expense['clientName'])),
                                DataCell(Text('\$${expense['price']}')),
                                DataCell(
                                    Text(expense['expense_id'].toString())),
                                DataCell(Text(expense['warehouseName'])),
                              ],
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  SizedBox(height: 16),
                ],
                if (purchases != null && purchases!.isNotEmpty) ...[
                  Text('Purchases:'),
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
                      rows: purchases!
                          .map(
                            (purchase) => DataRow(
                              cells: [
                                DataCell(Text(purchase['date'])),
                                DataCell(Text(purchase['stockName'])),
                                DataCell(Text(purchase['quantity'].toString())),
                                DataCell(Text(purchase['clientName'])),
                                DataCell(Text('\$${purchase['price']}')),
                                DataCell(
                                    Text(purchase['purchase_id'].toString())),
                                DataCell(Text(purchase['warehouseName'])),
                              ],
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  SizedBox(height: 16),
                ],
                if (warehouseTransfers != null &&
                    warehouseTransfers!.isNotEmpty) ...[
                  Text('Warehouse Transfers:'),
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
                      rows: warehouseTransfers!
                          .map(
                            (transfer) => DataRow(
                              cells: [
                                DataCell(Text(transfer['date'])),
                                DataCell(Text(transfer['warehousetransfer_id']
                                    .toString())),
                                DataCell(Text(transfer['quantity'].toString())),
                                DataCell(Text(transfer['approvalstatus'])),
                                DataCell(Text(transfer['comment'])),
                                DataCell(Text(transfer['source'])),
                                DataCell(Text(transfer['target'])),
                              ],
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  SizedBox(height: 16),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
