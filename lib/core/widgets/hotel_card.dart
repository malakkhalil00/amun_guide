// 📁 lib/core/widgets/hotel_card.dart

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class HotelCard extends StatelessWidget {
  final String image;
  final String name;
  final String location;
  final int stars;
  final String price;
  final VoidCallback onTap;

  const HotelCard({
    super.key,
    required this.image,
    required this.name,
    required this.location,
    required this.stars,
    required this.price,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 80,
                height: 80,
                child: image.startsWith('http')
                    ? Image.network(
                        image,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Image.asset(
                          'assets/images/pyramids.jpg',
                          fit: BoxFit.cover,
                        ),
                      )
                    : Image.asset(
                        image.isNotEmpty ? image : 'assets/images/pyramids.jpg',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: AppColors.bgInput,
                          child: const Icon(
                            Icons.hotel,
                            color: Colors.white24,
                            size: 32,
                          ),
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    location,
                    style: const TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: List.generate(
                      stars,
                      (_) => const Icon(
                        Icons.star,
                        color: AppColors.gold,
                        size: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    price,
                    style: const TextStyle(
                      color: AppColors.gold,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white12,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}
