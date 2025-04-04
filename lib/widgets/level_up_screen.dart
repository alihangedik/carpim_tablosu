import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LevelUpScreen extends StatelessWidget {
  final int level;
  final VoidCallback onContinue;

  const LevelUpScreen({
    Key? key,
    required this.level,
    required this.onContinue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
<<<<<<< Updated upstream
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.stars,
              color: Color(0xffFFD700),
              size: 64,
            ),
            SizedBox(height: 16),
            Text(
              level >= 50 ? 'Maksimum Seviyeye Ulaştın!' : 'Seviye Atladın!',
              style: GoogleFonts.quicksand(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xff2d2e83),
=======
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Color(0xff2d2e83),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              'assets/animations/level_up.json',
              width: 200,
              height: 200,
              repeat: true,
            ),
            SizedBox(height: 16),
            Text(
              'Tebrikler!',
              style: GoogleFonts.quicksand(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
<<<<<<< Updated upstream
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
              ),
            ),
            SizedBox(height: 8),
            Text(
<<<<<<< Updated upstream
<<<<<<< Updated upstream
              level >= 50
                  ? 'Tebrikler! Bu işlem türünde maksimum seviyeye ulaştın.'
                  : 'Yeni Seviye: $level',
              style: GoogleFonts.quicksand(
                fontSize: 18,
                color: Colors.black87,
=======
=======
>>>>>>> Stashed changes
              'Seviye $level\'e ulaştın!',
              style: GoogleFonts.quicksand(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w500,
<<<<<<< Updated upstream
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
              ),
              textAlign: TextAlign.center,
            ),
<<<<<<< Updated upstream
<<<<<<< Updated upstream
            if (level < 50) ...[
              SizedBox(height: 16),
              Text(
                'Yeni Ödüller:',
                style: GoogleFonts.quicksand(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '• Daha yüksek zorluk seviyesi\n• Artan XP kazanımı\n• Yeni soru tipleri',
                style: GoogleFonts.quicksand(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ],
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xff2d2e83),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              onPressed: onContinue,
              child: Text(
                'Devam Et',
                style: GoogleFonts.quicksand(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
=======
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: onContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Color(0xff2d2e83),
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
=======
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: onContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Color(0xff2d2e83),
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
>>>>>>> Stashed changes
              child: Text(
                'Devam Et',
                style: GoogleFonts.quicksand(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
<<<<<<< Updated upstream
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
