import 'package:flutter/material.dart';
import 'shared/sync_bridge.dart';

void main() {
  runApp(const MobileApp());
}

class MobileApp extends StatelessWidget {
  const MobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WearCodes Manager',
      theme: ThemeData(colorScheme: const ColorScheme.dark()),
      home: const ManagerHome(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ManagerHome extends StatefulWidget {
  const ManagerHome({super.key});
  @override
  State<ManagerHome> createState() => _ManagerHomeState();
}

class _ManagerHomeState extends State<ManagerHome> {
  final controller = TextEditingController(text: '123456');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Codes (Phone)')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(labelText: 'Quick add code'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                // Example push: replace this with your real list later.
                final codes = <Map<String, String>>[
                  {'name': 'Sample', 'code': controller.text.trim()},
                ];
                await SyncBridge.sendCodes(codes);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Pushed to watch')),
                  );
                }
              },
              child: const Text('Push to Watch'),
            ),
          ],
        ),
      ),
    );
  }
}
