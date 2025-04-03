import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import 'dart:convert';

class PerformansVeri {
  final DateTime tarih;
  final double basariOrani;
  final int dogru;
  final int yanlis;
  final int xp;

  PerformansVeri({
    required this.tarih,
    required this.basariOrani,
    required this.dogru,
    required this.yanlis,
    required this.xp,
  });

  factory PerformansVeri.fromJson(Map<String, dynamic> json) {
    return PerformansVeri(
      tarih: DateTime.parse(json['tarih'] ?? DateTime.now().toIso8601String()),
      basariOrani: (json['basariOrani'] ?? 0.0).toDouble(),
      dogru: json['dogru']?.toInt() ?? 0,
      yanlis: json['yanlis']?.toInt() ?? 0,
      xp: json['xp']?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tarih': tarih.toIso8601String(),
      'basariOrani': basariOrani,
      'dogru': dogru,
      'yanlis': yanlis,
      'xp': xp,
    };
  }
}

class StatisticsScreen extends StatefulWidget {
  @override
  _StatisticsScreenState createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  Map<String, List<PerformansVeri>> performansVerileri = {};
  Map<String, List<Map<String, dynamic>>> yanlisSorular = {};
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    final prefs = await SharedPreferences.getInstance();

    // İşlem türlerini ve karşılık gelen storage key'lerini tanımla
    final operations = {
      'Toplama': 'toplama',
      'Çıkarma': 'cikarma',
      'Çarpma': 'carpma',
      'Bölme': 'bolme'
    };

    Map<String, List<PerformansVeri>> yeniPerformansVerileri = {};
    Map<String, List<Map<String, dynamic>>> yeniYanlisSorular = {};

    for (var entry in operations.entries) {
      final displayName = entry.key;
      final storageKey = entry.value;

      // Debug için yazdır
      print('İşlem türü yükleniyor: $displayName, Key: $storageKey');

      // Performans verilerini yükle
      final performansVerileri = _loadPerformanceData(prefs, storageKey);
      yeniPerformansVerileri[displayName] = performansVerileri;
      print('Performans verileri yüklendi: ${performansVerileri.length} kayıt');

      // Yanlış soruları yükle
      final yanlisList = prefs.getStringList('yanlisSorular_$storageKey') ?? [];
      if (yanlisList.isNotEmpty) {
        try {
          final List<Map<String, dynamic>> parsedList = yanlisList
              .map((jsonStr) => json.decode(jsonStr) as Map<String, dynamic>)
              .toList();

          // Kategori adını normalize et
          for (var soru in parsedList) {
            String kategori = soru['kategori']?.toString().toLowerCase() ?? '';
            if (kategori == "çarpma") kategori = "carpma";
            if (kategori == "çıkarma") kategori = "cikarma";
            if (kategori == "bölme") kategori = "bolme";
            soru['kategori'] = kategori;
          }

          yeniYanlisSorular[displayName] = parsedList;
          print('Yanlış sorular yüklendi: ${parsedList.length} soru');
        } catch (e) {
          print('Yanlış soru yükleme hatası ($displayName): $e');
          yeniYanlisSorular[displayName] = [];
        }
      } else {
        yeniYanlisSorular[displayName] = [];
      }
    }

    if (mounted) {
      setState(() {
        performansVerileri = yeniPerformansVerileri;
        yanlisSorular = yeniYanlisSorular;
      });
    }
  }

  List<PerformansVeri> _loadPerformanceData(
      SharedPreferences prefs, String islemTuru) {
    try {
      final String? jsonString = prefs.getString('performans_$islemTuru');
      print('Performans verisi okunuyor ($islemTuru): $jsonString');

      if (jsonString != null) {
        final List<dynamic> jsonList = json.decode(jsonString);
        return jsonList.map((json) {
          try {
            return PerformansVeri.fromJson(json);
          } catch (e) {
            print('Veri dönüştürme hatası ($islemTuru): $e');
            return PerformansVeri(
              tarih: DateTime.now(),
              basariOrani: 0.0,
              dogru: 0,
              yanlis: 0,
              xp: 0,
            );
          }
        }).toList();
      }
    } catch (e) {
      print('Performans verisi yükleme hatası ($islemTuru): $e');
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff2d2e83),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'İstatistikler',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            height: 50,
            margin: EdgeInsets.only(top: 8),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildTabButton('Genel', 0, Icons.analytics),
                _buildTabButton('Toplama', 1, Icons.add),
                _buildTabButton('Çıkarma', 2, Icons.remove),
                _buildTabButton('Çarpma', 3, Icons.close),
                _buildTabButton('Bölme', 4, Icons.calculate),
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
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildStatSection(
              icon: Icons.analytics,
              title: 'Genel Toplam',
              child: _buildGenelToplam(),
            ),
            if (_tumYanlisSorular().isNotEmpty) ...[
              _buildStatSection(
                icon: Icons.error_outline,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem('Doğru', toplamDogru.toString(), Colors.green),
                  Container(
                    width: 1,
                    height: 40,
                    color: Colors.white.withOpacity(0.1),
                  ),
                  _buildStatItem('Yanlış', toplamYanlis.toString(), Colors.red),
                  Container(
                    width: 1,
                    height: 40,
                    color: Colors.white.withOpacity(0.1),
                  ),
                  _buildStatItem(
                    'Başarı',
                    '%${basariOrani.round()}',
                    Colors.amber,
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Son 7 Günlük Performans',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Container(
              height: 200,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
              ),
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    horizontalInterval: 20,
                    verticalInterval: 1,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.white.withOpacity(0.1),
                        strokeWidth: 1,
                      );
                    },
                    getDrawingVerticalLine: (value) {
                      return FlLine(
                        color: Colors.white.withOpacity(0.05),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value >= 0 && value < gunlukVeriler.length) {
                            final date = gunlukVeriler[value.toInt()].tarih;
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                '${date.day}/${date.month}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            );
                          }
                          return Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 20,
                        reservedSize: 50,
                        getTitlesWidget: (value, meta) {
                          return Container(
                            alignment: Alignment.centerRight,
                            padding: EdgeInsets.only(right: 8),
                            child: Text(
                              '%${value.toInt()}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: false,
                  ),
                  minX: 0,
                  maxX: 6,
                  minY: 0,
                  maxY: 100,
                  lineBarsData: [
                    LineChartBarData(
                      spots: gunlukVeriler.asMap().entries.map((entry) {
                        return FlSpot(
                          entry.key.toDouble(),
                          entry.value.basariOrani.roundToDouble(),
                        );
                      }).toList(),
                      isCurved: true,
                      color: Colors.white,
                      barWidth: 2,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: Colors.white,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (yanlisList.isNotEmpty) ...[
              SizedBox(height: 20),
              Text(
                'Yanlış Cevaplar',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              _buildYanlisCevaplar(yanlisList),
            ],
          ],
        ),
      ),
    );
  }

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
          }
          toplamBasariOrani += son7GunlukVeriler.last.basariOrani;
        }

        // Yanlış cevapları topla
        final yanlisList = yanlisSorular[islemTuru] ?? [];
        toplamYanlis += yanlisList.length;
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
              ),
              _buildStatItem(
                  'Toplam Yanlış', toplamYanlis.toString(), Colors.red),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withOpacity(0.1),
              ),
              _buildStatItem(
                'Genel Başarı',
                '%${ortalamaBasariOrani.round()}',
                Colors.amber,
              ),
            ],
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Son 7 Günlük İstatistikler',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${toplamDogru + toplamYanlis} Soru',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

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
                        soru['islemTuru'] as String,
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
                  soru['soru'] as String,
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
                      soru['yanlisCevap'] as String,
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
                      soru['dogruCevap'] as String,
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 14,
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
                  soru['soru'] as String,
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
                      soru['yanlisCevap'].toString(),
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
                      soru['dogruCevap'].toString(),
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
}
