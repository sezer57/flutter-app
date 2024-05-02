import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/api/pdf_api_client.dart';
import 'package:flutter_application_1/api/pdf_stock_api.dart';
import 'package:flutter_application_1/model/stock.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/api/pdf_api.dart';
import 'package:flutter_application_1/model/client.dart';
import 'package:flutter_application_1/widget/buttonwidget.dart';

class PdfPage extends StatefulWidget {
  @override
  _PdfPageState createState() => _PdfPageState();
}

class _PdfPageState extends State<PdfPage> {
  List<dynamic> clients = [];

  @override
  void initState() {
    super.initState();
    fetchclnts();
  }

  Future<void> fetchclnts() async {
    final response = await http.get(
      Uri.parse('http://104.248.42.73:8080/api/getStocks'),
    );
    if (response.statusCode == 200) {
      setState(() {
        clients = jsonDecode(utf8.decode(response.bodyBytes));
        clients.sort((a, b) => b['stockName'].compareTo(a['stockName']));
      });
    } else {
      // Handle errors
      print('Failed to fetch clnts: ${response.statusCode}');
    }
  }

  Future<void> createInvoices(List<dynamic> clients) async {
    // Satışlar listesi boş ise işlem yapmayalım
    if (clients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No stocks available to create PDF.'),
        ),
      );
      return;
    }

    // Tüm müşteri verilerini birleştir
    List<StockItem> stockItems = [];
    for (var clnt in clients) {
      stockItems.add(StockItem(
        stockId: clnt['stockId'] ?? -1,
        stockName: clnt['stockName'] ?? 'Unknown',
        stockCode: clnt['stockCode'] ?? 'Unknown',
        barcode: clnt['barcode'] ?? 'Unknown',
        groupName: clnt['groupName'] ?? 'Unknown',
        middleGroupName: clnt['middleGroupName'] ?? 'Unknown',
        unit: clnt['unit'] ?? 'Unknown',
        salesPrice: clnt['salesPrice'] ?? -1,
        purchasePrice: clnt['purchasePrice'] ?? -1,
        warehouseId: clnt['warehouseId'] ?? -1,
        registrationDate: clnt['registrationDate'] != null
            ? DateTime.parse(clnt['registrationDate'])
            : DateTime.now(),
      ));
    }

    // Tüm müşteri verilerini tek bir Client nesnesinde topla
    final stock = Stock(items: stockItems);

    // Tek bir PDF oluştur
    final pdfFile = await PdfStockApi.generate(stock);

    // Dosyayı aç
    PdfApi.openFile(pdfFile);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stock List'),
        actions: [
          IconButton(
            icon: Icon(Icons.print),
            onPressed: () {
              // Butona tıklandığında PDF oluşturulsun
              createInvoices(clients);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: clients.length,
              itemBuilder: (BuildContext context, int index) {
                final purchase = clients[index];
                return Card(
                  elevation: 3,
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    title: Text('Stock Code: ${purchase['stockCode']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Stock Name: ${purchase['stockName']}'),
                        Text('Stock Code: ${purchase['stockCode']}'),
                        Text('Sales Price: ${purchase['salesPrice']}'),
                        Text('Warehouse Id: ${purchase['warehouseId']}'),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
