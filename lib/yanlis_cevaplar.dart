import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter/material.dart';

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'mainmenu.dart';

class YanlisSorularProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _yanlisSorular = [];

  List<Map<String, dynamic>> get yanlisSorular => _yanlisSorular;

  // Yanlış soru ekleme metodu
  Future<void> addYanlisSoru(Map<String, dynamic> soru) async {
    yanlisSorular.add(soru);
    notifyListeners(); // Önce UI güncelle
    await saveYanlisSorularToPrefs(); // Sonra kaydet

  }

  // SharedPreferences'tan soruları yükleme
  Future<void> loadYanlisSorularFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? jsonList = prefs.getStringList('yanlisSorular'); // Liste olarak al

    if (jsonList != null) {
      try {
        _yanlisSorular = jsonList
            .map((item) => json.decode(item) as Map<String, dynamic>) // JSON parse et
            .toList();
        notifyListeners();

      } catch (e) {
        log("Hata: $e"); // Hata loglaması
      }
    }
  }
  // SharedPreferences'a soruları kaydetme

  Future<void> saveYanlisSorularToPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Her öğeyi JSON stringe çevir ve liste olarak kaydet
    List<String> jsonList = _yanlisSorular.map((item) => json.encode(item)).toList();

    await prefs.setStringList('yanlisSorular', jsonList); // Listeyi SharedPreferences'a kaydet

    notifyListeners();

  }

  // İşlem türüne göre filtreleme fonksiyonu
  List<Map<String, dynamic>> filtreleByIslemTuru(String islemTuru) {
    return _yanlisSorular
        .where((soru) => soru['kategori'] == islemTuru)
        .toList();
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

      setState(() {
        Provider.of<YanlisSorularProvider>(context, listen: false).loadYanlisSorularFromPrefs();
        Provider.of<YanlisSorularProvider>(context, listen: false).saveYanlisSorularToPrefs();
      });

  }

  // Tek bir fonksiyonla Dismissible widget'ı tekrar kullanabilmek
  Widget _buildSoruListesi(String islemTuru) {
    bool isLoading = false;
    return RefreshIndicator(
      onRefresh: () async{
        setState(() {
          Provider.of<YanlisSorularProvider>(context, listen: false).loadYanlisSorularFromPrefs();

        });
      },
      child: Consumer<YanlisSorularProvider>(
        builder: (context, provider, child) {
          var sorular = provider.filtreleByIslemTuru(islemTuru);
          return isLoading == true ? CircularProgressIndicator() : sorular.length == 0 ? Center(child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("🎉", style: TextStyle(fontSize: 100)),
              Text("Bu kategoride \nyanlış soru yapmadın" , style: TextStyle(color: Colors.white , fontSize: 20 , fontWeight: FontWeight.bold ) , textAlign: TextAlign.center),
            ],
          ),): Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.info_outline, color: Colors.white54 , size: 18) ,
                    SizedBox(width: 5),
                    Text("Silmek için sola kaydır" , style: TextStyle(color: Colors.white54 , fontSize: 12 , fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Container(
                height: MediaQuery.of(context).size.height - 200,
                child: ListView.builder(
                  itemCount: sorular.length,
                  itemBuilder: (context, index) {
                    var soru = sorular[index];
                    return Dismissible(
                      key: Key(soru['soru']),
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) {
                        provider._yanlisSorular.removeAt(index);
                        provider.saveYanlisSorularToPrefs();
                        setState(() {});
                      },
                      background: Container(
                        color: Colors.green,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.0),
                            child: Text("Bu soruyu anladım", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                      child: Container(

                        height: 140,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Card(

                            color: Colors.white,
                            child: Stack(
                              children: [
                                Positioned( right: 0, bottom: 0, child: Opacity(opacity: 0.4, child: Image.asset('assets/card_background.png', height: 100, fit: BoxFit.cover))),
                                ListTile(
                                  title: Padding(
                                    padding: const EdgeInsets.symmetric(vertical:  5.0),
                                    child: Text(soru['soru'] ?? '', style: TextStyle(color: Color(0xff2d2e83), fontSize: 25 , fontWeight: FontWeight.bold)),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          'Senin Cevabın: ${soru['yanlisCevap']}' , style: TextStyle(color: Color(0xff2d2e83) , fontSize: 16 , fontWeight: FontWeight.bold)),
                                      Text('Doğru Cevap: ${soru['dogruCevap']}' , style: TextStyle(color: Color(0xff2d2e83) , fontSize: 16 , fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff2d2e83),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => Mainmenu(yanlisSorular:Provider.of<YanlisSorularProvider>(context, listen: false)._yanlisSorular ,)));
          },
        ),
        backgroundColor: Color(0xff2d2e83),
        title: Text("Yanlış Sorular", style: TextStyle(color: Colors.white)),
        bottom: TabBar(
dividerColor:Color(0xff2d2e83),
          indicatorColor: Colors.white,
          unselectedLabelColor: Colors.white,
          labelColor: Colors.white,
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

        controller: _tabController,
        children: [
          // Toplama Soruları Sekmesi
          _buildSoruListesi("Toplama"),
          // Çıkarma Soruları Sekmesi
          _buildSoruListesi("Çıkarma"),
          // Bölme Soruları Sekmesi
          _buildSoruListesi("Bölme"),
          // Çarpma Soruları Sekmesi
          _buildSoruListesi("Çarpma"),
        ],
      ),
    );
  }
}