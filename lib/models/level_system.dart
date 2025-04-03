import 'package:shared_preferences/shared_preferences.dart';

class LevelSystem {
  final String operationType; // İşlem türü (toplama, çıkarma, çarpma, bölme)
  int currentLevel;
  int currentXP;
  int requiredXP;
  static const int MAX_LEVEL = 50; // Maksimum seviye sınırı
  static const int BASE_XP = 100; // Temel XP miktarı
  static const double XP_MULTIPLIER = 1.5; // XP artış çarpanı

  // Her seviye için gereken XP miktarı formülü
  static int calculateRequiredXP(int level) {
    if (level <= 0) return BASE_XP;
    if (level > MAX_LEVEL) return calculateRequiredXP(MAX_LEVEL);
    return (BASE_XP * level * XP_MULTIPLIER).round();
  }

  LevelSystem({
    required this.operationType,
    this.currentLevel = 1,
    this.currentXP = 0,
  }) : requiredXP = calculateRequiredXP(1);

  // XP Kazanma
  bool gainXP(int amount) {
    if (amount <= 0) return false; // Negatif veya 0 XP kazanımını engelle
    if (currentLevel >= MAX_LEVEL) {
      currentXP = requiredXP; // Max seviyede XP'yi dolu tut
      saveLevelData();
      return false;
    }

    bool leveledUp = false;
    currentXP += amount;

    // Seviye atlama kontrolü
    if (currentXP >= requiredXP) {
      leveledUp = true;
      levelUp();
    }

    // XP'yi kaydet
    saveLevelData();
    return leveledUp;
  }

  // Seviye Atlama
  void levelUp() {
    if (currentLevel >= MAX_LEVEL) return;

    currentXP -= requiredXP;
    currentLevel++;
    requiredXP = calculateRequiredXP(currentLevel);

    // Eğer son seviyeye ulaştıysak, XP'yi maksimumda tut
    if (currentLevel >= MAX_LEVEL) {
      currentXP = requiredXP;
    }
  }

  // İlerleme yüzdesi
  double getProgress() {
    if (currentLevel >= MAX_LEVEL) return 1.0;
    return currentXP / requiredXP;
  }

  // Seviye bilgilerini kaydetme
  Future<void> saveLevelData() async {
    final prefs = await SharedPreferences.getInstance();
    String normalizedType = operationType
        .toLowerCase()
        .replaceAll('ç', 'c')
        .replaceAll('ı', 'i')
        .replaceAll('ö', 'o')
        .replaceAll('ü', 'u');

    await prefs.setInt('${normalizedType}_level', currentLevel);
    await prefs.setInt('${normalizedType}_xp', currentXP);
    await prefs.setInt('${normalizedType}_required_xp', requiredXP);
  }

  // Seviye bilgilerini yükleme
  static Future<LevelSystem> loadLevelData(String operationType) async {
    final prefs = await SharedPreferences.getInstance();
    String normalizedType = operationType
        .toLowerCase()
        .replaceAll('ç', 'c')
        .replaceAll('ı', 'i')
        .replaceAll('ö', 'o')
        .replaceAll('ü', 'u');

    final level = prefs.getInt('${normalizedType}_level') ?? 1;
    final xp = prefs.getInt('${normalizedType}_xp') ?? 0;

    // Seviye sınırlaması
    final adjustedLevel = level.clamp(1, MAX_LEVEL);

    LevelSystem system = LevelSystem(
      operationType: operationType,
      currentLevel: adjustedLevel,
      currentXP: xp,
    );

    // requiredXP'yi mevcut seviyeye göre güncelle
    system.requiredXP = calculateRequiredXP(adjustedLevel);

    // Max seviyede XP'yi dolu tut
    if (system.currentLevel >= MAX_LEVEL) {
      system.currentXP = system.requiredXP;
    }

    return system;
  }

  // Seviye ödüllerini kontrol etme
  Map<String, dynamic> getLevelRewards() {
    // Maksimum değerler
    const int MAX_NUMBER = 100;
    const int MAX_TIME_BONUS = 10;
    const double MAX_XP_MULTIPLIER = 3.0;

    return {
      'maxNumber': (10 + (currentLevel * 2)).clamp(10, MAX_NUMBER),
      'timeBonus': (currentLevel / 5).floor().clamp(0, MAX_TIME_BONUS),
      'xpMultiplier': (1 + (currentLevel / 10)).clamp(1.0, MAX_XP_MULTIPLIER),
      'isMaxLevel': currentLevel >= MAX_LEVEL,
    };
  }
}
