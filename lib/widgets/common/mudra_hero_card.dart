import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/spacing.dart';

/// A dark gold gradient hero card used as the primary KPI card on each screen.
///
/// Example:
/// ```dart
/// MudraHeroCard(
///   label: 'TOTAL BALANCE',
///   amount: '₹1,24,500',
///   sublabel: 'across 3 accounts',
///   trailing: StatusBadge(label: 'Healthy'),
///   bottom: FuelGaugeRing(value: 0.72),
/// )
/// ```
class MudraHeroCard extends StatelessWidget {
  const MudraHeroCard({
    super.key,
    required this.label,
    required this.amount,
    this.sublabel,
    this.trailing,
    this.bottom,
  });

  final String label;
  final String amount;
  final String? sublabel;
  final Widget? trailing;
  final Widget? bottom;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2A1C04),
            Color(0xFF4A3010),
            Color(0xFF7A5818),
            Color(0xFFA07020),
          ],
          stops: [0.0, 0.35, 0.65, 1.0],
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: const [
          BoxShadow(
            color: Color(0x4D2A1C04),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Stack(
          children: [
            // Glow 1 — top-right
            Positioned(
              top: -40,
              right: -40,
              child: Container(
                width: 160,
                height: 160,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [Color(0x33C49430), Colors.transparent],
                  ),
                ),
              ),
            ),
            // Glow 2 — bottom-left
            Positioned(
              bottom: -30,
              left: -20,
              child: Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [Color(0x1AC49430), Colors.transparent],
                  ),
                ),
              ),
            ),
            // Main content
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        label,
                        style: GoogleFonts.ibmPlexMono(
                          fontSize: 9,
                          letterSpacing: 2.0,
                          color: const Color(0x80FFFFFF),
                        ),
                      ),
                      if (trailing != null) ...[
                        const Spacer(),
                        trailing!,
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    amount,
                    style: GoogleFonts.ibmPlexMono(
                      fontSize: 42,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.0,
                    ),
                  ),
                  if (sublabel != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      sublabel!,
                      style: GoogleFonts.ibmPlexMono(
                        fontSize: 10,
                        color: const Color(0x99FFFFFF),
                      ),
                    ),
                  ],
                  if (bottom != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    bottom!,
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
