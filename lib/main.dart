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
  late final StreamSubscription<RotaryEvent> _rotarySubscription;
  bool isClockwise = true;

  bool bounceAdd = false;
  bool bounceFirst = false;

  @override
  void initState() {
    super.initState();
    _rotarySubscription = rotaryEvents.listen(handleRotaryEvent);
  }

  void handleRotaryEvent(RotaryEvent event) {
    final totalItems = codes.length + 1;
    setState(() {
      if (event.direction == RotaryDirection.clockwise) {
        if (selectedIndex < totalItems - 1) {
          selectedIndex++;
          isClockwise = true;
          HapticFeedback.selectionClick();
        } else {
          HapticFeedback.heavyImpact();
          _triggerBounceAdd();
        }
      } else {
        if (selectedIndex > 0) {
          selectedIndex--;
          isClockwise = false;
          HapticFeedback.selectionClick();
        } else {
          HapticFeedback.heavyImpact();
          _triggerBounceFirst();
        }
      }
    });
  }

  void _triggerBounceAdd() {
    setState(() => bounceAdd = true);
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) setState(() => bounceAdd = false);
    });
  }

  void _triggerBounceFirst() {
    setState(() => bounceFirst = true);
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) setState(() => bounceFirst = false);
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
                  duration: const Duration(milliseconds: 350),
                  transitionBuilder: (child, animation) {
                    final offsetAnimation = Tween<Offset>(
                      begin: isClockwise
                          ? const Offset(1.0, 0.0) // from right
                          : const Offset(-1.0, 0.0), // from left
                      end: Offset.zero,
                    ).animate(animation);

                    return SlideTransition(
                      position: offsetAnimation,
                      child: FadeTransition(opacity: animation, child: child),
                    );
                  },
                  child: Column(
                    key: ValueKey<int>(selectedIndex),
                    children: [
                      if (selectedIndex < codes.length) ...[
                        // First code with bounce
                        if (selectedIndex == 0)
                          AnimatedScale(
                            scale: bounceFirst ? 1.2 : 1.0,
                            duration: const Duration(milliseconds: 150),
                            curve: Curves.easeOut,
                            child: Column(
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
                                  data: codes[selectedIndex],
                                  barcode: Barcode.code39(),
                                  width: 180,
                                  height: 60,
                                  backgroundColor: Colors.black,
                                  margin: const EdgeInsets.all(8),
                                  color: Colors.white,
                                  drawText: false,
                                ),
                              ],
                            ),
                          )
                        else
                          Column(
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
                                data: codes[selectedIndex],
                                barcode: Barcode.code39(),
                                width: 180,
                                height: 60,
                                backgroundColor: Colors.black,
                                margin: const EdgeInsets.all(8),
                                color: Colors.white,
                                drawText: false,
                              ),
                            ],
                          ),
                      ] else ...[
                        // Add button with bounce
                        AnimatedScale(
                          scale: bounceAdd ? 1.2 : 1.0,
                          duration: const Duration(milliseconds: 150),
                          curve: Curves.easeOut,
                          child: IconButton(
                            icon: const Icon(
                              Icons.add_circle_outline,
                              size: 40,
                            ),
                            onPressed: () async {
                              final TextEditingController controller =
                                  TextEditingController();

                              final String? newCode = await showDialog<String>(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text("Add Code"),
                                    content: TextField(
                                      controller: controller,
                                      autofocus: true,
                                      maxLength: 20,
                                      decoration: InputDecoration(
                                        hintText: "Enter code",
                                        counterText: "",
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text("Cancel"),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          if (controller.text
                                              .trim()
                                              .isNotEmpty) {
                                            Navigator.pop(
                                              context,
                                              controller.text.trim(),
                                            );
                                          }
                                        },
                                        child: Text("Add"),
                                      ),
                                    ],
                                  );
                                },
                              );
                              if (newCode != null) {
                                setState(() {
                                  codes.add(newCode);
                                  selectedIndex = codes.length - 1;
                                });
                                HapticFeedback.mediumImpact();
                              }
                            },
                          ),
                        ),
                        const Text("Add new code"),
                      ],
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
