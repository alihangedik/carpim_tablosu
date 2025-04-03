import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class LevelUpScreen extends StatefulWidget {
  final int newLevel;
  final String operationType;
  final Map<String, dynamic> rewards;

  const LevelUpScreen({
    Key? key,
    required this.newLevel,
    required this.operationType,
    required this.rewards,
  }) : super(key: key);

  @override
  _LevelUpScreenState createState() => _LevelUpScreenState();
}

class _LevelUpScreenState extends State<LevelUpScreen>
    with TickerProviderStateMixin {
  late AnimationController _confettiController;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _confettiController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    );

    _scaleController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );

    _confettiController.forward();
    _scaleController.forward();

    // 3 saniye sonra otomatik kapanma
    Future.delayed(Duration(seconds: 3), () {
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                // Konfeti animasyonu
                Lottie.asset(
                  'assets/confetti.json',
                  controller: _confettiController,
                  height: 200,
                ),
                // Seviye rozeti
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Color(0xff2d2e83).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${widget.newLevel}',
                      style: GoogleFonts.poppins(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff2d2e83),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            ScaleTransition(
              scale: _scaleAnimation,
              child: Text(
                'Tebrikler!',
                style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff2d2e83),
                ),
              ),
            ),
            SizedBox(height: 8),
            Text(
              '${widget.operationType} işleminde ${widget.newLevel}. seviyeye ulaştın!',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 16),
            // Yeni özelliklerin listesi
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xff2d2e83).withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  _buildRewardItem(
                    Icons.star_rounded,
                    'Daha büyük sayılar!',
                    'Artık ${widget.rewards['maxNumber']} e kadar olan sayılarla çalışabilirsin',
                  ),
                  if (widget.rewards['timeBonus'] > 0) ...[
                    SizedBox(height: 8),
                    _buildRewardItem(
                      Icons.timer,
                      'Zaman Bonusu!',
                      '+${widget.rewards['timeBonus']} saniye ek süre kazandın',
                    ),
                  ],
                  if (widget.rewards['xpMultiplier'] > 1) ...[
                    SizedBox(height: 8),
                    _buildRewardItem(
                      Icons.flash_on_rounded,
                      'XP Çarpanı!',
                      'Artık x${widget.rewards['xpMultiplier'].toStringAsFixed(1)} XP kazanacaksın',
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardItem(IconData icon, String title, String description) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Color(0xff2d2e83), size: 24),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff2d2e83),
                ),
              ),
              Text(
                description,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
