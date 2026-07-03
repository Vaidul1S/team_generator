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
      home: NavClass(),
    );
  }
}

class NavClass extends StatefulWidget {
  const NavClass({super.key});

  @override
  State<NavClass> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<NavClass> {
  int currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Team Generator'), centerTitle: true),
        bottomNavigationBar: NavigationBar(
          destinations: [
            NavigationDestination(icon: Icon(Icons.home), label: 'Generator'),
            NavigationDestination(
              icon: Icon(Icons.copyright_outlined),
              label: 'Credits',
            ),
            NavigationDestination(icon: Icon(Icons.table_view), label: 'Table'),
            NavigationDestination(
              icon: Icon(Icons.mediation),
              label: 'Bracket',
            ),
          ],
          onDestinationSelected: (int value) {
            setState((){
              currentIndex = value;
            });
          },
          selectedIndex: currentIndex,
        ),
      );
  }
}