import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../age_selection.dart';
import '../mainmenu.dart';

class LegalConsentScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff2d2e83),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 40),
              Text(
                'Yasal Bilgilendirme',
                style: GoogleFonts.quicksand(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bu uygulamayı kullanmadan önce lütfen aşağıdaki koşulları dikkatlice okuyun:',
                        style: GoogleFonts.quicksand(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                      SizedBox(height: 20),
                      _buildInfoCard(
                        'Yapay Zeka Kullanımı',
                        'Bu uygulama, soruların oluşturulması ve performans değerlendirmelerinde yapay zeka teknolojisinden yararlanmaktadır.',
                      ),
                      SizedBox(height: 16),
                      _buildInfoCard(
                        'Doğruluk Garantisi',
                        'Yapay zeka tarafından üretilen içeriklerin ve değerlendirmelerin %100 doğruluğu garanti edilemez.',
                      ),
                      SizedBox(height: 16),
                      _buildInfoCard(
                        'Tavsiye Niteliği',
                        'Uygulama içerisinde yapılan değerlendirmeler tavsiye niteliğindedir ve profesyonel eğitim danışmanlığının yerini tutmaz.',
                      ),
                      SizedBox(height: 16),
                      _buildInfoCard(
                        'Kullanıcı Sorumluluğu',
                        'Kullanıcılar, yapay zeka sisteminin ürettiği içerikleri kontrol etmekle ve hatalı olduğunu düşündükleri durumları bildirmekle yükümlüdür.',
                      ),
                      SizedBox(height: 16),
                      _buildInfoCard(
                        'Sorumluluk Reddi',
                        'Uygulama geliştiricisi, yapay zeka sisteminin ürettiği içeriklerden ve bu içeriklerin kullanımından doğabilecek herhangi bir zarardan sorumlu tutulamaz.',
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('legal_consent_given', true);

                  // Yaş seçimi yapılmış mı kontrol et
                  final selectedAge = prefs.getInt('selected_age');
                  if (selectedAge != null) {
                    // Yaş seçimi yapılmışsa ana menüye git
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => Mainmenu(yanlisSorular: []),
                      ),
                    );
                  } else {
                    // Yaş seçimi yapılmamışsa yaş seçim ekranına git
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => AgeSelectionScreen(),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Color(0xff2d2e83),
                  minimumSize: Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: Text(
                  'Okudum ve Kabul Ediyorum',
                  style: GoogleFonts.quicksand(
                    fontSize: 18,
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

  Widget _buildInfoCard(String title, String content) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.quicksand(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            content,
            style: GoogleFonts.quicksand(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
