import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Add this import statement for HTTP requests
import 'package:flutter_application_1/pages/DailyExpensesPage.dart'; // Import SalesList.dart
// Add the necessary imports
import 'package:flutter_application_1/api/checkLoginStatus.dart';

import 'package:flutter_application_1/pages/DailyExpensesPage.dart'; // Satış Listesi sayfasını içeri aktar
// HTTP istekleri için bu import ifadesini ekle
// Gerekli import ifadelerini ekle

class NotificationsPage extends StatefulWidget {
  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  List<dynamic>? _warehouseTransfers; // Depo transferlerini tutar
  List<dynamic>? _expenses; // Harcamaları tutar
  List<dynamic>? _purchases; // Satın almaları tutar
  List<dynamic>? _clients;
  List<dynamic>? _stocks;

  // Seçilen tarihe göre günlük harcamaları getir
  Future<void> _getDailyExpenses(String selectedDate) async {
    final response = await http.get(
        Uri.parse(
            'http://192.168.1.102:8080/api/getDailyExpenses?date=$selectedDate'),
        headers: <String, String>{
          'Authorization': 'Bearer ${await getTokenFromLocalStorage()}'
        });

    if (response.statusCode == 200) {
      List<dynamic> expenses = jsonDecode(utf8.decode(response.bodyBytes));
      setState(() {
        _warehouseTransfers = expenses
            .where((expense) => expense.containsKey('warehousetransfer_id'))
            .toList(); // Depo transferlerini filtrele
        _expenses = expenses
            .where((expense) => expense.containsKey('expense_id'))
            .toList(); // Harcamaları filtrele
        _purchases = expenses
            .where((expense) => expense.containsKey('purchase_id'))
            .toList(); // Satın almaları filtrele
        _clients = expenses
            .where((expense) => expense.containsKey('client_id'))
            .toList();
        _stocks = expenses
            .where((expense) => expense.containsKey('stock_id'))
            .toList();
      });
    } else {
      // Hata durumunda bir şey yapılabilir
    }
  }

  // Günlük harcamalar sayfasına geçiş yap
  void _navigateToDailyExpensesPage(String selectedDate) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DailyExpensesPage(
          selectedDate: selectedDate,
          warehouseTransfers: _warehouseTransfers,
          expenses: _expenses,
          purchases: _purchases,
          clients: _clients,
          stocks: _stocks,
        ),
      ),
    );
  }

  TextEditingController dateController = TextEditingController();
  TextEditingController dateController2 = TextEditingController();

  Future<void> _getWeeklyPurchaseInvoices() async {
    final response = await http.get(
      Uri.parse(
          'http://192.168.1.102:8080/api/getWeeklyPurchaseInvoices?startDate=${dateController.text}&endDate=${dateController2.text}'),
      headers: <String, String>{
        'Authorization': 'Bearer ${await getTokenFromLocalStorage()}'
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> _weeklyPurchaseInvoices =
          jsonDecode(utf8.decode(response.bodyBytes));
      setState(() {
        setState(() {
          _warehouseTransfers = _weeklyPurchaseInvoices
              .where((expense) => expense.containsKey('warehousetransfer_id'))
              .toList(); // Depo transferlerini filtrele
          _expenses = _weeklyPurchaseInvoices
              .where((expense) => expense.containsKey('expense_id'))
              .toList(); // Harcamaları filtrele
          _purchases = _weeklyPurchaseInvoices
              .where((expense) => expense.containsKey('purchase_id'))
              .toList(); // Satın almaları filtrele
          _clients = _weeklyPurchaseInvoices
              .where((expense) => expense.containsKey('client_id'))
              .toList();
          _stocks = _weeklyPurchaseInvoices
              .where((expense) => expense.containsKey('stock_id'))
              .toList();
        });
      });
    } else {
      // Hata durumunda bir şey yapılabilir
    }
  }

  late String formattedDate2;
  late String formattedDate;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'), // Bildirimler başlığı
      ),
      body: Center(
        child: Column(children: [
          Text('Get Daily Report'),
          TableCalendar(
              firstDay: DateTime.utc(2021, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) async {
                if (true) {
                  // Eğer istenirse
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                  String formattedDate =
                      "${selectedDay.year}-${selectedDay.month.toString().padLeft(2, '0')}-${selectedDay.day.toString().padLeft(2, '0')}";
                  await _getDailyExpenses(
                      formattedDate); // Günlük harcamaları getir
                  _navigateToDailyExpensesPage(
                      formattedDate); // Harcamalar sayfasına geçiş yap
                }
              },
              onFormatChanged: (format) {
                if (_calendarFormat != format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                }
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              }),
          SizedBox(height: 25),
          Text('Get Bettween Times Report'),
          TextField(
            controller: dateController,
            decoration: const InputDecoration(
                icon: Icon(Icons.calendar_today), labelText: "Enter Date 1"),
            readOnly: true,
            onTap: () async {
              DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101));

              if (pickedDate != null) {
                print(pickedDate);
                formattedDate =
                    "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                print(formattedDate);

                setState(() {
                  dateController.text = formattedDate;
                });
              } else {
                print("Date is not selected");
              }
            },
          ),
          TextField(
            controller: dateController2,
            decoration: const InputDecoration(
                icon: Icon(Icons.calendar_today), labelText: "Enter Date 2"),
            readOnly: true,
            onTap: () async {
              DateTime? pickedDate2 = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101));

              if (pickedDate2 != null) {
                print(pickedDate2);
                formattedDate2 =
                    "${pickedDate2.year}-${pickedDate2.month.toString().padLeft(2, '0')}-${pickedDate2.day.toString().padLeft(2, '0')}";
                print(formattedDate2);

                setState(() {
                  dateController2.text = formattedDate2;
                });
              } else {
                print("Date is not selected");
              }
            },
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              await _getWeeklyPurchaseInvoices();
              _navigateToDailyExpensesPage(
                  formattedDate + "|" + formattedDate2);
            },
            child: Text('Get Report'),
          ),
        ]),
      ),
    );
  }
}
