import 'dart:convert';
import 'package:flutter/material.dart';
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
  List<dynamic> purchases = [];

  @override
  void initState() {
    super.initState();
    fetchSales();
  }

  Future<void> fetchSales() async {
    final response = await http.get(
        Uri.parse('http://104.248.42.73:8080/api/getSales'),
        headers: <String, String>{
          'Authorization': 'Bearer ${await getTokenFromLocalStorage()}'
        });
    if (response.statusCode == 200) {
      setState(() {
        purchases = jsonDecode(utf8.decode(response.bodyBytes));
        purchases.sort((a, b) => b['expense_id'].compareTo(a['expense_id']));
      });
    } else {
      // Handle errors
      print('Failed to fetch sales: ${response.statusCode}');
    }
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
        number: sale['clientPhone']);

    // Supplier oluşturma (Varsayılan değerler kullanıldı, isteğe bağlı olarak değiştirilebilir)
    Supplier supplier = Supplier(
      Tel: ' +971 4 2266114',
      WhatsApp: ' +971559438444',
      POBox: 'P.O.Box 65127',
      name: 'Murshid Bazar',
      name2: 'Obaid Omayar Bldg',
      address: 'Shop No:1, Dubai, U.A.E',
    );

    // Item oluşturma
    InvoiceItem item = InvoiceItem(
      description: 'Product: ${sale['stockName']}',
      date: DateTime.now(),
      quantity: sale['quantity'],
      unitPrice: sale['price'],
      vat: 0.05, // Örnek olarak KDV oranı %18
    );

    // Invoice oluşturma
    Invoice invoice = Invoice(
        info: info,
        supplier: supplier,
        customer: customer,
        items: [item],
        type: "sale");

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
        title: Text('Sales List'),
      ),
      body: ListView.builder(
        itemCount: purchases.length,
        itemBuilder: (BuildContext context, int index) {
          final purchase = purchases[index];
          return Card(
            elevation: 3, // Opsiyonel: Kartın gölge derecesini belirler
            margin: EdgeInsets.symmetric(
                vertical: 8,
                horizontal: 16), // Opsiyonel: Kartın kenar boşluklarını ayarlar
            child: ListTile(
              title: Text('Invoice Id: ${purchase['expense_id']}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Stock Name: ${purchase['stockName']}'),
                  Text('Price: ${purchase['price']}'),
                  Text('Date: ${purchase['date']}'),
                  Text('Client Name: ${purchase['clientName']}'),
                ],
              ),
              onTap: () {
                createInvoice(purchase);
              },
            ),
          );
        },
      ),
    );
  }
}
