import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/model/supplier.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/api/checkLoginStatus.dart';
import 'package:flutter_application_1/api/pdf_receipt_api.dart';
import 'package:flutter_application_1/api/pdf_api.dart';
import 'package:flutter_application_1/model/customer.dart';
import 'package:flutter_application_1/model/receipt.dart'; // Ensure you have this file

class ReceiptPage extends StatefulWidget {
  @override
  _ReceiptPageState createState() => _ReceiptPageState();
}

class _ReceiptPageState extends State<ReceiptPage> {
  List<dynamic> receipts = [];
  List<dynamic> filteredReceipt = [];
  int page = 0;

  @override
  void initState() {
    super.initState();
    fetchPurchasesByPage(page);
  }

  Future<void> fetchPurchasesByPage(int page) async {
    final response = await http.get(
      Uri.parse(
          'http://192.168.1.130:8080/api/getBalanceTransferByPage?page=$page'),
      headers: <String, String>{
        'Authorization': 'Bearer ${await getTokenFromLocalStorage()}'
      },
    );
    if (response.statusCode == 200) {
      setState(() {
        receipts = jsonDecode(utf8.decode(response.bodyBytes));
        receipts.sort((a, b) =>
            b['balance_transfer_ID'].compareTo(a['balance_transfer_ID']));
        filteredReceipt = receipts;
      });
    } else {
      print('Failed to fetch purchases: ${response.statusCode}');
    }
  }

  void goToPreviousPage() {
    if (page > 0) {
      setState(() {
        page--;
      });
      fetchPurchasesByPage(page);
    }
  }

  void goToNextPage() {
    if (filteredReceipt.length >= 10) {
      setState(() {
        page++;
      });
      fetchPurchasesByPage(page);
    }
  }

  void searchPurchases(String query) {
    setState(() {
      filteredReceipt = receipts
          .where((purchase) => purchase['clientName']
              .toLowerCase()
              .contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<void> createReceipt(dynamic purchase) async {
    Customer customer = Customer(
      name: purchase['clientName'],
      address: purchase['clientSurname'],
      number: purchase['commericalTitle'],
    );

    Supplier supplier = Supplier(
      Tel: ' +971 4 2266114',
      WhatsApp: ' +971559438444',
      POBox: 'P.O.Box 65127',
      name: 'Murshid Bazar',
      name2: 'Obaid Omayar Bldg',
      address: 'Shop No:1, Dubai, U.A.E',
    );

    ReceiptItem receiptItem = ReceiptItem(
      description: purchase['paymentType'],
      date: DateTime.now(),
      balance: purchase['balance'],
      amount: purchase['amount'],
    );

    Receipt receipt = Receipt(
      items: [receiptItem],
      type: "${purchase['comment']}",
      customer: customer,
      supplier: supplier,
    );

    final pdfFile = await PdfReceiptApi.generate(receipt);
    PdfApi.openFile(pdfFile);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Purchase List'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by client name...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: searchPurchases,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredReceipt.length,
              itemBuilder: (BuildContext context, int index) {
                final purchase = filteredReceipt[index];
                return Card(
                  elevation: 3,
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    title: Text('Process Type: ${purchase['comment']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            'Client Name: ${purchase['clientName'] ?? ''} ${purchase['clientSurname'] ?? ''}'),
                        Text('Amount: ${purchase['amount']}'),
                        Text('Payment Type: ${purchase['paymentType']}'),
                        Text('Date: ${purchase['date']}'),
                      ],
                    ),
                    onTap: () {
                      createReceipt(purchase);
                    },
                  ),
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: goToPreviousPage,
                icon: Icon(Icons.arrow_back),
              ),
              Text('Page ${page + 1}'),
              IconButton(
                onPressed: goToNextPage,
                icon: Icon(Icons.arrow_forward),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
