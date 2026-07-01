import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Team Generator',
      theme: ThemeData(        
        colorScheme: .fromSeed(seedColor: const Color.fromRGBO(64, 176, 204, 1)),
      ),
      home: const MyHomePage(title: 'Team Generator'),        
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {      
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {    
    return Scaffold(
      appBar: AppBar(        
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,        
        title: Center(child: Text(widget.title)),
      ),
      body: Center(                
        child: Column(          
          mainAxisAlignment: .center,
          children: [
            const Text('You have pushed the + this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Press',
        child: const Icon(Icons.add),
      ),
      backgroundColor: Color.fromRGBO(43, 108, 124, 1),
    );
  }
}
