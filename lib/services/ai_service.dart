
import 'dart:convert';
import 'dart:math';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AIService {
  final String? apiKey;
  final List<Map<String, dynamic>> _sonSorular = [];
  final int _maxSoruGecmisi = 20; // Son 20 soruyu takip et

  AIService({this.apiKey});

  bool _soruTekrariVarMi(String soru) {
    return _sonSorular.any((eskiSoru) => eskiSoru['soru'] == soru);
  }

  void _soruEkle(Map<String, dynamic> soru) {
    _sonSorular.add(soru);
    if (_sonSorular.length > _maxSoruGecmisi) {
      _sonSorular.removeAt(0);
    }
  }

  Future<Map<String, dynamic>> generateQuestion({
    required int yas,
    required String islemTuru,
    required String zorlukSeviyesi,
  }) async {

    try {
      Map<String, dynamic> yeniSoru;
      bool soruUygun = false;
      int denemeSayisi = 0;
      final maxDeneme = 10; // Maksimum 10 kez yeni soru üretmeyi dene

      do {
        // Yaş ve zorluk seviyesine göre sayı aralıklarını belirle
        int minSayi = 1;
        int maxSayi = 10;

        // Yaşa göre temel aralıkları belirle
        if (yas <= 6) {
          maxSayi = 10;
        } else if (yas <= 8) {
          maxSayi = 20;
        } else if (yas <= 10) {
          maxSayi = 50;
        } else {
          maxSayi = 100;
        }

        // Zorluk seviyesine göre aralıkları ayarla
        switch (zorlukSeviyesi.toLowerCase()) {
          case 'kolay':
            maxSayi = (maxSayi * 0.5).round();
            break;
          case 'orta':
            break;
          case 'zor':
            maxSayi = (maxSayi * 1.5).round();
            break;
        }

        // Sayıları üret
        int sayi1;
        int sayi2;
        int cevap;
        String islem;

        switch (islemTuru.toLowerCase()) {
          case 'toplama':
            sayi1 = minSayi + Random().nextInt(maxSayi - minSayi);
            sayi2 = minSayi + Random().nextInt(maxSayi - minSayi);
            cevap = sayi1 + sayi2;
            islem = '+';
            break;

          case 'cikarma':
            sayi1 = minSayi + Random().nextInt(maxSayi - minSayi);
            do {
              sayi2 = minSayi + Random().nextInt(sayi1);
            } while (sayi2 >= sayi1);
            cevap = sayi1 - sayi2;
            islem = '-';
            break;

          case 'carpma':
            // Çarpma için özel sayı aralıkları
            int carpmaMinSayi = 1;
            int carpmaMaxSayi;

            // Yaşa göre çarpma için özel aralıklar
            if (yas <= 6) {
              carpmaMaxSayi = 5; // 5 yaş için 1'den 5'e kadar
            } else if (yas <= 8) {
              carpmaMaxSayi = 7; // 6-8 yaş için 1'den 7'ye kadar
            } else if (yas <= 10) {
              carpmaMaxSayi = 10; // 9-10 yaş için 1'den 10'a kadar
            } else {
              carpmaMaxSayi = 12; // 11 yaş ve üstü için 1'den 12'ye kadar
            }

            // Zorluk seviyesine göre ayarla
            switch (zorlukSeviyesi.toLowerCase()) {
              case 'kolay':
                // Kolay seviyede bile en az 2'ye kadar olsun
                carpmaMinSayi = 1;
                carpmaMaxSayi = max(3, (carpmaMaxSayi * 0.5).round());
                break;
              case 'orta':
                carpmaMinSayi = 2;
                // Orta seviye için normal aralık
                break;
              case 'zor':
                carpmaMinSayi = 3;
                carpmaMaxSayi = (carpmaMaxSayi * 1.2).round();
                break;
            }

            // Sayıları üret
            sayi1 = carpmaMinSayi +
                Random().nextInt(carpmaMaxSayi - carpmaMinSayi + 1);
            sayi2 = carpmaMinSayi +
                Random().nextInt(carpmaMaxSayi - carpmaMinSayi + 1);

            // 1x1 gibi çok basit sorulardan kaçın
            if (sayi1 == 1 && sayi2 == 1) {
              sayi1 = 2; // En azından bir sayıyı 2 yap
            }

            cevap = sayi1 * sayi2;
            islem = 'x';
            break;

          case 'bolme':
            sayi2 = minSayi + Random().nextInt(5);
            cevap = minSayi + Random().nextInt((maxSayi ~/ 10) - minSayi);
            sayi1 = sayi2 * cevap;
            islem = '÷';
            break;

          default:
            sayi1 = minSayi + Random().nextInt(maxSayi - minSayi);
            sayi2 = minSayi + Random().nextInt(maxSayi - minSayi);
            cevap = sayi1 + sayi2;
            islem = '+';
        }

        int zorlukPuani = zorlukSeviyesi.toLowerCase() == 'kolay'
            ? 1
            : zorlukSeviyesi.toLowerCase() == 'orta'
                ? 2
                : 3;

        String ipucu = _generateHint(sayi1, sayi2, islem, yas);
        String aciklama = _generateExplanation(sayi1, sayi2, cevap, islem, yas);

        yeniSoru = {
          'soru': '$sayi1 $islem $sayi2',
          'cevap': cevap.toString(),
          'ipucu': ipucu,
          'aciklama': aciklama,
          'zorlukPuani': zorlukPuani.toString(),
        };


        // Soru daha önce sorulmamışsa veya maksimum deneme sayısına ulaşıldıysa döngüden çık
        soruUygun = !_soruTekrariVarMi(yeniSoru['soru']);
        denemeSayisi++;
      } while (!soruUygun && denemeSayisi < maxDeneme);

      // Yeni soruyu geçmişe ekle
      _soruEkle(yeniSoru);

      return yeniSoru;
    } catch (e) {
      print('Soru üretme hatası: $e');
      throw e;
    }
  }

  String _generateHint(int sayi1, int sayi2, String islem, int yas) {
    if (yas <= 7) {
      // Küçük yaşlar için daha basit ipuçları
      switch (islem) {
        case '+':
          return 'Parmaklarını kullanarak sayabilirsin';
        case '-':
          return 'Büyük sayıdan geriye doğru say';
        case 'x':
          return 'Toplama işlemi gibi düşün ve tekrar et';
        case '÷':
          return '$sayi1 içinde kaç tane $sayi2 var?';
        default:
          return 'Adım adım say';
      }
    } else {
      // Büyük yaşlar için daha detaylı ipuçları
      switch (islem) {
        case '+':
          return 'Önce birlikleri, sonra onları topla';
        case '-':
          return 'Büyük sayıdan küçük sayıyı çıkar, gerekirse onluk bozabilirsin';
        case 'x':
          return '$sayi1 sayısını $sayi2 kere topla veya çarpım tablosunu kullan';
        case '÷':
          return '$sayi1 sayısını $sayi2\'ye böl, kaç grup oluşuyor?';
        default:
          return 'İşlemi adım adım yap';
      }
    }
  }

  String _generateExplanation(
      int sayi1, int sayi2, int cevap, String islem, int yas) {
    if (yas <= 7) {
      // Küçük yaşlar için basit açıklamalar
      switch (islem) {
        case '+':
          return '$sayi1 tane nesne ile $sayi2 tane nesneyi bir araya getirince $cevap tane olur';
        case '-':
          return '$sayi1 tane nesneden $sayi2 tanesini çıkarınca $cevap tane kalır';
        case 'x':
          return '$sayi2 kere $sayi1 tane nesne ekleyince $cevap eder';
        case '÷':
          return '$sayi1 tane nesneyi $sayi2\'şerli gruplara ayırınca $cevap grup olur';
        default:
          return 'Sonuç: $cevap';
      }
    } else {
      // Büyük yaşlar için detaylı açıklamalar
      switch (islem) {
        case '+':
          return '$sayi1 + $sayi2 = $cevap\nSayıları soldan sağa doğru topladık';
        case '-':
          return '$sayi1 - $sayi2 = $cevap\nBüyük sayıdan küçük sayıyı çıkardık';
        case 'x':
          return '$sayi1 x $sayi2 = $cevap\n$sayi1 sayısını $sayi2 kere topladık';
        case '÷':
          return '$sayi1 ÷ $sayi2 = $cevap\n$sayi1 sayısını $sayi2\'ye böldük';
        default:
          return 'Sonuç: $cevap';
      }
    }
  }

  Future<String> getHint(String soru, String islemTuru) async {
    try {
      if (apiKey == null) {
        return 'İşlemi adım adım yaparak çözebilirsin.';
      }

      final url = Uri.parse('https://api.openai.com/v1/chat/completions');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'user',
              'content': 'Bu matematik sorusunu çözmek için ipucu ver: $soru',
            }
          ],
          'temperature': 0.7,
          'max_tokens': 100,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'].trim();
      }

      return 'İşlemi adım adım yaparak çözebilirsin.';
    } catch (e) {
      print('İpucu üretme hatası: $e');
      return 'İşlemi adım adım yaparak çözebilirsin.';
    }
  }
    // Basit soru üretme mantığı




  Future<String> getExplanation(
    String soru,
    String cevap,
    String islemTuru,
  ) async {

    try {
      if (apiKey == null) {
        return 'Sorunun çözümü: $cevap';
      }

      final url = Uri.parse('https://api.openai.com/v1/chat/completions');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'user',
              'content':
                  'Bu matematik sorusunun çözümünü açıkla: $soru = $cevap',
            }
          ],
          'temperature': 0.7,
          'max_tokens': 150,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'].trim();
      }

      return 'Sorunun çözümü: $cevap';
    } catch (e) {
      print('Açıklama üretme hatası: $e');
      return 'Sorunun çözümü: $cevap';
    }
  }

  String _buildPrompt(int yas, String islemTuru, String zorlukSeviyesi) {
    return '''
    $yas yaşındaki bir öğrenci için $islemTuru işlemi sorusu üret.
    Zorluk seviyesi: $zorlukSeviyesi
    
    Yanıt formatı:
    {
      "soru": "...",
      "cevap": "...",
      "ipucu": "...",
      "aciklama": "...",
      "zorlukPuani": "1-5 arası"
    }
    ''';
  }

  Map<String, dynamic> _parseResponse(String response) {
    try {
      // JSON formatındaki metni ayıkla
      final jsonStr = response.substring(
        response.indexOf('{'),
        response.lastIndexOf('}') + 1,
      );

      final data = json.decode(jsonStr);
      return {
        'soru': data['soru'] ?? '',
        'cevap': data['cevap'] ?? '',
        'ipucu': data['ipucu'] ?? '',
        'aciklama': data['aciklama'] ?? '',
        'zorlukPuani': data['zorlukPuani'] ?? '1',
      };
    } catch (e) {
      print('Soru ayrıştırma hatası: $e');
      return _generateBasicQuestion('Toplama');
    }
  }

  Map<String, dynamic> _generateBasicQuestion(String islemTuru) {
    final sayi1 = 1 + (DateTime
        .now()
        .millisecondsSinceEpoch % 9);
    final sayi2 = 1 + (DateTime
        .now()
        .microsecondsSinceEpoch % 9);

    String islem;
    String cevap;

    switch (islemTuru.toLowerCase()) {
      case 'toplama':
        islem = '+';
        cevap = (sayi1 + sayi2).toString();
        break;
      case 'cikarma':
        islem = '-';
        cevap = (sayi1 - sayi2).toString();
        break;
      case 'carpma':
        islem = 'x';
        cevap = (sayi1 * sayi2).toString();
        break;
      case 'bolme':
        islem = '÷';
        final carpim = sayi1 * sayi2;
        cevap = sayi1.toString();
        return {
          'soru': '$carpim $islem $sayi2 = ?',
          'cevap': cevap,
          'ipucu': '$carpim ÷ $sayi2 işlemini yap',
          'aciklama': '$carpim sayısını $sayi2 ye bölünce $cevap elde edilir',
          'zorlukPuani': '1',
        };
      default:
        islem = '+';
        cevap = (sayi1 + sayi2).toString();
    }

    return {
      'soru': '$sayi1 $islem $sayi2 = ?',
      'cevap': cevap,
      'ipucu': 'İşlemi adım adım yap',
      'aciklama': 'Basit bir $islemTuru işlemi',
      'zorlukPuani': '1',
    };

  }
}
