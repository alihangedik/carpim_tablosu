import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class CarpimTablosuSayfasi extends StatelessWidget {
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
          'Nasıl Oynanır?',
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSection(
                icon: Icons.play_circle_outline,
                title: 'Oyuna Başlama',
                content:
                    'Ana menüden "Oyuna Başla" butonuna tıklayarak istediğiniz işlem türünü (toplama, çıkarma, çarpma, bölme) seçebilirsiniz. Her işlem türü için ayrı seviye ve XP sistemi bulunmaktadır.',
              ),
              _buildSection(
                icon: Icons.timer,
                title: 'Süre ve Puanlama',
                content:
                    'Her soru için belirli bir süreniz vardır. Ne kadar hızlı cevap verirseniz, o kadar çok XP kazanırsınız. Süreyi ayarlar menüsünden değiştirebilirsiniz.',
              ),
              _buildSection(
                icon: Icons.star,
                title: 'Seviye Sistemi',
                content:
                    'Her doğru cevap için XP kazanırsınız. Yeterli XP\'ye ulaştığınızda seviye atlarsınız. Her işlem türü için ayrı seviyeniz vardır ve maksimum 50. seviyeye ulaşabilirsiniz.',
              ),
              _buildSection(
                icon: Icons.flash_on,
                title: 'Seri Sistemi',
                content:
                    'Arka arkaya doğru cevaplar vererek seri oluşturabilirsiniz. Seriniz arttıkça kazandığınız XP miktarı da artar. Yanlış cevap verdiğinizde veya çıkış yaptığınızda seriniz sıfırlanır.',
              ),
              _buildSection(
                icon: Icons.bar_chart,
                title: 'İstatistikler',
                content:
                    'İstatistik ekranından çocuğunuzun her işlem türündeki performansını, seviyelerini ve başarı oranlarını takip edebilirsiniz. Hangi konularda zorlandığını görerek ona yardımcı olabilirsiniz.',
              ),
              _buildSection(
                icon: Icons.settings,
                title: 'Ebeveyn Kontrolü',
                content:
                    'Ayarlar menüsünden çocuğunuzun yaşını, soru sürelerini ve zorluk seviyesini belirleyebilirsiniz. Bu sayede çocuğunuzun seviyesine uygun sorularla çalışmasını sağlayabilirsiniz.',
              ),
              _buildMathSection(
                icon: Icons.add,
                title: 'Toplama İşlemi',
                content:
                    'Yaşınıza ve seçtiğiniz zorluk seviyesine göre uygun sayılar ile toplama işlemleri yaparsınız.',
                example: 'Örnek: 3 + 2 = 5\nÖrnek: 24 + 13 = 37',
                tip:
                    'İpucu: Büyük sayıları önce onlar sonra birler basamağı şeklinde toplayabilirsiniz.',
              ),
              _buildMathSection(
                icon: Icons.remove,
                title: 'Çıkarma İşlemi',
                content:
                    'Yaşınıza ve seçtiğiniz zorluk seviyesine göre uygun sayılar ile çıkarma işlemleri yaparsınız.',
                example: 'Örnek: 7 - 3 = 4\nÖrnek: 52 - 27 = 25',
                tip:
                    'İpucu: Büyük sayıdan küçük sayıyı çıkarırken basamak basamak ilerleyin.',
              ),
              _buildMathSection(
                icon: Icons.close,
                title: 'Çarpma İşlemi',
                content:
                    'Yaşınıza ve seçtiğiniz zorluk seviyesine göre uygun sayılar ile çarpma işlemleri yaparsınız.',
                example: 'Örnek: 4 × 3 = 12\nÖrnek: 8 × 7 = 56',
                tip:
                    'İpucu: Çarpım tablosunu ezberlemek yerine, sayıları gruplama mantığını anlamaya çalışın.',
              ),
              _buildMathSection(
                icon: FontAwesomeIcons.divide,
                title: 'Bölme İşlemi',
                content:
                    'Yaşınıza ve seçtiğiniz zorluk seviyesine göre uygun sayılar ile bölme işlemleri yaparsınız.',
                example: 'Örnek: 6 ÷ 2 = 3\nÖrnek: 45 ÷ 9 = 5',
                tip:
                    'İpucu: Bölme işlemini çarpmanın tersi olarak düşünebilirsiniz.',
              ),
              _buildTipSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
          Expanded(
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

  Widget _buildMathSection({
    required IconData icon,
    required String title,
    required String content,
    required String example,
    required String tip,
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
            crossAxisAlignment: CrossAxisAlignment.start,
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
              Expanded(
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
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 52, top: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    example,
                    style: GoogleFonts.quicksand(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: Colors.amber,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        tip,
                        style: GoogleFonts.quicksand(
                          color: Colors.amber,
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: Colors.amber,
                size: 24,
              ),
              SizedBox(width: 12),
              Text(
                'Genel İpucu',
                style: GoogleFonts.quicksand(
                  color: Colors.amber,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            'Düzenli pratik yaparak ve hatalı sorularınızı tekrar ederek kendinizi geliştirebilirsiniz. Her işlem türü için ayrı seviyeniz olduğunu unutmayın ve tüm işlemlerde ustalaşmaya çalışın!',
            style: GoogleFonts.quicksand(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
