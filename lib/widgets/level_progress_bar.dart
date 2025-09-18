import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/level_system.dart';

class LevelProgressBar extends StatelessWidget {
  final LevelSystem levelSystem;

  const LevelProgressBar({
    Key? key,
    required this.levelSystem,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isMaxLevel = levelSystem.currentLevel >= 50;
    final double required = levelSystem.requiredXP == 0 ? 1 : levelSystem.requiredXP.toDouble();
    final double progress = (levelSystem.currentXP.toDouble() / required).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  FontAwesomeIcons.solidStar,
                  color: Color(0xffFFD700),
                  size: 12,
                ),
                const SizedBox(width: 4),
                Text(
                  'Seviye ${levelSystem.currentLevel}',
                  style: GoogleFonts.quicksand(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          if (!isMaxLevel) ...[
            const SizedBox(width: 8),
            Container(
              width: 100,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xffFFD700),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}