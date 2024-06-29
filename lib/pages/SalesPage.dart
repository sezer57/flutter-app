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
  final int pageSize = 6;
  dynamic selectedStock;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchStocks(page).then((stocks) async {
      setState(() {
        _stocks = stocks;
      });
    });
  }

  late int totalPages;
  Future<List<dynamic>> _fetchStocks(int page) async {
    final url = searchController.text.isEmpty
        ? 'http://${await loadIP()}:8080/api/getStockWithIdProductByPage?page=$page&warehouse_id=${widget.selectedSourceWarehouse}&size=$pageSize'
        : 'http://${await loadIP()}:8080/api/getStockWithIdProductByPageSearch?keyword=${searchController.text}&warehouse_id=${widget.selectedSourceWarehouse}&page=$page&size=$pageSize';

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

  void searchStocks(String query) {
    setState(() {
      _currentPage = 0;
      _fetchStocks(_currentPage).then((stocks) async {
        setState(() {
          _stocks = stocks;
        });
      });
    });
  }

  void _goToPreviousPage() async {
    try {
      if (_currentPage > 0) {
        final nextPageStocks = await _fetchStocks(_currentPage - 1);
        setState(() {
          _currentPage--;
          _stocks = nextPageStocks;
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
        final nextPageStocks = await _fetchStocks(_currentPage + 1);
        setState(() {
          //  _stocks.addAll(nextPageStocks);
          //filteredStocks = _stocks;
          _stocks = nextPageStocks;
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
                      hintText: 'Search stocks...',
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
              future: _fetchStocks(page),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
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
                                subtitle: Text(
                                    'Sales Price: \$${stock['salesPrice']}' +
                                        " Warehouse: ${stock['warehouse']['name']}"),
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
                          Text('Page ${page + 1}'),
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
