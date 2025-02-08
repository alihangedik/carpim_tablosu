import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'mainmenu.dart';

class YanlisSorularSayfasi extends StatefulWidget {
  @override
  State<YanlisSorularSayfasi> createState() => _YanlisSorularSayfasiState();
}

class _YanlisSorularSayfasiState extends State<YanlisSorularSayfasi> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _yanlisSorular = [];


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadYanlisSorular();
  }

  // ✅ Yanlış Soruları SharedPreferences'tan Yükleme
  Future<void> _loadYanlisSorular() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? encodedList = prefs.getStringList('yanlisSorular');

    if (encodedList != null) {
      setState(() {
        _yanlisSorular = encodedList.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
      });
    }
  }

  // ✅ Yanlış Soruları Kalıcı Olarak Saklama
  Future<void> _saveYanlisSorular() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> encodedList = _yanlisSorular.map((e) => jsonEncode(e)).toList();
    await prefs.setStringList('yanlisSorular', encodedList);
  }

  // ✅ Yanlış Soru Ekleme ve Güncelleme
  Future<void> addYanlisSoru(Map<String, dynamic> yeniSoru) async {
    setState(() {
      _yanlisSorular.add(yeniSoru);
    });
    await _saveYanlisSorular();
  }

  // ✅ Yanlış Soruyu Silme
  void _removeSoru(int index) {
    setState(() {
      _yanlisSorular.removeAt(index);
    });
    _saveYanlisSorular();
  }

  // ✅ Kategoriye Göre Yanlış Soruları Getir
  List<Map<String, dynamic>> _getSorularByKategori(String kategori) {
    return _yanlisSorular.where((soru) => soru['kategori'] == kategori).toList();
  }

  // ✅ Listeyi Oluşturma
  Widget _buildSoruListesi(String kategori) {
    List<Map<String, dynamic>> filtrelenmisSorular = _getSorularByKategori(kategori);

    if (filtrelenmisSorular.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("🎉", style: TextStyle(fontSize: 100)),
            SizedBox(height: 20),
            Text(
              'Tebrikler! \nBu kategoride yanlışın yok!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: filtrelenmisSorular.length,
      itemBuilder: (context, index) {
        final soru = filtrelenmisSorular[index];
        return Dismissible(
          key: Key(soru['soru']),
          direction: DismissDirection.startToEnd,
          background: Container(
            alignment: Alignment.centerRight,
            padding: EdgeInsets.symmetric(horizontal: 20),
            color: Colors.green,
            child: Row(
              children: [
                Icon(Icons.check, color: Colors.white, size: 30),
                Text('Bu soruyu anladım', style: TextStyle(color: Colors.white, fontSize: 20)),
              ],
            ),
          ),
          onDismissed: (direction) {
            _removeSoru(_yanlisSorular.indexOf(soru));
          },
          child: Card(
            color: Color(0xff2d2e83),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🧐 Soru: ${soru['soru']}',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.check, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Doğru Cevap: ${soru['dogruCevap']}',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.close, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Senin Cevabın: ${soru['yanlisCevap']}',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => Mainmenu(yanlisSorular: _yanlisSorular,),
              ),
                  (route) => false,
            );
          },
        ),
        backgroundColor: Color(0xff2d2e83),
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'Yanlış Bilinen Sorular',
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(text: "Toplama"),
            Tab(text: "Çıkarma"),
            Tab(text: "Çarpma"),
            Tab(text: "Bölme"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSoruListesi("Toplama"),
          _buildSoruListesi("Çıkarma"),
          _buildSoruListesi("Çarpma"),
          _buildSoruListesi("Bölme"),
        ],
      ),
    );
  }
}