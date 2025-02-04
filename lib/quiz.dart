import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:math';

import 'package:carpim_tablosu/yanlis_cevaplar.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'mainmenu.dart';

class QuizEkrani extends StatefulWidget {
  final int yeniPuan;

  const QuizEkrani({super.key, required this.yeniPuan});

  @override
  _QuizEkraniState createState() => _QuizEkraniState();
}

class _QuizEkraniState extends State<QuizEkrani> {
  Map<String, dynamic> mevcutSoru = {};
  int puan = 0;
  int highestScore = 0;
  int kalanSure = 0; // Her soru için süre (saniye)
  Timer? timer;
  List<Map<String, dynamic>> yanlisSorular = [];
  List secilenCevaplar = [];

  @override
  void initState() {
    super.initState();
    sonrakiSoru();
    puan = widget.yeniPuan;
    _loadHighestScore();
    _loadYanlisSorular();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

// En yüksek skoru cihaz hafızasından yükleme
  Future<void> _loadHighestScore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      highestScore = prefs.getInt('highestScore') ?? 0;
    });
  }

  // Yeni en yüksek skoru hafızaya kaydetme
  Future<void> _saveHighestScore() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('highestScore', highestScore);
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
  Future<void> _saveYanlisSorular() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> encodedList = yanlisSorular.map((e) => jsonEncode(e)).toList();
    await prefs.setStringList('yanlisSorular', encodedList);
  }

  void sonrakiSoru() {
    // Zamanlayıcıyı sıfırla
    timer?.cancel();
    kalanSure = 15;

    // Yeni soru ayarla
    setState(() {
      mevcutSoru = rastgeleSoruUret();
    });

    // Zamanlayıcı başlat
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
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

  void kontrolEt(int dogruCevap, String soruMetni, int yanlisCevap) {
    if (dogruCevap != yanlisCevap) {
      yanlisSorular.add({
        'soru': soruMetni,
        'dogruCevap': dogruCevap,
        'yanlisCevap': yanlisCevap,
      });
      _saveYanlisSorular();
    }
  }

  void cevapKontrol(int secilenCevap) {
    if (secilenCevap == mevcutSoru['dogruCevap']) {
      setState(() {
        puan++;
        if (puan > highestScore) {
          highestScore = puan;
          _saveHighestScore();
        }
      });
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
    } else {
      kontrolEt(mevcutSoru["dogruCevap"], mevcutSoru["soru"], secilenCevap);
      developer.log("Yanlış sorular: $yanlisSorular");
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        // false = kullanıcı dışarıya dokunarak dialogu kapatamaz
        builder: (BuildContext dialogContext) {
          kalanSure = 0;

          timer?.cancel(); // Zamanlayıcıyı durdur

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
                  setState(() {
                    puan = 0;
                  });
                  Navigator.of(dialogContext).pop(); // Dialogu kapat
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
                          builder: (context) =>
                              Mainmenu(mevcutPuan: highestScore, yanlisSorular: yanlisSorular,)),
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
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (context) => YanlisSorularSayfasi(
                              yanlisSorular: yanlisSorular,
                            )),
                  );
                },
              ),
            ],
          );
        },
      );
    }
    sonrakiSoru();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                                  Mainmenu(mevcutPuan: highestScore , yanlisSorular: yanlisSorular,)),
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
        title: Text('Çarpım Tablosu', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xff2d2e83),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            child: mevcutSoru.isEmpty
                ? Center(child: CircularProgressIndicator())
                : Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Süre göstergesi
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
                                        ? Colors.green
                                        : kalanSure > 1
                                            ? Colors.orange
                                            : Colors.red,
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
                                      ? Colors.green
                                      : kalanSure > 1
                                          ? Colors.orange
                                          : Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 30),

                        // Soru
                        Padding(
                          padding: const EdgeInsets.only(bottom: 80.0, top: 20),
                          child: AnimatedSwitcher(
                            duration: Duration(milliseconds: 100),
                            transitionBuilder:
                                (Widget child, Animation<double> animation) {
                              return SlideTransition(

                                position: Tween<Offset>(

                                  begin:
                                      Offset(0.0, 1.0), // Aşağıdan yukarı kayar
                                  end: Offset.zero,
                                ).animate(animation),
                                child: child,
                              );
                            },
                            child: Container(
                              key: ValueKey(mevcutSoru['soru']),
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Color(0xff2d2e83),
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
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Seçenekler
                        ...mevcutSoru['cevaplar'].asMap().entries.map((entry) {
                          int index = entry.key;
                          int cevap = entry.value;

                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Color(0xff2d2e83),
                                  width: 0.5,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              width: 250,
                              child: AnimatedContainer(
                                duration: Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                width: 250,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color:Color(0xff2d2e83), width: 1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 32),
                                  ),
                                  onPressed: () {
                                    timer?.cancel(); // Zamanlayıcıyı durdur
                                    cevapKontrol(cevap);
                                  },
                                  child: Text(
                                    '$cevap',
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
                        }).toList(),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "En Yüksek Puan: ",
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xff2d2e83)),
                            ),
                            Container(
                              width: 30,
                              child: Text(
                                '$highestScore',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xff2d2e83),
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Puan göstergesi
                      ],
                    ),
                  ),
          ),
          Positioned(
            right: 20,
            top: 20,
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
                      color: Color(0xff2d2e83),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Rastgele soru üretme fonksiyonu
Map<String, dynamic> rastgeleSoruUret() {
  int sayi1 = Random().nextInt(10) + 1;
  int sayi2 = Random().nextInt(10) + 1;
  int dogruCevap = sayi1 * sayi2;

  List<int> cevaplar = [
    dogruCevap,
    Random().nextInt(100),
    Random().nextInt(100),
    Random().nextInt(100),
  ]..shuffle();

  return {
    "soru": "$sayi1 x $sayi2 = ?",
    "cevaplar": cevaplar,
    "dogruCevap": dogruCevap,
  };
}
