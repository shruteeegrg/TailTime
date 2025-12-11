import 'package:flutter/material.dart';
import 'screens/login_screen.dart'; // Import the new file

void main() {
  runApp(const TailTimeApp());
}

class TailTimeApp extends StatelessWidget {
  const TailTimeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TailTime',
      debugShowCheckedModeBanner: false, // Removes the ugly 'Debug' banner
      theme: ThemeData(
        primaryColor: const Color(0xFFFF4081),
        useMaterial3: true,
      ),
      home: const LoginScreen(), // START HERE
    );
  }
}