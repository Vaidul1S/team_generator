import 'package:flutter/material.dart';
import 'package:flutter_application_1/bracket.dart';
import 'package:flutter_application_1/credits.dart';
import 'package:flutter_application_1/table.dart';
import 'generator.dart'; // if you split it into its own file

List<Widget> pages = [Generator(), Credits(), TournamentTable(), Bracket()];
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: NavClass());
  }
}

class NavClass extends StatefulWidget {
  const NavClass({super.key});

  @override
  State<NavClass> createState() => _NavClassState();
}

class _NavClassState extends State<NavClass> {
  int currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: pages[currentIndex]),

      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.black,
        destinations: [
          NavigationDestination(icon: Icon(Icons.home), label: 'Generator'),
          NavigationDestination(
            icon: Icon(Icons.copyright_outlined),
            label: 'Credits',
          ),
          NavigationDestination(icon: Icon(Icons.table_view), label: 'Table'),
          NavigationDestination(icon: Icon(Icons.mediation), label: 'Bracket'),
        ],
        onDestinationSelected: (int value) {
          setState(() {
            currentIndex = value;
          });
        },
        selectedIndex: currentIndex,
      ),
    );
  }
}
