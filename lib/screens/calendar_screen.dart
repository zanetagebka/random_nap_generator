import 'dart:math';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:add_2_calendar/add_2_calendar.dart';

import 'package:random_nap_generator/screens/utils/night_sky.dart';

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

  Future<void> _checkCalendarPermission() async {
    final PermissionStatus status = await Permission.calendarFullAccess.request();
    setState(() {
      _calendarPermissionGranted = status == PermissionStatus.granted;
    });
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.lightBlue,
          title: const Text('Permission Denied'),
          content: const Text('Calendar access is required for this feature.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK',
                  style: TextStyle(color: Colors.white,
                      fontWeight: FontWeight.w500)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
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
                  titleTextStyle: TextStyle(color: Colors.white,
                      fontWeight: FontWeight.w500),
                  formatButtonTextStyle: TextStyle(color: Colors.white,
                      fontWeight: FontWeight.w500),
                ),
                calendarStyle: const CalendarStyle(
                  defaultTextStyle: TextStyle(color: Colors.white,
                      fontWeight: FontWeight.w500),
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
        if (_selectedDay != null && _calendarPermissionGranted) {
          await addRandomNapEvent(_selectedDay!);
          setState(() {});
        } else if (_selectedDay != null && !_calendarPermissionGranted) {
          _showPermissionDeniedDialog();
      } else {
          _showNoDaySelectedDialog();
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.lightBlue,
      ),
      child: const Text(
        'Tell me when to nap!',
        style: TextStyle(color: Colors.white,
            fontWeight: FontWeight.w500),
      ),
    );
  }

  Future<void> addRandomNapEvent(DateTime selectedDay) async {
    DateTime now = DateTime.now();
    DateTime startTimeLimit = DateTime(selectedDay.year, selectedDay.month, selectedDay.day, 9, 0);
    DateTime endTimeLimit = DateTime(selectedDay.year, selectedDay.month, selectedDay.day, 22, 0);

    if (selectedDay.isBefore(now) && !isSameDay(selectedDay, now)) {
      _showErrorDialog('I am so sorry! We still do not know how to time travel. You cannot sleep in the past. :)');
    } else if (isSameDay(selectedDay, now) && now.hour > endTimeLimit.hour) {
      _showErrorDialog('It\'s too late to take a nap. You should go to bed!');
    } else {
      if (isSameDay(selectedDay, now) && now.hour > startTimeLimit.hour) {
        startTimeLimit = DateTime(selectedDay.year, selectedDay.month, selectedDay.day, now.hour, now.minute);
      }

      int maxDuration = 45;
      int durationRange = endTimeLimit.difference(startTimeLimit).inMinutes;

      if (durationRange <= 0 || durationRange < maxDuration) {
        _showErrorDialog('Something went wrong. Please try again.');
      } else {
        int duration = _random.nextInt(maxDuration) + 15; // Random duration in minutes (15-45)
        DateTime startTime = DateTime(
          selectedDay.year,
          selectedDay.month,
          selectedDay.day,
          _random.nextInt(14) + 9,
          _random.nextInt(60),
        );
        DateTime endTime = startTime.add(Duration(minutes: duration));

        if (startTime.isAfter(now) && endTime.isBefore(endTimeLimit)) {
          String event = 'Nap (${endTime.difference(startTime).inMinutes}min)';

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
          } catch (e) {
            _showErrorDialog('An error occurred: $e');
          }
        } else if (isSameDay(selectedDay, now) && now.hour > endTimeLimit.hour) {
          _showErrorDialog('It\'s too late. You should go to bed! :)');
        }
      }
    }
  }

  void _showNoDaySelectedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.lightBlue,
          title: const Text('Oops!', style: TextStyle(color: Colors.white)),
          content: const Text('Please select a day from the calendar.',
          style: TextStyle(color: Colors.white)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Sure!',
                style: TextStyle(color: Colors.white,
                fontWeight: FontWeight.w500),
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
          title: const Text('Oops!',
              style: TextStyle(color: Colors.white)),
          content: Text(error,
              style: TextStyle(color: Colors.white)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Ohh :(',
              style: TextStyle(color: Colors.white,
                  fontWeight: FontWeight.w500)),
            ),
          ],
        );
      },
    );
  }
}
