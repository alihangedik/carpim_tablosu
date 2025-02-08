import 'dart:async';
import 'dart:math';
import 'package:carpim_tablosu/quiz.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';



class IslemTuruSecimEkrani extends StatefulWidget {
  @override
  _IslemTuruSecimEkraniState createState() => _IslemTuruSecimEkraniState();
}

class _IslemTuruSecimEkraniState extends State<IslemTuruSecimEkrani> {
  int enYuksekToplamaSkor = 0;
  int enYuksekCikarmaSkor = 0;
  int enYuksekBolmeSkor = 0;
  int enYuksekCarpmaSkor = 0;

  @override
  void initState() {
    super.initState();
    _loadEnYuksekSkorlar();
    setState(() {
      enYuksekToplamaSkor = 0;
      enYuksekCikarmaSkor = 0;
      enYuksekBolmeSkor = 0;
      enYuksekCarpmaSkor = 0;
    });
  }

  // SharedPreferences'dan en yüksek skorları yükleyen fonksiyon
  Future<void> _loadEnYuksekSkorlar() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      enYuksekToplamaSkor = prefs.getInt('toplama') ?? 0;
      enYuksekCikarmaSkor = prefs.getInt('cikarma') ?? 0;
      enYuksekBolmeSkor = prefs.getInt('bolme') ?? 0;
      enYuksekCarpmaSkor = prefs.getInt('carpma') ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('İşlem Türü Seç'),
        backgroundColor: Color(0xFF4CAF50),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CalismaEkrani(islemTuru: 'Toplama')),
                );
              },
              child: Text('Toplama - En Yüksek Skor: $enYuksekToplamaSkor'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CalismaEkrani(islemTuru: 'Çıkarma')),
                );
              },
              child: Text('Çıkarma - En Yüksek Skor: $enYuksekCikarmaSkor'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CalismaEkrani(islemTuru: 'Bölme')),
                );
              },
              child: Text('Bölme - En Yüksek Skor: $enYuksekBolmeSkor'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CalismaEkrani(islemTuru: 'Çarpma')),
                );
              },
              child: Text('Çarpma - En Yüksek Skor: $enYuksekCarpmaSkor'),
            ),
          ],
        ),
      ),
    );
  }
}



