import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/theme.dart';
import 'package:flutter_application_1/pages/Appbar.dart';

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
  late Future<List<dynamic>> _stocksFuture;
  List<dynamic> _stocks = [];
  final int pageSize = 6; // Sayfa başına gösterilecek stok sayısı

  int page = 0;
  int _currentPage = 0;
  bool isLoading = false;
  List<dynamic> warehouseNames = []; // Warehouse isimleri buraya eklenecek.

  TextEditingController searchController = TextEditingController();
  String selectedWarehouseFilter = 'All';
  late Future<List<dynamic>> _ssFuture;

  @override
  void initState() {
    super.initState();
    searchController.clear();
    _ssFuture = getNames();
    _stocksFuture = _initializeState();
  }

  Future<List<dynamic>> _initializeState() async {
    await _ssFuture;
    return _fetchStocks(page);
  }

  Future<List<dynamic>> getNames() async {
    final url = 'http://${await loadIP()}:8080/api/getWarehouseName';
    final response = await http.get(Uri.parse(url), headers: <String, String>{
      'Authorization': 'Bearer ${await getTokenFromLocalStorage()}'
    });
    if (response.statusCode == 200) {
      final utf8Body = utf8.decode(response.bodyBytes);
      warehouseNames.add("All");
      warehouseNames.addAll(
        (jsonDecode(utf8Body) as List<dynamic>)
            .map((e) => e as String)
            .toSet()
            .toList(),
      );
      selectedWarehouseFilter = warehouseNames[1];
    }

    return warehouseNames;
  }

  late int totalPages;
  Future<List<dynamic>> _fetchStocks(int page) async {
    String url;
    if (selectedWarehouseFilter == "All") {
      url = searchController.text.isEmpty
          ? 'http://${await loadIP()}:8080/api/getWarehouseStockByPage?page=$page&size=$pageSize'
          : 'http://${await loadIP()}:8080/api/getWarehouseStockBySearch?keyword=${searchController.text}&page=$page&size=$pageSize';
    } else {
      url =
          'http://${await loadIP()}:8080/api/getWarehouseStockBySearchAndWarehouse?warehouse=${selectedWarehouseFilter}&keyword=${searchController.text}&page=$page&size=$pageSize';
    }

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

  void _applyWarehouseFilter(String warehouse) async {
    _currentPage = 0;
    setState(() {
      _stocksFuture = _fetchStocks(_currentPage);
    });
  }

  void _goToPreviousPage() async {
    if (_currentPage > 0) {
      setState(() {
        _currentPage--;
        _stocksFuture = _fetchStocks(_currentPage);
      });
    }
  }

  void _goToNextPage() async {
    if (_currentPage + 1 < totalPages) {
      setState(() {
        _currentPage++;
        _stocksFuture = _fetchStocks(_currentPage);
      });
    }
  }

  void searchStocks(String query) {
    setState(() {
      _currentPage = 0;
      _stocksFuture = _fetchStocks(_currentPage);
    });
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

  void _changeStatus(dynamic stock) async {
    final url =
        'http://${await loadIP()}:8080/api/setStatus?stockId=${stock['stock']['stockId']}';
    final response = await http.post(Uri.parse(url), headers: <String, String>{
      'Authorization': 'Bearer ${await getTokenFromLocalStorage()}'
    });
    if (response.statusCode == 200) {
      setState(() {
        _stocksFuture = _fetchStocks(_currentPage);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${response.body}')),
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
      appBar: CustomAppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color.fromARGB(255, 0, 0, 0)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: 'Stocks Page',
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
                        fillColor: Colors.white,
                        filled: true,
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
                  SizedBox(
                      width:
                          16.0), // Adding space between search field and dropdown
                  FutureBuilder<List<dynamic>>(
                    future: _ssFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(child: Text('No stocks found'));
                      } else {
                        // Assuming warehouseNames is a List<dynamic> initialized elsewhere
                        warehouseNames = snapshot.data!;
                        return DropdownButton<dynamic>(
                          value: selectedWarehouseFilter,
                          items: warehouseNames.map((dynamic value) {
                            return DropdownMenuItem<dynamic>(
                              value: value,
                              child: Text(value.toString()),
                            );
                          }).toList(),
                          onChanged: (dynamic newValue) {
                            setState(() {
                              selectedWarehouseFilter = newValue!;
                              _applyWarehouseFilter(selectedWarehouseFilter);
                            });
                          },
                        );
                      }
                    },
                  ),
                ],
              )),
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _stocksFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No stocks found'));
                } else {
                  _stocks = snapshot.data!;
                  return Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: _stocks.length,
                          itemBuilder: (context, index) {
                            final stock = _stocks[index];
                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(
                                  color: Color.fromARGB(255, 174, 174, 174),
                                  width: 1,
                                ),
                              ),
                              margin: EdgeInsets.symmetric(
                                  vertical: 7.0, horizontal: 10),
                              elevation: 2,
                              color: index % 2 == 0
                                  ? const Color.fromARGB(255, 255, 255, 255)
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
                                            "Stock Code: " +
                                                stock['stock']['stockCode'] +
                                                " Barcode: " +
                                                stock['stock']['barcode'],
                                            style: TextStyle(
                                                color: Color.fromARGB(
                                                    255, 81, 81, 81)),
                                          ),
                                          Text(
                                            'Quantity: ${stock['stock']['unitType']}:${(stock['quantityRemaining'] / stock['stock']['unit']).toStringAsFixed(2)} Piece:${stock['quantityRemaining']}',
                                            style: TextStyle(
                                                color: Color.fromARGB(
                                                    255, 255, 77, 0)),
                                          ),
                                          Text(
                                            'Type: ${stock['stock']['unitType']}|${stock['stock']['unit']}',
                                            style: TextStyle(
                                                color: Color.fromARGB(
                                                    255, 1, 50, 128)),
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
                                  Row(
                                    children: [
                                      Text(
                                        stock['stock']['statusStock']
                                                    .toString() ==
                                                'false'
                                            ? 'Active'
                                            : 'Pasive',
                                        style: TextStyle(
                                          color: stock['stock']['statusStock']
                                                      .toString() ==
                                                  'false'
                                              ? Colors.green
                                              : Colors.red,
                                        ),
                                      ),
                                      IconButton(
                                        icon:
                                            Icon(Icons.change_circle_outlined),
                                        onPressed: () async {
                                          _changeStatus(stock);
                                        },
                                      ),
                                    ],
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
