import 'dart:async';
import 'dart:math';
import 'package:carpim_tablosu/mainmenu.dart';
import 'package:carpim_tablosu/quiz.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import './models/level_system.dart';

class IslemTuruSecimEkrani extends StatefulWidget {
  @override
  _IslemTuruSecimEkraniState createState() => _IslemTuruSecimEkraniState();
}

class _IslemTuruSecimEkraniState extends State<IslemTuruSecimEkrani> {
  Map<String, LevelSystem> levelSystems = {};
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _initializeLevelSystems();
    // Her 2 saniyede bir seviye bilgilerini güncelle
    _refreshTimer = Timer.periodic(Duration(seconds: 2), (timer) {
      _loadLevelSystems();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _initializeLevelSystems() async {
    final operations = {
      'Toplama': 'toplama',
      'Çıkarma': 'cikarma',
      'Çarpma': 'carpma',
      'Bölme': 'bolme'
    };

    for (var entry in operations.entries) {
      final levelSystem = LevelSystem();
      levelSystems[entry.key] = levelSystem;
    }
    await _loadLevelSystems();
  }

  Future<void> _loadLevelSystems() async {
    final operations = {
      'Toplama': 'toplama',
      'Çıkarma': 'cikarma',
      'Çarpma': 'carpma',
      'Bölme': 'bolme'
    };

    for (var entry in operations.entries) {
      try {
        String normalizedType = entry.value;
        if (!levelSystems.containsKey(entry.key)) {
          levelSystems[entry.key] = LevelSystem();
        }
        await levelSystems[entry.key]!.loadLevel(normalizedType);
        if (mounted) {
          setState(() {});
        }
      } catch (e) {
        print('Seviye yükleme hatası (${entry.key}): $e');
      }
    }
  }

  Widget _buildOperationCard(String operation, IconData icon) {
    final levelSystem = levelSystems[operation];
    if (levelSystem == null) return Container();

    // İşlem türünü küçük harfe çevir ve Türkçe karakterleri düzelt
    String operationKey = operation
        .toLowerCase()
        .replaceAll('ç', 'c')
        .replaceAll('ı', 'i')
        .replaceAll('ö', 'o')
        .replaceAll('ü', 'u');

    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Quiz(islemTuru: operation),
          ),
        );
        // Geri döndüğünde seviye bilgisini güncelle
        _loadLevelSystems();
      },
      child: Container(
        margin: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 40,
              color: Colors.white,
            ),
            SizedBox(height: 8),
            Text(
              operation,
              style: GoogleFonts.quicksand(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Seviye',
                    style: GoogleFonts.quicksand(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    '${levelSystem.currentLevel}',
                    style: GoogleFonts.quicksand(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff2d2e83),
      appBar: AppBar(
        leading: IconButton(
          highlightColor: Colors.transparent,
            splashColor: Colors.transparent,

            onPressed: () {
            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>Mainmenu(yanlisSorular: [])), (Route<dynamic> route) => false);
            },
            icon: Icon(
              FontAwesomeIcons.angleLeft,
              color: Colors.white,
            )),
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xff2d2e83),
        elevation: 0,
        title: Text(
          'İşlem Seçin',
          style: GoogleFonts.quicksand(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
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
          Padding(
            padding: EdgeInsets.all(16),
            child: GridView.count(
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              children: [
                _buildOperationCard('Toplama', FontAwesomeIcons.plus),
                _buildOperationCard('Çıkarma', FontAwesomeIcons.minus),
                _buildOperationCard('Çarpma', FontAwesomeIcons.xmark),
                _buildOperationCard('Bölme', FontAwesomeIcons.divide),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
