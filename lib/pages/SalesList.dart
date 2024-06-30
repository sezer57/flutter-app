import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/ClientsPage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/api/pdf_api.dart';
import 'package:flutter_application_1/model/customer.dart';
import 'package:flutter_application_1/model/invoice.dart';
import 'package:flutter_application_1/model/supplier.dart';
import 'package:flutter_application_1/pages/utils.dart';
import 'package:flutter_application_1/api/pdf_invoice_api.dart';
import 'package:flutter_application_1/api/checkLoginStatus.dart';

class SalesList extends StatefulWidget {
  @override
  _SalesListState createState() => _SalesListState();
}

class _SalesListState extends State<SalesList> {
  List<dynamic> sales = [];
  late Future<List<dynamic>> _salesFuture;
  int page = 0;
  int _currentPage = 0;
  bool isLoading = false;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _salesFuture = fetchSalesByPage(page);
  }

  final int pageSize = 6;
  late int totalPages;
  Future<List<dynamic>> fetchSalesByPage(int page) async {
    final response = await http.get(
      Uri.parse(
          'http://${await loadIP()}:8080/api/getSalesByPage?page=$page&size=$pageSize&keyword=${searchController.text}'),
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
        _salesFuture = fetchSalesByPage(_currentPage);
      });
    }
  }

  void _goToNextPage() async {
    if (_currentPage + 1 < totalPages) {
      setState(() {
        _currentPage++;
        _salesFuture = fetchSalesByPage(_currentPage);
      });
    }
  }

  void searchClients(String query) {
    setState(() {
      _currentPage = 0;

      _salesFuture = fetchSalesByPage(_currentPage);
    });
  }

  Future<void> createInvoice(dynamic sale) async {
    // InvoiceInfo oluşturma
    InvoiceInfo info = InvoiceInfo(
      number: sale['expense_id'].toString(),
      date: DateTime.now(),
      description: 'Sales Invoice for ${sale['stockName']}',
    );

    // Customer oluşturma
    Customer customer = Customer(
      name: sale['clientName'],
      address: sale['clientAdress'],
      number: sale['clientPhone'],
    );

    // Supplier oluşturma
    Supplier supplier = Supplier(
      Tel: ' +971 4 2266114',
      WhatsApp: ' +971559438444',
      POBox: 'P.O.Box 65127',
      name: 'Murshid Bazar',
      name2: 'Obaid Omayar Bldg',
      address: 'Shop No:1, Dubai, U.A.E',
    );

    List<InvoiceItem> invoiceItems = [];

    for (int i = 0; i < sale['stockName'].length; i++) {
      InvoiceItem item = InvoiceItem(
        description: 'Product: ${sale['stockName'][i]}',
        date: DateTime.now(),
        quantity: int.parse(sale['quantity'][i]),
        unitPrice:
            double.parse(sale['price'][i]) / (1 + (sale['vat'][i]) / 100),
        vat: (sale['vat'][i]) / 100, // 0.05, // Example VAT rate 5%
      );
      invoiceItems.add(item);
    }

    // Invoice oluşturma
    Invoice invoice = Invoice(
      info: info,
      supplier: supplier,
      customer: customer,
      items: invoiceItems,
      type: "sale",
    );

    // Fatura oluşturma ve dosyayı kaydetme
    final pdfFile = await PdfInvoiceApi.generate(invoice);
    PdfApi.openFile(pdfFile);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sales List'),
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
              future: _salesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No sales list found'));
                } else {
                  sales = snapshot.data!;
                  return Column(children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: sales.length,
                        itemBuilder: (BuildContext context, int index) {
                          final sale = sales[index];
                          return Card(
                            elevation: 3,
                            margin: EdgeInsets.symmetric(
                                vertical: 8, horizontal: 16),
                            child: ListTile(
                              title: Text('Invoice Id: ${sale['expense_id']}'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Stock Name: ${sale['stockName']}'),
                                  Text('Price: ${sale['price']}'),
                                  Text('Client Name: ${sale['clientName']}'),
                                  Text('Date: ${sale['date']}'),
                                ],
                              ),
                              onTap: () {
                                createInvoice(sale);
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
