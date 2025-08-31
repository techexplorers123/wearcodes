import 'package:flutter/material.dart';
import 'package:wear/wear.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        visualDensity: VisualDensity.compact,
        useMaterial3: true,
        colorScheme: const ColorScheme.dark(
          primary: Colors.white24,
          onBackground: Colors.white10,
          onSurface: Colors.white10,
        ),
      ),
      home: main_page(),
    );
  }
}

class main_page extends StatelessWidget {
  const main_page({super.key});

  @override
  Widget build(BuildContext context) {
    return WatchShape(
      builder: (context, shape, child) {
        return const Scaffold(
          body: Center(
            child: Text("Hello World", style: TextStyle(fontSize: 20)),
          ),
        );
      },
    );
  }
}
