import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Tracking step data.
class TrackingStep {
  final String label;
  final String time;
  final TrackingStepStatus status;

  const TrackingStep({
    required this.label,
    required this.time,
    required this.status,
  });
}

enum TrackingStepStatus { done, active, pending }

/// Animated vertical timeline widget for job tracking.
class TrackingTimeline extends StatelessWidget {
  final List<TrackingStep> steps;

  const TrackingTimeline({super.key, required this.steps});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(steps.length, (i) {
        final step = steps[i];
        final isLast = i == steps.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Dot + Line column ────────
            SizedBox(
              width: 30,
              child: Column(
                children: [
                  _dot(step.status),
                  if (!isLast)
                    Container(
                      width: 2,
                      height: 44,
                      color: step.status == TrackingStepStatus.done
                          ? AppColors.primaryGreen.withValues(alpha: 0.4)
                          : AppColors.surfaceBorder,
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // ── Content ──────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        step.label,
                        style: AppTextStyles.bodySM.copyWith(
                          color: step.status == TrackingStepStatus.pending
                              ? AppColors.textMuted
                              : AppColors.textPrimary,
                          fontWeight: step.status == TrackingStepStatus.active
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ),
                    Text(
                      step.time,
                      style: AppTextStyles.bodyXS.copyWith(
                        color: step.status == TrackingStepStatus.active
                            ? AppColors.primaryGreen
                            : AppColors.textMuted,
                        fontWeight: step.status == TrackingStepStatus.active
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _dot(TrackingStepStatus status) {
    switch (status) {
      case TrackingStepStatus.done:
        return Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: AppColors.primaryGreen.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primaryGreen, width: 2),
          ),
          child: const Center(
            child: Icon(Icons.check, size: 12, color: AppColors.primaryGreen),
          ),
        );
      case TrackingStepStatus.active:
        return Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: AppColors.primaryGreen,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryGreen.withValues(alpha: 0.5),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Center(
            child: Icon(Icons.circle, size: 8, color: Colors.white),
          ),
        );
      case TrackingStepStatus.pending:
        return Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.surfaceBorderLight, width: 2),
          ),
        );
    }
  }
}
