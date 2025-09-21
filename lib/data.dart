import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Data {
  static Future<List<Map<String, String>>> loadCodes() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList('codes');
    if (stored != null) {
      return stored
          .map((s) => Map<String, String>.from(jsonDecode(s)))
          .toList();
    }
    return [];
  }

  static Future<void> saveCodes(List<Map<String, String>> codes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('codes', codes.map(jsonEncode).toList());
  }

  static Future<void> addCode(Map<String, String> newCode) async {
    final codes = await loadCodes();
    codes.add(newCode);
    await saveCodes(codes);
  }
}
