// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class YanlisSorularProvider with ChangeNotifier {
//   List<Map<String, dynamic>> _yanlisSorular = [];
//
//   List<Map<String, dynamic>> get yanlisSorular => _yanlisSorular;
//
//   void addYanlisSoru(Map<String, dynamic> soru) {
//     _yanlisSorular.add(soru);
//     notifyListeners();
//   }
//
//   void removeSoru(int index) {
//     _yanlisSorular.removeAt(index);
//     notifyListeners();
//   }
//
//   // SharedPreferences ile veriyi kaydet
//   Future<void> saveYanlisSorular() async {
//     final prefs = await SharedPreferences.getInstance();
//     final List<String> encodedList = _yanlisSorular.map((e) => jsonEncode(e)).toList();
//     await prefs.setStringList('yanlisSorular', encodedList);
//   }
//
//   // SharedPreferences'tan veriyi yükle
//   Future<void> loadYanlisSorular() async {
//     final prefs = await SharedPreferences.getInstance();
//     final List<String>? storedSorular = prefs.getStringList('yanlisSorular');
//
//     if (storedSorular != null) {
//       _yanlisSorular = storedSorular.map((soru) => jsonDecode(soru)).toList().cast<Map<String, dynamic>>();
//       notifyListeners();
//     }
//   }
// }