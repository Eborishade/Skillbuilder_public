import 'package:flutter/material.dart';
import 'homepage.dart';
import 'landingPage.dart';
//import 'settingsPage.dart';
//import 'homepage.dart';
//import 'voiceTester.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(),
      home: OpenAIScreen(),
    );
  }
}
