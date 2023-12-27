import 'package:flutter/material.dart';
import 'package:random_nap_generator/screens/welcome_screen.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:random_nap_generator/screens/calendar_screen.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MaterialApp(
    home: WelcomeScreen()
  ));
}

Future<void> initializeNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');
  final DarwinInitializationSettings initializationSettingsIOS =
  DarwinInitializationSettings(
    requestSoundPermission: false,
    requestBadgePermission: false,
    requestAlertPermission: false,
    onDidReceiveLocalNotification: (id, title, body, payload) async {},
  );
  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

class CalendarApp extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  const CalendarApp({super.key, required this.navigatorKey});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Random Nap Generator',
      theme: ThemeData(
        fontFamily: 'Nunito',
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: Theme.of(context).textTheme.apply(
          bodyColor: Colors.white,
          // Add more specific text styles here
        ),
      ),
      navigatorKey: navigatorKey,
      home: const CalendarScreen(),
    );
  }
}
