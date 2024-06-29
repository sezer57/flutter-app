import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:flutter_application_1/api/checkLoginStatus.dart';
import 'package:flutter_application_1/pages/UpdateStockPage.dart';
import 'package:flutter_application_1/pages/StockDetailesPageList.dart';

class StockPage extends StatefulWidget {
  @override
  _StockPageState createState() => _StockPageState();
}

class _StockPageState extends State<StockPage> {
  List<dynamic> _stocks = [];
  final int pageSize = 6; // Sayfa başına gösterilecek stok sayısı

  int page = 0;
  int _currentPage = 0;
  bool isLoading = false;
  List<String> warehouseNames = ['All']; // Warehouse isimleri buraya eklenecek.

  TextEditingController searchController = TextEditingController();
  String selectedWarehouseFilter = 'All';
  //late Timer _timer;

  @override
  void initState() {
    super.initState();
    getnamse();
    _fetchStocks(page).then((stocks) async {
      setState(() {
        _stocks = stocks;
      });
    });
    // _timer = Timer.periodic(Duration(seconds: 5), (Timer t) => _fetchStocks());
  }

  @override
  void dispose() {
    // _timer.cancel();
    super.dispose();
  }

  void getnamse() async {
    final url = 'http://${await loadIP()}:8080/api/getWarehouseName';
    final response = await http.get(Uri.parse(url), headers: <String, String>{
      'Authorization': 'Bearer ${await getTokenFromLocalStorage()}'
    });
    if (response.statusCode == 200) {
      final utf8Body = utf8.decode(response.bodyBytes);
      warehouseNames.addAll(
        (jsonDecode(utf8Body) as List<dynamic>)
            .map((e) => e as String)
            .toSet()
            .toList(),
      );
    }
  }

  late int totalPages;
  Future<List<dynamic>> _fetchStocks(int page) async {
    if (selectedWarehouseFilter == "All") {
      final url = searchController.text.isEmpty
          ? 'http://${await loadIP()}:8080/api/getWarehouseStockByPage?page=$page&size=$pageSize'
          : 'http://${await loadIP()}:8080/api/getWarehouseStockBySearch?keyword=${searchController.text}&page=$page&size=$pageSize';

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
    } else {
      final url =
          'http://${await loadIP()}:8080/api/getWarehouseStockBySearchAndWarehouse?warehouse=${selectedWarehouseFilter}&keyword=${searchController.text}&page=$page&size=$pageSize';

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
  }

  void _applyWarehouseFilter(String warehouse) async {
    _currentPage = 0;
    _fetchStocks(_currentPage).then((stocks) async => setState(() {
          _stocks = stocks;
        }));
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

  void _navigateToUpdateStockPage(dynamic stock) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StockDetailesPageList(stock),
      ),
    );

    if (result == true) {
      _fetchStocks(page);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stocks Page'),
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
                DropdownButton<String>(
                  value: selectedWarehouseFilter,
                  items: warehouseNames.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedWarehouseFilter = newValue!;
                      _applyWarehouseFilter(selectedWarehouseFilter);
                    });
                  },
                ),
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
                          itemBuilder: (context, index) {
                            final stock = _stocks[index];
                            return Card(
                              color: index % 2 == 0
                                  ? Colors.grey[200]
                                  : Colors.white,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: ListTile(
                                      title: Text(
                                        stock['stock']['stockName'],
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.blue,
                                        ),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Quantity Remaining: ${stock['quantityRemaining']}',
                                            style:
                                                TextStyle(color: Colors.orange),
                                          ),
                                          Text(
                                            'Quantity Transfer: ${stock['quantityTransfer']}',
                                            style: TextStyle(
                                                color: Color.fromARGB(
                                                    255, 136, 112, 245)),
                                          ),
                                          Text(
                                            'Warehouse: ${stock['warehouse']['name']}',
                                            style: TextStyle(
                                                color: Colors.grey[600]),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: () async {
                                      _navigateToUpdateStockPage(stock);
                                    },
                                  ),
                                ],
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
