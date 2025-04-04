import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:just_audio/just_audio.dart';
import './models/level_system.dart';
import './widgets/level_up_screen.dart';
import './widgets/level_progress_bar.dart';
import './services/ai_service.dart';

<<<<<<< Updated upstream
<<<<<<< Updated upstream
// Rastgele soru üretme için Random 0-9 arası üretiliyor onu 100 ile 0 arasına çek - İsmail Efe Çelik
// Kullanıcının istediğne göre işlem sırasındaki çeşitliliği kontrol et - İsmail Efe Çelik

=======
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
class Quiz extends StatefulWidget {
  final String islemTuru;
  Quiz({required this.islemTuru});

  @override
  _QuizState createState() => _QuizState();
}

class _QuizState extends State<Quiz> with TickerProviderStateMixin {
  int kalanSure = 30;
  Timer? _timer;
  late String islemTuru;
  Map<String, dynamic>? mevcutSoru;
  bool _isLoading = true;
  String? _ipucu;
  String? _aciklama;
  String _currentAnswer = '';
<<<<<<< Updated upstream
<<<<<<< Updated upstream
  List<Map<String, dynamic>> _sonSorular =
      []; // Son soruları takip etmek için liste
  final int _maxSoruGecmisi = 10; // Son kaç soruyu takip edeceğimiz
=======
  List<Map<String, dynamic>> _sonSorular = [];
  final int _maxSoruGecmisi = 10;
>>>>>>> Stashed changes
=======
  List<Map<String, dynamic>> _sonSorular = [];
  final int _maxSoruGecmisi = 10;
>>>>>>> Stashed changes

  late AnimationController _animationController;
  late AudioPlayer _audioPlayer;
  bool _isSoundEnabled = true;

  LevelSystem levelSystem = LevelSystem();
  int streak = 0;
  Timer? _gameTimer;
  late AIService _aiService;

<<<<<<< Updated upstream
<<<<<<< Updated upstream
  late AIService _aiService;
=======
  final TextEditingController _answerController = TextEditingController();
>>>>>>> Stashed changes
=======
  final TextEditingController _answerController = TextEditingController();
>>>>>>> Stashed changes

  @override
  void initState() {
    super.initState();
    islemTuru = widget.islemTuru
        .toLowerCase()
        .replaceAll('ç', 'c')
        .replaceAll('ı', 'i')
        .replaceAll('ö', 'o')
        .replaceAll('ü', 'u');
    _audioPlayer = AudioPlayer();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _aiService = AIService();
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

  Future<void> _loadLevelSystem() async {
    await levelSystem.loadLevel(islemTuru);
  }

  Future<void> _loadNextQuestion() async {
    setState(() {
      _isLoading = true;
      _ipucu = null;
      _aciklama = null;
      _currentAnswer = '';
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final yas = prefs.getInt('userAge') ?? 7;
      final zorlukSeviyesi = prefs.getString('difficulty') ?? 'Orta';

      developer.log('Yapay zeka sorusu üretiliyor... İşlem türü: $islemTuru' +
          '$zorlukSeviyesi');

      final soru = await _aiService.generateQuestion(
        yas: yas,
        islemTuru: islemTuru,
        zorlukSeviyesi: zorlukSeviyesi,
      );

      developer.log('Yapay zeka sorusu başarıyla üretildi: ${soru['soru']}');

      setState(() {
        mevcutSoru = soru;
        _isLoading = false;
      });

      _startTimer();
    } catch (e) {
      developer.log('Yapay zeka hatası: $e');
      developer.log('Basit soru üretiliyor...');

      setState(() {
        mevcutSoru = _generateBasicQuestion();
        _isLoading = false;
      });

      developer.log('Basit soru üretildi: ${mevcutSoru!['soru']}');
    }
  }

<<<<<<< Updated upstream
<<<<<<< Updated upstream
=======
=======
>>>>>>> Stashed changes
  @override
  void dispose() {
    _timer?.cancel();
    _gameTimer?.cancel();
    _animationController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _gameTimer?.cancel();
        return true;
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/background.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.timer, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            '$kalanSure',
                            style: GoogleFonts.quicksand(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber),
                          SizedBox(width: 8),
                          Text(
                            'Seri: $streak',
                            style: GoogleFonts.quicksand(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 32),
                  if (mevcutSoru != null) ...[
                    Text(
                      '${mevcutSoru!['sayi1']} ${mevcutSoru!['islem']} ${mevcutSoru!['sayi2']} = ?',
                      style: GoogleFonts.quicksand(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 32),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: TextField(
                        controller: _answerController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.quicksand(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Cevabınızı yazın',
                          hintStyle: GoogleFonts.quicksand(
                            fontSize: 24,
                            color: Colors.grey,
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _currentAnswer = value;
                          });
                        },
                        onSubmitted: (value) {
                          if (value.isNotEmpty) {
                            _checkAnswer();
                          }
                        },
                      ),
                    ),
                    SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding:
                            EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onPressed: _currentAnswer.isEmpty ? null : _checkAnswer,
                      child: Text(
                        'Kontrol Et',
                        style: GoogleFonts.quicksand(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: Icon(Icons.lightbulb_outline,
                              color: Colors.white),
                          onPressed: _showHint,
                          tooltip: 'İpucu Al',
                        ),
                        IconButton(
                          icon: Icon(Icons.help_outline, color: Colors.white),
                          onPressed: _showExplanation,
                          tooltip: 'Açıklama İste',
                        ),
                      ],
                    ),
                  ] else ...[
                    CircularProgressIndicator(),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

<<<<<<< Updated upstream
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
  Map<String, dynamic> _generateBasicQuestion() {
    final prefs = SharedPreferences.getInstance();
    final zorlukSeviyesi =
        prefs.then((prefs) => prefs.getString('difficulty') ?? 'Orta');

    int minSayi = 1;
    int maxSayi = 10;

    // Zorluk seviyesine göre sayı aralıklarını ayarla
    switch (zorlukSeviyesi) {
      case 'Kolay':
        maxSayi = 10;
        break;
      case 'Orta':
        minSayi = 5;
        maxSayi = 20;
        break;
      case 'Zor':
        minSayi = 10;
        maxSayi = 30;
        break;
    }

    int sayi1;
    int sayi2;
    int cevap;
    String islem;
    Map<String, dynamic> yeniSoru;

    do {
      sayi1 = minSayi + Random().nextInt(maxSayi - minSayi + 1);
      sayi2 = minSayi + Random().nextInt(maxSayi - minSayi + 1);

      switch (islemTuru) {
        case 'toplama':
          cevap = sayi1 + sayi2;
          islem = '+';
          break;
        case 'cikarma':
          // Çıkarma için her zaman büyük sayıdan küçük sayıyı çıkar
          if (sayi1 < sayi2) {
            final temp = sayi1;
            sayi1 = sayi2;
            sayi2 = temp;
          }
          cevap = sayi1 - sayi2;
          islem = '-';
          break;
        case 'carpma':
          // Çarpma için sayıları küçült
          sayi1 = minSayi + Random().nextInt((maxSayi ~/ 2) - minSayi + 1);
          sayi2 = minSayi + Random().nextInt((maxSayi ~/ 2) - minSayi + 1);
          cevap = sayi1 * sayi2;
          islem = 'x';
          break;
        case 'bolme':
          // Bölme için tam bölünen sayılar üret
          sayi2 = minSayi + Random().nextInt(5);
          cevap = minSayi + Random().nextInt((maxSayi ~/ sayi2) - minSayi + 1);
          sayi1 = sayi2 * cevap;
          islem = '÷';
          break;
        default:
          print('Bilinmeyen işlem türü: $islemTuru');
          cevap = sayi1 + sayi2;
          islem = '+';
      }

      yeniSoru = {
        'soru': '$sayi1 $islem $sayi2',
        'cevap': cevap.toString(),
        'ipucu': _generateHint(sayi1, sayi2, islem),
        'aciklama': _generateExplanation(sayi1, sayi2, cevap, islem),
        'zorlukPuani': zorlukSeviyesi == 'Kolay'
            ? '1'
            : zorlukSeviyesi == 'Orta'
                ? '2'
                : '3',
      };
    } while (_sonSorular.any((soru) => soru['soru'] == yeniSoru['soru']));

    // Yeni soruyu geçmişe ekle
    _sonSorular.add(yeniSoru);
    // Geçmiş listesini sınırla
    if (_sonSorular.length > _maxSoruGecmisi) {
      _sonSorular.removeAt(0);
    }

    return yeniSoru;
  }

  String _generateHint(int sayi1, int sayi2, String islem) {
    switch (islem) {
      case '+':
        return 'Önce birlikleri, sonra onları topla';
      case '-':
        return 'Büyük sayıdan küçük sayıyı çıkar';
      case 'x':
        return 'Çarpım tablosunu hatırla veya adım adım topla';
      case '÷':
        return '$sayi1 sayısı içinde kaç tane $sayi2 var?';
      default:
        return 'İşlemi adım adım yap';
    }
  }

  String _generateExplanation(int sayi1, int sayi2, int cevap, String islem) {
    switch (islem) {
      case '+':
        return '$sayi1 + $sayi2 = $cevap\nSayıları soldan sağa doğru topladık.';
      case '-':
        return '$sayi1 - $sayi2 = $cevap\nBüyük sayıdan küçük sayıyı çıkardık.';
      case 'x':
        return '$sayi1 x $sayi2 = $cevap\n$sayi1 sayısını $sayi2 kere topladık.';
      case '÷':
        return '$sayi1 ÷ $sayi2 = $cevap\n$sayi1 sayısını $sayi2\'ye böldük.';
      default:
        return 'Basit bir $islemTuru işlemi';
    }
  }

  Future<void> _showHint() async {
    if (_ipucu == null && mevcutSoru != null) {
      final hint = await _aiService.getHint(mevcutSoru!['soru'], islemTuru);
      setState(() {
        _ipucu = hint;
      });
    }
  }

  Future<void> _showExplanation() async {
    if (_aciklama == null && mevcutSoru != null) {
      final explanation = await _aiService.getExplanation(
        mevcutSoru!['soru'],
        mevcutSoru!['cevap'],
        islemTuru,
      );
      setState(() {
        _aciklama = explanation;
      });
    }
  }

  void _startTimer() {
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (kalanSure > 0) {
            kalanSure--;
          } else {
            _gameTimer?.cancel();
            _handleWrongAnswer();
          }
        });
      }
    });
  }

  Future<void> _handleCorrectAnswer() async {
    _gameTimer?.cancel();
    streak++;

    // Level sistemini güncelle
    int kazanilanPuan = 10 + (streak * 2);
    await levelSystem.addExperience(kazanilanPuan);

    // Doğru cevap dialogunu göster
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 64,
                ),
                SizedBox(height: 16),
                Text(
                  'Doğru!',
                  style: GoogleFonts.quicksand(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '+$kazanilanPuan XP',
                  style: GoogleFonts.quicksand(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xffFFD700),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      // 1.5 saniye sonra dialogu kapat ve sonraki soruya geç
      Future.delayed(Duration(milliseconds: 1500), () {
        if (mounted) {
          Navigator.of(context).pop();
          if (levelSystem.hasLeveledUp) {
            _showLevelUpScreen();
          } else {
            setState(() {
              kalanSure = 30;
            });
            _loadNextQuestion();
          }
        }
      });
    }

    if (_isSoundEnabled) {
      try {
        await _audioPlayer.setAsset('assets/sounds/correct_answer.wav');
        await _audioPlayer.play();
      } catch (e) {
        print('Ses çalma hatası: $e');
      }
    }

    // Performans verilerini kaydet
    await _savePerformanceData(true);

    // Sadece animasyonu çalıştır
    if (_animationController.isAnimating) {
      _animationController.stop();
    }

    if (!_animationController.isDismissed && mounted) {
      _animationController.forward().then((_) {
        if (mounted) {
          _animationController.reset();
        }
      });
    }
  }

  Future<void> _handleWrongAnswer() async {
    _gameTimer?.cancel();
    streak = 0;

    // Yanlış cevabı sakla
    String yanlisCevap = _currentAnswer;

    // Sadece süre dolduğunda XP düşür
    if (kalanSure == 0) {
      await levelSystem.removeExperience(5);
    }

    // Performans verilerini kaydet
    await _savePerformanceData(false, yanlisCevap);

    // Eğer süre bitmemişse (yani kullanıcı yanlış cevap verdiyse) dialog göster
    if (kalanSure > 0 && mounted) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.cancel,
                  color: Colors.white,
                  size: 64,
                ),
                SizedBox(height: 16),
                Text(
                  'Yanlış Cevap!',
                  style: GoogleFonts.quicksand(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Doğru cevap: ${mevcutSoru!['cevap']}',
                  style: GoogleFonts.quicksand(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.red,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: () {
<<<<<<< Updated upstream
<<<<<<< Updated upstream
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => Mainmenu(
                          mevcutPuan: 0,
                          yanlisSorular: [],
                        ),
                      ),
                      (route) => false,
                    );
                  },
                  child: Text(
                    'Ana Menüye Dön',
=======
=======
>>>>>>> Stashed changes
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Devam Et',
<<<<<<< Updated upstream
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Yanlış cevap animasyonu ve yeni soru
    setState(() {
      _currentAnswer = '';
      kalanSure = 30;
    });
    _loadNextQuestion();
  }

<<<<<<< Updated upstream
<<<<<<< Updated upstream
  Future<void> _savePerformanceData(bool isDogru, [String? yanlisCevap]) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final performanceKey = 'performans_${islemTuru.toLowerCase()}';
    final yanlisSorularKey = 'yanlisSorular_${islemTuru.toLowerCase()}';

    // Performans verilerini kaydet
    List<Map<String, dynamic>> performanceList = [];
    final String? performanceData = prefs.getString(performanceKey);

    if (performanceData != null) {
      performanceList =
          List<Map<String, dynamic>>.from(jsonDecode(performanceData) as List);
    }

    performanceList.add({
      'tarih': now.toIso8601String(),
      'dogru': isDogru,
      'soru': mevcutSoru!['soru'],
      'cevap': mevcutSoru!['cevap'],
      'zorlukPuani': mevcutSoru!['zorlukPuani'] ?? '1',
      'sure': 30 - kalanSure,
      'streak': streak,
    });

    // Son 100 performans verisini tut
    if (performanceList.length > 100) {
      performanceList = performanceList.sublist(performanceList.length - 100);
    }

    await prefs.setString(performanceKey, jsonEncode(performanceList));

    // Yanlış cevap verildiyse yanlış sorular listesine ekle
    if (!isDogru && yanlisCevap != null) {
      List<String> yanlisSorular = prefs.getStringList(yanlisSorularKey) ?? [];
      final yanlisSoru = {
        'soru': mevcutSoru!['soru'],
        'dogruCevap': mevcutSoru!['cevap'],
        'yanlisCevap': yanlisCevap,
        'kategori': islemTuru,
        'tarih': now.toIso8601String(),
      };
      yanlisSorular.add(jsonEncode(yanlisSoru));

      // Son 50 yanlış soruyu tut
      if (yanlisSorular.length > 50) {
        yanlisSorular = yanlisSorular.sublist(yanlisSorular.length - 50);
      }

      await prefs.setStringList(yanlisSorularKey, yanlisSorular);
    }
  }

  void _showLevelUpScreen() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => LevelUpScreen(
        level: levelSystem.currentLevel,
        onContinue: () {
          Navigator.of(context).pop();
          _loadNextQuestion();
        },
      ),
    );
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _animationController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Çıkış dialogunu göster
        bool shouldPop = await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                title: Text(
                  'Çıkmak istediğinize emin misiniz?',
                  style: GoogleFonts.quicksand(
                    fontWeight: FontWeight.bold,
                    color: Color(0xff2d2e83),
                  ),
                ),
                content: Text(
                  'Eğer çıkarsanız mevcut seriniz sıfırlanacak.',
                  style: GoogleFonts.quicksand(
                    color: Colors.black87,
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(
                      'İptal',
                      style: GoogleFonts.quicksand(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      _gameTimer?.cancel();
                      Navigator.of(context).pop(true);
                    },
                    child: Text(
                      'Çık',
                      style: GoogleFonts.quicksand(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ) ??
            false;
        return shouldPop;
      },
      child: Scaffold(
        backgroundColor: Color(0xff2d2e83),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(FontAwesomeIcons.arrowLeft, color: Colors.white),
            onPressed: () async {
              // Çıkış dialogunu göster
              bool shouldPop = await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      title: Text(
                        'Çıkmak istediğinize emin misiniz?',
                        style: GoogleFonts.quicksand(
                          fontWeight: FontWeight.bold,
                          color: Color(0xff2d2e83),
                        ),
                      ),
                      content: Text(
                        'Eğer çıkarsanız mevcut seriniz sıfırlanacak.',
                        style: GoogleFonts.quicksand(
                          color: Colors.black87,
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: Text(
                            'İptal',
                            style: GoogleFonts.quicksand(
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            _gameTimer?.cancel();
                            Navigator.of(context).pop(true);
                          },
                          child: Text(
                            'Çık',
                            style: GoogleFonts.quicksand(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ) ??
                  false;

              if (shouldPop) {
                Navigator.of(context).pop();
              }
            },
          ),
          actions: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              margin: EdgeInsets.only(right: 20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  SizedBox(width: 4),
                  LevelProgressBar(levelSystem: levelSystem),
                  Text(
                    '${levelSystem.currentXP} XP',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
=======
  Future<void> _checkAnswer() async {
    if (_answerController.text.isEmpty) return;

    int userAnswer;
    try {
      userAnswer = int.parse(_answerController.text);
    } catch (e) {
      _handleWrongAnswer();
      return;
    }

    if (userAnswer == int.parse(mevcutSoru!['cevap'])) {
      await _handleCorrectAnswer();
    } else {
      await _handleWrongAnswer();
    }

    _answerController.clear();
    _loadNextQuestion();
  }

  Future<void> _showLevelUpScreen() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xff2d2e83),
        title: Text(
          'Tebrikler! Seviye Atladınız!',
          style: GoogleFonts.quicksand(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.star,
              color: Colors.yellow,
              size: 50,
            ),
            SizedBox(height: 16),
            Text(
              'Yeni Seviye: ${levelSystem.currentLevel}',
              style: GoogleFonts.quicksand(
                color: Colors.white,
>>>>>>> Stashed changes
              ),
            ),
          ],
        ),
<<<<<<< Updated upstream
        body: _isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: Colors.white,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Sorular Hazırlanıyor...',
                      style: GoogleFonts.quicksand(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              )
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                FontAwesomeIcons.clock,
                                color: kalanSure > 10
                                    ? Colors.white
                                    : Colors.redAccent,
                                size: 18,
                              ),
                              SizedBox(width: 6),
                              Text(
                                '$kalanSure',
                                style: GoogleFonts.quicksand(
                                  color: kalanSure > 10
                                      ? Colors.white
                                      : Colors.redAccent,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                FontAwesomeIcons.boltLightning,
                                color: Color(0xffFFD700),
                                size: 18,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Seri: $streak',
                                style: GoogleFonts.quicksand(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (mevcutSoru != null) ...[
                              Container(
                                alignment: Alignment.center,
                                width: double.infinity,
                                height:
                                    MediaQuery.of(context).size.height * 0.2,
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          mevcutSoru!['soru'] ?? '',
                                          style: GoogleFonts.quicksand(
                                            color: Colors.white,
                                            fontSize: 32,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          ' = ',
                                          style: GoogleFonts.quicksand(
                                            color: Colors.white,
                                            fontSize: 32,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.white.withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                            _currentAnswer.isEmpty
                                                ? '?'
                                                : _currentAnswer,
                                            style: GoogleFonts.quicksand(
                                              color: Colors.white,
                                              fontSize: 32,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 30),
                              // Numara tuşları grid'i
                              Container(
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: GridView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    childAspectRatio: 1.5,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                  ),
                                  itemCount: 12,
                                  itemBuilder: (context, index) {
                                    if (index == 9) {
                                      return _buildActionButton(
                                        icon: FontAwesomeIcons.backspace,
                                        onPressed: () {
                                          setState(() {
                                            if (_currentAnswer.isNotEmpty) {
                                              _currentAnswer =
                                                  _currentAnswer.substring(
                                                      0,
                                                      _currentAnswer.length -
                                                          1);
                                            }
                                          });
                                        },
                                      );
                                    }
                                    if (index == 10) {
                                      return _buildNumberButton('0');
                                    }
                                    if (index == 11) {
                                      return _buildActionButton(
                                        icon: FontAwesomeIcons.checkCircle,
                                        onPressed: _checkAnswer,
                                      );
                                    }
                                    return _buildNumberButton('${index + 1}');
                                  },
                                ),
                              ),
                              SizedBox(height: 20),
                              if (_ipucu != null) ...[
                                SizedBox(height: 20),
                                Container(
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(
                                      color: Colors.amber.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.lightbulb,
                                            color: Colors.amber,
                                            size: 20,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'İpucu',
                                            style: GoogleFonts.quicksand(
                                              color: Colors.amber,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        _ipucu!,
                                        style: GoogleFonts.quicksand(
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              if (_aciklama != null) ...[
                                SizedBox(height: 20),
                                Container(
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(
                                      color: Colors.green.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.help,
                                            color: Colors.green,
                                            size: 20,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'Açıklama',
                                            style: GoogleFonts.quicksand(
                                              color: Colors.green,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        _aciklama!,
                                        style: GoogleFonts.quicksand(
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
=======
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              'Devam Et',
              style: GoogleFonts.quicksand(
                color: Colors.white,
              ),
            ),
          ),
        ],
>>>>>>> Stashed changes
      ),
    );
  }

<<<<<<< Updated upstream
  Widget _buildNumberButton(String number) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white.withOpacity(0.1),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      onPressed: () {
        setState(() {
          if (_currentAnswer.length < 10) {
            _currentAnswer += number;
          }
        });
      },
      child: Text(
        number,
        style: GoogleFonts.quicksand(
          fontSize: 24,
=======
  Future<void> _checkAnswer() async {
    if (_answerController.text.isEmpty) return;

    int userAnswer;
    try {
      userAnswer = int.parse(_answerController.text);
    } catch (e) {
      _handleWrongAnswer();
      return;
    }

    if (userAnswer == int.parse(mevcutSoru!['cevap'])) {
      await _handleCorrectAnswer();
    } else {
      await _handleWrongAnswer();
    }

    _answerController.clear();
    _loadNextQuestion();
  }

  Future<void> _showLevelUpScreen() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xff2d2e83),
        title: Text(
          'Tebrikler! Seviye Atladınız!',
          style: GoogleFonts.quicksand(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.star,
              color: Colors.yellow,
              size: 50,
            ),
            SizedBox(height: 16),
            Text(
              'Yeni Seviye: ${levelSystem.currentLevel}',
              style: GoogleFonts.quicksand(
                color: Colors.white,
              ),
            ),
          ],
>>>>>>> Stashed changes
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              'Devam Et',
              style: GoogleFonts.quicksand(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

<<<<<<< Updated upstream
  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white.withOpacity(0.1),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      onPressed: onPressed,
      child: Icon(icon, size: 24),
    );
  }

  void _checkAnswer() {
    if (_currentAnswer.isEmpty || mevcutSoru == null) return;

    if (_currentAnswer == mevcutSoru!['cevap']) {
      _handleCorrectAnswer();
    } else {
      _handleWrongAnswer();
    }

    setState(() {
      _currentAnswer = '';
    });
=======
  Future<void> _savePerformanceData(bool isCorrect,
      [String? wrongAnswer]) async {
    final prefs = await SharedPreferences.getInstance();
    String operationType = islemTuru.toLowerCase();

    // Toplam skor
    int totalScore = prefs.getInt('${operationType}_total_score') ?? 0;
    await prefs.setInt(
        '${operationType}_total_score', totalScore + (isCorrect ? 10 : 0));

    // Yanlış cevap sayısı
    int wrongAnswers = prefs.getInt('${operationType}_wrong_answers') ?? 0;
    if (!isCorrect) {
      await prefs.setInt('${operationType}_wrong_answers', wrongAnswers + 1);
    }

    // Doğru cevap sayısı
    int correctAnswers = prefs.getInt('${operationType}_correct_answers') ?? 0;
    if (isCorrect) {
      await prefs.setInt(
          '${operationType}_correct_answers', correctAnswers + 1);
    }

=======
  Future<void> _savePerformanceData(bool isCorrect,
      [String? wrongAnswer]) async {
    final prefs = await SharedPreferences.getInstance();
    String operationType = islemTuru.toLowerCase();

    // Toplam skor
    int totalScore = prefs.getInt('${operationType}_total_score') ?? 0;
    await prefs.setInt(
        '${operationType}_total_score', totalScore + (isCorrect ? 10 : 0));

    // Yanlış cevap sayısı
    int wrongAnswers = prefs.getInt('${operationType}_wrong_answers') ?? 0;
    if (!isCorrect) {
      await prefs.setInt('${operationType}_wrong_answers', wrongAnswers + 1);
    }

    // Doğru cevap sayısı
    int correctAnswers = prefs.getInt('${operationType}_correct_answers') ?? 0;
    if (isCorrect) {
      await prefs.setInt(
          '${operationType}_correct_answers', correctAnswers + 1);
    }

>>>>>>> Stashed changes
    // Yanlış cevapları kaydet
    if (!isCorrect) {
      List<String> wrongAnswersList =
          prefs.getStringList('${operationType}_wrong_answers_list') ?? [];
      String wrongAnswerData =
          '${mevcutSoru!['sayi1']}${mevcutSoru!['islem']}${mevcutSoru!['sayi2']}=$wrongAnswer';
      wrongAnswersList.add(wrongAnswerData);
      await prefs.setStringList(
          '${operationType}_wrong_answers_list', wrongAnswersList);
    }
<<<<<<< Updated upstream
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
  }
}
