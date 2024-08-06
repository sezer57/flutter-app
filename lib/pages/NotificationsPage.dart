import 'dart:io' show Platform;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/Appbar.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_application_1/components/theme.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
// Import your DailyExpensesPage.dart and other necessary files
import 'package:flutter_application_1/pages/DailyExpensesPage.dart';
import 'package:flutter_application_1/api/checkLoginStatus.dart';

class NotificationsPage extends StatefulWidget {
  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  List<dynamic>? _warehouseTransfers;
  List<dynamic>? _expenses;
  List<dynamic>? _purchases;
  List<dynamic>? _clients;
  List<dynamic>? _stocks;

  Future<void> _getDailyExpenses(String selectedDate) async {
    final response = await http.get(
      Uri.parse(
          'http://${await loadIP()}:8080/api/getDailyExpenses?date=$selectedDate'),
      headers: <String, String>{
        'Authorization': 'Bearer ${await getTokenFromLocalStorage()}'
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> expenses = jsonDecode(utf8.decode(response.bodyBytes));

      setState(() {
        _warehouseTransfers = expenses
            .where((expense) => expense.containsKey('warehousetransfer_id'))
            .toList();
        _expenses = expenses
            .where((expense) => expense.containsKey('expense_id'))
            .toList();
        _purchases = expenses
            .where((expense) => expense.containsKey('purchase_id'))
            .toList();
        _clients = expenses
            .where((expense) => expense.containsKey('client_id'))
            .toList();
        _stocks = expenses
            .where((expense) => expense.containsKey('stock_id'))
            .toList();
      });
    } else {
      // Handle error
    }
  }

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
          'http://${await loadIP()}:8080/api/getWeeklyPurchaseInvoices?startDate=${dateController.text}&endDate=${dateController2.text}'),
      headers: <String, String>{
        'Authorization': 'Bearer ${await getTokenFromLocalStorage()}'
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> _weeklyPurchaseInvoices =
          jsonDecode(utf8.decode(response.bodyBytes));
      setState(() {
        _warehouseTransfers = _weeklyPurchaseInvoices
            .where((expense) => expense.containsKey('warehousetransfer_id'))
            .toList();
        _expenses = _weeklyPurchaseInvoices
            .where((expense) => expense.containsKey('expense_id'))
            .toList();
        _purchases = _weeklyPurchaseInvoices
            .where((expense) => expense.containsKey('purchase_id'))
            .toList();
        _clients = _weeklyPurchaseInvoices
            .where((expense) => expense.containsKey('client_id'))
            .toList();
        _stocks = _weeklyPurchaseInvoices
            .where((expense) => expense.containsKey('stock_id'))
            .toList();
      });
    } else {
      // Handle error
    }
  }

  late String formattedDate2;
  late String formattedDate;

  Widget _buildCalendarOrDatePicker() {
    if (Platform.isIOS) {
      // Use CupertinoDatePicker for iOS
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 150, // Example height, adjust as needed
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.date,
              initialDateTime: DateTime.now(),
              onDateTimeChanged: (DateTime newDateTime) {
                setState(() {
                  _selectedDay = newDateTime;
                });
              },
            ),
          ),
          SizedBox(height: 12), // Add spacing between date picker and button
          ElevatedButton(
            onPressed: () async {
              String formattedDate =
                  DateFormat('yyyy-MM-ddTHH:mm:ss').format(_selectedDay);
              await _getDailyExpenses(formattedDate);
              _navigateToDailyExpensesPage(formattedDate);
            },
            child: Text('Get Daily Report'),
          ),
        ],
      );
    } else {
      // Use TableCalendar for other platforms
      return TableCalendar(
        firstDay: DateTime.utc(2021, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        selectedDayPredicate: (day) {
          return isSameDay(_selectedDay, day);
        },
        onDaySelected: (selectedDay, focusedDay) async {
          //  print(selectedDay);
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
          String formattedDate =
              DateFormat('yyyy-MM-ddTHH:mm:ss').format(selectedDay);

          // String formattedDate =
          //     "${selectedDay.year}-${selectedDay.month.toString().padLeft(2, '0')}-${selectedDay.day.toString().padLeft(2, '0')}";
          await _getDailyExpenses(formattedDate);
          _navigateToDailyExpensesPage(formattedDate);
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
        },
      );
    }
  }

  DateTime _selectedDate1 = DateTime.now(); // Define _selectedDate1
  DateTime _selectedDate2 = DateTime.now(); // Define _selectedDate2

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color.fromARGB(255, 0, 0, 0)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: 'Notifications',
      ),
      body: Center(
        child: Column(
          children: [
            Text('Get Daily Reports'),
            _buildCalendarOrDatePicker(),
            SizedBox(height: 25),
            Text('Get Between Times Report'),
            TextField(
              controller: dateController,
              decoration: const InputDecoration(
                icon: Icon(Icons.calendar_today),
                labelText: "Enter Date 1",
              ),
              readOnly: true,
              onTap: () async {
                DateTime? pickedDate;
                if (Platform.isIOS) {
                  pickedDate = await showCupertinoModalPopup<DateTime>(
                    context: context,
                    builder: (BuildContext context) {
                      return Container(
                        height: 200,
                        child: CupertinoDatePicker(
                          mode: CupertinoDatePickerMode.date,
                          initialDateTime: DateTime.now(),
                          onDateTimeChanged: (DateTime newDateTime) {
                            formattedDate = DateFormat('yyyy-MM-ddTHH:mm:ss')
                                .format(newDateTime);

                            setState(() {
                              dateController.text = formattedDate;
                            });
                          },
                        ),
                      );
                    },
                  );
                } else {
                  DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101));

                  if (pickedDate != null) {
                    formattedDate =
                        DateFormat('yyyy-MM-ddTHH:mm:ss').format(pickedDate);

                    setState(() {
                      dateController.text = formattedDate;
                    });
                  }
                }
              },
            ),
            SizedBox(height: 20),
            TextField(
              controller: dateController2,
              decoration: const InputDecoration(
                icon: Icon(Icons.calendar_today),
                labelText: "Enter Date 2",
              ),
              readOnly: true,
              onTap: () async {
                DateTime? pickedDate2;
                if (Platform.isIOS) {
                  pickedDate2 = await showCupertinoModalPopup<DateTime>(
                    context: context,
                    builder: (BuildContext context) {
                      return Container(
                        height: 200,
                        child: CupertinoDatePicker(
                          mode: CupertinoDatePickerMode.date,
                          initialDateTime: DateTime.now(),
                          onDateTimeChanged: (DateTime newDateTime) {
                            DateTime endDate = DateTime(newDateTime.year,
                                newDateTime.month, newDateTime.day, 23, 59, 59);
                            String formattedDate2 =
                                DateFormat('yyyy-MM-ddTHH:mm:ss')
                                    .format(endDate);
                            setState(() {
                              dateController2.text = formattedDate2;
                            });
                          },
                        ),
                      );
                    },
                  );
                } else {
                  DateTime? pickedDate2 = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101));

                  if (pickedDate2 != null) {
                    DateTime endDate = DateTime(pickedDate2.year,
                        pickedDate2.month, pickedDate2.day, 23, 59, 59);
                    String formattedDate2 =
                        DateFormat('yyyy-MM-ddTHH:mm:ss').format(endDate);
                    setState(() {
                      dateController2.text = formattedDate2;
                    });
                  }
                }
              },
            ),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                // You can use _selectedDate1 and _selectedDate2 directly here
                // or format them into strings if needed

                String formattedDate1 =
                    DateFormat('yyyy-MM-ddTHH:mm:ss').format(_selectedDate1);

                DateTime endDate = DateTime(_selectedDate2.year,
                    _selectedDate2.month, _selectedDate2.day, 23, 59, 59);
                String formattedDate2 =
                    DateFormat('yyyy-MM-ddTHH:mm:ss').format(endDate);

                await _getWeeklyPurchaseInvoices();
                _navigateToDailyExpensesPage("$formattedDate1|$formattedDate2");
              },
              child: Text('Get Report'),
            ),
          ],
        ),
      ),
    );
  }
}
