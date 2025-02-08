import 'dart:async';
import 'dart:math';
import 'package:carpim_tablosu/quiz.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
      backgroundColor: Color(0xff2d2e83),
      appBar: AppBar(
automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('İşlem Türü Seç', style: TextStyle(color: Colors.white , fontSize: 20, fontWeight: FontWeight.bold)),
        backgroundColor: Color(0xff2d2e83),
      ),
      body: Center(
        child: Stack(
          children: [
            Positioned(bottom: -10, right: 0, left: 0, child: Opacity(opacity: 0.4, child: Image.asset("assets/backgroud_image.png" , fit: BoxFit.cover,))),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                GridView(gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
                  physics: NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.all(16),
                  shrinkWrap: true,
                  children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xff2d2e83),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    height: 150,
                    width: 150,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        foregroundColor: Colors.transparent,
                        overlayColor: Colors.transparent
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => CalismaEkrani(islemTuru: 'Toplama')),
                        );
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FaIcon(FontAwesomeIcons.plus, color: Colors.white, size: 50),
                          Text('Toplama İşlemi' , style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(Icons.star, color: Colors.white, size: 20),
                              Text('$enYuksekToplamaSkor', style: TextStyle(color: Colors.white, fontSize: 25 , fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xff2d2e83),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    height: 200,
                    width: 200,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          foregroundColor: Colors.transparent,
                          overlayColor: Colors.transparent
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => CalismaEkrani(islemTuru: 'Çıkarma')),
                        );
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FaIcon(FontAwesomeIcons.minus, color: Colors.white, size: 50),
                          Text('Çıkarma İşlemi' , style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(Icons.star, color: Colors.white, size: 20),
                              Text('$enYuksekCikarmaSkor', style: TextStyle(color: Colors.white, fontSize: 25 , fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color(0xff2d2e83),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        height: 200,
                        width: 200,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              foregroundColor: Colors.transparent,
                              overlayColor: Colors.transparent
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => CalismaEkrani(islemTuru: 'Bölme')),
                            );
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                             FaIcon(FontAwesomeIcons.divide, color: Colors.white, size: 50),
                              SizedBox(height: 10),
                              Text('Bölme İşlemi' , style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(Icons.star, color: Colors.white, size: 20),
                                  Text('$enYuksekBolmeSkor', style: TextStyle(color: Colors.white, fontSize: 25 , fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color(0xff2d2e83),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        height: 200,
                        width: 200,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              foregroundColor: Colors.transparent,
                              overlayColor: Colors.transparent
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => CalismaEkrani(islemTuru: 'Çarpma')),
                            );
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              FaIcon(FontAwesomeIcons.close, color: Colors.white, size: 50),
                              Text('Çarpma İşlemi' , style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(Icons.star, color: Colors.white, size: 20),
                                  Text('$enYuksekCarpmaSkor', style: TextStyle(color: Colors.white, fontSize: 25 , fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                          ],
                        ),

                  ]),
          ],
        ),
    ));
  }
}



