import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/api/pdf_api_client.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/api/pdf_api.dart';
import 'package:flutter_application_1/model/client.dart';
import 'package:flutter_application_1/widget/buttonwidget.dart';
import 'package:flutter_application_1/api/checkLoginStatus.dart';

class PdfPage extends StatefulWidget {
  @override
  _PdfPageState createState() => _PdfPageState();
}

class _PdfPageState extends State<PdfPage> {
  List<dynamic> clients = [];
  Map<String, dynamic>? balanceData;
  @override
  void initState() {
    super.initState();
    fetchclnts();
  }

  Future<void> fetchclnts() async {
    final response = await http.get(
        Uri.parse('http://192.168.1.102:8080/api/getClients'),
        headers: <String, String>{
          'Authorization': 'Bearer ${await getTokenFromLocalStorage()}'
        });
    if (response.statusCode == 200) {
      setState(() {
        clients = jsonDecode(utf8.decode(response.bodyBytes));
        clients.sort((a, b) => b['name'].compareTo(a['name']));
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
          content: Text('No clients available to create PDF.'),
        ),
      );
      return;
    }

    // Declare variables outside the loop
    var clientItems = <ClientItem>[];
    Map<String, dynamic>? balanceData;

    for (var clnt in clients) {
      final url = Uri.parse(
          "http://192.168.1.102:8080/api/getBalanceWithClientID?ClientID=${clnt['clientId']}");
      final response = await http.get(url, headers: <String, String>{
        'Authorization': 'Bearer ${await getTokenFromLocalStorage()}'
      });
      if (response.statusCode == 200) {
        setState(() {
          balanceData = jsonDecode(utf8.decode(response.bodyBytes));
        });
      } else {
        throw Exception('Failed to load balance data');
      }

      // Extract balance data with proper type conversions
      var balance = balanceData?['balance']?.toString() ?? 'Unknown';
      var comment = balanceData?['comment']?.toString() ?? 'Unknown';
      var debitCreditStatus =
          balanceData?['debitCreditStatus']?.toString() ?? 'Unknown';

      // Add client item with balance data
      clientItems.add(ClientItem(
        clientCode: clnt['clientCode'] ?? -1,
        commercialTitle: clnt['commercialTitle'] ?? 'Unknown',
        name: clnt['name'] ?? 'Unknown',
        surname: clnt['surname'] ?? 'Unknown',
        address: clnt['address'] ?? 'Unknown',
        country: clnt['country'] ?? 'Unknown',
        city: clnt['city'] ?? 'Unknown',
        phone: clnt['phone'] ?? 'Unknown',
        gsm: clnt['gsm'] ?? 'Unknown',
        registrationDate: clnt['registrationDate'] != null
            ? DateTime.parse(clnt['registrationDate'])
            : DateTime.now(),
        balance: balance,
        comment: comment,
        debitCreditStatus: debitCreditStatus,
      ));
    }

    // // Print client items
    // for (var item in clientItems) {
    //   print('Client Code: ${item.clientCode}');
    //   print('Commercial Title: ${item.commercialTitle}');
    //   print('Name: ${item.name}');
    //   print('Surname: ${item.surname}');
    //   print('Address: ${item.address}');
    //   print('Country: ${item.country}');
    //   print('City: ${item.city}');
    //   print('Phone: ${item.phone}');
    //   print('GSM: ${item.gsm}');
    //   print('Registration Date: ${item.registrationDate}');
    //   print('Balance: ${item.balance}');
    //   print('Comment: ${item.comment}');
    //   print('Debit Credit Status: ${item.debitCreditStatus}');
    //   print('---------------------');
    // }

    // Tüm müşteri verilerini tek bir Client nesnesinde topla
    final client = Client(items: clientItems);

    // Tek bir PDF oluştur
    final pdfFile = await PdfClientApi.generate(client);

    // Dosyayı aç
    PdfApi.openFile(pdfFile);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Client List'),
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
                    title: Text('Client Code: ${purchase['clientCode']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Name: ${purchase['name']}'),
                        Text('Surname: ${purchase['surname']}'),
                        Text('Address: ${purchase['address']}'),
                        Text('Phone: ${purchase['phone']}'),
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
