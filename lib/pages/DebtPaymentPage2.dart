import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/Appbar.dart';
import 'package:flutter_application_1/pages/ClientsPayDoPage.dart';
import 'package:flutter_application_1/pages/ClientsPayListPage.dart';
import 'package:flutter_application_1/components/theme.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_application_1/api/checkLoginStatus.dart';

class DebtPaymentPage2 extends StatefulWidget {
  final dynamic client;

  const DebtPaymentPage2({Key? key, required this.client}) : super(key: key);

  @override
  _DebtPaymentPageState createState() => _DebtPaymentPageState();
}

class _DebtPaymentPageState extends State<DebtPaymentPage2> {
  TextEditingController debtAmountController = TextEditingController();
  TextEditingController paymentAmountController = TextEditingController();

  DateTime selectedDate = DateTime.now();
  Map<String, dynamic>? balanceData;
  String? selectedPaymentType;
  String? selectedDebtType;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });
  }

  Future<void> _fetchBalanceData() async {
    final url = Uri.parse(
        'http://${await loadIP()}:8080/api/getBalanceWithClientID?ClientID=${widget.client['clientId']}');
    final response = await http.get(url, headers: <String, String>{
      'Authorization': 'Bearer ${await getTokenFromLocalStorage()}'
    });
    if (response.statusCode == 200) {
      setState(() {
        balanceData = {
          'Balance': json.decode(response.body)['balanceDebt'],
        };
      });
    } else {
      throw Exception('Failed to load balance data');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchBalanceData();
  }

  String getDebtTypeAmount(String debtType) {
    if (balanceData != null && balanceData!.containsKey(debtType)) {
      return balanceData![debtType].toString();
    }
    return '';
  }

  Future<void> _makePayment() async {
    try {
      if (selectedPaymentType != null &&
          paymentAmountController.text.isNotEmpty) {
        final url = Uri.parse(
            'http://${await loadIP()}:8080/api/${widget.client['clientId']}/updateBalance2');
        final response = await http.patch(url, body: {
          'paymentType': selectedPaymentType!,
          'value': paymentAmountController.text,
        }, headers: <String, String>{
          'Authorization': 'Bearer ${await getTokenFromLocalStorage()}'
        });
        if (response.statusCode == 200) {
          // If successful, update balance data
          await _fetchBalanceData();
          setState(() {
            // Reset selected payment type and payment amount fields
            selectedPaymentType = null;
            paymentAmountController.text = '';
          });
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Payment successful'),
          ));
        } else {
          // Even if there's a 404 status code, consider it a successful payment
          // and proceed to update balance data
          await _fetchBalanceData();
          setState(() {
            // Reset selected payment type and payment amount fields
            selectedPaymentType = null;
            paymentAmountController.text = '';
          });
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Payment successful'),
          ));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Please select payment type and enter payment amount'),
        ));
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('An error occurred: $error'),
      ));
    }
  }

  void _navigateToPurchaseListPage() async {
    final dynamic result1 = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ClientsPayDoPage(
                selectedClient: widget.client,
              )),
    );
    if (result1 != null) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color.fromARGB(255, 0, 0, 0)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: 'Debt Payment Sales',
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Client: ${widget.client['name']} ${widget.client['surname']}',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                    width:
                        10), // Adds some space between the text and the button
                ElevatedButton(
                  onPressed: _navigateToPurchaseListPage,
                  child: Text('Open Records'),
                ),
              ],
            ),
            SizedBox(height: 12),
            if (balanceData != null) ...[
              for (var entry in balanceData!.entries)
                Text(
                  '${entry.key}: ${entry.value}',
                  style: TextStyle(fontSize: 16),
                ),
              SizedBox(height: 12),
              if (balanceData!['Balance'] > 0)
                Text(
                  'Sale payment',
                  style: TextStyle(fontSize: 16, color: Colors.red),
                )
              else if (balanceData!['Balance'] == 0)
                Text(
                  'Clear',
                  style: TextStyle(
                      fontSize: 16, color: Color.fromARGB(255, 44, 51, 252)),
                )
              else
                Text(
                  'Sales Payment',
                  style: TextStyle(fontSize: 16, color: Colors.green),
                )
            ],
            SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: selectedPaymentType,
              onChanged: (value) {
                setState(() {
                  selectedPaymentType = value;
                  selectedDebtType = null;
                });
              },
              decoration: InputDecoration(labelText: 'Payment Type'),
              items: [
                DropdownMenuItem(
                  value: 'Debit',
                  child: Text('Debit'),
                ),
                DropdownMenuItem(
                  value: 'Credit',
                  child: Text('Credit'),
                ),
                DropdownMenuItem(
                  value: 'Cash',
                  child: Text('Cash'),
                ),
              ],
            ),
            SizedBox(height: 12),
            if (selectedPaymentType != null) ...[
              SizedBox(height: 0),
              Text(
                'Selected Debt Amount: ${getDebtTypeAmount(selectedPaymentType!)}',
                style: TextStyle(fontSize: 10),
              ),
            ],
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: paymentAmountController,
                    decoration: InputDecoration(labelText: 'Payment Amount'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(context),
                ),
                Text("${selectedDate.toLocal()}".split(' ')[0]),
              ],
            ),
            SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.start, children: [
              ElevatedButton(
                onPressed: _makePayment,
                child: Text('Make Payment'),
              ),
            ])
          ],
        ),
      ),
    );
  }
}
