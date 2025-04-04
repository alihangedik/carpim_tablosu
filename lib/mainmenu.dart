import 'package:carpim_tablosu/carpim_tablosu.dart';
import 'package:carpim_tablosu/statistics_screen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:carpim_tablosu/settings_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:carpim_tablosu/models/level_system.dart';

import 'islem_secme.dart';
import 'quiz.dart';

class Mainmenu extends StatefulWidget {
  int? mevcutPuan;
  List<Map<String, dynamic>> yanlisSorular;

  Mainmenu({this.mevcutPuan, required this.yanlisSorular});

  @override
  State<Mainmenu> createState() => _MainmenuState();
}

class _MainmenuState extends State<Mainmenu> {
  final String _url = 'https://instagram.com/alihangedikcom';

  @override
  Widget build(BuildContext context) {
    Future<void> _launchUrl() async {
      if (!await launchUrl(Uri.parse(_url))) {
        throw Exception('Could not launch $_url');
      }
    }

    return Scaffold(
      backgroundColor: Color(0xff2d2e83),
      body: Stack(
        children: [
          Positioned(
            bottom: -5,
            right: 0,
            left: 0,
            child: Opacity(
              opacity: 0.3,
              child: Image.asset(
                "assets/backgroud_image_3.png",
                width: 500,
              ),
            ),
          ),
          Positioned(
            top: 45,
            right: 16,
            child: IconButton(
              icon: Icon(FontAwesomeIcons.gear, color: Colors.white, size: 28),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsScreen()),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20, 80, 20, 20),
            child: Column(
              children: [
                Expanded(
                  flex: 2,
                  child: Center(
                    child: ColorFiltered(
                      colorFilter: ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                      child: Image.asset(
                        'assets/carpim_tablosu.png',
                        width: 280,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Color(0xff2d2e83),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 5,
                          ),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => IslemTuruSecimEkrani(),
                              ),
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(FontAwesomeIcons.play, size: 28),
                              SizedBox(width: 12),
                              Text(
                                'Oyuna Başla',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white.withOpacity(0.2),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                elevation: 0,
                              ),
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => StatisticsScreen(),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Icon(FontAwesomeIcons.chartSimple,
                                    size: 28),
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white.withOpacity(0.2),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                elevation: 0,
                              ),
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        CarpimTablosuSayfasi(),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child:
                                    Icon(FontAwesomeIcons.question, size: 28),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
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
