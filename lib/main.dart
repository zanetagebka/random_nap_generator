import 'package:flutter/material.dart';
import 'package:random_nap_generator/screens/calendar_screen.dart';
import 'package:random_nap_generator/screens/first_time_screen.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isFirstTime = prefs.getBool('first_time') ?? true;

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  runApp(MaterialApp(
    home: isFirstTime
        ? FirstTimeScreen(navigatorKey: navigatorKey)
        : CalendarApp(navigatorKey: navigatorKey),
  ));
}

Future<void> initializeNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');
  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
      onDidReceiveLocalNotification: (id, title, body, payload) async {},
    ),
  );
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}


class CalendarApp extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  const CalendarApp({Key? key, required this.navigatorKey}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Random Nap Generator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: Theme.of(context).textTheme.apply(
          bodyColor: Colors.white,
          // Add more specific text styles here
        ),
      ),
      navigatorKey: navigatorKey,
      home: CalendarScreen(),
    );
  }
}

