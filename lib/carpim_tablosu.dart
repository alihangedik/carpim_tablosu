import 'package:flutter/material.dart';

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
          style: TextStyle(
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
                    'Ana menüden "Oyuna Başla" butonuna tıklayarak istediğiniz işlem türünü (toplama, çıkarma, çarpma, bölme) seçebilirsiniz.',
              ),
              _buildSection(
                icon: Icons.timer,
                title: 'Süre',
                content:
                    'Her soru için belirli bir süreniz vardır. Süre dolmadan doğru cevabı vermeye çalışın. Süreyi ayarlar menüsünden değiştirebilirsiniz.',
              ),
              _buildSection(
                icon: Icons.check_circle_outline,
                title: 'Doğru Cevap',
                content:
                    'Doğru cevabı verdiğinizde puan kazanırsınız ve bir sonraki soruya geçersiniz. Puanınız ne kadar hızlı cevap verirseniz o kadar yüksek olur.',
              ),
              _buildMathSection(
                icon: Icons.add,
                title: 'Toplama İşlemi',
                content:
                    'Toplama, iki veya daha fazla sayıyı birleştirerek daha büyük bir sayı elde etme işlemidir.',
                example: 'Örnek: 3 elma + 2 elma = 5 elma\nÖrnek: 4 + 5 = 9',
                tip:
                    'İpucu: Parmaklarınızı kullanarak sayıları toplayabilirsiniz!',
              ),
              _buildMathSection(
                icon: Icons.remove,
                title: 'Çıkarma İşlemi',
                content:
                    'Çıkarma, bir sayıdan başka bir sayıyı çıkararak kalan miktarı bulma işlemidir.',
                example:
                    'Örnek: 7 kalem - 3 kalem = 4 kalem\nÖrnek: 10 - 6 = 4',
                tip: 'İpucu: Büyük sayıdan küçük sayıyı çıkarın!',
              ),
              _buildMathSection(
                icon: Icons.close,
                title: 'Çarpma İşlemi',
                content:
                    'Çarpma, bir sayıyı kendisiyle belirtilen sayı kadar toplama işlemidir.',
                example:
                    'Örnek: 3 x 4 = 12 (3 + 3 + 3 + 3 = 12)\nÖrnek: 2 x 5 = 10',
                tip: 'İpucu: Çarpma işlemini tekrarlı toplama olarak düşünün!',
              ),
              _buildMathSection(
                icon: Icons.calculate,
                title: 'Bölme İşlemi',
                content: 'Bölme, bir sayıyı eşit parçalara ayırma işlemidir.',
                example:
                    'Örnek: 12 ÷ 3 = 4 (12 şekeri 3 arkadaşa eşit dağıtmak)\nÖrnek: 10 ÷ 2 = 5',
                tip: 'İpucu: Bölme işlemini eşit paylaştırma olarak düşünün!',
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
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  content,
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
          Text(
            content,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
              height: 1.5,
            ),
          ),
          SizedBox(height: 12),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              example,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
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
                  style: TextStyle(
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
                  'Genel İpucu',
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Düzenli pratik yaparak ve hatalı sorularınızı tekrar ederek kendinizi geliştirebilirsiniz. Her gün biraz pratik yapmayı unutmayın!',
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
