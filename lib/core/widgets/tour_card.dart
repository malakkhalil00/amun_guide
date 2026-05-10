// 📁 lib/core/widgets/tour_card.dart

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class TourCard extends StatelessWidget {
  final String image;
  final String name;
  final String location;
  final String rating;
  final String price;
  final String tag;
  final VoidCallback onTap;

  const TourCard({
    super.key,
    required this.image,
    required this.name,
    required this.location,
    required this.rating,
    required this.price,
    required this.tag,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image + Tag
            Stack(children: [
              ClipRRect(
                borderRadius:
                const BorderRadius.vertical(top: Radius.circular(16)),
                child: SizedBox(
                  height: 110, width: double.infinity,
                 child: image.startsWith('http')
    ? Image.network(image, fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Image.asset('assets/images/pyramids.jpg', fit: BoxFit.cover))
    : Image.asset(image.isNotEmpty ? image : 'assets/images/pyramids.jpg', fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                          color: AppColors.bgInput,
                          child: const Icon(Icons.image,
                              color: Colors.white24, size: 40))),
                ),
              ),
              Positioned(
                bottom: 8, right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                      color: AppColors.gold,
                      borderRadius: BorderRadius.circular(8)),
                  child: Text(tag,
                      style: const TextStyle(
                          color: Colors.black,
                          fontSize: 10,
                          fontWeight: FontWeight.bold)),
                ),
              ),
            ]),

            // Info
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(location,
                      style: const TextStyle(
                          color: Colors.white38, fontSize: 11)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(children: [
                        const Icon(Icons.star,
                            color: AppColors.gold, size: 12),
                        const SizedBox(width: 3),
                        Text(rating,
                            style: const TextStyle(
                                color: Colors.white54, fontSize: 11)),
                      ]),
                      Text(price,
                          style: const TextStyle(
                              color: AppColors.gold,
                              fontSize: 11,
                              fontWeight: FontWeight.bold)),
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
}