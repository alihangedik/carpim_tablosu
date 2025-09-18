import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class GlowingGradientButton extends StatefulWidget {
  final VoidCallback onPressed;

  const GlowingGradientButton({Key? key, required this.onPressed})
      : super(key: key);

  @override
  State<GlowingGradientButton> createState() => _GlowingGradientButtonState();
}

class _GlowingGradientButtonState extends State<GlowingGradientButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _GlowingGradientBorderPainter(progress: _controller.value),
          child: InkWell(
            borderRadius: BorderRadius.circular(15),
            onTap: widget.onPressed,
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(FontAwesomeIcons.play,
                      size: 28, color: Color(0xff2d2e83)),
                  SizedBox(width: 12),
                  Text(
                    'Oyuna Başla',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff2d2e83),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _GlowingGradientBorderPainter extends CustomPainter {
  final double progress;

  _GlowingGradientBorderPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(15),
    );

    final gradient = SweepGradient(
      startAngle: 0,
      endAngle: 6.28319, // 2π
      transform: GradientRotation(progress * 6.28319),
      colors: const [
        Color(0xff6D5DF6),
        Color(0xff3D8BFD),
        Color(0xff2CE3A6),
        Color(0xff6D5DF6),
      ],
    );

    // Glow efekti için kalın blur'lu çizim
    final glowPaint = Paint()
      ..shader = gradient.createShader(rect.outerRect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

    // Normal border için ince çizim
    final borderPaint = Paint()
      ..shader = gradient.createShader(rect.outerRect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawRRect(rect, glowPaint);   // Glow
    canvas.drawRRect(rect, borderPaint); // Normal border
  }

  @override
  bool shouldRepaint(_GlowingGradientBorderPainter oldDelegate) =>
      oldDelegate.progress != progress;
}