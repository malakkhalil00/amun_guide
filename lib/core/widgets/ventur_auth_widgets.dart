// 📁 lib/core/widgets/ventur_auth_widgets.dart

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// ── Underline text input ──────────────────────────────────────────────────────
class VenturInput extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final TextInputType keyboardType;
  final Widget? suffixIcon;
  final bool enabled;

  const VenturInput({
    super.key,
    required this.controller,
    required this.hint,
    this.obscure = false,
    this.keyboardType = TextInputType.text,
    this.suffixIcon,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: enabled ? const Color(0xFFE2E8F0) : const Color(0xFFF1F5F9),
            width: 1.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscure,
              keyboardType: keyboardType,
              enabled: enabled,
              style: TextStyle(
                color: enabled
                    ? const Color(0xFF1A1A12)
                    : const Color(0xFF94A3B8),
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(
                  color: Color(0xFFCBD5E1),
                  fontSize: 14,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          if (suffixIcon != null) ...[const SizedBox(width: 8), suffixIcon!],
        ],
      ),
    );
  }
}

// ── Small field label ─────────────────────────────────────────────────────────
class VenturLabel extends StatelessWidget {
  final String text;
  const VenturLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF94A3B8),
        fontSize: 11,
        letterSpacing: 0.6,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

// ── Section separator label ───────────────────────────────────────────────────
class VenturSectionLabel extends StatelessWidget {
  final String text;
  const VenturSectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 15,
          decoration: BoxDecoration(
            color: AppColors.gold,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            color: Color(0xFF1A1A12),
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

// ── Primary button — White on Dark ────────────────────────────────────────────
class VenturPrimaryBtn extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback onTap;

  const VenturPrimaryBtn({
    super.key,
    required this.label,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          color: AppColors.btnPrimaryBg,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.btnPrimaryText,
                  ),
                )
              : Text(
                  label,
                  style: TextStyle(
                    color: AppColors.btnPrimaryText,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                ),
        ),
      ),
    );
  }
}

// ── Circle icon button (back arrow) ──────────────────────────────────────────
class CircleIconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const CircleIconBtn({super.key, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.black26,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white24, width: 1),
        ),
        child: Icon(icon, color: Colors.white, size: 16),
      ),
    );
  }
}

// ── Role pill badge ───────────────────────────────────────────────────────────
class RolePill extends StatelessWidget {
  final bool isGuide;
  final String? label;

  const RolePill({super.key, required this.isGuide, this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.goldDim,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderGold, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isGuide ? Icons.map_outlined : Icons.luggage_outlined,
            color: AppColors.gold,
            size: 13,
          ),
          const SizedBox(width: 5),
          Text(
            label ?? (isGuide ? 'Guide' : 'Tourist'),
            style: TextStyle(
              color: AppColors.gold,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Social login button ───────────────────────────────────────────────────────
// ── Social login button ───────────────────────────────────────────────────────
class SocialBtn extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const SocialBtn({
    super.key,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isGoogle = label == 'Google';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            isGoogle
                ? const FaIcon(
                    FontAwesomeIcons.google,
                    size: 18,
                    color: Colors.white70,
                  )
                : const FaIcon(
                    FontAwesomeIcons.apple,
                    size: 20,
                    color: Colors.white70,
                  ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Ventur Role Card ──────────────────────────────────────────────────────────
class VenturRoleCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String desc;
  final bool isSelected;
  final bool dark;
  final VoidCallback onTap;

  const VenturRoleCard({
    super.key,
    required this.emoji,
    required this.title,
    required this.desc,
    required this.isSelected,
    required this.dark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Tourist card = فاتح مع border gold لما selected
    // Guide card = دايما داكن
    final bg = dark ? AppColors.bgCard : const Color(0xFFF8F6F0);
    final borderColor = isSelected
        ? AppColors.gold
        : (dark ? AppColors.border : const Color(0xFFE8E4DC));
    final borderWidth = isSelected ? 1.5 : 1.0;
    final titleColor = dark ? Colors.white : AppColors.textDark;
    final descColor = dark ? Colors.white54 : const Color(0xFF6B6B5A);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: borderWidth),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: dark
                    ? AppColors.bgInput
                    : (isSelected
                          ? AppColors.goldDim
                          : const Color(0xFFEDE9DF)),
                borderRadius: BorderRadius.circular(14),
                border: isSelected
                    ? Border.all(color: AppColors.borderGold)
                    : null,
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 22)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isSelected && !dark ? AppColors.gold : titleColor,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    desc,
                    style: TextStyle(
                      color: descColor,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: isSelected ? AppColors.gold : Colors.white30,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
