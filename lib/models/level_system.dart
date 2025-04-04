import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

class LevelSystem {
<<<<<<< Updated upstream
<<<<<<< Updated upstream
  int currentLevel;
  int currentXP;
  int requiredXP;
  bool hasLeveledUp;
  String operationType;
  double xpMultiplier;

  LevelSystem({
    this.currentLevel = 1,
    this.currentXP = 0,
    this.requiredXP = 100,
    this.hasLeveledUp = false,
    this.operationType = '',
    this.xpMultiplier = 1.0,
  });

  Future<void> loadLevel(String operationType) async {
    this.operationType = operationType;
    final prefs = await SharedPreferences.getInstance();
    final key = 'level_${operationType.toLowerCase()}';

    final Map<String, dynamic>? levelData =
        json.decode(prefs.getString(key) ?? '{}') as Map<String, dynamic>?;

    if (levelData != null) {
      currentLevel = levelData['level'] ?? 1;
      currentXP = levelData['xp'] ?? 0;
      requiredXP = levelData['requiredXP'] ?? 100;
      xpMultiplier = levelData['xpMultiplier'] ?? 1.0;
    }
  }

  Future<void> saveLevel() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'level_${operationType.toLowerCase()}';

    await prefs.setString(
        key,
        json.encode({
          'level': currentLevel,
          'xp': currentXP,
          'requiredXP': requiredXP,
          'xpMultiplier': xpMultiplier,
        }));
  }

  Future<void> addExperience(int xp) async {
    hasLeveledUp = false;
    currentXP += (xp * xpMultiplier).round();

    while (currentXP >= requiredXP) {
      currentXP -= requiredXP;
      currentLevel++;
      requiredXP = (requiredXP * 1.5).round();
      xpMultiplier += 0.1;
      hasLeveledUp = true;
    }

    await saveLevel();
  }

  Future<void> removeExperience(int xp) async {
    currentXP = max(0, currentXP - xp); // XP'nin 0'ın altına düşmemesini sağla
    await saveLevel();
  }

  Map<String, dynamic> getLevelRewards() {
    return {
      'xpMultiplier': xpMultiplier,
      'isMaxLevel': currentLevel >= 50,
    };
=======
  int currentLevel = 1;
  int currentXP = 0;
  bool hasLeveledUp = false;
  final int maxLevel = 50;

  Future<void> loadLevel(String islemTuru) async {
    final prefs = await SharedPreferences.getInstance();
    currentLevel = prefs.getInt('level_${islemTuru.toLowerCase()}') ?? 1;
    currentXP = prefs.getInt('xp_${islemTuru.toLowerCase()}') ?? 0;
    hasLeveledUp = false;
  }

=======
  int currentLevel = 1;
  int currentXP = 0;
  bool hasLeveledUp = false;
  final int maxLevel = 50;

  Future<void> loadLevel(String islemTuru) async {
    final prefs = await SharedPreferences.getInstance();
    currentLevel = prefs.getInt('level_${islemTuru.toLowerCase()}') ?? 1;
    currentXP = prefs.getInt('xp_${islemTuru.toLowerCase()}') ?? 0;
    hasLeveledUp = false;
  }

>>>>>>> Stashed changes
  Future<void> saveLevel(String islemTuru) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('level_${islemTuru.toLowerCase()}', currentLevel);
    await prefs.setInt('xp_${islemTuru.toLowerCase()}', currentXP);
  }

  int getRequiredXP(int level) {
    return (100 * level * (1 + (level - 1) * 0.1)).round();
  }

  Future<void> addExperience(int xp) async {
    if (currentLevel >= maxLevel) return;

    currentXP += xp;
    int requiredXP = getRequiredXP(currentLevel);

    while (currentXP >= requiredXP && currentLevel < maxLevel) {
      currentXP -= requiredXP;
      currentLevel++;
      hasLeveledUp = true;
      requiredXP = getRequiredXP(currentLevel);
    }

    if (currentLevel >= maxLevel) {
      currentLevel = maxLevel;
      currentXP = 0;
    }
  }

  Future<void> removeExperience(int xp) async {
    currentXP -= xp;
    if (currentXP < 0) currentXP = 0;
  }

  double getProgress() {
    if (currentLevel >= maxLevel) return 1.0;
    return currentXP / getRequiredXP(currentLevel);
<<<<<<< Updated upstream
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
  }
}
