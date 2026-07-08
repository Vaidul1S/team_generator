import 'package:flutter/material.dart';
import 'bracket.dart';
import 'credits.dart';
import 'table.dart';
import 'generator.dart';

List<Widget> pages = [Generator(), Credits(), TournamentTable(), Bracket()];
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Team Generator', home: NavClass());
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
        backgroundColor: const Color.fromRGBO(7, 7, 7, 1),
        indicatorColor: Color.fromRGBO(75, 75, 75, 0.75),
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(
            color: const Color.fromRGBO(255, 255, 255, 0.5),
            fontFamily: 'BrightAura',
          ),
        ),
        destinations: [
          NavigationDestination(
            icon: Icon(
              Icons.shuffle,
              color: Color.fromRGBO(255, 255, 255, 0.5),
            ),
            label: 'Generator',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.copyright_outlined,
              color: Color.fromRGBO(255, 255, 255, 0.5),
            ),
            label: 'Credits',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.table_view,
              color: Color.fromRGBO(255, 255, 255, 0.5),
            ),
            label: 'Table',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.mediation,
              color: Color.fromRGBO(255, 255, 255, 0.5),
            ),
            label: 'Bracket',
          ),
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
