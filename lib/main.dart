import 'package:flutter/material.dart';
import 'package:wear/wear.dart';
import 'package:barcode_widget/barcode_widget.dart';

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
          onSurface: Colors.white10,
        ),
      ),
      home: MainPage(),
    );
  }
}

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return WatchShape(
      builder: (context, shape, child) {
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "qr1",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                BarcodeWidget(
                  data: "2349",
                  barcode: Barcode.code39(),
                  width: 200,
                  height: 80,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
