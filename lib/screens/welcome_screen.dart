import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';
import 'first_time_screen.dart';

class WelcomeScreen extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future<void> navigate(bool isFirstTime, BuildContext context) async {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => !isFirstTime
              ? FirstTimeScreen(navigatorKey: navigatorKey)
              : CalendarApp(navigatorKey: navigatorKey),
        ),
      );
    }

    // Simulating a delay before redirection
    Future.delayed(const Duration(seconds: 2), () async {
      WidgetsFlutterBinding.ensureInitialized();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool isFirstTime = prefs.getBool('first_time') ?? true;

      navigate(isFirstTime, context);
    });

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
      home: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/sky-full-moon.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 100),
                Text(
                  'Random Nap Generator',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


