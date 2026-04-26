import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF1A3A2A),
      body: Center(
        child: Text(
          'Home',
          style: TextStyle(color: Colors.white, fontSize: 32),
        ),
      ),
    );
  }
}
