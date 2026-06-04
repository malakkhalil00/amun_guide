// 📁 lib/core/widgets/place_card.dart

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../services/likes_service.dart';

enum PlaceCardStyle { grid, list }

class PlaceCard extends StatefulWidget {
  final int? id;
  final String image;
  final String name;
  final String location;
  final String rating;
  final String price;
  final String? category;
  final bool isSaved;
  final bool isNetworkImage;
  final PlaceCardStyle style;
  final VoidCallback onTap;
  final VoidCallback? onSave;

  const PlaceCard({
    super.key,
    this.id,
    required this.image,
    required this.name,
    required this.location,
    required this.rating,
    required this.price,
    this.category,
    this.isSaved = false,
    this.isNetworkImage = false,
    this.style = PlaceCardStyle.grid,
    required this.onTap,
    this.onSave,
  });

  @override
  State<PlaceCard> createState() => _PlaceCardState();
}

class _PlaceCardState extends State<PlaceCard> {
  late bool _isSaved;

  @override
  void initState() {
    super.initState();
    _isSaved = widget.isSaved;
  }

  @override
  void didUpdateWidget(covariant PlaceCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isSaved != widget.isSaved) {
      _isSaved = widget.isSaved;
    }
  }

  Future<void> _handleSave() async {
    if (widget.onSave != null) widget.onSave!();
    if (widget.id == null) return;
    setState(() => _isSaved = !_isSaved);
    try {
      final likesService = LikesService();
      await likesService.toggleLike(
        likeableType: 'places',
        likeableId: widget.id!,
      );
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
      if (mounted) {
        setState(() => _isSaved = !_isSaved);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update favorite status.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildImage(double height) {
    final isNetwork = widget.isNetworkImage && widget.image.startsWith('http');
    return SizedBox(
      height: height,
      width: double.infinity,
      child: isNetwork
          ? Image.network(
              widget.image,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _imageFallback(),
            )
          : Image.asset(
              widget.image,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _imageFallback(),
            ),
    );
  }

  Widget _imageFallback() => Container(
        color: AppColors.bgInput,
        child: const Icon(Icons.image_outlined,
            color: Colors.white24, size: 40),
      );

  @override
  Widget build(BuildContext context) {
    return widget.style == PlaceCardStyle.grid
        ? _gridCard()
        : _listCard();
  }

  Widget _gridCard() {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20)),
                  child: _buildImage(130),
                ),
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20)),
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black54],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: GestureDetector(
                    onTap: _handleSave,
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Icon(
                        _isSaved
                            ? Icons.bookmark
                            : Icons.bookmark_outline,
                        color: _isSaved ? AppColors.gold : Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
                if (widget.category != null)
                  Positioned(
                    bottom: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.gold,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        widget.category!,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      letterSpacing: 0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          color: AppColors.gold, size: 12),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          widget.location,
                          style: const TextStyle(
                              color: Colors.white38, fontSize: 11),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.star_rounded,
                              color: AppColors.gold, size: 13),
                          const SizedBox(width: 3),
                          Text(
                            widget.rating,
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        widget.price,
                        style: const TextStyle(
                          color: AppColors.gold,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _listCard() {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: SizedBox(
                width: 95,
                height: 95,
                child: widget.isNetworkImage &&
                        widget.image.startsWith('http')
                    ? Image.network(
                        widget.image,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _imageFallback(),
                      )
                    : Image.asset(
                        widget.image,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _imageFallback(),
                      ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.category != null) ...[
                    Text(
                      widget.category!,
                      style: const TextStyle(
                        color: AppColors.gold,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 3),
                  ],
                  Text(
                    widget.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          color: Colors.white38, size: 12),
                      const SizedBox(width: 3),
                      Text(
                        widget.location,
                        style: const TextStyle(
                            color: Colors.white38, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.star_rounded,
                              color: AppColors.gold, size: 14),
                          const SizedBox(width: 3),
                          Text(
                            widget.rating,
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        widget.price,
                        style: const TextStyle(
                          color: AppColors.gold,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: _handleSave,
              child: Container(
                width: 36,
                height: 36,
                margin: const EdgeInsets.only(left: 8),
                decoration: BoxDecoration(
                  color: _isSaved
                      ? AppColors.goldDim
                      : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color:
                        _isSaved ? AppColors.gold : AppColors.border,
                  ),
                ),
                child: Icon(
                  _isSaved ? Icons.bookmark : Icons.bookmark_outline,
                  color:
                      _isSaved ? AppColors.gold : Colors.white38,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}