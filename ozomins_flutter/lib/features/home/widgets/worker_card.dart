import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/mock_data.dart';

/// Gradient avatar colors by index.
const _gradients = [
  AppColors.avatarGreenGrad,
  AppColors.avatarPurpleGrad,
  AppColors.avatarOrangeGrad,
  AppColors.avatarBlueGrad,
];

/// Worker card with avatar, rating, skills, distance, ETA, and price.
class WorkerCard extends StatelessWidget {
  final WorkerData worker;
  final VoidCallback? onTap;

  const WorkerCard({super.key, required this.worker, this.onTap});

  @override
  Widget build(BuildContext context) {
    final grad = _gradients[worker.gradientIndex % _gradients.length];

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.surfaceBorder),
        ),
        child: Row(
          children: [
            // ── Avatar ──────────────────────
            Stack(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: grad,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      worker.initial,
                      style: AppTextStyles.headingMD.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.cardBg, width: 2.5),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            // ── Info ────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    worker.name,
                    style: AppTextStyles.headingSM,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    worker.skills.join(' · '),
                    style: AppTextStyles.bodyXS.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          color: AppColors.warningAmber, size: 14),
                      const SizedBox(width: 3),
                      Text(
                        '${worker.rating} · ${worker.jobCount} jobs',
                        style: AppTextStyles.bodyXS.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // ── Right column ────────────────
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  worker.distance,
                  style: AppTextStyles.bodySM.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  worker.eta,
                  style: AppTextStyles.bodyXS.copyWith(
                    color: AppColors.primaryGreen,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '₹${worker.pricePerHour}/hr',
                  style: AppTextStyles.headingSM.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
