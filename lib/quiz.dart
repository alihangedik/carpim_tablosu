import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:developer' as developer;
import 'package:carpim_tablosu/mainmenu.dart';
import 'package:carpim_tablosu/provider.dart';
import 'package:carpim_tablosu/yanlis_cevaplar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CalismaEkrani extends StatefulWidget {
  final String islemTuru;

  CalismaEkrani({required this.islemTuru});

  @override
  _CalismaEkraniState createState() => _CalismaEkraniState();
}

class _CalismaEkraniState extends State<CalismaEkrani> {
  int puan = 0;
  int kalanSure = 15;
  Timer? _timer;
  late String islemTuru;
  late String currentIslemTuru;
  late Map<String, dynamic> mevcutSoru;
  List<Map<String, dynamic>> yanlisSorular = [];

  // En yüksek skorlara ait değişkenler
  int enYuksekToplamaSkor = 0;
  int enYuksekCikarmaSkor = 0;
  int enYuksekBolmeSkor = 0;
  int enYuksekCarpmaSkor = 0;

  @override
  void initState() {
    super.initState();
    islemTuru = widget.islemTuru;
    currentIslemTuru = islemTuru;
    _loadEnYuksekSkorlar();
    sonrakiSoru();
  }

  void sonrakiSoru() {
    // Zamanlayıcıyı sıfırla
    _timer?.cancel();
    kalanSure = 15;

    // Yeni soru ayarla
    setState(() {
      mevcutSoru = rastgeleSoruUret(islemTuru);
    });

    // Zamanlayıcı başlat
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (kalanSure > 0) {
        setState(() {
          kalanSure--;
        });
      } else {
        // Süre doldu, bir sonraki soruya geç
        timer.cancel();
        sonrakiSoru();
      }
    });
  }

  Map<String, dynamic> rastgeleSoruUret(String islemTuru) {
    int sayi1 = Random().nextInt(10) + 1;
    int sayi2 = Random().nextInt(10) + 1;
    late String soru;
    late int dogruCevap;
    late List<int> cevaplar;

    switch (islemTuru) {
      case 'Toplama':
        soru = '$sayi1 + $sayi2 = ?';
        dogruCevap = sayi1 + sayi2;
        break;
      case 'Çıkarma':
        soru = '$sayi1 - $sayi2 = ?';
        dogruCevap = sayi1 - sayi2;
        break;
      case 'Bölme':
        sayi1 = sayi2 * (Random().nextInt(9) + 1);
        soru = '$sayi1 ÷ $sayi2 = ?';
        dogruCevap = sayi1 ~/ sayi2;
        break;
      case 'Çarpma':
        soru = '$sayi1 × $sayi2 = ?';
        dogruCevap = sayi1 * sayi2;
        break;
      default:
        soru = '';
        dogruCevap = 0;
    }

    cevaplar = [dogruCevap];
    while (cevaplar.length < 4) {
      int yanlisCevap = Random().nextInt(20) + 1;
      if (!cevaplar.contains(yanlisCevap)) {
        cevaplar.add(yanlisCevap);
      }
    }
    cevaplar.shuffle();

    return {'soru': soru, 'cevaplar': cevaplar, 'dogruCevap': dogruCevap};
  }
  Future<void> _loadYanlisSorular() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? storedList = prefs.getStringList('yanlisSorular');

    if (storedList != null) {
      setState(() {
        yanlisSorular = storedList.map((e) => Map<String, dynamic>.from(jsonDecode(e))).toList();
      });
    }
  }

// Yanlış soruları hafızaya kaydetme
  Future<void> saveYanlisSorularToPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Her öğeyi JSON stringe çevir ve liste olarak kaydet
    List<String> jsonList = yanlisSorular.map((item) => json.encode(item)).toList();

    await prefs.setStringList('yanlisSorular', jsonList); // Listeyi SharedPreferences'a kaydet


  }

  void cevapKontrol(int verilenCevap) {
    if (verilenCevap == mevcutSoru['dogruCevap']) {
      setState(() {
        puan++;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text(
              'Doğru! Harikasın! 🎉',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 25),
            ),
            duration: Duration(milliseconds: 500),
          ),
        );
      });
    } else {
      kontrolEt(mevcutSoru['dogruCevap'], mevcutSoru['soru'], verilenCevap,);
      // Yanlış cevap verildiğinde alert dialog aç
      _showWrongAnswerDialog();
    }
    sonrakiSoru();
  }
  void kontrolEt(int dogruCevap, String soruMetni, int yanlisCevap) {
    if (dogruCevap != yanlisCevap) {
      final provider = Provider.of<YanlisSorularProvider>(context, listen: false);
      provider.yanlisSorular.add({
        'soru': soruMetni,
        'dogruCevap': dogruCevap.toString(),
        'yanlisCevap': yanlisCevap.toString(),
        'kategori': currentIslemTuru,
      });


      provider.saveYanlisSorularToPrefs();
    }
  }
  void _showWrongAnswerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        _timer?.cancel();
        return AlertDialog(
          actionsOverflowAlignment: OverflowBarAlignment.center,
          // Butonları ortala
          backgroundColor: Colors.white,
          // Arka plan rengi
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), // Yumuşak kenarlar
          ),
          title: Column(
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 50,
                color: Colors.redAccent, // İkon rengi
              ),
              SizedBox(height: 10),
              Text(
                'Maalesef Yanlış!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent,
                ),
              ),
            ],
          ),
          content: Text(
            'Tekrar denemek ister misin?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          // Butonları ortala
          actions: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, // Buton arka plan rengi
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(15), // Yuvarlatılmış buton
                ),
              ),
              onPressed: () {

                Navigator.of(context).pop(); // Dialogu kapat
                setState(() {
                  sonrakiSoru();
                });
              },
              child: Text(
                'Tekrar Dene',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (context) => Mainmenu(mevcutPuan: puan, yanlisSorular: yanlisSorular,)),
                    (route) => false);
              },
              child: Text(
                'Ana Menü',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.question_mark,
                color: Colors.orangeAccent,
              ),
              onPressed: () {
               setState(() {
                 Provider.of<YanlisSorularProvider>(context, listen: false).loadYanlisSorularFromPrefs();
               });
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => YanlisSorularTabView()),
                );

              },
            ),
          ],
        );
      },
    );
  }

  // En yüksek skoru güncelleyen fonksiyon
  void enYuksekSkoruKontrolEt() {
    switch (currentIslemTuru) {
      case 'Toplama':
        if (puan > enYuksekToplamaSkor) {
          setState(() {
            enYuksekToplamaSkor = puan;
          });
          _saveEnYuksekSkor('toplama', enYuksekToplamaSkor);
        }
        break;
      case 'Çıkarma':
        if (puan > enYuksekCikarmaSkor) {
          setState(() {
            enYuksekCikarmaSkor = puan;
          });
          _saveEnYuksekSkor('cikarma', enYuksekCikarmaSkor);
        }
        break;
      case 'Bölme':
        if (puan > enYuksekBolmeSkor) {
          setState(() {
            enYuksekBolmeSkor = puan;
          });
          _saveEnYuksekSkor('bolme', enYuksekBolmeSkor);
        }
        break;
      case 'Çarpma':
        if (puan > enYuksekCarpmaSkor) {
          setState(() {
            enYuksekCarpmaSkor = puan;
          });
          _saveEnYuksekSkor('carpma', enYuksekCarpmaSkor);
        }
        break;
    }
  }

  Future<void> _loadEnYuksekSkorlar() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      enYuksekToplamaSkor = prefs.getInt('toplama') ?? 0;
      enYuksekCikarmaSkor = prefs.getInt('cikarma') ?? 0;
      enYuksekBolmeSkor = prefs.getInt('bolme') ?? 0;
      enYuksekCarpmaSkor = prefs.getInt('carpma') ?? 0;
    });
  }

  Future<void> _saveEnYuksekSkor(String islemTuru, int skor) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt(islemTuru, skor);
  }

  @override
  void dispose() {
    enYuksekSkoruKontrolEt();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    enYuksekSkoruKontrolEt();

    return Stack(
      children: [Container(color: Color(0xff2d2e83)),
        Positioned(bottom: -5, right: 0, left: 0, child: Opacity(opacity: 0.4, child: Image.asset("assets/backgroud_image_3.png" , width: 500,))),

        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(

            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    actionsOverflowAlignment: OverflowBarAlignment.center,
                    // Butonları ortala
                    backgroundColor: Colors.white,
                    // Arka plan rengi
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20), // Yumuşak kenarlar
                    ),
                    title: Column(
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          size: 50,
                          color: Colors.redAccent, // İkon rengi
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Çıkış Yap',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.redAccent,
                          ),
                        ),
                      ],
                    ),
                    content: Text(
                      'Çıkmak istediğinize emin misin? Çıkarsanız puanlarınız kaybolacak.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    actionsAlignment: MainAxisAlignment.center,
                    // Butonları ortala
                    actions: <Widget>[
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          // Buton arka plan rengi
                          shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(15), // Yuvarlatılmış buton
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(dialogContext).pop(); // Dialogu kapat
                        },
                        child: Text(
                          'Hayır',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                  builder: (context) =>
                                      Mainmenu(mevcutPuan: puan, yanlisSorular: yanlisSorular,)),
                                  (route) => false);
                        },
                        child: Text(
                          'Evet',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal:  30.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.star,
                      color: Colors.orange,
                      size: 30,
                    ),
                    SizedBox(width: 5),
                    Container(
                      child: Text(
                        '$puan',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            backgroundColor: Color(0xff2d2e83),
          ),
          body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[

                Container(
                  alignment: Alignment.center,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        height: 100,
                        width: 100,
                        child: CircularProgressIndicator(
                          value: kalanSure / 15,
                          valueColor: AlwaysStoppedAnimation(
                            kalanSure > 3
                                ? Colors.white
                                : kalanSure > 1
                                    ? Colors.orangeAccent
                                    : Colors.redAccent,
                          ),
                          strokeWidth: 10,
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                      Text(
                        '$kalanSure',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: kalanSure > 3
                              ? Colors.white
                              : kalanSure > 1
                                  ? Colors.orangeAccent
                                  : Colors.redAccent,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 60),
                Padding(
                  padding: const EdgeInsets.only(bottom: 80.0, top: 20),
                  child: AnimatedSwitcher(
                    duration: Duration(milliseconds: 200),
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return SlideTransition(
                        position: Tween<Offset>(
                          begin: Offset(0.0, .5), // Aşağıdan yukarı kayar
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      );
                    },
                    child: Container(
                      key: ValueKey(mevcutSoru['soru']),
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Container(
                        width: 250,
                        child: Text(
                          mevcutSoru['soru'],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff2d2e83),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Column(
                  children: List.generate(4, (index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Color(0xff2d2e83),
                            width: 0,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        width: 250,
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 1000),
                          curve: Curves.easeInOut,
                          width: 250,
                          decoration: BoxDecoration(
                            border: Border.all(color: Color(0xff2d2e83), width: 0),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: ElevatedButton(

                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding:
                                  EdgeInsets.symmetric(vertical: 8, horizontal: 32),
                            ),
                            onPressed: () {
                              _timer?.cancel(); // Zamanlayıcıyı durdur
                              cevapKontrol(mevcutSoru['cevaplar'][index]);
                            },
                            child: Text(
                              (mevcutSoru['cevaplar'][index]).toString(),
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xff2d2e83),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                SizedBox(height: 20),
                Text(
                  'En Yüksek Skor: ${getEnYuksekSkor()}',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String getEnYuksekSkor() {
    switch (currentIslemTuru) {
      case 'Toplama':
        return enYuksekToplamaSkor.toString();
      case 'Çıkarma':
        return enYuksekCikarmaSkor.toString();
      case 'Bölme':
        return enYuksekBolmeSkor.toString();
      case 'Çarpma':
        return enYuksekCarpmaSkor.toString();
      default:
        return '0';
    }
  }
}
