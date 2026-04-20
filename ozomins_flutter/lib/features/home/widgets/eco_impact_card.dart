import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// 3-column eco impact stats: services, recycled, earned.
class EcoImpactCard extends StatelessWidget {
  final int services;
  final String recycled;
  final String earned;

  const EcoImpactCard({
    super.key,
    required this.services,
    required this.recycled,
    required this.earned,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'YOUR ECO IMPACT',
            style: AppTextStyles.caption.copyWith(
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _StatItem(value: '$services', label: 'Services'),
              _VerticalDivider(),
              _StatItem(value: recycled, label: 'Recycled'),
              _VerticalDivider(),
              _StatItem(value: earned, label: 'Earned'),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;

  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: AppTextStyles.statNumber.copyWith(fontSize: 22),
          ),
          const SizedBox(height: 4),
          Text(label, style: AppTextStyles.bodyXS),
        ],
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 36,
      color: AppColors.surfaceBorder,
    );
  }
}
