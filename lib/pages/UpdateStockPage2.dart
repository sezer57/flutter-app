import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UpdateStockForm extends StatefulWidget {
  final int stockId;
  final String stockName;
  const UpdateStockForm(
      {Key? key, required this.stockId, required this.stockName})
      : super(key: key);

  @override
  _UpdateStockFormState createState() => _UpdateStockFormState();
}

class _UpdateStockFormState extends State<UpdateStockForm> {
  TextEditingController quantityInController = TextEditingController();
  TextEditingController quantityOutController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Material(
      // Wrap with Material widget
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Product Name: " + widget.stockName),
            TextField(
              controller: quantityInController,
              decoration: InputDecoration(labelText: 'Quantity In'),
            ),
            TextField(
              controller: quantityOutController,
              decoration: InputDecoration(labelText: 'Quantity Out'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                _updateQuantities();
              },
              child: Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateQuantities() async {
    int quantityIn = int.tryParse(quantityInController.text) ?? 0;
    int quantityOut = int.tryParse(quantityOutController.text) ?? 0;
    String urlQuantityIn =
        'http://192.168.1.105:8080/api/${widget.stockId}/updateQuantityIn?quantityIn=$quantityIn';
    String urlQuantityOut =
        'http://192.168.1.105:8080/api/${widget.stockId}/updateQuantityOut?quantityOut=$quantityOut';

    try {
      final responseQuantityIn = await http.patch(Uri.parse(urlQuantityIn));
      final responseQuantityOut = await http.patch(Uri.parse(urlQuantityOut));

      if (responseQuantityIn.statusCode == 200 &&
          responseQuantityOut.statusCode == 200) {
        // Handle successful update
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Quantities updated successfully'),
            duration: Duration(seconds: 4),
          ),
        );

        // Navigate back to the stock page
        Navigator.pop(context, true);
      } else {
        // Handle unsuccessful update
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update quantities'),
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      // Handle errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
