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
  List<dynamic> sales = [];
  List<dynamic> filteredSales = [];
  int page = 0;

  @override
  void initState() {
    super.initState();
    fetchSalesByPage(page);
  }

  Future<void> fetchSalesByPage(int page) async {
    final response = await http.get(
      Uri.parse('http://192.168.1.122:8080/api/getSalesByPage?page=$page'),
      headers: <String, String>{
        'Authorization': 'Bearer ${await getTokenFromLocalStorage()}'
      },
    );
    if (response.statusCode == 200) {
      setState(() {
        sales = jsonDecode(utf8.decode(response.bodyBytes));
        sales.sort((a, b) => b['expense_id'].compareTo(a['expense_id']));
        filteredSales = sales; // Initially, filteredSales will be same as sales
      });
    } else {
      // Handle errors
      print('Failed to fetch sales: ${response.statusCode}');
    }
  }

  void goToPreviousPage() {
    if (page > 0) {
      setState(() {
        page--;
      });
      fetchSalesByPage(page);
    }
  }

  void goToNextPage() {
    if (filteredSales.length >= 10) {
      setState(() {
        page++;
      });
      fetchSalesByPage(page);
    }
  }

  void searchSales(String query) {
    setState(() {
      // Filter the list of all sales based on the query
      // Assuming you want to filter by clientName
      filteredSales = sales
          .where((sale) =>
              sale['clientName'].toLowerCase().contains(query.toLowerCase()))
          .toList();
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
        unitPrice: double.parse(sale['price'][i]),
        vat: 0.05, // Example VAT rate 5%
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
              decoration: InputDecoration(
                hintText: 'Search by client name...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: searchSales,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredSales.length,
              itemBuilder: (BuildContext context, int index) {
                final sale = filteredSales[index];
                return Card(
                  elevation: 3,
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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
