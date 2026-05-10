// 📁 lib/core/widgets/amun_input.dart

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AmunInput extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final IconData? prefixIcon;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? label;
  final bool lightTheme; // true = white bg (login screen)

  const AmunInput({
    super.key,
    required this.controller,
    required this.hint,
    this.prefixIcon,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.label,
    this.lightTheme = false,
  });

  @override
  State<AmunInput> createState() => _AmunInputState();
}

class _AmunInputState extends State<AmunInput> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final bg       = widget.lightTheme ? const Color(0xFFF5F5F0) : AppColors.bgInput;
    final textCol  = widget.lightTheme ? Colors.black87 : Colors.white;
    final hintCol  = widget.lightTheme ? Colors.black38 : Colors.white38;
    final iconCol  = widget.lightTheme ? Colors.black38 : Colors.white38;
    final radius   = BorderRadius.circular(12);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(widget.label!,
              style: TextStyle(
                  color: widget.lightTheme ? AppColors.textDark : Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
        ],
        Container(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: radius,
            border: Border.all(
              color: widget.lightTheme
                  ? Colors.black12
                  : AppColors.border,
            ),
          ),
          child: TextField(
            controller: widget.controller,
            obscureText: widget.isPassword && _obscure,
            keyboardType: widget.keyboardType,
            style: TextStyle(color: textCol, fontSize: 14),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: TextStyle(color: hintCol, fontSize: 14),
              prefixIcon: widget.prefixIcon != null
                  ? Icon(widget.prefixIcon, color: iconCol, size: 20)
                  : null,
              suffixIcon: widget.isPassword
                  ? IconButton(
                icon: Icon(
                  _obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: iconCol,
                  size: 20,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              )
                  : null,
              border: InputBorder.none,
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }
}