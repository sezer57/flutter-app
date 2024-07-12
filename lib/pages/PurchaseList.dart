import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/api/checkLoginStatus.dart';
import 'package:flutter_application_1/api/pdf_invoice_api.dart';
import 'package:flutter_application_1/api/pdf_api.dart';
import 'package:flutter_application_1/model/customer.dart';
import 'package:flutter_application_1/model/invoice.dart';
import 'package:flutter_application_1/model/supplier.dart';

class PurchaseList extends StatefulWidget {
  @override
  _PurchaseListState createState() => _PurchaseListState();
}

class _PurchaseListState extends State<PurchaseList> {
  List<dynamic> purchases = [];
  late Future<List<dynamic>> _stocksFuture;
  int page = 0;
  int _currentPage = 0;
  bool isLoading = false;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _stocksFuture = fetchPurchasesByPage(_currentPage);
  }

  final int pageSize = 6;
  late int totalPages;
  Future<List<dynamic>> fetchPurchasesByPage(int page) async {
    final response = await http.get(
      Uri.parse(
          'http://${await loadIP()}:8080/api/getPurchasesByPage?page=$page&size=$pageSize&keyword=${searchController.text}'),
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

  void searchStocks(String query) {
    setState(() {
      _currentPage = 0;
      _stocksFuture = fetchPurchasesByPage(_currentPage);
    });
  }

  void _goToPreviousPage() {
    if (_currentPage > 0) {
      setState(() {
        _currentPage--;
        _stocksFuture = fetchPurchasesByPage(_currentPage);
      });
    }
  }

  void _goToNextPage() {
    if (_currentPage + 1 < totalPages) {
      setState(() {
        _currentPage++;
        _stocksFuture = fetchPurchasesByPage(_currentPage);
      });
    }
  }

  Future<void> createInvoice(dynamic purchase) async {
    // InvoiceInfo oluşturma
    // Örnek olarak, her satın alma için aynı fatura bilgilerini kullanıyoruz
    InvoiceInfo info = InvoiceInfo(
      number: purchase['purchase_id'].toString(),
      date: DateTime.now(),
      description: 'Purchase Invoice for ${purchase['stockName']}',
    );

    // Supplier oluşturma (Varsayılan değerler kullanıldı, isteğe bağlı olarak değiştirilebilir)
    Supplier supplier = Supplier(
      Tel: ' +971 4 2266114',
      WhatsApp: ' +971559438444',
      POBox: 'P.O.Box 65127',
      name: 'Murshid Bazar',
      name2: 'Obaid Omayar Bldg',
      address: 'Shop No:1, Dubai, U.A.E',
    );

    // Customer oluşturma
    Customer customer = Customer(
        name: purchase['clientName'],
        address: purchase['clientAdress'],
        number: purchase['clientPhone']);

    // Item oluşturma

    List<InvoiceItem> invoiceItems = [];
    for (int i = 0; i < purchase['stockName'].length; i++) {
      InvoiceItem item = InvoiceItem(
        description: 'Product: ${purchase['stockName'][i]}',
        date: DateTime.now(),
        quantity: (purchase['quantity'][i]),
        quantity_type: '${purchase['quantity_type'][i]}',
        unitPrice: (purchase['price'][i]) / (1 + (purchase['vat'][i]) / 100),
        vat: (purchase['vat'][i]) / 100, // 0.05, // Example VAT rate 5%
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
    // Fatura dosyasını görüntüleme (Opsiyonel)
    // Android için: PDFViewer.openFile(pdfFile.path);
    // iOS için: PDFViewer.openFile(pdfFile.path);

    // Fatura dosyasını paylaşma (Opsiyonel)
    // shareFile(pdfFile);
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
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search by client name...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: searchStocks,
            ),
          ),
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _stocksFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No purchases found'));
                } else {
                  purchases = snapshot.data!;
                  return Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: purchases.length,
                          itemBuilder: (BuildContext context, int index) {
                            final purchase = purchases[index];
                            return Card(
                              elevation: 3,
                              margin: EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 16),
                              child: ListTile(
                                title: Text(
                                    'Invoice Id: ${purchase['purchase_id']}'),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        'Stock Name: ${purchase['stockName']}'),
                                    Text('Price: ${purchase['price']}'),
                                    Text(
                                        'Client Name: ${purchase['clientName']}'),
                                    Text('Date: ${purchase['date']}'),
                                  ],
                                ),
                                onTap: () {
                                  createInvoice(purchase);
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
                      ),
                    ],
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
