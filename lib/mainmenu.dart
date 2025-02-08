import 'dart:convert';
import 'package:carpim_tablosu/carpim_tablosu.dart';
import 'package:carpim_tablosu/quiz.dart';
import 'package:carpim_tablosu/yanlis_cevaplar.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'islem_secme.dart';

class Mainmenu extends StatefulWidget {
  int? mevcutPuan;
  List<Map<String, dynamic>> yanlisSorular;

  Mainmenu({this.mevcutPuan, required this.yanlisSorular});

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
        widget.yanlisSorular = storedList
            .map((e) => Map<String, dynamic>.from(jsonDecode(e)))
            .toList();
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

      body: Container(
        decoration: BoxDecoration(
          color: Color(0xff2d2e83),
        ),
        child: Center(
          child: Stack(
            children: [
              Image.asset("assets/backgroud_image_2.png" , width: double.infinity, height: double.infinity, fit: BoxFit.cover,),
              Center(
                child: Container(
                  height: 800,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Mevcut puan göstergesi
                      Padding(
                        padding: const EdgeInsets.only(top:  150.0),
                        child: Image.asset("assets/carpim_tablosu.png", width: 300, color: Colors.white,),
                      ),

                      SizedBox(height: 120),

                      // "Tekrar Oyna" Butonu
                      Container(

                        height: 180,
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    padding:
                                        EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                  onPressed: () {
                                    int yeniPuan = 0;
                                    // Navigator.of(context).pushReplacement(
                                    //   MaterialPageRoute(builder: (context) => QuizEkrani(yeniPuan: yeniPuan,)),
                                    // );

                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (context) => IslemTuruSecimEkrani()),
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
                                          color: Color(0xff2d2e83),
                                        ),
                                        Text("Oyuna Başla",
                                            style:
                                                TextStyle(fontSize: 20, color: Color(0xff2d2e83))),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(width: 20),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
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
                                          color: Color(0xff2d2e83),
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
                                  backgroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                child: Text("Yanlış Soruları Gör",
                                    style: TextStyle(color: Color(0xff2d2e83))),
                                onPressed: () {
                                  var yanlisSorular = widget.yanlisSorular;
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => YanlisSorularTabView(),
                                    ),
                                  );
                                },
                              ),
                            ),Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Designed by", style: TextStyle(color: Colors.white54)),
                                TextButton(
                                  style: ButtonStyle(
                                    backgroundColor:
                                    WidgetStateProperty.all(Colors.transparent),
                                    foregroundColor:
                                    WidgetStateProperty.all(Colors.transparent),
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
                                          style: TextStyle(color: Colors.white54))),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),

                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
