// 📁 lib/core/widgets/amun_app_bar.dart

import 'package:flutter/material.dart';

class AmunAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBack;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final Color? titleColor;
  final Color? iconColor;

  const AmunAppBar({
    super.key,
    required this.title,
    this.showBack = true,
    this.actions,
    this.backgroundColor,
    this.titleColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor ?? Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      leading: showBack
          ? IconButton(
        icon: Icon(Icons.arrow_back,
            color: iconColor ?? Colors.white),
        onPressed: () => Navigator.pop(context),
      )
          : null,
      title: Text(title,
          style: TextStyle(
              color: titleColor ?? Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 17)),
      centerTitle: true,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}