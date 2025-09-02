import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
          primary: Colors.black,
          onSurface: Colors.white,
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
  List<String> codes = [];
  int selectedIndex = 0;
  late final StreamSubscription<RotaryEvent> _rotarySubscription;
  bool isClockwise = true;
  bool bounceAdd = false;
  bool bounceFirst = false;

  @override
  void initState() {
    super.initState();
    _rotarySubscription = rotaryEvents.listen(_handleRotary);
    _loadCodes();
  }

  Future<void> _loadCodes() async {
    final prefs = await SharedPreferences.getInstance();
    final storedCodes = prefs.getStringList('codes');
    if (storedCodes != null) setState(() => codes = storedCodes);
  }

  Future<void> _saveCodes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('codes', codes);
  }

  void _handleRotary(RotaryEvent event) {
    final totalItems = codes.length + 1;
    setState(() {
      if (event.direction == RotaryDirection.clockwise) {
        if (selectedIndex < totalItems - 1) {
          selectedIndex++;
          isClockwise = true;
          HapticFeedback.selectionClick();
        } else {
          _triggerBounceAdd();
          HapticFeedback.heavyImpact();
        }
      } else {
        if (selectedIndex > 0) {
          selectedIndex--;
          isClockwise = false;
          HapticFeedback.selectionClick();
        } else {
          _triggerBounceFirst();
          HapticFeedback.heavyImpact();
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

  Future<void> _handleAddCode() async {
    final controller = TextEditingController();
    final newCode = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Code"),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 20,
          decoration: const InputDecoration(
            hintText: "Enter code",
            counterText: "",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                Navigator.pop(context, controller.text.trim());
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );

    if (newCode != null) {
      setState(() {
        codes.add(newCode);
        selectedIndex = codes.length - 1;
      });
      await _saveCodes();
      HapticFeedback.mediumImpact();
    }
  }

  Future<void> _handleDeleteCode(int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Code?"),
        content: Text("Do you want to delete code: ${codes[index]}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        codes.removeAt(index);
        if (selectedIndex >= codes.length) selectedIndex = codes.length - 1;
      });
      await _saveCodes();
      HapticFeedback.mediumImpact();
    }
  }

  Widget _buildCodeCard(int index) {
    final bounce = index == 0 ? bounceFirst : false;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedScale(
          scale: bounce ? 1.2 : 1.0,
          duration: const Duration(milliseconds: 150),
          child: GestureDetector(
            onLongPress: () => _handleDeleteCode(index),
            child: Card(
              color: Colors.grey[900],
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "qr$index",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    BarcodeWidget(
                      data: codes[index],
                      barcode: Barcode.code39(),
                      width: 180,
                      height: 60,
                      color: Colors.white,
                      backgroundColor: Colors.black,
                      drawText: false,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Position indicator inside the card
        Text(
          "${index + 1} / ${codes.length}",
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white70,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildAddCard() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Add New Code",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        AnimatedScale(
          scale: bounceAdd ? 1.15 : 1.0,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          child: GestureDetector(
            onTap: _handleAddCode,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.4),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(Icons.add, size: 40, color: Colors.black),
            ),
          ),
        ),
      ],
    );
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
          backgroundColor: Colors.black,
          body: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              transitionBuilder: (child, animation) {
                final offsetAnimation = Tween<Offset>(
                  begin: isClockwise ? const Offset(1, 0) : const Offset(-1, 0),
                  end: Offset.zero,
                ).animate(animation);
                return SlideTransition(
                  position: offsetAnimation,
                  child: FadeTransition(opacity: animation, child: child),
                );
              },
              child: selectedIndex < codes.length
                  ? _buildCodeCard(selectedIndex)
                  : _buildAddCard(),
            ),
          ),
        );
      },
    );
  }
}
