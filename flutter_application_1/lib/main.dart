import 'package:flutter/material.dart';
import 'generator.dart'; // if you split it into its own file

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Team Generator',
      home: const Generator(),
    );
  }
}