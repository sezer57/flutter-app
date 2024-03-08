import 'package:flutter/material.dart';

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
            TextFormField(
              controller: debtAmountController,
              decoration: InputDecoration(labelText: 'Debt Amount'),
              keyboardType: TextInputType.number,
            ),
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
