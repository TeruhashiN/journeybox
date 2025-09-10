import 'package:flutter/material.dart';
import 'screen/splash_screen.dart';

void main() {
  runApp(const JourneyBox());
}

class JourneyBox extends StatelessWidget {
  const JourneyBox({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'JourneyBox',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const SplashScreen(),
    );
  }
}
