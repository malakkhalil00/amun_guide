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
    final child = isLoading
        ? const SizedBox(
      width: 20, height: 20,
      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
    )
        : Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18,
              color: variant == AmunButtonVariant.filled
                  ? Colors.black
                  : AppColors.gold),
          const SizedBox(width: 8),
        ],
        Text(label,
            style: variant == AmunButtonVariant.filled
                ? AppTextStyles.btnDark
                : AppTextStyles.btnDark.copyWith(color: AppColors.gold)),
      ],
    );

    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(30));

    Widget btn;
    switch (variant) {
      case AmunButtonVariant.filled:
        btn = ElevatedButton(
          onPressed: isLoading ? null : onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.gold,
            padding: EdgeInsets.symmetric(vertical: verticalPadding, horizontal: 24),
            shape: shape,
            elevation: 0,
          ),
          child: child,
        );
        break;
      case AmunButtonVariant.outlined:
        btn = OutlinedButton(
          onPressed: isLoading ? null : onTap,
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.gold),
            padding: EdgeInsets.symmetric(vertical: verticalPadding, horizontal: 24),
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