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
  List<dynamic> filteredPurchases = [];
  int page = 0;

  @override
  void initState() {
    super.initState();
    fetchPurchasesByPage(page);
  }

  Future<void> fetchPurchasesByPage(int page) async {
    final response = await http.get(
      Uri.parse('http://192.168.1.130:8080/api/getPurchasesByPage?page=$page'),
      headers: <String, String>{
        'Authorization': 'Bearer ${await getTokenFromLocalStorage()}'
      },
    );
    if (response.statusCode == 200) {
      setState(() {
        purchases = jsonDecode(utf8.decode(response.bodyBytes));
        purchases.sort((a, b) => b['purchase_id'].compareTo(a['purchase_id']));
        filteredPurchases =
            purchases; // Initially, filteredPurchases will be same as purchases
      });
    } else {
      // Handle errors
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
    if (filteredPurchases.length >= 10) {
      setState(() {
        page++;
      });
      fetchPurchasesByPage(page);
    }
  }

  void searchPurchases(String query) {
    setState(() {
      // Filter the list of all purchases based on the query
      // Assuming you want to filter by clientName
      filteredPurchases = purchases
          .where((purchase) => purchase['clientName']
              .toLowerCase()
              .contains(query.toLowerCase()))
          .toList();
    });
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
              decoration: InputDecoration(
                hintText: 'Search by client name...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: searchPurchases,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredPurchases.length,
              itemBuilder: (BuildContext context, int index) {
                final purchase = filteredPurchases[index];
                return Card(
                  elevation: 3,
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    title: Text('Invoice Id: ${purchase['purchase_id']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Stock Name: ${purchase['stockName']}'),
                        Text('Price: ${purchase['price']}'),
                        Text('Client Name: ${purchase['clientName']}'),
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
