// 📁 lib/core/widgets/amun_button.dart

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

enum AmunButtonVariant { filled, outlined, ghost }

class AmunButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final AmunButtonVariant variant;
  final IconData? icon;
  final bool fullWidth;
  final double verticalPadding;
  final bool isLoading;

  const AmunButton({
    super.key,
    required this.label,
    required this.onTap,
    this.variant = AmunButtonVariant.filled,
    this.icon,
    this.fullWidth = true,
    this.verticalPadding = 16,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isLight = variant == AmunButtonVariant.filled;

    final child = isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: isLight ? Colors.black : AppColors.gold,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 18,
                  color: isLight ? Colors.black : AppColors.gold,
                ),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: isLight
                    ? AppTextStyles.btnDark
                    : AppTextStyles.btnDark.copyWith(color: AppColors.gold),
              ),
            ],
          );

    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
    );

    Widget btn;
    switch (variant) {
      case AmunButtonVariant.filled:
        btn = ElevatedButton(
          onPressed: isLoading ? null : onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.gold,
            foregroundColor: Colors.black,
            padding: EdgeInsets.symmetric(
              vertical: verticalPadding,
              horizontal: 24,
            ),
            shape: shape,
            elevation: 0,
            shadowColor: AppColors.gold.withOpacity(0.3),
          ),
          child: child,
        );
        break;
      case AmunButtonVariant.outlined:
        btn = OutlinedButton(
          onPressed: isLoading ? null : onTap,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.gold,
            side: const BorderSide(color: AppColors.gold, width: 1.5),
            padding: EdgeInsets.symmetric(
              vertical: verticalPadding,
              horizontal: 24,
            ),
            shape: shape,
          ),
          child: child,
        );
        break;
      case AmunButtonVariant.ghost:
        btn = TextButton(
          onPressed: isLoading ? null : onTap,
          child: Text(label, style: AppTextStyles.labelGold),
        );
        break;
    }

    return fullWidth ? SizedBox(width: double.infinity, child: btn) : btn;
  }
}