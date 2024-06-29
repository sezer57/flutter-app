import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/pages/DebtPaymentPage2.dart';
import 'package:flutter_application_1/api/checkLoginStatus.dart';

class ClientsPayDoPage extends StatefulWidget {
  final dynamic selectedClient;
  ClientsPayDoPage({required this.selectedClient});
  @override
  _ClientsPayDoPageState createState() => _ClientsPayDoPageState();
}

class _ClientsPayDoPageState extends State<ClientsPayDoPage> {
  List<dynamic> purchases = [];

  TextEditingController searchController = TextEditingController();

  int page = 0;

  bool isLoading = false;
  final int pageSize = 10;
  late int totalPages;

  int _currentPage = 0;
  @override
  void initState() {
    super.initState();
    fetchPurchasesByPage(page).then((value) async => setState(() {
          purchases = value;
        }));
  }

  Future<List<dynamic>> fetchPurchasesByPage(int page) async {
    final response = await http.get(
      Uri.parse(
          'http://${await loadIP()}:8080/api/getPurchaseInvoiceClientByPage?page=$page&client_id=${widget.selectedClient['clientId']}&keyword=${searchController.text}&size=$pageSize'),
      headers: <String, String>{
        'Authorization': 'Bearer ${await getTokenFromLocalStorage()}'
      },
    );
    if (response.statusCode == 200) {
      final utf8Body = utf8.decode(response.bodyBytes);
      totalPages = jsonDecode(utf8Body)['totalPages'];
      print(jsonDecode(utf8Body)['content']);
      return jsonDecode(utf8Body)['content'];
    } else {
      return List.empty();
    }
  }

  void searchPurchases(String query) {
    setState(() {
      _currentPage = 0;
      fetchPurchasesByPage(_currentPage).then((stocks) async {
        setState(() {
          purchases = stocks;
        });
      });
    });
  }

  void _goToPreviousPage() async {
    try {
      if (_currentPage > 0) {
        final nextPageStocks = await fetchPurchasesByPage(_currentPage - 1);
        setState(() {
          _currentPage--;
          purchases = nextPageStocks;
          //    filteredStocks = stocks;
        });
      }
    } catch (e) {
      // Handle error
    }
  }

  void _goToNextPage() async {
    try {
      if (_currentPage + 1 < totalPages) {
        final nextPageStocks = await fetchPurchasesByPage(_currentPage + 1);
        setState(() {
          //  _stocks.addAll(nextPageStocks);
          //filteredStocks = _stocks;
          purchases = nextPageStocks;
          _currentPage++;
        });
      } else {}
    } catch (e) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sales List'),
      ),
      body: Column(
        children: [
          // Padding(
          //   padding: const EdgeInsets.all(8.0),
          //   child: TextField(
          //     controller: searchController,
          //     decoration: InputDecoration(
          //       hintText: 'Search purchases...',
          //       prefixIcon: Icon(Icons.search),
          //     ),
          //     onChanged: searchPurchases,
          //   ),
          // ),
          Expanded(
            child: ListView.builder(
              itemCount: purchases.length,
              itemBuilder: (BuildContext context, int index) {
                final purchase = purchases[index];
                return ListTile(
                  title: Text('Stock Name: ${purchase['stockName']}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Price: \$${purchase['price']}'),
                      Text('Quantity: ${purchase['quantity']}'),
                      Text('Date: ${purchase['date']}'),
                    ],
                  ),
                  // onTap: () {
                  //   Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //       builder: (context) => DebtPaymentPage2(
                  //         client: widget.selectedClient,
                  //       ),
                  //     ),
                  //   );
                  // },
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
              Text('Page ${page + 1}'),
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
