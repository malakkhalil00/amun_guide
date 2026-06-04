// 📁 lib/core/constants/app_colors.dart

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Primary Gold ──────────────────────────────────────────
  static const Color gold           = Color(0xFFC5A358);
  static const Color goldLight      = Color(0xFFE8D5A3);
  static const Color goldDim        = Color(0x1FC5A358);
  static const Color goldDark       = Color(0xFF9E7E3A);
  static const Color borderGold     = Color(0x4DC5A358);

  // ── Backgrounds ───────────────────────────────────────────
  static const Color bgDark         = Color(0xFF151411);
  static const Color bgCard         = Color(0xFF1E1A16);
  static const Color bgInput        = Color(0xFF2A241F);
  static const Color bgLight        = Color(0xFFF8F6F0);

  // ── Auth Screen Gradients ─────────────────────────────────
  // استخدمها في Stack مع Positioned.fill
  static const List<Color> authGradient = [
    Color(0xFF151411),   // top — نفس bgDark
    Color(0xFF1A1208),   // mid — دفا خفيف
    Color(0xFF0D0D0A),   // bottom — أغمق
  ];

  static const List<Color> authGradientAlt = [
    Color(0xFF1A1510),   // للشاشات التانية
    Color(0xFF0F0E0A),
    Color(0xFF080807),
  ];

  // Overlay فوق الصور لو اتضافت
  static const Color overlayDark        = Color(0xCC000000);
  static const Color overlayMid         = Color(0x80000000);
  static const Color shimmerBase        = Color(0xFF2A241F);
  static const Color shimmerHighlight   = Color(0xFF3A3028);

  // ── Primary Button (White on Dark) ────────────────────────
  static const Color btnPrimaryBg      = Color(0xFFFFFFFF);
  static const Color btnPrimaryText    = Color(0xFF151411);
  static const Color btnPrimaryBorder  = Color(0x00000000); // transparent

  // Secondary button (Gold outlined)
  static const Color btnSecondaryBg    = Color(0x00000000); // transparent
  static const Color btnSecondaryText  = Color(0xFFC5A358);
  static const Color btnSecondaryBorder = Color(0xFFC5A358);

  // ── Text ──────────────────────────────────────────────────
  static const Color textWhite  = Color(0xFFFFFFFF);
  static const Color textMuted  = Color(0x99FFFFFF);  // 60% white
  static const Color textFaint  = Color(0x61FFFFFF);  // 38% white
  static const Color textDark   = Color(0xFF1A1A12);
  static const Color textGray   = Color(0x66000000);

  // ── Status ────────────────────────────────────────────────
  static const Color success    = Color(0xFF4CAF50);
  static const Color error      = Color(0xFFE53935);
  static const Color warning    = Color(0xFFFFC107);

  // ── Borders ───────────────────────────────────────────────
  static const Color border     = Color(0x1AFFFFFF);  // subtle white border
  static const Color borderDark = Color(0x14000000);
}