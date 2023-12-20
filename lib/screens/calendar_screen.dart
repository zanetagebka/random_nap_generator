import 'dart:math';
import 'package:table_calendar/table_calendar.dart';
import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:random_nap_generator/night_sky.dart';

import '../main.dart';


class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
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

  Future<void> _requestCalendarPermission() async {
    final PermissionStatus status = await Permission.calendar.request();
    setState(() {
      _calendarPermissionGranted = status == PermissionStatus.granted;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Random Nap Generator',
              style: TextStyle(color: Colors.grey)),
          backgroundColor: Colors.black,
        ),
      body:
      Stack(
        children: [
          const NightSky(),
          Column(
            children: [
              Expanded(
                child: Column(
                  children: [
                    TableCalendar(
                      firstDay: DateTime.utc(2023, 1, 1),
                      lastDay: DateTime.utc(2023, 12, 31),
                      headerStyle: const HeaderStyle(titleCentered: true,
                      titleTextStyle: TextStyle(color: Colors.pink)),
                      calendarStyle: const CalendarStyle(defaultTextStyle: TextStyle(color: Colors.pink),
                      todayDecoration: BoxDecoration(color: Colors.purple, shape: BoxShape.circle),
                      selectedDecoration: BoxDecoration(color: Colors.pink, shape: BoxShape.circle)),
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
                    ElevatedButton(
                      onPressed: () async {
                        if (_selectedDay != null) {
                          await addRandomNapEvent(_selectedDay!);
                          setState(() {});
                        } else {
                          // Handle when no day is selected
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                backgroundColor: Colors.pink,
                                title: const Text('Oops!'),
                                content: const Text('Please select a day from the calendar.'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text('Sure!',
                                    style: TextStyle(color: Colors.black)),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink,
                        // Set the background color here
                      ),
                      child: const Text('Tell me when to nap!',
                        style: TextStyle(color: Colors.black),),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      )
    );
  }

  Future<void> addRandomNapEvent(DateTime selectedDay) async {
    DateTime startTime = DateTime(
      selectedDay.year,
      selectedDay.month,
      selectedDay.day,
      _random.nextInt(13), // Random hour from 0 to 12 (13 hours)
      _random.nextInt(4) * 15, // Random multiple of 15 minutes
    );

    // If the selected day is today, limit the start hour to the current or future hours
    if (isSameDay(selectedDay, DateTime.now())) {
      final currentHour = DateTime.now().hour;
      startTime = startTime.add(Duration(hours: currentHour));

      // If the randomly chosen hour is before the current hour, update it
      if (startTime.isBefore(DateTime.now())) {
        startTime = DateTime(
          selectedDay.year,
          selectedDay.month,
          selectedDay.day,
          currentHour,
          _random.nextInt(4) * 15,
        );
      }
    }

    int duration = _random.nextInt(45) +
        15; // Random duration in minutes (15-60)
    DateTime endTime = startTime.add(Duration(minutes: duration));

    String event = 'Nap (${duration}min)'; // Event with random duration

    final Event addEvent = Event(
      title: event,
      description: 'This time I am going to take a nap! And nothing can stop me!', // Optional: Add description
      location: 'Home', // Optional: Set event location
      startDate: startTime,
      endDate: endTime,
      allDay: false,
    );

    try {
      await Add2Calendar.addEvent2Cal(addEvent);
      showEventAddedNotification();
    } catch (e) {
      // Handle exception
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('An error occurred: $e'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }
}
