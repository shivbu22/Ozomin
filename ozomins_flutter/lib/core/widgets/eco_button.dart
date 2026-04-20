import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

enum EcoButtonVariant { primary, outline, ghost }
enum EcoButtonSize { sm, md, lg }

/// Ozomins branded button with 3 variants and 3 sizes.
class EcoButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final EcoButtonVariant variant;
  final EcoButtonSize size;
  final IconData? icon;
  final bool loading;
  final bool fullWidth;

  const EcoButton({
    super.key,
    required this.label,
    this.onTap,
    this.variant = EcoButtonVariant.primary,
    this.size = EcoButtonSize.md,
    this.icon,
    this.loading = false,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final isSmall = size == EcoButtonSize.sm;
    final isLarge = size == EcoButtonSize.lg;

    final vPad = isSmall ? 8.0 : isLarge ? 16.0 : 12.0;
    final hPad = isSmall ? 14.0 : isLarge ? 28.0 : 20.0;
    final textStyle = isSmall ? AppTextStyles.buttonSM : AppTextStyles.buttonLG;
    final radius = isSmall ? 10.0 : 12.0;

    Color bgColor;
    Color fgColor;
    BorderSide border;

    switch (variant) {
      case EcoButtonVariant.primary:
        bgColor = AppColors.primaryGreen;
        fgColor = AppColors.textOnGreen;
        border = BorderSide.none;
        break;
      case EcoButtonVariant.outline:
        bgColor = Colors.transparent;
        fgColor = AppColors.primaryGreen;
        border = const BorderSide(color: AppColors.primaryGreen, width: 1.5);
        break;
      case EcoButtonVariant.ghost:
        bgColor = Colors.transparent;
        fgColor = AppColors.textSecondary;
        border = BorderSide.none;
        break;
    }

    final child = loading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation(fgColor),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: isSmall ? 16 : 20, color: fgColor),
                const SizedBox(width: 8),
              ],
              Text(label, style: textStyle.copyWith(color: fgColor)),
            ],
          );

    final button = Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(radius),
      child: InkWell(
        onTap: loading ? null : onTap,
        borderRadius: BorderRadius.circular(radius),
        splashColor: AppColors.primaryGreen.withValues(alpha: 0.15),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            border: border == BorderSide.none ? null : Border.all(color: border.color, width: border.width),
          ),
          child: Center(child: child),
        ),
      ),
    );

    return fullWidth
        ? SizedBox(width: double.infinity, child: button)
        : button;
  }
}
