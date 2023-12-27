import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:random_nap_generator/screens/calendar_screen.dart';

class FirstTimeScreen extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  const FirstTimeScreen({super.key, required this.navigatorKey});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/sky-full-moon.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Expanded(
                    child: SingleChildScrollView(
                      child: _buildMainText(),
                    ),
                  ),
                  _buildShutUpButton(context),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMainText() {
    return Container(
      margin: const EdgeInsets.all(5.0),
      padding: const EdgeInsets.all(5.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 5.0,
            spreadRadius: 2.0,
          ),
        ],
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
          decoration: BoxDecoration(
            color: Colors.transparent.withOpacity(0.3), // Adjust opacity for glass effect
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: const Text(
            'Hello!\n\n'
            'Welcome here for the first time! You might be wondering why this app exists. Let me share the story with you...\n\n'
                'There are two reasons. Firstly - it is of course for learning purposes. I always thought that Flutter is a cool tool for creating apps and I always wanted to create something with it. Here we are! And I have more ideas (more useful too, do not worry).\n\n'
                'Secondly, this all began with a joke at work, and a wonder how people can randomly take a naps during the day... so I decided to make this app a unique channel for expressing feelings. For me, these mediums—technology, like this app, and music—became a way to articulate emotions that are challenging to express verbally. That\'s why I embarked on creating this small thing.\n\n'
                'I sincerely hope this app will brings you nothing but joy, but of course you can always tell me to...',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShutUpButton(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.lightBlue,
      ),
      onPressed: () async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('first_time', false);

        if (!context.mounted) return;

        _navigateToCalendar(context);
      },
      child: const Text(
        'Shut up :)',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _navigateToCalendar(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const CalendarScreen()),
    );
  }
}
