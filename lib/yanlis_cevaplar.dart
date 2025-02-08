import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter/material.dart';

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class YanlisSorularProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _yanlisSorular = [];

  List<Map<String, dynamic>> get yanlisSorular => _yanlisSorular;

  // Yanlış soru ekleme metodu
  Future<void> addYanlisSoru(Map<String, String> soru) async {
    _yanlisSorular.add(soru);
    await _saveYanlisSorularToPrefs();
    notifyListeners();
  }

  // SharedPreferences'a soruları kaydetme
  Future<void> _saveYanlisSorularToPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jsonString = json.encode(_yanlisSorular); // Listeyi JSON formatında dönüştür
    await prefs.setString('yanlisSorular', jsonString); // Veriyi shared_preferences'a kaydediyoruz
  }

  // SharedPreferences'tan soruları yükleme
  Future<void> loadYanlisSorularFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString('yanlisSorular'); // Veriyi String olarak alıyoruz

    if (jsonString != null) {
      // JSON string'i çözümle ve listeye dönüştür
      List<dynamic> decodedList = json.decode(jsonString);
      _yanlisSorular = decodedList.map((item) => Map<String, dynamic>.from(item)).toList();
      notifyListeners();
    }
  }

  // İşlem türüne göre filtreleme fonksiyonu
  List<Map<String, dynamic>> filtreleByIslemTuru(String islemTuru) {
    return _yanlisSorular.where((soru) => soru['kategori'] == islemTuru).toList();
  }
}
class YanlisSorularTabView extends StatefulWidget {
  @override
  State<YanlisSorularTabView> createState() => _YanlisSorularTabViewState();
}

class _YanlisSorularTabViewState extends State<YanlisSorularTabView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    Provider.of<YanlisSorularProvider>(context, listen: false).loadYanlisSorularFromPrefs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Yanlış Sorular"),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: "Toplama"),
            Tab(text: "Çıkarma"),
            Tab(text: "Bölme"),
            Tab(text: "Çarpma"),
          ],
        ),
      ),
      body: TabBarView(
        physics: NeverScrollableScrollPhysics(),
        controller: _tabController,
        children: [
          // Toplama Soruları Sekmesi
          Consumer<YanlisSorularProvider>(
            builder: (context, provider, child) {
              var sorular = provider.filtreleByIslemTuru("Toplama");
              return ListView.builder(
                itemCount: sorular.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(sorular[index]['soru'] ?? ''),
                    subtitle: Text('Yanlış Cevap: ${sorular[index]['yanlisCevap']} - Doğru Cevap: ${sorular[index]['dogruCevap']}'),
                  );
                },
              );
            },
          ),
          // Çıkarma Soruları Sekmesi
          Consumer<YanlisSorularProvider>(
            builder: (context, provider, child) {
              var sorular = provider.filtreleByIslemTuru("Çıkarma");
              return ListView.builder(
                itemCount: sorular.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(sorular[index]['soru'] ?? ''),
                    subtitle: Text('Yanlış Cevap: ${sorular[index]['yanlisCevap']} - Doğru Cevap: ${sorular[index]['dogruCevap']}'),
                  );
                },
              );
            },
          ),
          // Bölme Soruları Sekmesi
          Consumer<YanlisSorularProvider>(
            builder: (context, provider, child) {
              var sorular = provider.filtreleByIslemTuru("Bölme");
              return ListView.builder(
                itemCount: sorular.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(sorular[index]['soru'] ?? ''),
                    subtitle: Text('Yanlış Cevap: ${sorular[index]['yanlisCevap']} - Doğru Cevap: ${sorular[index]['dogruCevap']}'),
                  );
                },
              );
            },
          ),
          // Çarpma Soruları Sekmesi
          Consumer<YanlisSorularProvider>(
            builder: (context, provider, child) {
              var sorular = provider.filtreleByIslemTuru("Çarpma");
              return ListView.builder(
                itemCount: sorular.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(sorular[index]['soru'] ?? ''),
                    subtitle: Text('Yanlış Cevap: ${sorular[index]['yanlisCevap']} - Doğru Cevap: ${sorular[index]['dogruCevap']}'),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}