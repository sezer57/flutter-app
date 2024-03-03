import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/UpdateStockPage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async'; // Eklemeyi unutmayın

class StockPage extends StatefulWidget {
  @override
  _StockPageState createState() => _StockPageState();
}

class _StockPageState extends State<StockPage> {
  List<dynamic> stocks = [];
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _fetchStocks();

    // Initialize the timer and call _fetchStocks every 5 seconds
    _timer = Timer.periodic(Duration(seconds: 5), (Timer t) => _fetchStocks());
  }

  @override
  void dispose() {
    // Cancel the timer when the widget is disposed
    _timer.cancel();
    super.dispose();
  }

  Future<void> _fetchStocks() async {
    final response = await http
        .get(Uri.parse('http://192.168.1.105:8080/api/getWarehouseStock'));

    if (response.statusCode == 200) {
      setState(() {
        stocks = json.decode(utf8.decode(response.bodyBytes));
      });
    } else {
      throw Exception('Failed to fetch stocks');
    }
  }

  void _navigateToUpdateStockPage(int stockId, String stockName) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            UpdateStockForm(stockId: stockId, stockName: stockName),
      ),
    );

    if (result == true) {
      // Refresh the stock list if a new stock was added
      _fetchStocks();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stocks Page'),
      ),
      body: Center(
        child: stocks.isEmpty
            ? CircularProgressIndicator()
            : ListView.builder(
                itemCount: stocks.length,
                itemBuilder: (context, index) {
                  final stock = stocks[index];
                  return Card(
                    color: index % 2 == 0
                        ? Colors.grey[200]
                        : Colors.white, // Alternate row colors
                    child: ListTile(
                      title: Text(
                        stock['stock']['stockName'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.blue, // Text color for stock name
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Quantity In: ${stock['quantityIn']}',
                            style: TextStyle(
                                color:
                                    Colors.green), // Text color for quantity in
                          ),
                          Text(
                            'Quantity Out: ${stock['quantityOut']}',
                            style: TextStyle(
                                color:
                                    Colors.red), // Text color for quantity out
                          ),
                          Text(
                            'Quantity Remaining: ${stock['quantityRemaining']}',
                            style: TextStyle(
                                color: Colors
                                    .orange), // Text color for quantity remaining
                          ),
                          Text(
                            'Warehouse: ${stock['warehouse']['name']}',
                            style: TextStyle(
                                color: Colors.grey[
                                    600]), // Text color for warehouse name
                          ),
                        ],
                      ),
                      onTap: () {
                        _navigateToUpdateStockPage(
                          stock['stock']['stockId'],
                          stock['stock']['stockName'],
                        );
                      },
                    ),
                  );
                },
              ),
      ),
    );
  }
}
