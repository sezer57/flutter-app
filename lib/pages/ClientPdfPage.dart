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

TextEditingController searchController = TextEditingController();

class _PdfPageState extends State<PdfPage> {
  late Future<List<dynamic>> _clientsFuture;
  List<dynamic> _clients = [];
  int page = 0;
  int _currentPage = 0;
  bool isLoading = false;
  late int totalPages;
  final int pageSize = 6; // Sayfa başına gösterilecek stok sayısı

  Map<String, dynamic>? balanceData;
  @override
  void initState() {
    super.initState();
    _clientsFuture = _fetchClients(page);
  }

  Future<List<dynamic>> _fetchClients(int page) async {
    final url = searchController.text.isEmpty
        ? 'http://${await loadIP()}:8080/api/getClientsByPage?page=$page&size=$pageSize'
        : 'http://${await loadIP()}:8080/api/getClientsBySearch?keyword=${searchController.text}&page=$page&size=$pageSize';

    final response = await http.get(Uri.parse(url), headers: <String, String>{
      'Authorization': 'Bearer ${await getTokenFromLocalStorage()}'
    });
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
        _clientsFuture = _fetchClients(_currentPage);
      });
    }
  }

  void _goToNextPage() async {
    if (_currentPage + 1 < totalPages) {
      setState(() {
        _currentPage++;
        _clientsFuture = _fetchClients(_currentPage);
      });
    }
  }

  void searchClients(String query) {
    setState(() {
      _currentPage = 0;

      _clientsFuture = _fetchClients(_currentPage);
    });
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
          "http://${await loadIP()}:8080/api/getBalanceWithClientID?ClientID=${clnt['clientId']}");
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
              createInvoices(_clients);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'Search Client...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(color: Colors.grey),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(color: Colors.blue),
              ),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
            ),
            onChanged: searchClients,
          ),
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _clientsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No clients found'));
                } else {
                  _clients = snapshot.data!;
                  return Column(children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: _clients.length,
                        itemBuilder: (BuildContext context, int index) {
                          final purchase = _clients[index];
                          return Card(
                            elevation: 3,
                            margin: EdgeInsets.symmetric(
                                vertical: 8, horizontal: 16),
                            child: ListTile(
                              title: Text(
                                  'Client Code: ${purchase['clientCode']}'),
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
                  ]);
                }
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
      ),
    );
  }
}
