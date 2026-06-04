// 📁 lib/core/widgets/app_skeleton.dart

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppSkeleton extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const AppSkeleton({
    super.key,
    this.width = double.infinity,
    this.height = 16,
    this.borderRadius = 8,
  });

  @override
  State<AppSkeleton> createState() => _AppSkeletonState();
}

class _AppSkeletonState extends State<AppSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: AppColors.shimmerBase,
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
      ),
    );
  }
}

// ─── Skeleton Variants ────────────────────────────────

class SkeletonPlaceCard extends StatelessWidget {
  const SkeletonPlaceCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppSkeleton(height: 130, borderRadius: 20),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                AppSkeleton(width: 100, height: 14),
                SizedBox(height: 8),
                AppSkeleton(width: 70, height: 11),
                SizedBox(height: 10),
                AppSkeleton(width: double.infinity, height: 11),
                SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SkeletonTourCard extends StatelessWidget {
  const SkeletonTourCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 175,
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppSkeleton(height: 120, borderRadius: 20),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                AppSkeleton(width: 110, height: 13),
                SizedBox(height: 8),
                AppSkeleton(width: 80, height: 11),
                SizedBox(height: 10),
                AppSkeleton(width: double.infinity, height: 11),
                SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SkeletonListCard extends StatelessWidget {
  const SkeletonListCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const AppSkeleton(width: 95, height: 95, borderRadius: 14),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                AppSkeleton(width: 60, height: 11),
                SizedBox(height: 8),
                AppSkeleton(width: 130, height: 15),
                SizedBox(height: 8),
                AppSkeleton(width: 90, height: 11),
                SizedBox(height: 10),
                AppSkeleton(width: double.infinity, height: 11),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SkeletonHomeHeader extends StatelessWidget {
  const SkeletonHomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            AppSkeleton(width: 80, height: 13),
            SizedBox(height: 8),
            AppSkeleton(width: 180, height: 22),
            SizedBox(height: 6),
            AppSkeleton(width: 140, height: 13),
          ],
        ),
        const AppSkeleton(width: 44, height: 44, borderRadius: 22),
      ],
    );
  }
}