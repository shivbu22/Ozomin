import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/eco_button.dart';

/// Bottom sheet shown after successful booking confirmation.
class BookingConfirmationSheet extends StatefulWidget {
  final String jobId;
  final String workerName;
  final String eta;
  final VoidCallback onTrack;

  const BookingConfirmationSheet({
    super.key,
    required this.jobId,
    required this.workerName,
    required this.eta,
    required this.onTrack,
  });

  @override
  State<BookingConfirmationSheet> createState() =>
      _BookingConfirmationSheetState();
}

class _BookingConfirmationSheetState extends State<BookingConfirmationSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scale = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut),
    );
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 36),
      decoration: const BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: AppColors.surfaceBorder),
          left: BorderSide(color: AppColors.surfaceBorder),
          right: BorderSide(color: AppColors.surfaceBorder),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.surfaceBorderLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 28),
          // Success icon
          ScaleTransition(
            scale: _scale,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: 0.12),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primaryGreen.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: const Center(
                child: Text('✅', style: TextStyle(fontSize: 36)),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('Booking Confirmed!', style: AppTextStyles.headingLG),
          const SizedBox(height: 8),
          Text(
            'Job #${widget.jobId}',
            style: AppTextStyles.bodySM.copyWith(color: AppColors.primaryGreen),
          ),
          const SizedBox(height: 20),
          // Worker info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.scaffoldBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.surfaceBorder),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: AppColors.avatarGreenGrad,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      widget.workerName[0],
                      style: AppTextStyles.headingMD.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.workerName, style: AppTextStyles.headingSM),
                      Text(
                        'Arriving in ${widget.eta}',
                        style: AppTextStyles.bodySM.copyWith(
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.star_rounded,
                    color: AppColors.warningAmber, size: 18),
                const SizedBox(width: 2),
                Text(
                  '4.9',
                  style: AppTextStyles.bodySM.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          EcoButton(
            label: 'Track Worker',
            fullWidth: true,
            icon: Icons.location_on_rounded,
            onTap: widget.onTrack,
          ),
          const SizedBox(height: 10),
          EcoButton(
            label: 'Back to Home',
            variant: EcoButtonVariant.ghost,
            fullWidth: true,
            onTap: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
