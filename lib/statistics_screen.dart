import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
// Aşağıdakiler başka bölümlerde kullanılabilir; durmalarında sakınca yok.
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';

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

    final borderGradient = LinearGradient(
      colors: [
        glowColor.withOpacity(0.05),
        glowColor.withOpacity(1),
        glowColor.withOpacity(0.05),
      ],
      stops: const [0.0, 0.5, 1.0],
    );

    final outerGlowPaint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..shader = borderGradient.createShader(
        Rect.fromPoints(
          Offset(size.width * (progress - 0.8), 0),
          Offset(size.width * (progress + 0.8), size.height),
        ),
      );

    final innerGlowPaint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..shader = borderGradient.createShader(
        Rect.fromPoints(
          Offset(size.width * (progress - 0.6), 0),
          Offset(size.width * (progress + 0.6), size.height),
        ),
      );

    final ambientGlowPaint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12)
      ..color = glowColor.withOpacity(0.05);

    canvas.drawRRect(rect.inflate(2), ambientGlowPaint);
    canvas.drawRRect(rect, outerGlowPaint);
    canvas.drawRRect(rect, innerGlowPaint);
  }

  @override
  bool shouldRepaint(GlowBorderPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.glowColor != glowColor ||
        oldDelegate.radius != radius;
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
      duration: const Duration(milliseconds: 2500),
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

    // İşlem türleri: görüntü adı -> storage anahtarı
    final operations = {
      'Toplama': 'toplama',
      'Çıkarma': 'cikarma',
      'Çarpma': 'carpma',
      'Bölme': 'bolme'
    };

    final Map<String, List<PerformansVeri>> yeniPerformansVerileri = {};
    final Map<String, List<Map<String, dynamic>>> yeniYanlisSorular = {};

    for (var entry in operations.entries) {
      final displayName = entry.key;
      final storageKey = entry.value;

      // Performans verileri
      final performansKey = 'performans_$storageKey';
      final performansJson = prefs.getString(performansKey);

      if (performansJson != null) {
        try {
          final List<dynamic> performansList = json.decode(performansJson);

          final Map<String, PerformansVeri> gunlukVeriler = {};

          for (var veri in performansList) {
            final tarih = DateTime.parse(veri['tarih'] as String);
            final tarihKey = '${tarih.year}-${tarih.month}-${tarih.day}';

            gunlukVeriler.putIfAbsent(
              tarihKey,
                  () => PerformansVeri(
                tarih: tarih,
                basariOrani: 0,
                dogru: 0,
                yanlis: 0,
                xp: 0,
                islemTuru: storageKey,
              ),
            );

            final g = gunlukVeriler[tarihKey]!;
            final dogruMu = veri['dogru'] as bool;

            if (dogruMu) {
              gunlukVeriler[tarihKey] = PerformansVeri(
                tarih: tarih,
                basariOrani: ((g.dogru + 1) /
                    (g.dogru + g.yanlis + 1) *
                    100)
                    .toDouble(),
                dogru: g.dogru + 1,
                yanlis: g.yanlis,
                xp: g.xp + int.parse(veri['zorlukPuani'] as String) * 10,
                islemTuru: storageKey,
              );
            } else {
              gunlukVeriler[tarihKey] = PerformansVeri(
                tarih: tarih,
                basariOrani:
                (g.dogru / (g.dogru + g.yanlis + 1) * 100).toDouble(),
                dogru: g.dogru,
                yanlis: g.yanlis + 1,
                xp: g.xp,
                islemTuru: storageKey,
              );
            }
          }

          yeniPerformansVerileri[displayName] =
          gunlukVeriler.values.toList()..sort((a, b) => a.tarih.compareTo(b.tarih));
        } catch (e) {
          // quietly skip broken json
          yeniPerformansVerileri[displayName] = [];
        }
      } else {
        yeniPerformansVerileri[displayName] = [];
      }

      // Yanlış sorular
      final yanlisSorularKey = 'yanlisSorular_$storageKey';
      final yanlisList = prefs.getStringList(yanlisSorularKey) ?? [];

      try {
        final List<Map<String, dynamic>> islemYanlislari = yanlisList
            .map((jsonStr) => json.decode(jsonStr) as Map<String, dynamic>)
            .toList();
        yeniYanlisSorular[displayName] = islemYanlislari;
      } catch (e) {
        yeniYanlisSorular[displayName] = [];
      }
    }

    if (!mounted) return;
    setState(() {
      performansVerileri = yeniPerformansVerileri;
      yanlisSorular = yeniYanlisSorular;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff2d2e83),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('İstatistikler', style: GoogleFonts.quicksand()),
      ),
      body: Column(
        children: [
          // Sekmeler
          Container(
            height: 50,
            margin: const EdgeInsets.only(top: 8, bottom: 20),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildTabButton('Genel', 0, FontAwesomeIcons.chartSimple),
                _buildTabButton('Toplama', 1, FontAwesomeIcons.plus),
                _buildTabButton('Çıkarma', 2, FontAwesomeIcons.minus),
                _buildTabButton('Çarpma', 3, FontAwesomeIcons.xmark),
                _buildTabButton('Bölme', 4, FontAwesomeIcons.divide),
              ],
            ),
          ),
          // Sayfalar
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _selectedIndex = index);
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

  // Sekme butonu
  Widget _buildTabButton(String text, int index, IconData icon) {
    final bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              text,
              style: GoogleFonts.quicksand(
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

  // GENEL sayfası
  Widget _buildGenelPage() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
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
                  return SizedBox(
                    height: 80,
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const SizedBox.shrink();
                }

                final data = snapshot.data!;
                final yetersiz = data['baslik'] == 'Veri Yetersiz';

                return Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Stack(
                    fit: StackFit.passthrough,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  FontAwesomeIcons.graduationCap,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Matematik Koçun',
                                  style: GoogleFonts.quicksand(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            if (!yetersiz) ...[
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  data['baslik'] ?? '',
                                  style: GoogleFonts.quicksand(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: 8),
                            Text(
                              yetersiz
                                  ? 'Performans değerlendirmesi için en az 7 farklı günde pratik yapılması gerekiyor.'
                                  : (data['yorum'] ?? ''),
                              style: GoogleFonts.quicksand(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                                height: 1.5,
                                fontStyle: yetersiz
                                    ? FontStyle.italic
                                    : FontStyle.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!yetersiz)
                        Positioned.fill(
                          child: IgnorePointer(
                            child: AnimatedBuilder(
                              animation: _glowController,
                              builder: (context, child) {
                                return CustomPaint(
                                  painter: GlowBorderPainter(
                                    progress: Curves.easeInOutSine
                                        .transform(_glowController.value),
                                    glowColor: const Color(0xFF4B4CFF),
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
              title: 'Genel Toplam (Son 7 Gün)',
              child: _buildGenelToplam(),
            ),
            if (_tumYanlisSorular().isNotEmpty)
              _buildStatSection(
                icon: FontAwesomeIcons.exclamation,
                title: 'Tüm Yanlış Cevaplar',
                child: _buildTumYanlisCevaplar(),
              ),
          ],
        ),
      ),
    );
  }

  // İşlem bazlı sayfa
  Widget _buildIslemPage(String islemTuru) {
    final performansListesi = performansVerileri[islemTuru] ?? [];
    final yanlisList = yanlisSorular[islemTuru] ?? [];

    // Son 7 gün
    final now = DateTime.now();
    final List<PerformansVeri> gunlukVeriler = List.generate(7, (index) {
      final tarih = DateTime(now.year, now.month, now.day - (6 - index));
      final gunVeri = performansListesi.where((veri) {
        final t = veri.tarih;
        return t.year == tarih.year && t.month == tarih.month && t.day == tarih.day;
      }).toList();

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

    int toplamDogru = 0;
    int toplamYanlis = 0;
    for (var v in gunlukVeriler) {
      toplamDogru += v.dogru;
      toplamYanlis += v.yanlis;
    }
    final toplam = toplamDogru + toplamYanlis;
    final basariOrani = toplam > 0 ? (toplamDogru / toplam * 100) : 0.0;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildStatSection(
              icon: FontAwesomeIcons.clipboardCheck,
              title: '$islemTuru Özeti (Son 7 Gün)',
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem('Doğru', toplamDogru.toString(),
                      valueColor: Colors.green),
                  Container(
                    width: 1,
                    height: 40,
                    color: Colors.white.withOpacity(0.1),
                  ),
                  _buildStatItem('Yanlış', toplamYanlis.toString(),
                      valueColor: Colors.redAccent),
                  Container(
                    width: 1,
                    height: 40,
                    color: Colors.white.withOpacity(0.1),
                  ),
                  _buildStatItem(
                    'Başarı',
                    '${basariOrani.toStringAsFixed(1)}%',
                    valueColor: Colors.amber,
                  ),
                ],
              ),
            ),
            if (yanlisList.isNotEmpty)
              _buildStatSection(
                icon: FontAwesomeIcons.circleXmark,
                title: '$islemTuru Yanlışları',
                child: _buildYanlisCevaplar(yanlisList),
              ),
          ],
        ),
      ),
    );
  }

  // GENEL — üst toplamlar
  Widget _buildGenelToplam() {
    int toplamDogru = 0;
    int toplamYanlis = 0;
    double toplamBasariOrani = 0;
    int islemSayisi = 0;

    performansVerileri.forEach((_, performansListesi) {
      if (performansListesi.isNotEmpty) {
        islemSayisi++;
        final now = DateTime.now();
        final son7 = performansListesi.where((veri) {
          final fark = now.difference(veri.tarih).inDays;
          return fark <= 7;
        }).toList();

        for (var v in son7) {
          toplamDogru += v.dogru;
          toplamYanlis += v.yanlis;
        }

        if (son7.isNotEmpty) {
          double islemBasari = 0;
          for (var v in son7) {
            islemBasari += v.basariOrani;
          }
          toplamBasariOrani += islemBasari / son7.length;
        }
      }
    });

    final ortalamaBasariOrani =
    islemSayisi > 0 ? (toplamBasariOrani / islemSayisi) : 0.0;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem('Toplam Doğru', '$toplamDogru',
                valueColor: Colors.green),
            
            Container(width: 1, height: 40, color: Colors.white.withOpacity(0.1)),
            _buildStatItem('Toplam Yanlış', '$toplamYanlis',
                valueColor: Colors.redAccent),
            Container(width: 1, height: 40, color: Colors.white.withOpacity(0.1)),
            _buildStatItem('Ortalama Başarı',
                '${ortalamaBasariOrani.toStringAsFixed(1)}%',
                valueColor: Colors.amber),
          ],
        ),
      ],
    );
  }

  // Tüm yanlışlar (tür eklenmiş ve tarihe göre sıralı)
  List<Map<String, dynamic>> _tumYanlisSorular() {
    final List<Map<String, dynamic>> tum = [];
    yanlisSorular.forEach((islemTuru, list) {
      for (final s in list) {
        final copy = Map<String, dynamic>.from(s);
        copy['islemTuru'] = islemTuru;
        tum.add(copy);
      }
    });
    tum.sort((a, b) {
      final dateA = DateTime.parse(a['tarih'] as String);
      final dateB = DateTime.parse(b['tarih'] as String);
      return dateB.compareTo(dateA);
    });
    return tum;
  }

  Widget _buildTumYanlisCevaplar() {
    final tumYanlislar = _tumYanlisSorular();
    return Column(
      children: tumYanlislar.map((soru) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(10),
          ),
          child: _yanlisCevapTile(soru),
        );
      }).toList(),
    );
  }

  // İşlem sayfasında kısa liste
  Widget _buildYanlisCevaplar(List<Map<String, dynamic>> yanlisList) {
    return Column(
      children: yanlisList.take(5).map((soru) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(10),
          ),
          child: _yanlisCevapTile(soru),
        );
      }).toList(),
    );
  }

  // Kart içeriği
  Widget _yanlisCevapTile(Map<String, dynamic> soru) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (soru['islemTuru'] != null) ...[
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  soru['islemTuru'].toString(),
                  style: GoogleFonts.quicksand(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        Text(
          (soru['soru'] ?? '').toString(),
          style: GoogleFonts.quicksand(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              'Senin Cevabın: ',
              style: GoogleFonts.quicksand(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
            Text(
              (soru['yanlisCevap'] ?? '').toString(),
              style: GoogleFonts.quicksand(
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
              style: GoogleFonts.quicksand(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
            Text(
              (soru['dogruCevap'] ?? '').toString(),
              style: GoogleFonts.quicksand(
                color: Colors.green,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        if (soru['tarih'] != null) ...[
          const SizedBox(height: 4),
          Text(
            _formatDate(DateTime.parse(soru['tarih'] as String)),
            style: GoogleFonts.quicksand(
              color: Colors.white.withOpacity(0.5),
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }

  // Bölüm başlığı + kutu
  Widget _buildStatSection({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: GoogleFonts.quicksand(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  // Basit sayı kartı
  Widget _buildStatItem(String label, String value, {Color? valueColor}) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.quicksand(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: valueColor ?? Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.quicksand(
            fontSize: 14,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

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

  // (İsteğe bağlı) Toplamlar hesap yardımcıları:
  int _calculateTotalCorrect() {
    int toplamDogru = 0;
    performansVerileri.forEach((_, list) {
      final now = DateTime.now();
      final son7 = list.where((v) => now.difference(v.tarih).inDays <= 7);
      for (var v in son7) toplamDogru += v.dogru;
    });
    return toplamDogru;
  }

  int _calculateTotalWrong() {
    int toplamYanlis = 0;
    performansVerileri.forEach((_, list) {
      final now = DateTime.now();
      final son7 = list.where((v) => now.difference(v.tarih).inDays <= 7);
      for (var v in son7) toplamYanlis += v.yanlis;
    });
    return toplamYanlis;
  }

  double _calculateAverageSuccess() {
    double toplamBasari = 0;
    int islemSayisi = 0;

    performansVerileri.forEach((_, list) {
      if (list.isEmpty) return;
      islemSayisi++;
      final now = DateTime.now();
      final son7 = list.where((v) => now.difference(v.tarih).inDays <= 7).toList();
      if (son7.isEmpty) return;
      double ort = 0;
      for (var v in son7) ort += v.basariOrani;
      toplamBasari += (ort / son7.length);
    });

    return islemSayisi > 0 ? (toplamBasari / islemSayisi) : 0.0;
  }
}


// == GRAFİK YARDIMCILARI ==

List<PerformansVeri> _last7DaysSeries(List<PerformansVeri> list) {
  final now = DateTime.now();
  return List.generate(7, (i) {
    final d = DateTime(now.year, now.month, now.day - (6 - i));
    final inDay = list.where((v) =>
    v.tarih.year == d.year && v.tarih.month == d.month && v.tarih.day == d.day);
    return inDay.isNotEmpty
        ? inDay.last
        : PerformansVeri(
      tarih: d,
      basariOrani: 0,
      dogru: 0,
      yanlis: 0,
      xp: 0,
      islemTuru: '',
    );
  });
}

// Tek serilik haftalık başarı çizgisi (0-100%)
Widget buildWeeklySuccessLineChart(List<PerformansVeri> gunlukVeriler) {
  final spots = <FlSpot>[];
  for (int i = 0; i < gunlukVeriler.length; i++) {
    final y = gunlukVeriler[i].basariOrani.clamp(0, 100).toDouble();
    spots.add(FlSpot(i.toDouble(), y));
  }

  return SizedBox(
    height: 180,
    child: LineChart(
      LineChartData(
        minX: 0, maxX: 6, minY: 0, maxY: 100,
        gridData: FlGridData(
          show: true, drawVerticalLine: false, horizontalInterval: 20,
          getDrawingHorizontalLine: (_) => FlLine(
            color: Colors.white.withOpacity(0.10), strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true, reservedSize: 28, interval: 20,
              getTitlesWidget: (v, __) => Text(
                '${v.toInt()}',
                style: TextStyle(color: Colors.white.withOpacity(.7), fontSize: 10),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true, reservedSize: 22,
              getTitlesWidget: (v, __) {
                const labels = ['Pzt','Sal','Çar','Per','Cum','Cts','Paz'];
                final i = v.toInt().clamp(0, 6);
                return Text(labels[i],
                    style: TextStyle(color: Colors.white.withOpacity(.7), fontSize: 10));
              },
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            barWidth: 3,
            color: const Color(0xff4B4CFF),
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: const Color(0xff4B4CFF).withOpacity(0.15),
            ),
          ),
        ],
      ),
    ),
  );
}

// Doğru/Yanlış donut
Widget buildCorrectWrongDonut(int correct, int wrong) {
  final total = (correct + wrong);
  final correctPerc = total == 0 ? 0.0 : correct / total;
  final wrongPerc = total == 0 ? 0.0 : wrong / total;

  return SizedBox(
    height: 160,
    child: Stack(
      alignment: Alignment.center,
      children: [
        PieChart(
          PieChartData(
            sectionsSpace: 2,
            centerSpaceRadius: 45,
            startDegreeOffset: -90,
            sections: [
              PieChartSectionData(
                value: correct.toDouble(),
                title: '',
                color: Colors.greenAccent.withOpacity(.85),
                radius: 42,
              ),
              PieChartSectionData(
                value: wrong.toDouble(),
                title: '',
                color: Colors.redAccent.withOpacity(.85),
                radius: 42,
              ),
            ],
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${(correctPerc * 100).toStringAsFixed(0)}%',
              style: GoogleFonts.quicksand(
                  color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
            ),
            Text(
              'Başarı',
              style: GoogleFonts.quicksand(
                  color: Colors.white.withOpacity(.8), fontSize: 12),
            ),
          ],
        ),
      ],
    ),
  );
}

// GENEL için haftalık ortalama başarı çizgisi (tüm işlemlerin ortalaması)
Widget buildOverallWeeklyLine(Map<String, List<PerformansVeri>> data) {
  // Her gün için tüm işlemlerin basariOrani ortalaması
  final now = DateTime.now();
  final List<double> dailyAvg = List.generate(7, (i) {
    final d = DateTime(now.year, now.month, now.day - (6 - i));
    double sum = 0; int count = 0;
    data.forEach((_, list) {
      final match = list.where((v) =>
      v.tarih.year == d.year && v.tarih.month == d.month && v.tarih.day == d.day);
      if (match.isNotEmpty) {
        sum += match.last.basariOrani; count++;
      }
    });
    return count == 0 ? 0 : (sum / count);
  });

  final spots = [
    for (int i = 0; i < dailyAvg.length; i++)
      FlSpot(i.toDouble(), dailyAvg[i].clamp(0, 100).toDouble())
  ];

  return SizedBox(
    height: 180,
    child: LineChart(
      LineChartData(
        minX: 0, maxX: 6, minY: 0, maxY: 100,
        gridData: FlGridData(
          show: true, drawVerticalLine: false, horizontalInterval: 20,
          getDrawingHorizontalLine: (_) => FlLine(
            color: Colors.white.withOpacity(0.10), strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true, reservedSize: 28, interval: 20,
              getTitlesWidget: (v, __) => Text(
                '${v.toInt()}', style: TextStyle(color: Colors.white.withOpacity(.7), fontSize: 10),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true, reservedSize: 22,
              getTitlesWidget: (v, __) {
                const labels = ['Pzt','Sal','Çar','Per','Cum','Cts','Paz'];
                final i = v.toInt().clamp(0, 6);
                return Text(labels[i],
                    style: TextStyle(color: Colors.white.withOpacity(.7), fontSize: 10));
              },
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            barWidth: 3,
            color: const Color(0xffEC38BC),
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: const Color(0xffEC38BC).withOpacity(0.15),
            ),
          ),
        ],
      ),
    ),
  );
}