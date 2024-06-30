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
  late Future<List<dynamic>> _receiptsFuture;
  int page = 0;
  int _currentPage = 0;
  bool isLoading = false;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _receiptsFuture = fetchPurchasesByPage(page);
  }

  final int pageSize = 6;
  late int totalPages;
  Future<List<dynamic>> fetchPurchasesByPage(int page) async {
    final response = await http.get(
      Uri.parse(
          'http://${await loadIP()}:8080/api/getBalanceTransferByPage?page=$page&size=$pageSize&keyword=${searchController.text}'),
      headers: <String, String>{
        'Authorization': 'Bearer ${await getTokenFromLocalStorage()}'
      },
    );
    if (response.statusCode == 200) {
      final utf8Body = utf8.decode(response.bodyBytes);
      totalPages = jsonDecode(utf8Body)['totalPages'];
      return jsonDecode(utf8Body)['content'];
    } else {
      return List.empty();
    }
  }

  void _goToPreviousPage() async {
    if (_currentPage > 0) {
      setState(() {
        _currentPage--;
        _receiptsFuture = fetchPurchasesByPage(_currentPage);
      });
    }
  }

  void _goToNextPage() async {
    if (_currentPage + 1 < totalPages) {
      setState(() {
        _currentPage++;
        _receiptsFuture = fetchPurchasesByPage(_currentPage);
      });
    }
  }

  void searchClients(String query) {
    setState(() {
      _currentPage = 0;

      _receiptsFuture = fetchPurchasesByPage(_currentPage);
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
        title: Text('Receipt List'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search by client name...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: searchClients,
            ),
          ),
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _receiptsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No receipt found'));
                } else {
                  receipts = snapshot.data!;
                  return Column(children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: receipts.length,
                        itemBuilder: (BuildContext context, int index) {
                          final purchase = receipts[index];
                          return Card(
                            elevation: 3,
                            margin: EdgeInsets.symmetric(
                                vertical: 8, horizontal: 16),
                            child: ListTile(
                              title:
                                  Text('Process Type: ${purchase['comment']}'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      'Client Name: ${purchase['clientName'] ?? ''} ${purchase['clientSurname'] ?? ''}'),
                                  Text('Amount: ${purchase['amount']}'),
                                  Text(
                                      'Payment Type: ${purchase['paymentType']}'),
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
                          onPressed: _goToPreviousPage,
                          icon: Icon(Icons.arrow_back),
                        ),
                        Text('Page ${_currentPage + 1}'),
                        IconButton(
                          onPressed: _goToNextPage,
                          icon: Icon(Icons.arrow_forward),
                        ),
                      ],
                    )
                  ]);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
