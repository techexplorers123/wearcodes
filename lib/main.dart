import 'dart:async';
import 'dart:convert';
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
  List<Map<String, String>> codes = [];
  int selectedIndex = 0;
  late final StreamSubscription<RotaryEvent> _rotarySubscription;
  bool isClockwise = true;
  bool bounceFirst = false;
  bool bounceAdd = false;
  @override
  void initState() {
    super.initState();
    _rotarySubscription = rotaryEvents.listen(_handleRotary);
    _loadCodes();
  }

  Future<void> _loadCodes() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList('codes');
    if (stored != null) {
      setState(() {
        codes = stored
            .map((s) => Map<String, String>.from(jsonDecode(s)))
            .toList();
      });
    }
  }

  Future<void> _saveCodes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('codes', codes.map(jsonEncode).toList());
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
          _triggerBounce(isAddCard: true);
        }
      } else {
        if (selectedIndex > 0) {
          selectedIndex--;
          isClockwise = false;
          HapticFeedback.selectionClick();
        } else {
          _triggerBounce(isAddCard: false);
        }
      }
    });
  }

  void _triggerBounce({required bool isAddCard}) {
    if (mounted) {
      setState(() {
        if (isAddCard) {
          bounceAdd = false; // reset immediately
          bounceAdd = true; // start new bounce
        } else {
          bounceFirst = false;
          bounceFirst = true;
        }
      });
    }

    HapticFeedback.heavyImpact();

    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) {
        setState(() {
          if (isAddCard) {
            bounceAdd = false;
          } else {
            bounceFirst = false;
          }
        });
      }
    });
  }

  Future<void> _handleAddCode() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddCodePage(
          onAdd: (newCode) async {
            setState(() {
              codes.add(newCode);
              selectedIndex = codes.length - 1;
            });
            await _saveCodes();
            HapticFeedback.mediumImpact();
          },
        ),
      ),
    );
  }

  Future<void> _handleDeleteCode(int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Code?"),
        content: Text("Do you want to delete code: ${codes[index]['name']}?"),
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedScale(
          scale: bounceFirst ? 1.2 : 1.0,
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
                      codes[index]["name"] ?? "Unnamed",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    BarcodeWidget(
                      data: codes[index]["code"] ?? "",
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
        AnimatedScale(
          scale: bounceAdd ? 1.15 : 1.0,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          child: Column(
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
              ElevatedButton(
                onPressed: _handleAddCode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(24),
                  elevation: 8,
                  shadowColor: Colors.white24,
                ),
                child: const Icon(
                  Icons.add,
                  size: 40,
                  color: Colors.black,
                  semanticLabel: "add",
                ),
              ),
            ],
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
      builder: (context, shape, child) => Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            transitionBuilder: (child, animation) {
              final offsetAnimation = Tween<Offset>(
                begin: isClockwise ? const Offset(1, 0) : const Offset(-1, 0),
                end: Offset.zero,
              ).animate(animation);

              final scaleAnimation = Tween<double>(begin: 0.95, end: 1.0)
                  .animate(
                    CurvedAnimation(parent: animation, curve: Curves.easeOut),
                  );

              return SlideTransition(
                position: offsetAnimation,
                child: ScaleTransition(
                  scale: scaleAnimation,
                  child: FadeTransition(opacity: animation, child: child),
                ),
              );
            },
            child: selectedIndex < codes.length
                ? _buildCodeCard(selectedIndex)
                : _buildAddCard(),
          ),
        ),
      ),
    );
  }
}

class AddCodePage extends StatefulWidget {
  final Function(Map<String, String>) onAdd;
  const AddCodePage({required this.onAdd, super.key});

  @override
  State<AddCodePage> createState() => _AddCodePageState();
}

class _AddCodePageState extends State<AddCodePage> {
  final nameController = TextEditingController();
  final codeController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                hintText: "Enter name",
                filled: true,
                fillColor: Colors.white10,
              ),
              style: const TextStyle(color: Colors.white),
              autofocus: false,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: codeController,
              decoration: const InputDecoration(
                hintText: "Enter code",
                filled: true,
                fillColor: Colors.white10,
              ),
              style: const TextStyle(color: Colors.white),
              maxLength: 20,
              autofocus: false,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (codeController.text.trim().isNotEmpty) {
                  widget.onAdd({
                    "name": nameController.text.trim(),
                    "code": codeController.text.trim(),
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text("Add"),
            ),
          ],
        ),
      ),
    );
  }
}
