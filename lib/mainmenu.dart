import 'dart:convert';
import 'package:carpim_tablosu/carpim_tablosu.dart';
import 'package:carpim_tablosu/quiz.dart';
import 'package:carpim_tablosu/yanlis_cevaplar.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';


class Mainmenu extends StatefulWidget {
  int? mevcutPuan;
  List<Map<String, dynamic>> yanlisSorular;
  Mainmenu({this.mevcutPuan , required this.yanlisSorular});

  @override
  State<Mainmenu> createState() => _MainmenuState();
}

class _MainmenuState extends State<Mainmenu> {

  // En yüksek skoru cihaz hafızasından yükleme
  Future<void> _loadHighestScore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      widget.mevcutPuan = prefs.getInt('highestScore') ?? 0;
    });
  }

  // Yeni en yüksek skoru hafızaya kaydetme
  Future<void> _saveHighestScore() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('highestScore', widget.mevcutPuan!);
  }

  Future<void> _loadYanlisSorular() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? storedList = prefs.getStringList('yanlisSorular');

    if (storedList != null) {
      setState(() {
        widget.yanlisSorular = storedList.map((e) => Map<String, dynamic>.from(jsonDecode(e))).toList();
      });
    }
  }


  @override
  void initState() {
    super.initState();
    _loadHighestScore();
    _loadYanlisSorular();

  }

  // Mevcut puanı ana menüye gönderiyoruz
  final String _url = 'https://instagram.com/alihangedikcom';

  @override
  Widget build(BuildContext context) {

    Future<void> _launchUrl() async {
      if (!await launchUrl(Uri.parse(_url))) {
        throw Exception('Could not launch $_url');
      }
    }


    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Color(0xff2d2e83),
        title: Text('Çarpım Tablosu', style: TextStyle(color: Colors.white)),
        centerTitle: true,

      ),
      body: Container(
        decoration: BoxDecoration(
         color: Colors.white,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Mevcut puan göstergesi
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Image.asset("assets/carpim_tablosu.png", width: 320),
                    SizedBox(height: 40),
                    Text(
                      'En Yüksek Puanın',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Color(0xff2d2e83),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      '${widget.mevcutPuan}',
                      style: TextStyle(
                        fontSize: 50,
                        fontWeight: FontWeight.w900,
                        color: Color(0xff2d2e83),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),

              // "Tekrar Oyna" Butonu
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xff2d2e83),
                      padding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: () {
                      int yeniPuan = 0;
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => QuizEkrani(yeniPuan: yeniPuan,)),
                      );
                    },
                    child: Container(
                      width: 180,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.play_arrow_rounded,
                            size: 40,
                            color: Colors.white,
                          ),
                          Text("Oyuna Başla",
                              style:
                                  TextStyle(fontSize: 20, color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xff2d2e83),
                      padding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => CarpimTablosuSayfasi()),
                      );
                    },
                    child: Container(
                      width: 40,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.calculate_rounded,
                            size: 40,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2),
              Container(
                width: 300,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xff2d2e83),
                    padding:
                    EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Text("Yanlış Soruları Gör", style: TextStyle(color: Colors.white)),
                  onPressed:  () {
                    var yanlisSorular = widget.yanlisSorular;
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => YanlisSorularSayfasi(yanlisSorular: yanlisSorular ,

                        ),
                      ),
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Designed by", style: TextStyle(color: Colors.black54)),
                  TextButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(Colors.transparent),
                      foregroundColor: WidgetStateProperty.all(Colors.transparent),
                      shadowColor: WidgetStateProperty.all(Colors.transparent),
                      overlayColor: WidgetStateProperty.all(Colors.transparent),
                      padding: WidgetStateProperty.all(
                        EdgeInsets.only(left: 3),
                      ),
                    ),
                    onPressed: () {
                      _launchUrl();
                    },
                    child: Container(
                        child: Text("@alihangedikcom",
                            style: TextStyle(color: Colors.black54))),
                  )
                ],
              ),

            ],
          ),
        ),
      ),
    );
  }
}
