import 'package:flutter/material.dart';

class CarpimTablosuSayfasi extends StatefulWidget {
  @override
  _CarpimTablosuSayfasiState createState() => _CarpimTablosuSayfasiState();
}

class _CarpimTablosuSayfasiState extends State<CarpimTablosuSayfasi> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  // İşlem kartı oluşturma fonksiyonu
  Widget _buildIslemKart(String islemAdi, String aciklama, String ornek) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              islemAdi,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            SizedBox(height: 10),
            Text(
              aciklama,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: Text(

                "Örnek: $ornek",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Toplama işlemi açıklaması ve etkileşimli örnek
  Widget _buildToplamaAciklamasi() {
    return Column(
      children: [
        _buildIslemKart(
          "Toplama",
          "Toplama, iki veya daha fazla sayıyı birleştirerek büyük bir sayı elde etme işlemidir.",
          "3 + 2 = 5",
        ),
        SizedBox(height: 20),
        Text(
          "Örnek: 2 elma + 3 elma = 5 elma.",
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
        SizedBox(height: 10),
        Text(
          "Şimdi sen de dene: 5 elma + 4 elma = ?",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ],
    );
  }

  // Çıkarma işlemi açıklaması ve etkileşimli örnek
  Widget _buildCikarmaAciklamasi() {
    return Column(
      children: [
        _buildIslemKart(
          "Çıkarma",
          "Çıkarma, bir sayıdan başka bir sayıyı çıkararak kalan sayıyı bulma işlemidir.",
          "5 - 3 = 2",
        ),
        SizedBox(height: 20),
        Text(
          "Örnek: 5 elma - 3 elma = 2 elma.",
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
        SizedBox(height: 10),
        Text(
          "Şimdi sen de dene: 7 elma - 4 elma = ?",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ],
    );
  }

  // Bölme işlemi açıklaması ve etkileşimli örnek
  Widget _buildBolmeAciklamasi() {
    return Column(
      children: [
        _buildIslemKart(
          "Bölme",
          "Bölme, bir sayıyı başka bir sayıya eşit parçalara ayırma işlemidir.",
          "12 ÷ 3 = 4",
        ),
        SizedBox(height: 20),
        Text(
          "Örnek: 12 elma, 3 arkadaşa eşit paylaştırılıyor. Her biri 4 elma alır.",
          style: TextStyle(fontSize: 18, color: Colors.white), textAlign: TextAlign.center,
        ),
        SizedBox(height: 10),
        Text(
          "Şimdi sen de dene: 15 elma, 5 arkadaşa paylaştırılıyor. Her biri kaç elma alır?",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white) , textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // Çarpma işlemi açıklaması ve etkileşimli örnek
  Widget _buildCarpmaAciklamasi() {
    return Column(
      children: [
        _buildIslemKart(
          "Çarpma",
          "Çarpma, bir sayıyı tekrar tekrar toplama işlemidir.",
          "3 x 2 = 6",
        ),
        SizedBox(height: 20),
        Text(
          "Örnek: 3 grup, her grupta 2 elma var. Toplam 6 elma eder.",
          style: TextStyle(fontSize: 18, color: Colors.white), textAlign: TextAlign.center,
        ),
        SizedBox(height: 10),
        Text(
          "Şimdi sen de dene: 4 grup, her grupta 3 elma var. Toplam kaç elma eder?",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Nasıl Yaparım?', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xff2d2e83),
        bottom: TabBar(
          indicatorColor: Colors.white,
          unselectedLabelColor: Colors.white,
          labelColor: Colors.white,
          dividerColor: Color(0xff2d2e83),
          controller: _tabController,
          tabs: [
            Tab(text: "Toplama"),
            Tab(text: "Çıkarma"),
            Tab(text: "Bölme"),
            Tab(text: "Çarpma"),
          ],
        ),
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Color(0xff2d2e83),
        ),
        child: TabBarView(

          controller: _tabController,
          children: [
            // Toplama kartları ve etkileşimli örnek
            SingleChildScrollView(
              padding: EdgeInsets.symmetric(vertical: 30, horizontal: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildToplamaAciklamasi(),
                ],
              ),
            ),
            // Çıkarma kartları ve etkileşimli örnek
            SingleChildScrollView(
              padding: EdgeInsets.symmetric(vertical: 30, horizontal: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildCikarmaAciklamasi(),
                ],
              ),
            ),
            // Bölme kartları ve etkileşimli örnek
            SingleChildScrollView(
              padding: EdgeInsets.symmetric(vertical: 30, horizontal: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildBolmeAciklamasi(),
                ],
              ),
            ),
            // Çarpma kartları ve etkileşimli örnek
            SingleChildScrollView(
              padding: EdgeInsets.symmetric(vertical: 30, horizontal: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildCarpmaAciklamasi(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}