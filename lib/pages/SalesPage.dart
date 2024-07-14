import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/api/checkLoginStatus.dart';

class SalesPage extends StatefulWidget {
  final String? selectedSourceWarehouse;
  SalesPage({required this.selectedSourceWarehouse});

  @override
  State<SalesPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SalesPage> {
  int page = 0;
  int _currentPage = 0;
  bool isLoading = false;
  List<dynamic> _stocks = [];
  late Future<List<dynamic>> _stocksFuture;
  final int pageSize = 6;
  dynamic selectedStock;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _stocksFuture = _fetchStocks(_currentPage);
  }

  late int totalPages;
  Future<List<dynamic>> _fetchStocks(int page) async {
    final url = searchController.text.isEmpty
        ? 'http://${await loadIP()}:8080/api/getStocksById?page=$page&warehouse_id=${widget.selectedSourceWarehouse}&size=$pageSize'
        : 'http://${await loadIP()}:8080/api/getStocksByIdSearch?keyword=${searchController.text}&warehouse_id=${widget.selectedSourceWarehouse}&page=$page&size=$pageSize';

    final response = await http.get(Uri.parse(url), headers: <String, String>{
      'Authorization': 'Bearer ${await getTokenFromLocalStorage()}'
    });

    if (response.statusCode == 200) {
      final utf8Body = utf8.decode(response.bodyBytes);
      final decodedBody = jsonDecode(utf8Body);
      totalPages = decodedBody['totalPages'];

      return decodedBody['content'];
    } else {
      print(response.statusCode);
      return List.empty();
    }
  }

  void searchStocks(String query) {
    setState(() {
      _currentPage = 0;
      _stocksFuture = _fetchStocks(_currentPage);
    });
  }

  void _goToPreviousPage() {
    if (_currentPage > 0) {
      setState(() {
        _currentPage--;
        _stocksFuture = _fetchStocks(_currentPage);
      });
    }
  }

  void _goToNextPage() {
    if (_currentPage + 1 < totalPages) {
      setState(() {
        _currentPage++;
        _stocksFuture = _fetchStocks(_currentPage);
      });
    }
  }

  void _changeStatus(dynamic stock) async {
    final url =
        'http://${await loadIP()}:8080/api/setStatus?stockId=${stock['stockId']}';
    final response = await http.post(Uri.parse(url), headers: <String, String>{
      'Authorization': 'Bearer ${await getTokenFromLocalStorage()}'
    });
    if (response.statusCode == 200) {
      setState(() {
        _stocksFuture = _fetchStocks(_currentPage);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${response.body}  ')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('${response.body}. Error: ${response.statusCode}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search stocks...'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Select stocks...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 14.0),
                    ),
                    onChanged: searchStocks,
                  ),
                ),
                SizedBox(width: 10),
              ],
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
                  return Center(child: Text('No sales list found'));
                } else {
                  _stocks = snapshot.data!;
                  return Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: _stocks.length,
                          itemBuilder: (BuildContext context, int index) {
                            final stock = _stocks[index];
                            return Card(
                              child: ListTile(
                                title:
                                    Text('Stock Name: ${stock['stockName']}'),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Sales Price: \ ${stock['salesPrice']}',
                                      style: TextStyle(
                                          fontSize: 15,
                                          color:
                                              Color.fromARGB(255, 118, 32, 26)),
                                    ),
                                    Text(
                                      'Quantity: ${stock['quantity'].toStringAsFixed(2)} Piece:${stock['quantity_remaing']}',
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Color.fromARGB(255, 54, 98, 244),
                                      ),
                                    ),
                                    Text(
                                      'Type: ${stock['type']}/${stock['typeS']}',
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Color.fromARGB(255, 54, 98, 244),
                                      ),
                                    ),

                                    // Icon(
                                    //   stock['statusStock'].toString() !=
                                    //           'false'
                                    //       ? Icons.check_circle
                                    //       : Icons.cancel,
                                    //   color:
                                    //       stock['statusStock'].toString() !=
                                    //               'false'
                                    //           ? Colors.green
                                    //           : Colors.red,
                                    // ),
                                    // SizedBox(width: 4),
                                    Text(
                                      stock['statusStock'].toString() == 'false'
                                          ? 'Active'
                                          : 'Pasive',
                                      style: TextStyle(
                                        color:
                                            stock['statusStock'].toString() ==
                                                    'false'
                                                ? Colors.green
                                                : Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  setState(() {
                                    selectedStock = stock;
                                  });
                                  Navigator.pop(context, selectedStock);
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
