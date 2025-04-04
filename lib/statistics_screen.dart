import 'package:flutter/material.dart';
<<<<<<< Updated upstream
<<<<<<< Updated upstream
=======
<<<<<<< Updated upstream
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import 'dart:convert';
import './services/performance_analysis_service.dart';
import './models/performans_veri.dart';

class GlowBorderPainter extends CustomPainter {
  final double progress;
  final Color glowColor;
  final double radius;

  GlowBorderPainter({
    required this.progress,
    required this.glowColor,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(radius),
    );

    // Ana border için gradient paint
    final borderGradient = LinearGradient(
      colors: [
        glowColor.withOpacity(0.05),
        glowColor.withOpacity(1),
        glowColor.withOpacity(0.05),
      ],
      stops: [0.0, 0.5, 1.0],
    );

    // Dış glow için paint
    final outerGlowPaint = Paint()
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..shader = borderGradient.createShader(
        Rect.fromPoints(
          Offset(size.width * (progress - 0.8), 0),
          Offset(size.width * (progress + 0.8), size.height),
        ),
      );

    // İç glow için paint
    final innerGlowPaint = Paint()
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 4)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..shader = borderGradient.createShader(
        Rect.fromPoints(
          Offset(size.width * (progress - 0.6), 0),
          Offset(size.width * (progress + 0.6), size.height),
        ),
      );

    // Ambient glow için paint
    final ambientGlowPaint = Paint()
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 12)
      ..color = glowColor.withOpacity(0.05);

    // Ambient glow çizimi
    canvas.drawRRect(rect.inflate(2), ambientGlowPaint);

    // Ana glow efektleri
    canvas.drawRRect(rect, outerGlowPaint);
    canvas.drawRRect(rect, innerGlowPaint);
  }

  @override
  bool shouldRepaint(GlowBorderPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class StatisticsScreen extends StatefulWidget {
  @override
  _StatisticsScreenState createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen>
    with SingleTickerProviderStateMixin {
  Map<String, List<PerformansVeri>> performansVerileri = {};
  Map<String, List<Map<String, dynamic>>> yanlisSorular = {};
  int _selectedIndex = 0;
  final PageController _pageController = PageController();
  late final AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
    _glowController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadStatistics() async {
    final prefs = await SharedPreferences.getInstance();

    // İşlem türlerini tanımla
    final operations = {
      'Toplama': 'toplama',
      'Çıkarma': 'cikarma',
      'Çarpma': 'carpma',
      'Bölme': 'bolme'
    };

    Map<String, List<PerformansVeri>> yeniPerformansVerileri = {};
    Map<String, List<Map<String, dynamic>>> yeniYanlisSorular = {};

    // Her işlem türü için performans verilerini yükle
    for (var entry in operations.entries) {
      final displayName = entry.key;
      final storageKey = entry.value;

      // Performans verilerini yükle
      final performansKey = 'performans_$storageKey';
      final performansJson = prefs.getString(performansKey);
      print('$displayName için performans JSON: $performansJson');

      if (performansJson != null) {
        try {
          final List<dynamic> performansList = json.decode(performansJson);
          print(
              '$displayName için performans listesi: ${performansList.length} kayıt');

          // Günlük performans verilerini hesapla
          final Map<String, PerformansVeri> gunlukVeriler = {};

          for (var veri in performansList) {
            final tarih = DateTime.parse(veri['tarih'] as String);
            final tarihKey = '${tarih.year}-${tarih.month}-${tarih.day}';

            // O gün için toplam doğru ve yanlış sayısını hesapla
            if (!gunlukVeriler.containsKey(tarihKey)) {
              gunlukVeriler[tarihKey] = PerformansVeri(
                tarih: tarih,
                basariOrani: 0,
                dogru: 0,
                yanlis: 0,
                xp: 0,
                islemTuru: storageKey,
              );
            }

            final gunlukVeri = gunlukVeriler[tarihKey]!;
            if (veri['dogru'] as bool) {
              gunlukVeriler[tarihKey] = PerformansVeri(
                tarih: tarih,
                basariOrani: ((gunlukVeri.dogru + 1) /
                    (gunlukVeri.dogru + gunlukVeri.yanlis + 1) *
                    100),
                dogru: gunlukVeri.dogru + 1,
                yanlis: gunlukVeri.yanlis,
                xp: gunlukVeri.xp +
                    int.parse(veri['zorlukPuani'] as String) * 10,
                islemTuru: storageKey,
              );
            } else {
              gunlukVeriler[tarihKey] = PerformansVeri(
                tarih: tarih,
                basariOrani: (gunlukVeri.dogru /
                    (gunlukVeri.dogru + gunlukVeri.yanlis + 1) *
                    100),
                dogru: gunlukVeri.dogru,
                yanlis: gunlukVeri.yanlis + 1,
                xp: gunlukVeri.xp,
                islemTuru: storageKey,
              );
            }
          }

          yeniPerformansVerileri[displayName] = gunlukVeriler.values.toList();
          print(
              '$displayName için günlük veriler: ${gunlukVeriler.length} gün');
        } catch (e) {
          print('$displayName performans verisi yükleme hatası: $e');
        }
      }

      // Yanlış soruları yükle
      final yanlisSorularKey = 'yanlisSorular_$storageKey';
      final yanlisList = prefs.getStringList(yanlisSorularKey) ?? [];
      print('$displayName için yanlış sorular: ${yanlisList.length}');

      try {
        final List<Map<String, dynamic>> islemYanlislari = yanlisList
            .map((jsonStr) => json.decode(jsonStr) as Map<String, dynamic>)
            .toList();

        yeniYanlisSorular[displayName] = islemYanlislari;
      } catch (e) {
        print('$displayName yanlış soru yükleme hatası: $e');
        yeniYanlisSorular[displayName] = [];
      }
    }

    if (mounted) {
      setState(() {
        performansVerileri = yeniPerformansVerileri;
        yanlisSorular = yeniYanlisSorular;
        print(
            'Performans verileri güncellendi: ${performansVerileri.length} işlem türü');
        print('Yanlış sorular güncellendi: ${yanlisSorular.length} işlem türü');
      });
    }
  }
=======
import 'package:google_fonts/google_fonts.dart';

<<<<<<< Updated upstream
<<<<<<< Updated upstream
=======
=======
>>>>>>> Stashed changes
class StatisticsScreen extends StatelessWidget {
  final List<Map<String, dynamic>> wrongAnswers;
  final int score;

  const StatisticsScreen({
    Key? key,
    required this.wrongAnswers,
    required this.score,
  }) : super(key: key);
>>>>>>> Stashed changes

>>>>>>> Stashed changes
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('İstatistikler'),
      ),
<<<<<<< Updated upstream
      body: Column(
        children: [
          Container(
            height: 50,
            margin: EdgeInsets.only(top: 8, bottom: 20),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildTabButton('Genel', 0, FontAwesomeIcons.chartSimple),
                _buildTabButton('Toplama', 1, FontAwesomeIcons.plus),
                _buildTabButton('Çıkarma', 2, FontAwesomeIcons.minus),
                _buildTabButton('Çarpma', 3, FontAwesomeIcons.xmark),
                _buildTabButton('Bölme', 4, FontAwesomeIcons.divide),
              ],
            ),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              children: [
                _buildGenelPage(),
                _buildIslemPage('Toplama'),
                _buildIslemPage('Çıkarma'),
                _buildIslemPage('Çarpma'),
                _buildIslemPage('Bölme'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String text, int index, IconData icon) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
          _pageController.animateToPage(
            index,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        });
      },
      child: Container(
        margin: EdgeInsets.only(right: 8),
        padding: EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color:
              isSelected ? Colors.white.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenelPage() {
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.only(top: 20.0, left: 20, right: 20),
        child: Column(
          children: [
            FutureBuilder<Map<String, String>>(
              future: PerformanceAnalysisService().generatePerformanceInsight(
                performansVerileri: performansVerileri,
                yanlisSorular: yanlisSorular,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    height: 80,
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Container();
                }

                return Container(
                  margin: EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Stack(
                    fit: StackFit.passthrough,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  FontAwesomeIcons.graduationCap,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Matematik Koçun',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            if (snapshot.data!['baslik'] !=
                                'Veri Yetersiz') ...[
                              SizedBox(height: 4),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  snapshot.data!['baslik'] ?? '',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                            SizedBox(height: 8),
                            Text(
                              snapshot.data!['baslik'] == 'Veri Yetersiz'
                                  ? 'Performans değerlendirmesi için en az 7 farklı günde pratik yapılması gerekiyor.'
                                  : snapshot.data!['yorum'] ?? '',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                                height: 1.5,
                                fontStyle:
                                    snapshot.data!['baslik'] == 'Veri Yetersiz'
                                        ? FontStyle.italic
                                        : FontStyle.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (snapshot.data!['baslik'] != 'Veri Yetersiz')
                        Positioned.fill(
                          child: IgnorePointer(
                            child: AnimatedBuilder(
                              animation: _glowController,
                              builder: (context, child) {
                                return CustomPaint(
                                  painter: GlowBorderPainter(
                                    progress: Curves.easeInOutSine
                                        .transform(_glowController.value),
                                    glowColor: Color(0xFF4B4CFF),
                                    radius: 15,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
            _buildStatSection(
              icon: FontAwesomeIcons.chartSimple,
              title: 'Genel Toplam',
              child: _buildGenelToplam(),
            ),
            if (_tumYanlisSorular().isNotEmpty) ...[
              _buildStatSection(
                icon: FontAwesomeIcons.exclamation,
                title: 'Tüm Yanlış Cevaplar',
                child: _buildTumYanlisCevaplar(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIslemPage(String islemTuru) {
    final performansListesi = performansVerileri[islemTuru] ?? [];
    final yanlisList = yanlisSorular[islemTuru] ?? [];

    // Son 7 günlük verileri hazırla
    final now = DateTime.now();
    final List<PerformansVeri> gunlukVeriler = List.generate(7, (index) {
      final tarih = DateTime(now.year, now.month, now.day - (6 - index));
      // Bu gün için veri var mı kontrol et
      final gunVeri = performansListesi.where((veri) {
        final veriTarih = veri.tarih;
        return veriTarih.year == tarih.year &&
            veriTarih.month == tarih.month &&
            veriTarih.day == tarih.day;
      }).toList();

      // Eğer o gün için veri varsa son veriyi al, yoksa 0 değerli veri oluştur
      return gunVeri.isNotEmpty
          ? gunVeri.last
          : PerformansVeri(
              tarih: tarih,
              basariOrani: 0,
              dogru: 0,
              yanlis: 0,
              xp: 0,
              islemTuru: islemTuru,
            );
    });

    // Son 7 günün toplam doğru ve yanlış sayılarını hesapla
    int toplamDogru = 0;
    int toplamYanlis = 0;
    for (var veri in gunlukVeriler) {
      toplamDogru += veri.dogru;
      toplamYanlis += veri.yanlis;
    }
    final toplam = toplamDogru + toplamYanlis;
    final basariOrani = toplam > 0 ? (toplamDogru / toplam * 100) : 0.0;

    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
=======
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
>>>>>>> Stashed changes
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGeneralStats(),
            SizedBox(height: 20),
            _buildWrongAnswersList(),
          ],
        ),
      ),
    );
  }

<<<<<<< Updated upstream
  Widget _buildGenelToplam() {
    int toplamDogru = 0;
    int toplamYanlis = 0;
    double toplamBasariOrani = 0;
    int islemSayisi = 0;

    // Her işlem türü için toplam hesapla
    performansVerileri.forEach((islemTuru, performansListesi) {
      if (performansListesi.isNotEmpty) {
        islemSayisi++;
        // Son 7 günlük verileri al
        final now = DateTime.now();
        final son7GunlukVeriler = performansListesi.where((veri) {
          final fark = now.difference(veri.tarih).inDays;
          return fark <= 7;
        }).toList();

        // Her işlem türü için son performans verilerini topla
        if (son7GunlukVeriler.isNotEmpty) {
          for (var veri in son7GunlukVeriler) {
            toplamDogru += veri.dogru;
            toplamYanlis += veri.yanlis;
          }
          // Son 7 günün ortalama başarı oranını al
          double islemBasariOrani = 0;
          for (var veri in son7GunlukVeriler) {
            islemBasariOrani += veri.basariOrani;
          }
          toplamBasariOrani += islemBasariOrani / son7GunlukVeriler.length;
        }
      }
    });

    // Ortalama başarı oranını hesapla
    final ortalamaBasariOrani =
        islemSayisi > 0 ? toplamBasariOrani / islemSayisi : 0.0;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                  'Toplam Doğru', toplamDogru.toString(), Colors.green),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withOpacity(0.1),
=======
  Widget _buildGeneralStats() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Genel Toplam',
              style: GoogleFonts.quicksand(
                fontSize: 20,
                fontWeight: FontWeight.bold,
>>>>>>> Stashed changes
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Toplam Skor', score.toString()),
                _buildStatItem('Yanlış Sayısı', wrongAnswers.length.toString()),
                _buildStatItem(
                  'Başarı Oranı',
                  '${((score / (score + wrongAnswers.length)) * 100).toStringAsFixed(1)}%',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWrongAnswersList() {
    if (wrongAnswers.isEmpty) {
      return Center(
        child: Text(
          'Henüz yanlış cevap yok!',
          style: GoogleFonts.quicksand(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

<<<<<<< Updated upstream
  List<Map<String, dynamic>> _tumYanlisSorular() {
    List<Map<String, dynamic>> tumYanlislar = [];

    yanlisSorular.forEach((islemTuru, yanlisList) {
      for (var soru in yanlisList) {
        soru['islemTuru'] = islemTuru; // İşlem türünü soruya ekle
        tumYanlislar.add(soru);
      }
    });

    // Tarihe göre sırala (en yeniden en eskiye)
    tumYanlislar.sort((a, b) {
      final dateA = DateTime.parse(a['tarih'] as String);
      final dateB = DateTime.parse(b['tarih'] as String);
      return dateB.compareTo(dateA);
    });

    return tumYanlislar;
  }

  Widget _buildTumYanlisCevaplar() {
    final tumYanlislar = _tumYanlisSorular();

    return SingleChildScrollView(
      child: Column(
        children: tumYanlislar.map((soru) {
          return Container(
            margin: EdgeInsets.only(bottom: 8),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        soru['islemTuru']?.toString() ?? '',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  soru['soru']?.toString() ?? '',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      'Senin Cevabın: ',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      soru['yanlisCevap']?.toString() ?? '',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      'Doğru Cevap: ',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      soru['dogruCevap']?.toString() ?? '',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                if (soru['tarih'] != null) ...[
                  SizedBox(height: 4),
                  Text(
                    _formatDate(DateTime.parse(soru['tarih'] as String)),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStatSection({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              SizedBox(width: 16),
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color valueColor) {
=======
>>>>>>> Stashed changes
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Yanlış Cevaplar',
          style: GoogleFonts.quicksand(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: wrongAnswers.length,
          itemBuilder: (context, index) {
            final wrongAnswer = wrongAnswers[index];
            return Card(
              margin: EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(
                  'Soru: ${wrongAnswer['question']}',
                  style: GoogleFonts.quicksand(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  'Cevabınız: ${wrongAnswer['userAnswer']} (Doğru: ${wrongAnswer['correctAnswer']})',
                  style: GoogleFonts.quicksand(),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

<<<<<<< Updated upstream
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} dakika önce';
      }
      return '${difference.inHours} saat önce';
    } else if (difference.inDays == 1) {
      return 'Dün';
    }
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildYanlisCevaplar(List<Map<String, dynamic>> yanlisList) {
    return SingleChildScrollView(
      child: Column(
        children: yanlisList.take(5).map((soru) {
          return Container(
            margin: EdgeInsets.only(bottom: 8),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  soru['soru']?.toString() ?? '',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      'Senin Cevabın: ',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      soru['yanlisCevap']?.toString() ?? '',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      'Doğru Cevap: ',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      soru['dogruCevap']?.toString() ?? '',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                if (soru['tarih'] != null) ...[
                  SizedBox(height: 4),
                  Text(
                    _formatDate(DateTime.parse(soru['tarih'] as String)),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          );
        }).toList(),
      ),
=======
  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.quicksand(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.quicksand(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
>>>>>>> Stashed changes
    );
  }

  int _calculateTotalCorrect() {
    int toplamDogru = 0;
    performansVerileri.forEach((islemTuru, performansListesi) {
      if (performansListesi.isNotEmpty) {
        final now = DateTime.now();
        final son7GunlukVeriler = performansListesi.where((veri) {
          final fark = now.difference(veri.tarih).inDays;
          return fark <= 7;
        }).toList();

        for (var veri in son7GunlukVeriler) {
          toplamDogru += veri.dogru;
        }
      }
    });
    return toplamDogru;
  }

  int _calculateTotalWrong() {
    int toplamYanlis = 0;
    performansVerileri.forEach((islemTuru, performansListesi) {
      if (performansListesi.isNotEmpty) {
        final now = DateTime.now();
        final son7GunlukVeriler = performansListesi.where((veri) {
          final fark = now.difference(veri.tarih).inDays;
          return fark <= 7;
        }).toList();

        for (var veri in son7GunlukVeriler) {
          toplamYanlis += veri.yanlis;
        }
      }
    });
    return toplamYanlis;
  }

  double _calculateAverageSuccess() {
    double toplamBasariOrani = 0;
    int islemSayisi = 0;

    performansVerileri.forEach((islemTuru, performansListesi) {
      if (performansListesi.isNotEmpty) {
        islemSayisi++;
        final now = DateTime.now();
        final son7GunlukVeriler = performansListesi.where((veri) {
          final fark = now.difference(veri.tarih).inDays;
          return fark <= 7;
        }).toList();

        if (son7GunlukVeriler.isNotEmpty) {
          double islemBasariOrani = 0;
          for (var veri in son7GunlukVeriler) {
            islemBasariOrani += veri.basariOrani;
          }
          toplamBasariOrani += islemBasariOrani / son7GunlukVeriler.length;
        }
      }
    });

    return islemSayisi > 0 ? toplamBasariOrani / islemSayisi : 0.0;
  }
}
