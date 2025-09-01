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
      home: const MainPage(),
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
  late final PageController _pageController;
  late final StreamSubscription<RotaryEvent> _rotarySubscription;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: 1000 * codes.length,
    ); // infinite loop trick
    _rotarySubscription = rotaryEvents.listen(handleRotaryEvent);
  }

  void handleRotaryEvent(RotaryEvent event) {
    if (event.direction == RotaryDirection.clockwise) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
    HapticFeedback.selectionClick();
  }

  @override
  void dispose() {
    _rotarySubscription.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WatchShape(
      builder: (context, shape, child) {
        return Scaffold(
          body: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                selectedIndex = index % codes.length;
              });
            },
            itemBuilder: (context, index) {
              final code = codes[index % codes.length];
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "qr$selectedIndex",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    BarcodeWidget(
                      data: code,
                      barcode: Barcode.code39(),
                      width: 180,
                      height: 60,
                      backgroundColor: Colors.black,
                      margin: const EdgeInsets.all(8),
                      color: Colors.white,
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
