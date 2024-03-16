import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/DailyMovementsOfClient.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ClientNotificationsPage extends StatefulWidget {
  @override
  _ClientNotificationsPageState createState() => _ClientNotificationsPageState();
}

class _ClientNotificationsPageState extends State<ClientNotificationsPage> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  List<dynamic>? _dailyMovementsOfClient;

 Future<void> _getDailyExpenses(String selectedDate) async {
  final response = await http.get(Uri.parse(
    'http://192.168.1.105:8080/api/getDailyMovementsOfClient?date=$selectedDate'));

  if (response.statusCode == 200) {
    List<dynamic> clientInfoList = json.decode(response.body);
    setState(() {
      _dailyMovementsOfClient = clientInfoList;
    });
    _navigateToDailyMovementsOfClient(selectedDate);
  } else {
    // Handle error
  }
}


  void _navigateToDailyMovementsOfClient(String selectedDate) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => DailyMovementsOfClient(
        selectedDate: selectedDate,
        dailyMovementsOfClient: _dailyMovementsOfClient,
      ),
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
      ),
      body: Center(
        child: Column(
          children: [
            TableCalendar(
              firstDay: DateTime.utc(2021, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) async {
                if (!isSameDay(_selectedDay, selectedDay)) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                  String formattedDate = "${selectedDay.year}-${selectedDay.month.toString().padLeft(2, '0')}-${selectedDay.day.toString().padLeft(2, '0')}";
                  await _getDailyExpenses(formattedDate);
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
              },
            ),
          ],
        ),
      ),
    );
  }
}
