import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

class TourStep {
  final String title;
  final String description;
  final Rect targetRect;
  final Alignment tooltipAlignment;

  const TourStep({
    required this.title,
    required this.description,
    required this.targetRect,
    this.tooltipAlignment = Alignment.topCenter,
  });
}

class OnboardingTour extends StatefulWidget {
  final List<TourStep> steps;
  final VoidCallback onComplete;
  final VoidCallback onSkip;

  const OnboardingTour({
    super.key,
    required this.steps,
    required this.onComplete,
    required this.onSkip,
  });

  @override
  State<OnboardingTour> createState() => _OnboardingTourState();
}

class _OnboardingTourState extends State<OnboardingTour> {
  int _currentStep = 0;

  void _next() {
    if (_currentStep < widget.steps.length - 1) {
      setState(() => _currentStep++);
    } else {
      widget.onComplete();
    }
  }

  void _prev() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  @override
  Widget build(BuildContext context) {
    final step = widget.steps[_currentStep];
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1E1E2E) : const Color(0xFFFFFFFF);
    final textColor = isDark
        ? const Color(0xFFE0E0E0)
        : const Color(0xFF2D3432);
    final subtextColor = isDark
        ? const Color(0xFFA0A0A0)
        : const Color(0xFF5A605E);
    final primaryColor = const Color(0xFF5F5E5E);

    return Stack(
      children: [
        // Dark overlay with spotlight hole
        CustomPaint(
          size: Size.infinite,
          painter: _SpotlightPainter(
            targetRect: step.targetRect,
            isDark: isDark,
          ),
        ),
        // Tooltip
        Positioned.fill(
          child: _buildTooltip(
            step,
            bgColor,
            textColor,
            subtextColor,
            primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildTooltip(
    TourStep step,
    Color bgColor,
    Color textColor,
    Color subtextColor,
    Color primaryColor,
  ) {
    return Align(
      alignment: step.tooltipAlignment,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Material(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          elevation: 8,
          child: Container(
            width: 320,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Step indicator
                Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.10),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${_currentStep + 1}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: primaryColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${_currentStep + 1} de ${widget.steps.length}',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: subtextColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Title
                Text(
                  step.title,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 8),
                // Description
                Text(
                  step.description,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: subtextColor,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 24),
                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: widget.onSkip,
                      child: Text(
                        'Saltar',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: subtextColor,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        if (_currentStep > 0)
                          TextButton(
                            onPressed: _prev,
                            child: Text(
                              'Anterior',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: primaryColor,
                              ),
                            ),
                          ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _next,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: const Color(0xFFFAF7F6),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                          ),
                          child: Text(
                            _currentStep == widget.steps.length - 1
                                ? '¡Empezar!'
                                : 'Siguiente',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SpotlightPainter extends CustomPainter {
  final Rect targetRect;
  final bool isDark;

  _SpotlightPainter({required this.targetRect, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;

    final spotlightRect = targetRect.inflate(12);
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(
        RRect.fromRectAndRadius(spotlightRect, const Radius.circular(12)),
      );

    canvas.drawPath(path, paint);

    // Spotlight border
    final borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawRRect(
      RRect.fromRectAndRadius(spotlightRect, const Radius.circular(12)),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _SpotlightPainter oldDelegate) {
    return oldDelegate.targetRect != targetRect || oldDelegate.isDark != isDark;
  }
}
