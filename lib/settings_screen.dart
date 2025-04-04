import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' show Platform;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int selectedAge = 7;
  String selectedDifficulty = 'Orta';
  bool soundEnabled = true;
  int _selectedTime = 30;
  String _appVersion = '';
  String _buildNumber = '';
  bool _isLegalExpanded = false;

  @override
  void initState() {
    super.initState();
    loadSettings();
    _loadAppInfo();
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedAge = prefs.getInt('userAge') ?? 7;
      selectedDifficulty = prefs.getString('difficulty') ?? 'Orta';
      soundEnabled = prefs.getBool('soundEnabled') ?? true;
      _selectedTime = prefs.getInt('question_time') ?? 30;
    });
  }

  Future<void> saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('userAge', selectedAge);
    await prefs.setString('difficulty', selectedDifficulty);
    await prefs.setBool('soundEnabled', soundEnabled);
    await prefs.setInt('question_time', _selectedTime);
  }

  Future<void> _loadAppInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _appVersion = packageInfo.version;
        _buildNumber = packageInfo.buildNumber;
      });
    } catch (e) {
      print('Uygulama bilgileri yüklenirken hata: $e');
      setState(() {
        _appVersion = '1.0.0';
        _buildNumber = '1';
      });
    }
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
          'Ayarlar',
          style: GoogleFonts.quicksand(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              _buildSettingSection(
                icon: Icons.person,
                title: 'Yaş',
                child: _buildAgeSetting(),
              ),
              _buildSettingSection(
                icon: Icons.speed,
                title: 'Zorluk Seviyesi',
                child: _buildDifficultySetting(),
              ),
              _buildSettingSection(
                icon: Icons.volume_up,
                title: 'Ses',
                child: _buildSoundSetting(),
              ),
              _buildSettingSection(
                icon: Icons.timer,
                title: 'Soru Süresi',
                child: _buildTimeSetting(),
              ),
              _buildSettingSection(
                icon: Icons.info_outline,
                title: 'Uygulama Bilgileri',
                child: Column(
                  children: [
                    _buildInfoTile('Sürüm', 'v$_appVersion'),
                    Divider(color: Colors.white.withOpacity(0.1)),
                    _buildInfoTile('Geliştirici', 'Alihan Gedik'),
                  ],
                ),
              ),
              _buildSettingSection(
                icon: Icons.delete_forever,
                title: 'Verileri Sıfırla',
                child: Column(
                  children: [
                    Text(
                      'Tüm istatistikleriniz ve ilerlemeniz silinecektir.',
                      style: GoogleFonts.quicksand(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              _buildSettingSection(
                icon: FontAwesomeIcons.envelope,
                title: 'İletişim',
                child: Column(
                  children: [
                    _buildContactTile(
                      'GitHub',
                      'github.com/alihangedik',
                      'https://github.com/alihangedik',
                      FontAwesomeIcons.github,
                    ),
                    Divider(color: Colors.white.withOpacity(0.1)),
                    _buildContactTile(
                      'LinkedIn',
                      'linkedin.com/in/alihangedik',
                      'https://linkedin.com/in/alihangedik',
                      FontAwesomeIcons.linkedin,
                    ),
                    Divider(color: Colors.white.withOpacity(0.1)),
                    _buildContactTile(
                      'Instagram',
                      'instagram.com/alihangedikcom',
                      'https://instagram.com/alihangedikcom',
                      FontAwesomeIcons.instagram,
                    ),
                    Divider(color: Colors.white.withOpacity(0.1)),
                    _buildContactTile(
                      'E-posta',
                      'gedikhan44@gmail.com',
                      'mailto:gedikhan44@gmail.com',
                      FontAwesomeIcons.solidEnvelope,
                    ),
                  ],
                ),
              ),
              _buildTipSection(),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: Colors.amber.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () {
                        setState(() {
                          _isLegalExpanded = !_isLegalExpanded;
                        });
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Yasal Bilgilendirme',
                            style: GoogleFonts.quicksand(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          FutureBuilder<bool>(
                            future: SharedPreferences.getInstance().then(
                              (prefs) =>
                                  prefs.getBool('legal_consent_given') ?? false,
                            ),
                            builder: (context, snapshot) {
                              if (snapshot.hasData && snapshot.data == true) {
                                return Row(
                                  children: [
                                    Text(
                                      'Kabul edildi',
                                      style: GoogleFonts.quicksand(
                                        fontSize: 14,
                                        color: Colors.green[300],
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    Icon(
                                      Icons.check_circle,
                                      color: Colors.green[300],
                                      size: 16,
                                    ),
                                  ],
                                );
                              }
                              return SizedBox();
                            },
                          ),
                          Icon(
                            _isLegalExpanded
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                    if (_isLegalExpanded) ...[
                      SizedBox(height: 12),
                      Text(
                        'Bu uygulama, soruların oluşturulması ve performans değerlendirmelerinde yapay zeka teknolojisinden yararlanmaktadır. Kullanıcılar aşağıdaki koşulları kabul etmiş sayılır:\n\n'
                        '• Yapay zeka tarafından üretilen içeriklerin ve değerlendirmelerin %100 doğruluğu garanti edilemez.\n\n'
                        '• Uygulama içerisinde yapılan değerlendirmeler tavsiye niteliğindedir ve profesyonel eğitim danışmanlığının yerini tutmaz.\n\n'
                        '• Kullanıcılar, yapay zeka sisteminin ürettiği içerikleri kontrol etmekle ve hatalı olduğunu düşündükleri durumları bildirmekle yükümlüdür.\n\n'
                        '• Uygulama geliştiricisi, yapay zeka sisteminin ürettiği içeriklerden ve bu içeriklerin kullanımından doğabilecek herhangi bir zarardan sorumlu tutulamaz.',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingSection({
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.quicksand(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (title == 'Verileri Sıfırla')
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: Colors.white.withOpacity(0.9),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        title: Row(
                          children: [
                            Icon(Icons.warning_amber_rounded,
                                color: Colors.red),
                            SizedBox(width: 10),
                            Text('Dikkat!'),
                          ],
                        ),
                        content: Text(
                          'Tüm verileriniz silinecektir. Bu işlem geri alınamaz.\n\n'
                          '• Tüm istatistikler\n'
                          '• Seviye ilerlemeleri\n'
                          '• Yanlış sorular\n'
                          '• Performans verileri',
                        ),
                        actions: [
                          TextButton(
                            child: Text(
                              'İptal',
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          TextButton(
                            child: Text(
                              'Sıfırla',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onPressed: () async {
                              final prefs =
                                  await SharedPreferences.getInstance();

                              // Tüm performans verilerini sil
                              await prefs.remove('performans_toplama');
                              await prefs.remove('performans_cikarma');
                              await prefs.remove('performans_carpma');
                              await prefs.remove('performans_bolme');

                              // Tüm yanlış soruları sil
                              await prefs.remove('yanlisSorular_toplama');
                              await prefs.remove('yanlisSorular_cikarma');
                              await prefs.remove('yanlisSorular_carpma');
                              await prefs.remove('yanlisSorular_bolme');

                              // Tüm seviye verilerini sil
                              await prefs.remove('level_toplama');
                              await prefs.remove('level_cikarma');
                              await prefs.remove('level_carpma');
                              await prefs.remove('level_bolme');

                              // Tüm doğru/yanlış sayılarını sil
                              await prefs.remove('dogru_toplama');
                              await prefs.remove('dogru_cikarma');
                              await prefs.remove('dogru_carpma');
                              await prefs.remove('dogru_bolme');
                              await prefs.remove('yanlis_toplama');
                              await prefs.remove('yanlis_cikarma');
                              await prefs.remove('yanlis_carpma');
                              await prefs.remove('yanlis_bolme');

                              Navigator.of(context).pop();

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      Text('Tüm veriler başarıyla sıfırlandı.'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child:
                        Icon(Icons.delete_forever, color: Colors.red, size: 20),
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

  Widget _buildAgeSetting() {
    return Platform.isIOS
        ? _buildIOSStyleSetting(
            value: '$selectedAge yaş',
            onTap: () {
              showCupertinoModalPopup(
                context: context,
                builder: (BuildContext context) => Container(
                  height: 216,
                  padding: const EdgeInsets.only(top: 6.0),
                  margin: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  color: Color(0xff2d2e83),
                  child: SafeArea(
                    top: false,
                    child: CupertinoPicker(
                      magnification: 1.22,
                      squeeze: 1.2,
                      useMagnifier: true,
                      itemExtent: 32.0,
                      scrollController: FixedExtentScrollController(
                        initialItem: selectedAge - 5,
                      ),
                      onSelectedItemChanged: (int selectedItem) {
                        setState(() {
                          selectedAge = selectedItem + 5;
                          saveSettings();
                        });
                      },
                      children: List<Widget>.generate(11, (int index) {
                        return Center(
                          child: Text(
                            '${index + 5} yaş',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              );
            },
          )
        : Container(
            padding: EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: selectedAge,
                icon: Container(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                elevation: 2,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
                dropdownColor: Color(0xff2d2e83),
                isExpanded: true,
                onChanged: (int? newValue) {
                  if (newValue != null) {
                    setState(() {
                      selectedAge = newValue;
                      saveSettings();
                    });
                  }
                },
                items: List<DropdownMenuItem<int>>.generate(
                  11,
                  (int index) => DropdownMenuItem<int>(
                    value: index + 5,
                    child: Text('${index + 5} yaş'),
                  ),
                ),
              ),
            ),
          );
  }

  Widget _buildDifficultySetting() {
    return Platform.isIOS
        ? _buildIOSStyleSetting(
            value: selectedDifficulty,
            onTap: () {
              showCupertinoModalPopup(
                context: context,
                builder: (BuildContext context) => Container(
                  height: 216,
                  padding: const EdgeInsets.only(top: 6.0),
                  margin: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  color: Color(0xff2d2e83),
                  child: SafeArea(
                    top: false,
                    child: CupertinoPicker(
                      magnification: 1.22,
                      squeeze: 1.2,
                      useMagnifier: true,
                      itemExtent: 32.0,
                      scrollController: FixedExtentScrollController(
                        initialItem: ['Kolay', 'Orta', 'Zor']
                            .indexOf(selectedDifficulty),
                      ),
                      onSelectedItemChanged: (int selectedItem) {
                        setState(() {
                          selectedDifficulty =
                              ['Kolay', 'Orta', 'Zor'][selectedItem];
                          saveSettings();
                        });
                      },
                      children:
                          ['Kolay', 'Orta', 'Zor'].map((String difficulty) {
                        return Center(
                          child: Text(
                            difficulty,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              );
            },
          )
        : Container(
            padding: EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedDifficulty,
                icon: Container(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                elevation: 2,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
                dropdownColor: Color(0xff2d2e83),
                isExpanded: true,
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      selectedDifficulty = newValue;
                      saveSettings();
                    });
                  }
                },
                items: ['Kolay', 'Orta', 'Zor']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
          );
  }

  Widget _buildSoundSetting() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Ses Efektleri',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        Switch(
          value: soundEnabled,
          onChanged: (bool value) {
            setState(() {
              soundEnabled = value;
              saveSettings();
            });
          },
          activeColor: Colors.white,
          activeTrackColor: Colors.white.withOpacity(0.3),
          inactiveThumbColor: Colors.white.withOpacity(0.5),
          inactiveTrackColor: Colors.white.withOpacity(0.1),
        ),
      ],
    );
  }

  Widget _buildTimeSetting() {
    return Platform.isIOS
        ? _buildIOSStyleSetting(
            value: '$_selectedTime saniye',
            onTap: () {
              showCupertinoModalPopup(
                context: context,
                builder: (BuildContext context) => Container(
                  height: 216,
                  padding: const EdgeInsets.only(top: 6.0),
                  margin: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  color: Color(0xff2d2e83),
                  child: SafeArea(
                    top: false,
                    child: CupertinoPicker(
                      magnification: 1.22,
                      squeeze: 1.2,
                      useMagnifier: true,
                      itemExtent: 32.0,
                      scrollController: FixedExtentScrollController(
                        initialItem: [15, 30, 45, 60].indexOf(_selectedTime),
                      ),
                      onSelectedItemChanged: (int selectedItem) {
                        setState(() {
                          _selectedTime = [15, 30, 45, 60][selectedItem];
                          saveSettings();
                        });
                      },
                      children: [15, 30, 45, 60].map((int time) {
                        return Center(
                          child: Text(
                            '$time saniye',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              );
            },
          )
        : Container(
            padding: EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _selectedTime,
                icon: Container(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                elevation: 2,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
                dropdownColor: Color(0xff2d2e83),
                isExpanded: true,
                onChanged: (int? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedTime = newValue;
                      saveSettings();
                    });
                  }
                },
                items: [15, 30, 45, 60].map<DropdownMenuItem<int>>((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text('$value saniye'),
                  );
                }).toList(),
              ),
            ),
          );
  }

  Widget _buildIOSStyleSetting({
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.white,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactTile(
    String title,
    String subtitle,
    String url,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        onTap: () async {
          final uri = Uri.parse(url);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri);
          }
        },
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 20,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
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

  Widget _buildTipSection() {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.amber.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.lightbulb_outline, color: Colors.amber, size: 24),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'İpucu',
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Başlangıçta daha uzun süreler seçerek pratik yapabilirsiniz. Geliştikçe süreyi azaltıp zorluk seviyesini artırabilirsiniz!',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                    height: 1.5,
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
