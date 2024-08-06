import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/Appbar.dart';

class DailyMovementsOfClient extends StatelessWidget {
  final String selectedDate;
  final List<dynamic>? dailyMovementsOfClient;

  DailyMovementsOfClient({
    required this.selectedDate,
    this.dailyMovementsOfClient,
  });
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Daily Movements Of Client - $selectedDate',
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                if (dailyMovementsOfClient != null &&
                    dailyMovementsOfClient!.isNotEmpty) ...[
                  Text('Daily Movements Of Client:'),
                  SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: [
                        DataColumn(label: Text('Client Code')),
                        DataColumn(label: Text('Commercial Title')),
                        DataColumn(label: Text('Name')),
                        DataColumn(label: Text('Surname')),
                        DataColumn(label: Text('Address')),
                        DataColumn(label: Text('Country')),
                        DataColumn(label: Text('City')),
                        DataColumn(label: Text('Phone')),
                        DataColumn(label: Text('GSM')),
                      ],
                      rows: dailyMovementsOfClient!
                          .map(
                            (data) => DataRow(
                              cells: [
                                DataCell(Text(data['clientCode'].toString())),
                                DataCell(Text(data['commercialTitle'])),
                                DataCell(Text(data['name'])),
                                DataCell(Text(data['surname'])),
                                DataCell(Text(data['address'])),
                                DataCell(Text(data['country'])),
                                DataCell(Text(data['city'].toString())),
                                DataCell(Text(data['phone'].toString())),
                                DataCell(Text(data['gsm'].toString())),
                              ],
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  SizedBox(height: 12),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
