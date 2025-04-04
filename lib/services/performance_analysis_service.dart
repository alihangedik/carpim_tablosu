<<<<<<< Updated upstream
<<<<<<< Updated upstream
import 'package:shared_preferences/shared_preferences.dart';
=======
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
import '../models/performans_veri.dart';

class PerformanceAnalysisService {
  Future<Map<String, String>> generatePerformanceInsight({
    required Map<String, List<PerformansVeri>> performansVerileri,
    required Map<String, List<Map<String, dynamic>>> yanlisSorular,
  }) async {
<<<<<<< Updated upstream
<<<<<<< Updated upstream
    try {
      final prefs = await SharedPreferences.getInstance();
      final yas = prefs.getInt('userAge') ?? 7;

      // Son 7 günün her biri için veri kontrolü
      final now = DateTime.now();
      Set<String> gunler = {};
      int toplamDogru = 0;
      int toplamYanlis = 0;
      double toplamBasariOrani = 0;
      int islemSayisi = 0;
      String enIyiIslemTuru = '';
      double enYuksekBasariOrani = 0;
      String enZorIslemTuru = '';
      double enDusukBasariOrani = 100;

      // Her işlem türü için analiz yap
      performansVerileri.forEach((islemTuru, performansListesi) {
        if (performansListesi.isNotEmpty) {
          final son7GunlukVeriler = performansListesi.where((veri) {
            final fark = now.difference(veri.tarih).inDays;
            if (fark <= 7) {
              // Gün takibi için tarih formatı
              String gunKey =
                  '${veri.tarih.year}-${veri.tarih.month}-${veri.tarih.day}';
              gunler.add(gunKey);
              return true;
            }
            return false;
          }).toList();

          if (son7GunlukVeriler.isNotEmpty) {
            islemSayisi++;
            int islemDogruSayisi = 0;
            int islemYanlisSayisi = 0;

            for (var veri in son7GunlukVeriler) {
              islemDogruSayisi += veri.dogru;
              islemYanlisSayisi += veri.yanlis;
            }

            final islemBasariOrani =
                islemDogruSayisi / (islemDogruSayisi + islemYanlisSayisi) * 100;

            toplamDogru += islemDogruSayisi;
            toplamYanlis += islemYanlisSayisi;
            toplamBasariOrani += islemBasariOrani;

            if (islemBasariOrani > enYuksekBasariOrani) {
              enYuksekBasariOrani = islemBasariOrani;
              enIyiIslemTuru = islemTuru;
            }
            if (islemBasariOrani < enDusukBasariOrani) {
              enDusukBasariOrani = islemBasariOrani;
              enZorIslemTuru = islemTuru;
            }
          }
        }
      });

      // En az 3 farklı günde veri olmalı
      if (gunler.length < 3) {
        return {
          'baslik': 'Veri Yetersiz',
          'yorum':
              'Değerlendirme için en az 3 farklı günde pratik yapılması gerekiyor.'
        };
      }

      final ortalamaBasariOrani =
          islemSayisi > 0 ? toplamBasariOrani / islemSayisi : 0.0;
      final toplamSoru = toplamDogru + toplamYanlis;

      // Yaşa göre beklenen başarı oranları
      double beklenenBasariOrani = yas <= 7 ? 65.0 : (yas <= 9 ? 75.0 : 85.0);

      // Başlık ve yorum belirleme
      String baslik;
      String yorum;

      if (ortalamaBasariOrani >= beklenenBasariOrani + 10) {
        baslik = 'Mükemmel! 🌟';
        yorum = '$enIyiIslemTuru işleminde çok başarılı. ';
        if (toplamSoru > 50) {
          yorum += 'Düzenli çalışması takdir edilesi.';
        }
      } else if (ortalamaBasariOrani >= beklenenBasariOrani) {
        baslik = 'Başarılı 👏';
        yorum = 'Genel performansı iyi düzeyde. ';
        if (enZorIslemTuru.isNotEmpty) {
          yorum += '$enZorIslemTuru konusunda biraz daha pratik yapabilir.';
        }
      } else if (ortalamaBasariOrani >= beklenenBasariOrani - 15) {
        baslik = 'Gelişime Açık 💪';
        yorum = 'Daha fazla pratik yaparak performansını artırabilir. ';
        if (enIyiIslemTuru.isNotEmpty) {
          yorum +=
              '$enIyiIslemTuru işlemindeki başarısını diğer konulara da taşıyabilir.';
        }
      } else {
        baslik = 'Desteğe İhtiyacı Var 🎯';
        yorum =
            'Düzenli pratik yapması ve temel konuları tekrar etmesi faydalı olacaktır.';
      }

      return {'baslik': baslik, 'yorum': yorum};
    } catch (e) {
      print('Performans analizi hatası: $e');
      return {'baslik': 'Hata', 'yorum': 'Performans analizi yapılamadı.'};
    }
=======
=======
>>>>>>> Stashed changes
    // Veri yoksa
    if (performansVerileri.isEmpty) {
      return {
        'baslik': 'Veri Yetersiz',
        'yorum': 'Henüz yeterli veri bulunmuyor.',
      };
    }

    // Toplam doğru ve yanlış sayılarını hesapla
    int toplamDogru = 0;
    int toplamYanlis = 0;
    double toplamBasariOrani = 0;
    int islemSayisi = 0;

    performansVerileri.forEach((islemTuru, veriler) {
      if (veriler.isNotEmpty) {
        islemSayisi++;
        for (var veri in veriler) {
          toplamDogru += veri.dogru;
          toplamYanlis += veri.yanlis;
          toplamBasariOrani += veri.basariOrani;
        }
      }
    });

    // Ortalama başarı oranını hesapla
    double ortalamaBasariOrani =
        islemSayisi > 0 ? toplamBasariOrani / islemSayisi : 0;

    // Performans yorumu oluştur
    String baslik;
    String yorum;

    if (ortalamaBasariOrani >= 90) {
      baslik = 'Mükemmel İlerleme! 🌟';
      yorum =
          'Harika gidiyorsun! Matematik konularında ustalaşmaya başladın. Bu tempoda devam et!';
    } else if (ortalamaBasariOrani >= 70) {
      baslik = 'İyi İlerleme 👍';
      yorum =
          'İyi bir performans gösteriyorsun. Biraz daha pratik yaparak daha da iyileşebilirsin.';
    } else if (ortalamaBasariOrani >= 50) {
      baslik = 'Gelişime Açık 📈';
      yorum =
          'Temel konuları kavramışsın ama daha fazla pratik yapman gerekiyor. Düzenli çalışarak kendini geliştirebilirsin.';
    } else {
      baslik = 'Desteğe İhtiyaç Var 🎯';
      yorum =
          'Zorlandığın konularda daha fazla pratik yapmalısın. Her gün düzenli çalışarak kısa sürede ilerleme kaydedebilirsin.';
    }

    return {
      'baslik': baslik,
      'yorum': yorum,
    };
<<<<<<< Updated upstream
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
  }
}
