import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

class LevelSystem {

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


}
