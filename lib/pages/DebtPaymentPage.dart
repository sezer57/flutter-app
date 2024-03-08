import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DebtPaymentPage extends StatefulWidget {
  final dynamic client;

  const DebtPaymentPage({Key? key, required this.client}) : super(key: key);

  @override
  _DebtPaymentPageState createState() => _DebtPaymentPageState();
}

class _DebtPaymentPageState extends State<DebtPaymentPage> {
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
    final url = Uri.parse('http://192.168.1.105:8080/api/getBalanceWithClientID?ClientID=${widget.client['clientId']}');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      setState(() {
        balanceData = json.decode(response.body);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Debt Payment'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Client: ${widget.client['name']} ${widget.client['surname']}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            if (balanceData != null) ...[
              for (var entry in balanceData!.entries)
                Text(
                  '${entry.key}: ${entry.value}',
                  style: TextStyle(fontSize: 16),
                ),
            ],
            SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: selectedPaymentType,
              onChanged: (value) {
                setState(() {
                  selectedPaymentType = value;
                  selectedDebtType = null; // Reset selected debt type when payment type changes
                });
              },
              decoration: InputDecoration(labelText: 'Payment Type'),
              items: [
                DropdownMenuItem(
                  value: 'turnoverDebit',
                  child: Text('Turnover Debit'),
                ),
                DropdownMenuItem(
                  value: 'turnoverCredit',
                  child: Text('Turnover Credit'),
                ),
                DropdownMenuItem(
                  value: 'turnoverBalance',
                  child: Text('Turnover Balance'),
                ),
                DropdownMenuItem(
                  value: 'transactionalDebit',
                  child: Text('Transactional Debit'),
                ),
                DropdownMenuItem(
                  value: 'transactionalCredit',
                  child: Text('Transactional Credit'),
                ),
                DropdownMenuItem(
                  value: 'transactionalBalance',
                  child: Text('Transactional Balance'),
                ),
              ],
            ),
            SizedBox(height: 10),
            if (selectedPaymentType != null) ...[
              SizedBox(height: 0),
              Text(
                'Selected Debt Amount: ${getDebtTypeAmount(selectedPaymentType!)}',
                style: TextStyle(fontSize: 10),
              ),
            ],
            
            SizedBox(height: 20),
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
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Payment logic here
              },
              child: Text('Make Payment'),
            ),
          ],
        ),
      ),
    );
  }
}
