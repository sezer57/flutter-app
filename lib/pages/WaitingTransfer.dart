import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async'; // Eklemeyi unutmayın
import 'package:flutter_application_1/api/checkLoginStatus.dart';

class WaitingTransfer extends StatefulWidget {
  @override
  _WaitingTransferState createState() => _WaitingTransferState();
}

class _WaitingTransferState extends State<WaitingTransfer> {
  List<dynamic> _waitingTransfers = [];
  bool _isMounted = false;

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    _fetchWaitingTransfers();
  }

  @override
  void dispose() {
    _isMounted = false;
    super.dispose();
  }

  Future<void> _fetchWaitingTransfers() async {
    final response = await http.get(
        Uri.parse(
            'http://${await loadIP()}:8080/api/warehouseStock/get_waiting_transfer'),
        headers: <String, String>{
          'Authorization': 'Bearer ${await getTokenFromLocalStorage()}'
        });

    if (_isMounted && response.statusCode == 200) {
      setState(() {
        _waitingTransfers = jsonDecode(utf8.decode(response.bodyBytes));
      });
    } else if (_isMounted) {
      throw Exception('Failed to fetch waiting transfers');
    }
  }

  Future<void> _updateTransferStatus(String id, String status) async {
    final response = await http.patch(
        Uri.parse(
            'http://${await loadIP()}:8080/api/$id/approvelStatus?status=$status'),
        headers: <String, String>{
          'Authorization': 'Bearer ${await getTokenFromLocalStorage()}'
        });

    if (_isMounted && response.statusCode == 200) {
      // Successfully updated transfer status, fetch waiting transfers again
      _fetchWaitingTransfers();
    } else if (_isMounted) {
      throw Exception('Failed to update transfer status');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Waiting Transfers'),
      ),
      body: ListView.builder(
        itemCount: _waitingTransfers.length,
        itemBuilder: (context, index) {
          var transfer = _waitingTransfers[index];

          return Card(
            child: ListTile(
              title: Text('Transfer ID: ${transfer['id']}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('From: ${transfer['source']}'),
                  Text('To: ${transfer['target']}'),
                  Text('Quantity: ${transfer['quantity']}'),
                  Text('Approvel Status: ${transfer['approvelstatus']}'),
                  Text('Transfer Date: ${transfer['date']}'),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _updateTransferStatus(transfer['id'], 'onay');
                    },
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.green)),
                    child: Text(
                      'Approve',
                      style: TextStyle(
                          color: Colors.white), // Set text color explicitly
                    ),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      _updateTransferStatus(transfer['id'], 'red');
                    },
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.red)),
                    child: Text(
                      'Deny',
                      style: TextStyle(
                          color: Colors.white), // Set text color explicitly
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
