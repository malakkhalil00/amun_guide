// 📁 lib/core/constants/app_text_styles.dart

import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  // Headlines — white (dark bg)
  static const TextStyle h1 = TextStyle(color: AppColors.textWhite, fontSize: 32, fontWeight: FontWeight.bold, height: 1.2);
  static const TextStyle h2 = TextStyle(color: AppColors.textWhite, fontSize: 24, fontWeight: FontWeight.bold);
  static const TextStyle h3 = TextStyle(color: AppColors.textWhite, fontSize: 18, fontWeight: FontWeight.bold);

  // Headlines — dark (light bg)
  static const TextStyle h1Dark = TextStyle(color: AppColors.textDark, fontSize: 28, fontWeight: FontWeight.bold, height: 1.2);
  static const TextStyle h2Dark = TextStyle(color: AppColors.textDark, fontSize: 22, fontWeight: FontWeight.bold);
  static const TextStyle h3Dark = TextStyle(color: AppColors.textDark, fontSize: 17, fontWeight: FontWeight.bold);

  // Body
  static const TextStyle body      = TextStyle(color: AppColors.textWhite, fontSize: 15, height: 1.5);
  static const TextStyle bodyMuted = TextStyle(color: AppColors.textMuted, fontSize: 14, height: 1.5);
  static const TextStyle bodySmall = TextStyle(color: AppColors.textMuted, fontSize: 12);
  static const TextStyle bodyDark  = TextStyle(color: AppColors.textGray,  fontSize: 14, height: 1.5);

  // Labels
  static const TextStyle label     = TextStyle(color: AppColors.textMuted, fontSize: 13, fontWeight: FontWeight.w600);
  static const TextStyle labelGold = TextStyle(color: AppColors.gold,      fontSize: 13, fontWeight: FontWeight.w600);

  // Buttons
  static const TextStyle btnDark  = TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold);
  static const TextStyle btnWhite = TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold);

  // ✨ Added
  static const TextStyle displayLarge = TextStyle(
    color: AppColors.gold,
    fontSize: 42,
    fontWeight: FontWeight.bold,
    letterSpacing: 6,
    height: 1.1,
  );

  static const TextStyle caption = TextStyle(
    color: AppColors.textMuted,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.3,
  );

  static const TextStyle btnGold = TextStyle(
    color: AppColors.gold,
    fontSize: 16,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.5,
  );

  static const TextStyle tourPrice = TextStyle(
    color: AppColors.gold,
    fontSize: 18,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.3,
  );
}