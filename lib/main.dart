import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wear_plus/wear_plus.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:wearable_rotary/wearable_rotary.dart';
import 'package:flutter/services.dart';

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
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final List<String> codes = ["2349", "5678", "9012", "3456"];
  int selectedIndex = 0;
  late final StreamSubscription<RotaryEvent> _rotarySubscription;
  @override
  void initState() {
    super.initState();
    _rotarySubscription = rotaryEvents.listen(handleRotaryEvent);
  }

  void handleRotaryEvent(RotaryEvent event) {
    setState(() {
      if (event.direction == RotaryDirection.clockwise) {
        selectedIndex = (selectedIndex + 1) % codes.length;
      } else {
        selectedIndex = (selectedIndex - 1 + codes.length) % codes.length;
      }
      HapticFeedback.selectionClick();
    });
  }

  @override
  void dispose() {
    _rotarySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WatchShape(
      builder: (context, shape, child) {
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedSwitcher(
                  duration: Duration(milliseconds: 400),
                  transitionBuilder: (child, animation) => ScaleTransition(
                    scale: animation,
                    child: FadeTransition(opacity: animation, child: child),
                  ),
                  child: Column(
                    key: ValueKey<int>(selectedIndex),
                    children: [
                      Text(
                        "qr$selectedIndex",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      BarcodeWidget(
                        data: codes[selectedIndex],
                        barcode: Barcode.code39(),
                        width: 180,
                        height: 60,
                        backgroundColor: Colors.black,
                        margin: EdgeInsets.all(8),
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
