import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:random_nap_generator/night_sky.dart';
import '../main.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  CalendarScreenState createState() => CalendarScreenState();
}

class CalendarScreenState extends State<CalendarScreen> {
  bool _calendarPermissionGranted = false;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _checkCalendarPermission();
  }

  Future<void> showEventAddedNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'your channel id',
      'your channel name',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      'Event Added',
      'Your nap event has been added to the calendar!',
      platformChannelSpecifics,
      payload: 'item x',
    );
  }

  Future<void> _checkCalendarPermission() async {
    final PermissionStatus status = await Permission.calendar.status;
    setState(() {
      _calendarPermissionGranted = status == PermissionStatus.granted;
    });
  }

  @override
  Widget build(BuildContext context) {
    DateTime beginningOfYear = DateTime.now();
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Random Nap Generator',
          style: TextStyle(color: Colors.grey),
        ),
        backgroundColor: Colors.black,
      ),
      body: Stack(
        children: [
          const NightSky(),
          _buildCalendarView(),
        ],
      ),
    );
  }

  Widget _buildCalendarView() {
    DateTime beginningOfYear = DateTime.now();
    return Column(
      children: [
        Expanded(
          child: Column(
            children: [
              TableCalendar(
                firstDay: DateTime(beginningOfYear.year, 1, 1),
                lastDay: DateTime.utc(2100, 12, 31),
                headerStyle: const HeaderStyle(
                  leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white),
                  rightChevronIcon: Icon(Icons.chevron_right, color: Colors.white),
                  titleCentered: true,
                  titleTextStyle: TextStyle(color: Colors.white),
                  formatButtonTextStyle: TextStyle(color: Colors.white),
                ),
                calendarStyle: const CalendarStyle(
                  defaultTextStyle: TextStyle(color: Colors.white),
                  todayDecoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Colors.lightBlue,
                    shape: BoxShape.circle,
                  ),
                ),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                onFormatChanged: (format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
              ),
              const SizedBox(height: 20),
              _buildNapButton(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNapButton() {
    return ElevatedButton(
      onPressed: () async {
        if (_selectedDay != null) {
          await addRandomNapEvent(_selectedDay!);
          setState(() {});
        } else {
          _showNoDaySelectedDialog();
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.lightBlue,
      ),
      child: const Text(
        'Tell me when to nap!',
        style: TextStyle(color: Colors.black),
      ),
    );
  }

  Future<void> addRandomNapEvent(DateTime selectedDay) async {
    // Set the start and end time limits
    DateTime now = DateTime.now();
    DateTime startTimeLimit =
    DateTime(selectedDay.year, selectedDay.month, selectedDay.day, 9, 0);
    DateTime endTimeLimit =
    DateTime(selectedDay.year, selectedDay.month, selectedDay.day, 22, 0);

    // Adjust start time if selected day is today
    if (isSameDay(selectedDay, now)) {
      if (now.hour > startTimeLimit.hour) {
        startTimeLimit = DateTime(
          selectedDay.year,
          selectedDay.month,
          selectedDay.day,
          now.hour,
          now.minute,
        );
      }
    }

    // Randomly select a time between the limits
    DateTime startTime = startTimeLimit.add(Duration(
      minutes: _random.nextInt(
          (endTimeLimit.difference(startTimeLimit)).inMinutes),
    ));

    int duration = _random.nextInt(45) +
        15; // Random duration in minutes (15-60)
    DateTime endTime = startTime.add(Duration(minutes: duration));

    // Check if the generated time is within the limit
    if (startTime.isAfter(startTimeLimit) &&
        endTime.isBefore(endTimeLimit) &&
        startTime.isAfter(now)) {
      String event = 'Nap (${duration}min)'; // Event with random duration

      final Event addEvent = Event(
        title: event,
        description: 'This time I am going to take a nap!',
        location: 'Home',
        startDate: startTime,
        endDate: endTime,
        allDay: false,
      );

      try {
        await Add2Calendar.addEvent2Cal(addEvent);
        showEventAddedNotification();
      } catch (e) {
        // Handle exception
        _showErrorDialog('An error occurred: $e');
      }
    } else {
      _showErrorDialog('It\'s too late to take a nap. You should go to bed!');
    }
  }



  void _showNoDaySelectedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.lightBlue,
          title: const Text('Oops!'),
          content: const Text('Please select a day from the calendar.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Sure!',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.lightBlue,
          title: const Text('Oops!'),
          content: Text(error),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
