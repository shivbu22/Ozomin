import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';

/// Horizontal scrollable service category chip with emoji icon.
class ServiceCategoryChip extends StatelessWidget {
  final ServiceType service;
  final bool isActive;
  final VoidCallback onTap;

  const ServiceCategoryChip({
    super.key,
    required this.service,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        decoration: BoxDecoration(
          color: isActive 
              ? AppColors.primaryGreen.withValues(alpha: 0.1) 
              : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: isActive
              ? Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.3), width: 1.5)
              : Border.all(color: Colors.transparent, width: 1.5),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  service.emoji,
                  style: const TextStyle(fontSize: 28),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                service.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: AppTextStyles.labelSM.copyWith(
                  color: isActive ? AppColors.primaryGreen : AppColors.onSurface,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
