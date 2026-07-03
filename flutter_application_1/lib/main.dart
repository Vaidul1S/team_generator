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
      home: Scaffold(
        appBar: AppBar(title: Text('Team Generator'), centerTitle: true),
        bottomNavigationBar: NavigationBar(
          destinations: [
            NavigationDestination(icon: Icon(Icons.home), label: 'Generator'),
            NavigationDestination(
              icon: Icon(Icons.credit_score),
              label: 'Credits',
            ),
          ],
        ),
      ),
    );
  }
}
