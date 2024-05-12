import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/DebtPaymentPage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/api/checkLoginStatus.dart';

class ClientsPurcDoPage extends StatefulWidget {
  final dynamic selectedClient;
  ClientsPurcDoPage({required this.selectedClient});
  @override
  _ClientsPurcDoPageState createState() => _ClientsPurcDoPageState();
}

class _ClientsPurcDoPageState extends State<ClientsPurcDoPage> {
  List<dynamic> purchases = [];
  List<dynamic> filteredPurchases = [];
  TextEditingController searchController = TextEditingController();
  int page = 0;

  @override
  void initState() {
    super.initState();
    fetchPurchasesByPage(page);
  }

  Future<void> fetchPurchasesByPage(int page) async {
    final response = await http.get(
      Uri.parse(
          'http://192.168.1.122:8080/api/getPurchaseInvoiceClientByPage?page=$page&client_id=${widget.selectedClient['clientId']}'),
      headers: <String, String>{
        'Authorization': 'Bearer ${await getTokenFromLocalStorage()}'
      },
    );
    if (response.statusCode == 200) {
      setState(() {
        purchases = jsonDecode(utf8.decode(response.bodyBytes));
        filteredPurchases = List.from(purchases);
      });
    } else {
      // Handle errors
      print('Failed to fetch purchases: ${response.statusCode}');
    }
  }

  void searchPurchases(String query) {
    setState(() {
      filteredPurchases = purchases.where((purchase) {
        final stockName = purchase['stockName'].toString().toLowerCase();
        return stockName.contains(query.toLowerCase());
      }).toList();
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Purchases List'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search purchases...',
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
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DebtPaymentPage(
                          client: widget.selectedClient,
                        ),
                      ),
                    );
                  },
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
