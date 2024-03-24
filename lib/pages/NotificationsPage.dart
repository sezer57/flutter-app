import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
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

  // Seçilen tarihe göre günlük harcamaları getir
  Future<void> _getDailyExpenses(String selectedDate) async {
    final response = await http.get(Uri.parse(
        'http://192.168.1.105:8080/api/getDailyExpenses?date=$selectedDate'));

    if (response.statusCode == 200) {
      List<dynamic> expenses = json.decode(response.body);
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
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'), // Bildirimler başlığı
      ),
      body: Center(
        child: Column(children: [
          TableCalendar(
              firstDay: DateTime.utc(2021, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) async {
                if (true) { // Eğer istenirse
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                  String formattedDate =
                      "${selectedDay.year}-${selectedDay.month.toString().padLeft(2, '0')}-${selectedDay.day.toString().padLeft(2, '0')}";
                  await _getDailyExpenses(formattedDate); // Günlük harcamaları getir
                  _navigateToDailyExpensesPage(formattedDate); // Harcamalar sayfasına geçiş yap
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
        ]),
      ),
    );
  }
}
