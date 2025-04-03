import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:developer' as developer;
import 'package:carpim_tablosu/mainmenu.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:just_audio/just_audio.dart';
import './models/level_system.dart';
import './widgets/level_up_screen.dart';
import './widgets/level_progress_bar.dart';

// Rastgele soru üretme için Random 0-9 arası üretiliyor onu 100 ile 0 arasına çek - İsmail Efe Çelik
// Kullanıcının istediğne göre işlem sırasındaki çeşitliliği kontrol et - İsmail Efe Çelik

class CalismaEkrani extends StatefulWidget {
  final String islemTuru;

  CalismaEkrani({required this.islemTuru});

  @override
  _CalismaEkraniState createState() => _CalismaEkraniState();
}

class _CalismaEkraniState extends State<CalismaEkrani>
    with SingleTickerProviderStateMixin {
  int kalanSure = 30;
  Timer? _timer;
  late String islemTuru;
  Map<String, dynamic>? mevcutSoru;
  List<Map<String, dynamic>> yanlisSorular = [];
  bool _isLoading = true; // Yükleme durumu için flag

  late AnimationController _animationController;
  late AudioPlayer _audioPlayer;
  bool _isSoundEnabled = true;

  late LevelSystem levelSystem;
  int streak = 0;
  Timer? _gameTimer;

  List<Map<String, dynamic>> _previousQuestions =
      []; // Son soruları takip etmek için liste
  static const int MAX_PREVIOUS_QUESTIONS =
      10; // Takip edilecek maksimum soru sayısı

  @override
  void initState() {
    super.initState();
    islemTuru = widget.islemTuru;
    _audioPlayer = AudioPlayer();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _initializeQuiz();
  }

  Future<void> _initializeQuiz() async {
    try {
      await _loadSettings();
      await _loadLevelSystem();
      await _loadNextQuestion();
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Quiz başlatma hatası: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bir hata oluştu. Lütfen tekrar deneyin.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isSoundEnabled = prefs.getBool('soundEnabled') ?? true;
      kalanSure = prefs.getInt('question_time') ?? 30;
    });
  }

  Future<void> _playCorrectSound() async {
    if (_isSoundEnabled) {
      try {
        await _audioPlayer.setAsset('assets/sounds/correct_answer.wav');
        await _audioPlayer.play();
      } catch (e) {
        print('Ses çalma hatası: $e');
      }
    }
  }

  Future<void> _playWrongSound() async {
    if (_isSoundEnabled) {
      try {
        await _audioPlayer.setAsset('assets/sounds/wrong_answer.wav');
        await _audioPlayer.play();
      } catch (e) {
        print('Ses çalma hatası: $e');
      }
    }
  }

  Future<void> _loadNextQuestion() async {
    if (!mounted) return;

    _timer?.cancel();
    _gameTimer?.cancel();

    try {
      setState(() {
        mevcutSoru = null;
      });

      final prefs = await SharedPreferences.getInstance();
      final yeniKalanSure = prefs.getInt('question_time') ?? 30;
      final yeniSoru = await rastgeleSoruUret(islemTuru);

      if (!mounted) return;

      setState(() {
        mevcutSoru = yeniSoru;
        kalanSure = yeniKalanSure;
      });

      _startTimer();
    } catch (e) {
      print('Soru üretme hatası: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Soru yüklenirken bir hata oluştu.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<Map<String, dynamic>> rastgeleSoruUret(String islemTuru) async {
    if (!mounted) return {'soru': '', 'cevaplar': [], 'dogruCevap': 0};

    final prefs = await SharedPreferences.getInstance();
    int userAge = prefs.getInt('userAge') ?? 7;
    String difficulty = prefs.getString('difficulty') ?? 'Orta';

    // Yaşa ve zorluk seviyesine göre sayı aralıklarını belirle
    int maxNumber = 10;
    int minNumber = 1;

    if (userAge <= 7) {
      switch (difficulty) {
        case 'Kolay':
          maxNumber = 5;
          minNumber = 1;
          break;
        case 'Orta':
          maxNumber = 10;
          minNumber = 1;
          break;
        case 'Zor':
          maxNumber = 15;
          minNumber = 1;
          break;
        default:
          maxNumber = 10;
          minNumber = 1;
      }
    } else if (userAge <= 9) {
      switch (difficulty) {
        case 'Kolay':
          maxNumber = 10;
          minNumber = 1;
          break;
        case 'Orta':
          maxNumber = 15;
          minNumber = 1;
          break;
        case 'Zor':
          maxNumber = 20;
          minNumber = 1;
          break;
        default:
          maxNumber = 15;
          minNumber = 1;
      }
    } else {
      switch (difficulty) {
        case 'Kolay':
          maxNumber = 15;
          minNumber = 1;
          break;
        case 'Orta':
          maxNumber = 20;
          minNumber = 1;
          break;
        case 'Zor':
          maxNumber = 25;
          minNumber = 1;
          break;
        default:
          maxNumber = 20;
          minNumber = 1;
      }
    }

    Map<String, dynamic> yeniSoru;
    bool soruTekrari;
    int denemeSayisi = 0;
    final maxDeneme = 20;

    do {
      soruTekrari = false;
      int sayi1, sayi2;
      late String soru;
      late int dogruCevap;

      switch (islemTuru) {
        case 'Toplama':
          sayi1 = minNumber + Random().nextInt(maxNumber - minNumber + 1);
          sayi2 = minNumber + Random().nextInt(maxNumber - minNumber + 1);
          soru = '$sayi1 + $sayi2 = ?';
          dogruCevap = sayi1 + sayi2;
          break;

        case 'Çıkarma':
          do {
            sayi1 = minNumber + Random().nextInt(maxNumber - minNumber + 1);
            sayi2 = minNumber + Random().nextInt(sayi1);
          } while (sayi2 >= sayi1 || sayi1 > maxNumber);
          soru = '$sayi1 - $sayi2 = ?';
          dogruCevap = sayi1 - sayi2;
          break;

        case 'Bölme':
          List<int> bolenler = [];
          for (int i = 2; i <= maxNumber; i++) {
            if (i <= maxNumber ~/ i) {
              bolenler.add(i);
            }
          }

          if (bolenler.isEmpty) bolenler = [2];

          // Önceki sorularda kullanılmamış bir bölen seçmeye çalış
          List<int> kullanilmamisBolenler = bolenler.where((bolen) {
            return !_previousQuestions.any((soru) {
              String? soruMetni = soru['soru'] as String?;
              return soruMetni != null && soruMetni.contains('÷ $bolen =');
            });
          }).toList();

          // Eğer tüm bölenler kullanılmışsa, tüm bölenleri tekrar kullan
          sayi2 = kullanilmamisBolenler.isNotEmpty
              ? kullanilmamisBolenler[
                  Random().nextInt(kullanilmamisBolenler.length)]
              : bolenler[Random().nextInt(bolenler.length)];

          // Bölünen sayıyı seç
          List<int> olasiBolunenler = [];
          for (int carpan = 1; carpan <= maxNumber ~/ sayi2; carpan++) {
            int bolunen = sayi2 * carpan;
            if (bolunen <= maxNumber) {
              olasiBolunenler.add(bolunen);
            }
          }

          // Önceki sorularda kullanılmamış bir bölünen seç
          List<int> kullanilmamisBolunenler = olasiBolunenler.where((bolunen) {
            return !_previousQuestions.any((soru) {
              String? soruMetni = soru['soru'] as String?;
              return soruMetni != null && soruMetni.startsWith('$bolunen ÷');
            });
          }).toList();

          sayi1 = kullanilmamisBolunenler.isNotEmpty
              ? kullanilmamisBolunenler[
                  Random().nextInt(kullanilmamisBolunenler.length)]
              : olasiBolunenler[Random().nextInt(olasiBolunenler.length)];

          soru = '$sayi1 ÷ $sayi2 = ?';
          dogruCevap = sayi1 ~/ sayi2;
          break;

        case 'Çarpma':
          sayi1 = minNumber + Random().nextInt(maxNumber ~/ 2);
          sayi2 = minNumber + Random().nextInt(maxNumber ~/ 2);
          soru = '$sayi1 × $sayi2 = ?';
          dogruCevap = sayi1 * sayi2;
          break;

        default:
          return {'soru': '', 'cevaplar': [], 'dogruCevap': 0};
      }

      // Cevap şıklarını üret
      Set<int> cevaplar = {dogruCevap};
      int maxYanlisCevap =
          islemTuru == 'Çarpma' ? dogruCevap * 2 : dogruCevap + maxNumber;

      while (cevaplar.length < 4) {
        int yanlisCevap;
        if (Random().nextBool() && islemTuru != 'Bölme') {
          // Doğru cevaba yakın bir sayı üret
          yanlisCevap = dogruCevap + (Random().nextInt(5) - 2);
        } else {
          // Rastgele bir sayı üret
          switch (islemTuru) {
            case 'Bölme':
              yanlisCevap = 1 + Random().nextInt(maxNumber ~/ 2);
              break;
            case 'Çarpma':
              yanlisCevap = 1 + Random().nextInt(maxYanlisCevap);
              break;
            default:
              yanlisCevap =
                  minNumber + Random().nextInt(maxYanlisCevap - minNumber + 1);
          }
        }
        if (yanlisCevap > 0) {
          cevaplar.add(yanlisCevap);
        }
      }

      List<int> karisikCevaplar = cevaplar.toList()..shuffle();
      yeniSoru = {
        'soru': soru,
        'cevaplar': karisikCevaplar,
        'dogruCevap': dogruCevap
      };

      // Son sorularla karşılaştır
      soruTekrari = _previousQuestions.any((oncekiSoru) =>
          oncekiSoru['soru'] == yeniSoru['soru'] ||
          oncekiSoru['dogruCevap'] == yeniSoru['dogruCevap']);

      denemeSayisi++;
    } while (soruTekrari && denemeSayisi < maxDeneme);

    // Yeni soruyu listeye ekle ve eski soruları temizle
    _previousQuestions.add(yeniSoru);
    if (_previousQuestions.length > MAX_PREVIOUS_QUESTIONS) {
      _previousQuestions.removeAt(0);
    }

    return yeniSoru;
  }

  Future<void> _loadYanlisSorular() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? storedList = prefs.getStringList('yanlisSorular');

    if (storedList != null) {
      setState(() {
        yanlisSorular = storedList
            .map((e) => Map<String, dynamic>.from(jsonDecode(e)))
            .toList();
      });
    }
  }

// Yanlış soruları hafızaya kaydetme
  Future<void> saveYanlisSorularToPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Her öğeyi JSON stringe çevir ve liste olarak kaydet
    List<String> jsonList =
        yanlisSorular.map((item) => json.encode(item)).toList();

    await prefs.setStringList(
        'yanlisSorular', jsonList); // Listeyi SharedPreferences'a kaydet
  }

  Future<void> cevapKontrol(String cevap) async {
    final prefs = await SharedPreferences.getInstance();
    final islemKey = islemTuru.toLowerCase();

    if (cevap == mevcutSoru!['dogruCevap'].toString()) {
      // Doğru cevap istatistiklerini güncelle
      int dogruSayisi = prefs.getInt('dogru_$islemKey') ?? 0;
      await prefs.setInt('dogru_$islemKey', dogruSayisi + 1);

      // Performans verilerini güncelle
      await _performansVerisiniGuncelle(true);

      _handleCorrectAnswer();
    } else {
      // Yanlış cevap durumunda
      _saveWrongQuestionForOperation(
        mevcutSoru!['dogruCevap'],
        mevcutSoru!['soru'],
        int.parse(cevap),
      );

      // Performans verilerini güncelle
      await _performansVerisiniGuncelle(false);

      setState(() {
        streak = 0;
      });

      _playWrongSound();
      _showWrongAnswerDialog();
    }
  }

  Future<void> _saveWrongQuestionForOperation(
      int dogruCevap, String soruMetni, int yanlisCevap) async {
    final prefs = await SharedPreferences.getInstance();

    // İşlem türünü normalize et
    String islemKey = islemTuru.toLowerCase();
    if (islemKey == "çarpma") islemKey = "carpma";
    if (islemKey == "çıkarma") islemKey = "cikarma";
    if (islemKey == "bölme") islemKey = "bolme";

    final key = 'yanlisSorular_$islemKey';

    // Mevcut yanlış soruları al
    List<String> mevcutSorular = prefs.getStringList(key) ?? [];

    // Yeni soruyu ekle
    try {
      final yeniYanlisSoru = {
        'soru': soruMetni,
        'dogruCevap': dogruCevap.toString(),
        'yanlisCevap': yanlisCevap.toString(),
        'kategori': islemTuru,
        'tarih': DateTime.now().toIso8601String(),
      };

      String yeniSoruJson = json.encode(yeniYanlisSoru);
      mevcutSorular.add(yeniSoruJson);

      // Son 50 soruyu tut
      if (mevcutSorular.length > 50) {
        mevcutSorular = mevcutSorular.sublist(mevcutSorular.length - 50);
      }

      // Kaydet
      await prefs.setStringList(key, mevcutSorular);
    } catch (e) {
      print('Yanlış soru kaydedilirken hata: $e');
    }
  }

  Future<void> _performansVerisiniGuncelle(bool isDogru) async {
    final prefs = await SharedPreferences.getInstance();

    // İşlem türünü düzgün formatta kaydet
    String islemKey = islemTuru.toLowerCase();
    if (islemKey == "çarpma") islemKey = "carpma";
    if (islemKey == "çıkarma") islemKey = "cikarma";
    if (islemKey == "bölme") islemKey = "bolme";

    // Debug için performans verilerini yazdır
    developer.log('İşlem türü: $islemTuru, Key: $islemKey');

    // Mevcut performans verilerini yükle
    String? jsonString = prefs.getString('performans_$islemKey');
    developer.log('Mevcut veriler: $jsonString');

    List<Map<String, dynamic>> veriler = [];
    if (jsonString != null) {
      try {
        veriler = List<Map<String, dynamic>>.from(json.decode(jsonString));
      } catch (e) {
        developer.log('JSON decode hatası: $e');
        // Hata durumunda boş liste ile devam et
      }
    }

    // Bugünün tarihini al
    DateTime now = DateTime.now();
    String bugun = DateTime(now.year, now.month, now.day).toIso8601String();

    // Bugünün verisini bul veya oluştur
    Map<String, dynamic>? bugunVeri;
    int bugunIndex = -1;

    for (int i = 0; i < veriler.length; i++) {
      DateTime veriTarihi = DateTime.parse(veriler[i]['tarih']);
      if (veriTarihi.year == now.year &&
          veriTarihi.month == now.month &&
          veriTarihi.day == now.day) {
        bugunVeri = Map<String, dynamic>.from(veriler[i]);
        bugunIndex = i;
        break;
      }
    }

    if (bugunVeri == null) {
      bugunVeri = {
        'tarih': bugun,
        'dogru': 0,
        'yanlis': 0,
        'basariOrani': 0.0,
        'xp': levelSystem.currentXP,
      };
    }

    // Doğru veya yanlış sayısını güncelle
    if (isDogru) {
      bugunVeri['dogru'] = (bugunVeri['dogru'] ?? 0) + 1;
    } else {
      bugunVeri['yanlis'] = (bugunVeri['yanlis'] ?? 0) + 1;
    }

    // Başarı oranını hesapla
    int toplamDogru = bugunVeri['dogru'];
    int toplamYanlis = bugunVeri['yanlis'];
    int toplam = toplamDogru + toplamYanlis;
    double basariOrani = toplam > 0 ? (toplamDogru / toplam) * 100 : 0;
    bugunVeri['basariOrani'] = basariOrani;
    bugunVeri['xp'] = levelSystem.currentXP;

    // Debug için güncellenmiş veriyi yazdır
    developer.log('Güncellenmiş veri: $bugunVeri');

    // Veriyi güncelle veya ekle
    if (bugunIndex >= 0) {
      veriler[bugunIndex] = bugunVeri;
    } else {
      if (veriler.length >= 7) {
        veriler.removeAt(0);
      }
      veriler.add(bugunVeri);
    }

    // Verileri kaydet
    try {
      String yeniJson = json.encode(veriler);
      await prefs.setString('performans_$islemKey', yeniJson);
      developer.log('Veriler kaydedildi: $yeniJson');
    } catch (e) {
      developer.log('JSON encode hatası: $e');
    }
  }

  void _handleCorrectAnswer() {
    int xpGain = 10;

    // Hızlı cevap bonusu (kalan süreye göre)
    if (kalanSure > kalanSure / 2) {
      xpGain += 5;
    }

    // Doğru cevap serisi bonusu
    xpGain += (streak * 2);

    // Mevcut seviyenin XP çarpanını uygula
    final rewards = levelSystem.getLevelRewards();
    xpGain = (xpGain * rewards['xpMultiplier']).round();

    // XP'yi ekle ve seviye atlama kontrolü yap
    int oldLevel = levelSystem.currentLevel;
    bool leveledUp = levelSystem.gainXP(xpGain);

    if (leveledUp) {
      _showLevelUpDialog(oldLevel);
    }

    setState(() {
      streak++;
    });

    _playCorrectSound();
    _loadNextQuestion();
  }

  void _showLevelUpDialog(int oldLevel) {
    final rewards = levelSystem.getLevelRewards();
    bool isMaxLevel = rewards['isMaxLevel'];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.stars,
                color: Color(0xffFFD700),
                size: 64,
              ),
              SizedBox(height: 16),
              Text(
                isMaxLevel ? 'Maksimum Seviyeye Ulaştın!' : 'Seviye Atladın!',
                style: GoogleFonts.quicksand(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff2d2e83),
                ),
              ),
              SizedBox(height: 8),
              Text(
                isMaxLevel
                    ? 'Tebrikler! Bu işlem türünde maksimum seviyeye ulaştın.'
                    : 'Seviye ${oldLevel} → ${levelSystem.currentLevel}',
                style: GoogleFonts.quicksand(
                  fontSize: 18,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              if (!isMaxLevel) ...[
                SizedBox(height: 16),
                Text(
                  'Yeni Ödüller:',
                  style: GoogleFonts.quicksand(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '• Daha yüksek sayılarla işlemler\n• Artan zaman bonusu\n• Daha fazla XP kazanımı',
                  style: GoogleFonts.quicksand(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ],
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xff2d2e83),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Devam Et',
                  style: GoogleFonts.quicksand(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCorrectAnswerDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle_outline_rounded,
                  size: 40,
                  color: Colors.green,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Doğru!',
                style: GoogleFonts.quicksand(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '+${_calculateXPGain()} XP',
                style: GoogleFonts.quicksand(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.amber,
                ),
              ),
              if (streak > 1) ...[
                SizedBox(height: 8),
                Text(
                  '${streak}x Combo!',
                  style: GoogleFonts.quicksand(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.orange,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );

    // 1 saniye sonra dialog'u kapat ve yeni soruya geç
    Timer(Duration(seconds: 1), () {
      if (mounted) {
        Navigator.of(context).pop();
        _loadNextQuestion();
      }
    });
  }

  void _showWrongAnswerDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  size: 40,
                  color: Colors.redAccent,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Maalesef Yanlış!',
                textAlign: TextAlign.center,
                style: GoogleFonts.quicksand(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent,
                ),
              ),
              SizedBox(height: 8),
              Container(
                margin: EdgeInsets.symmetric(vertical: 8),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      'Doğru Cevap:',
                      style: GoogleFonts.quicksand(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                    Text(
                      '${mevcutSoru!['dogruCevap']}',
                      style: GoogleFonts.quicksand(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xff2d2e83),
                        elevation: 0,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        _loadNextQuestion();
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.restart_alt_rounded,
                              color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Tekrar Dene',
                            style: GoogleFonts.quicksand(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xff2d2e83),
                        elevation: 0,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => Mainmenu(
                              yanlisSorular: [],
                            ),
                          ),
                          (route) => false,
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.home_filled,
                              color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Ana Menü',
                            style: GoogleFonts.quicksand(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _calculateXPGain() {
    int xpGain = 10; // Temel XP

    // Hız bonusu
    if (kalanSure > kalanSure / 2) {
      xpGain += 5; // Hızlı cevap bonusu
    }

    // Streak bonusu
    if (streak > 1) {
      xpGain =
          (xpGain * (1 + (streak * 0.1))).round(); // Her streak için %10 bonus
    }

    return xpGain;
  }

  @override
  void dispose() {
    _animationController.dispose();
    _audioPlayer.dispose();
    _timer?.cancel();
    _gameTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || mevcutSoru == null) {
      return Scaffold(
        backgroundColor: Color(0xff2d2e83),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
              SizedBox(height: 16),
              Text(
                'Sorular Hazırlanıyor...',
                style: GoogleFonts.quicksand(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return WillPopScope(
      onWillPop: () async {
        bool? shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.white.withOpacity(0.9),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.orange),
                SizedBox(width: 10),
                Text('Uyarı'),
              ],
            ),
            content: Text(
                'Çıkmak istediğinize emin misiniz?\nİlerlemeniz kaydedilmeyecek.'),
            actions: [
              TextButton(
                child: Text(
                  'İptal',
                  style: GoogleFonts.quicksand(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              TextButton(
                child: Text(
                  'Çık',
                  style: GoogleFonts.quicksand(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          ),
        );
        return shouldPop ?? false;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: Colors.white.withOpacity(0.9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  title: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.orange),
                      SizedBox(width: 10),
                      Text('Uyarı'),
                    ],
                  ),
                  content: Text(
                      'Çıkmak istediğinize emin misiniz?\nİlerlemeniz kaydedilmeyecek.'),
                  actions: [
                    TextButton(
                      child: Text(
                        'İptal',
                        style: GoogleFonts.quicksand(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                    TextButton(
                      child: Text(
                        'Çık',
                        style: GoogleFonts.quicksand(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(true),
                    ),
                  ],
                ),
              ).then((shouldPop) {
                if (shouldPop ?? false) {
                  Navigator.of(context).pop();
                }
              });
            },
          ),
          title: Text(
            islemTuru,
            style: GoogleFonts.quicksand(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          backgroundColor: Color(0xff2d2e83),
          elevation: 0,
        ),
        backgroundColor: Color(0xff2d2e83),
        body: Stack(
          children: [
            Positioned(
              bottom: -5,
              right: 0,
              left: 0,
              child: Opacity(
                opacity: 0.4,
                child: Image.asset(
                  "assets/backgroud_image_3.png",
                  width: 500,
                ),
              ),
            ),
            Column(
              children: [
                if (levelSystem != null) ...[
                  Padding(
                    padding: EdgeInsets.only(top: 16, left: 16, right: 16),
                    child: LevelProgressBar(
                      currentLevel: levelSystem.currentLevel,
                      currentXP: levelSystem.currentXP,
                      requiredXP: levelSystem.requiredXP,
                      operationType: widget.islemTuru,
                    ),
                  ),
                ],
                Expanded(
                  child: Container(
                    height: MediaQuery.of(context).size.height,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          _buildTimerWidget(),
                          SizedBox(height: 10),
                          Container(
                            height: MediaQuery.of(context).size.height * 0.15,
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(bottom: 10, top: 20),
                              child: AnimatedSwitcher(
                                duration: Duration(milliseconds: 200),
                                transitionBuilder: (Widget child,
                                    Animation<double> animation) {
                                  return SlideTransition(
                                    position: Tween<Offset>(
                                      begin: Offset(0.0, .5),
                                      end: Offset.zero,
                                    ).animate(animation),
                                    child: child,
                                  );
                                },
                                child: Container(
                                  key: ValueKey(mevcutSoru!['soru']),
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Container(
                                    width: 250,
                                    child: Text(
                                      mevcutSoru!['soru'],
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
                          ),
                          Column(
                            children: List.generate(4, (index) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  width: 250,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      elevation: 0,
                                      backgroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                          vertical: 8, horizontal: 32),
                                    ),
                                    onPressed: () {
                                      _timer?.cancel();
                                      cevapKontrol(mevcutSoru!['cevaplar']
                                              [index]
                                          .toString());
                                    },
                                    child: Text(
                                      (mevcutSoru!['cevaplar'][index])
                                          .toString(),
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xff2d2e83),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimerWidget() {
    return FutureBuilder<int>(
      future: SharedPreferences.getInstance()
          .then((prefs) => prefs.getInt('question_time') ?? 30),
      builder: (context, snapshot) {
        final maxSure = snapshot.data ?? 30;
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              height: 100,
              width: 100,
              child: CircularProgressIndicator(
                value: kalanSure / maxSure,
                valueColor: AlwaysStoppedAnimation(
                  kalanSure > (maxSure * 0.5)
                      ? Colors.white
                      : kalanSure > (maxSure * 0.25)
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
                color: kalanSure > (maxSure * 0.5)
                    ? Colors.white
                    : kalanSure > (maxSure * 0.25)
                        ? Colors.orangeAccent
                        : Colors.redAccent,
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _loadLevelSystem() async {
    levelSystem = await LevelSystem.loadLevelData(widget.islemTuru);
    setState(() {});
  }

  void _startTimer() {
    _timer?.cancel();
    _gameTimer?.cancel();

    _gameTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        if (kalanSure > 0) {
          kalanSure--;
        } else {
          timer.cancel();
          streak = 0;
          _loadNextQuestion();
        }
      });
    });
  }
}
