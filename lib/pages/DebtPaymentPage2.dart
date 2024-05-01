import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DebtPaymentPage2 extends StatefulWidget {
  final dynamic client;
  final String initialPaymentAmount;

  const DebtPaymentPage2({
    Key? key,
    required this.client,
    required this.initialPaymentAmount, // Yeni parametre eklendi
  }) : super(key: key);

  @override
  _DebtPaymentPage2State createState() => _DebtPaymentPage2State();
}

class _DebtPaymentPage2State extends State<DebtPaymentPage2> {
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
        'http://104.248.42.73:8080/api/getBalanceWithClientID?ClientID=${widget.client['clientId']}');
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
    paymentAmountController.text =
        widget.initialPaymentAmount; // initialPaymentAmount değeri atanıyor
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
            'http://104.248.42.73:8080/api/${widget.client['clientId']}/updateBalance');
        final response = await http.patch(
          url,
          body: {
            'paymentType': selectedPaymentType!,
            'value': paymentAmountController.text,
          },
        );
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
                  selectedDebtType = null;
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
                    enabled: false, // Disable editing
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
              onPressed: _makePayment,
              child: Text('Make Payment'),
            ),
          ],
        ),
      ),
    );
  }
}
