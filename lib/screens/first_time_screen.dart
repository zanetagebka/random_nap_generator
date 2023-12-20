import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:random_nap_generator/screens/calendar_screen.dart';
import 'package:random_nap_generator/night_sky.dart';

class FirstTimeScreen extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  const FirstTimeScreen({super.key, required this.navigatorKey});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
      ),
      body: Stack(
        children: [
          const NightSky(),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Text(
                    'Hello Human!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.pink
                    ),
                  ),
                  const SizedBox(height: 40), // Additional space after the text
                  const Text(
                    'Welcome here for the first time! You might be wondering why this app exists. Let me share the story with you...\n\n'
                        'There are two reasons. Firstly - it is of course for learning purposes. I always thought that Flutter is a cool tool for creating apps and I always wanted to create something with it. Here we are! And I have more ideas (more useful too, do not worry).\n\n'
                        'Secondly, this all began with a joke at work, and a wonder how people can randomly take a naps during the day... So this app became a unique channel for expressing feelings that are hard to vocalize. For me, these mediums—technology, like this app, and music—became a way to articulate emotions that are challenging to express verbally. That\'s why I embarked on creating this app.\n\n'
                        'I sincerely hope this app brings joy without causing any unintended distress with my words, but of course you can always tell me to...',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.pink,
                    fontSize: 15),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink,
                      // Set the background color here
                    ),
                    onPressed: () async {
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('first_time', false);
                      _navigateToCalendar(context);
                    },
                    child: const Text('Shut up :)',
                    style: TextStyle(color: Colors.black)),
                  ),
                ],
              ),
            ),
          ),
        ],
      )
    );
  }
}

void _navigateToCalendar(BuildContext context) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => CalendarScreen()),
  );
}
