import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import 'common/amount_display.dart';
import 'common/section_label.dart';

class FuelGaugeRing extends StatefulWidget {
  const FuelGaugeRing({
    super.key,
    required this.percentage,
    required this.runway,
    required this.currency,
    required this.arcColor,
    required this.isOvercommitted,
    required this.selectedDay,
    this.size = 220,
  });

  final double percentage;
  final double runway;
  final String currency;
  final Color arcColor;
  final bool isOvercommitted;
  final int selectedDay;
  final double size;

  @override
  State<FuelGaugeRing> createState() => _FuelGaugeRingState();
}

class _FuelGaugeRingState extends State<FuelGaugeRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _fromPercent = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: widget.percentage).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(FuelGaugeRing old) {
    super.didUpdateWidget(old);
    if (old.percentage != widget.percentage) {
      _fromPercent = _animation.value;
      _animation =
          Tween<double>(begin: _fromPercent, end: widget.percentage).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _dayLabel() {
    final today = DateTime.now().day;
    if (widget.selectedDay == today) return 'today · day ${widget.selectedDay}';
    return 'day ${widget.selectedDay}';
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, _) {
          return Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _FuelGaugePainter(
                  percent: _animation.value,
                  arcColor: widget.arcColor,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // FittedBox prevents long amounts from clipping out of the circle
                  SizedBox(
                    width: widget.size * 0.62,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0, end: widget.runway),
                        duration: const Duration(milliseconds: 600),
                        builder: (_, v, __) => AmountDisplay(
                          amount: v,
                          currency: widget.currency,
                          style: AppTypography.monoHero
                              .copyWith(color: widget.arcColor),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  SectionLabel(
                    'projected month end',
                    color: widget.isOvercommitted
                        ? AppColors.red
                        : AppColors.inkDim,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _dayLabel(),
                    style: AppTypography.monoXSmall
                        .copyWith(color: AppColors.inkDim),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _FuelGaugePainter extends CustomPainter {
  const _FuelGaugePainter({required this.percent, required this.arcColor});

  final double percent;
  final Color arcColor;

  static const double _startAngle = 150 * math.pi / 180;
  static const double _sweepTotal = 240 * math.pi / 180;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 24) / 2;
    const strokeWidth = 12.0;

    final bgPaint = Paint()
      ..color = AppColors.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      _startAngle,
      _sweepTotal,
      false,
      bgPaint,
    );

    if (percent <= 0) return;

    final progressPaint = Paint()
      ..color = arcColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      _startAngle,
      _sweepTotal * (percent / 100),
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_FuelGaugePainter old) =>
      old.percent != percent || old.arcColor != arcColor;
}
