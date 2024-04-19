import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/api/pdf_invoice_api.dart'; // PdfInvoiceApi'yi ekleyin
import 'package:flutter_application_1/api/pdf_api.dart';
import 'package:flutter_application_1/model/customer.dart';
import 'package:flutter_application_1/model/invoice.dart';
import 'package:flutter_application_1/model/supplier.dart';
import 'package:flutter_application_1/pages/utils.dart';
import 'package:flutter_application_1/api/pdf_invoice_api.dart';
import 'package:flutter_application_1/api/checkLoginStatus.dart';

class PurchaseList extends StatefulWidget {
  @override
  _PurchaseListState createState() => _PurchaseListState();
}

class _PurchaseListState extends State<PurchaseList> {
  List<dynamic> purchases = [];

  @override
  void initState() {
    super.initState();
    fetchPurchases();
  }

  Future<void> fetchPurchases() async {
    final response = await http.get(
        Uri.parse('http://192.168.1.105:8080/api/getPurchases'),
        headers: <String, String>{
          'Authorization': 'Bearer ${await getTokenFromLocalStorage()}'
        });
    if (response.statusCode == 200) {
      setState(() {
        purchases = json.decode(response.body);
        purchases.sort((a, b) => b['purchase_id'].compareTo(a['purchase_id']));
      });
    } else {
      // Handle errors
      print('Failed to fetch purchases: ${response.statusCode}');
    }
  }

  Future<void> createInvoice(dynamic purchase) async {
    // InvoiceInfo oluşturma
    // Örnek olarak, her satın alma için aynı fatura bilgilerini kullanıyoruz
    InvoiceInfo info = InvoiceInfo(
      number: purchase['purchase_id'].toString(),
      date: DateTime.now(),
      dueDate:
          DateTime.now().add(Duration(days: 30)), // Örnek olarak 30 gün sonra
      description: 'Invoice for ${purchase['stockName']}',
    );

    // Supplier oluşturma (Varsayılan değerler kullanıldı, isteğe bağlı olarak değiştirilebilir)
    Supplier supplier = Supplier(
      name: 'Cekir Trading Co. ',
      address: 'Dubai',
      paymentInfo: 'TR5254657894564510000',
    );

    // Customer oluşturma
    Customer customer = Customer(
      name: purchase['clientName'],
      address: purchase['clientAdress'],
    );

    // Item oluşturma
    InvoiceItem item = InvoiceItem(
      description: 'Product: ${purchase['stockName']}',
      date: DateTime.now(),
      quantity: purchase['quantity'],
      unitPrice: purchase['price'],
      vat: 0.18, // Örnek olarak KDV oranı %18
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
        title: Text('Purchase List'),
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
              title: Text('Invoice Id: ${purchase['purchase_id']}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Stock Name: ${purchase['stockName']}'),
                  Text('Price: \$${purchase['price']}'),
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
    );
  }
}
