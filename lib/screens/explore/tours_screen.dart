// 📁 lib/screens/explore/tours_screen.dart

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/tours_service.dart';
import '../../core/widgets/amun_filter_chip.dart';
import '../../core/constants/app_assets.dart';

class ToursScreen extends StatefulWidget {
  const ToursScreen({super.key});

  @override
  State<ToursScreen> createState() => _ToursScreenState();
}

class _ToursScreenState extends State<ToursScreen> {
  final _toursService = ToursService();
  bool _isLoading = true;
  int _activeFilter = 0;
  final _filters = ['All', '1D', '2-3D', '4-7D', '7D+'];

  List<Map<String, dynamic>> _tours = [];

  // ✅ الصور الـ fallback اللي بتحطيها بإيدك لو الباك اند ملقتش صور
  static const List<String> _fallbackImages = [
    'assets/images/karnak_temple.jpg',
    'assets/images/luxor_temple.jpg',
    'assets/images/abu_simbel.jpg',
    'assets/images/valley_of_kings.jpg',
    'assets/images/pyramids.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _loadTours();
  }

Future<void> _loadTours() async {
  setState(() => _isLoading = true);
  try {
    final response = await _toursService.getAllTours();
    final data = response.data;
    final List items = data['data'] ?? data ?? [];
    final images = [
      AppAssets.pyramids,
      AppAssets.karnak,
      AppAssets.abuSimbel,
      AppAssets.alexandria,
      AppAssets.philae,
      AppAssets.siwa,
      AppAssets.nileSunset,
      AppAssets.luxorNight,
      AppAssets.valley,
      AppAssets.museum,
    ];
    setState(() {
      _tours = items.asMap().entries.map<Map<String, dynamic>>((entry) {
        final i = entry.key;
        final t = entry.value;
        return {
          'id': t['id'],
          'img': images[i % images.length],
          'isNetwork': false,
          'name': t['title'] ?? t['name'] ?? '',
          'loc': t['location'] ?? 'Egypt',
          'rating': (t['rating'] ?? 0).toString(),
          'price': '\$${t['price'] ?? 0}',
          'days': t['duration_days'] ?? t['days'] ?? 1,
        };
      }).toList();
    });
  } catch (e) {
    debugPrint('Error loading tours: $e');
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
}

  List<Map<String, dynamic>> get _filtered {
    if (_activeFilter == 0) return _tours;
    return _tours.where((t) {
      final d = t['days'] as int;
      switch (_activeFilter) {
        case 1: return d == 1;
        case 2: return d >= 2 && d <= 3;
        case 3: return d >= 4 && d <= 7;
        case 4: return d > 7;
        default: return true;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: Column(children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Column(children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Tours',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 14),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(_filters.length, (i) => AmunFilterChip(
                    label: _filters[i],
                    isActive: _activeFilter == i,
                    onTap: () => setState(() => _activeFilter = i),
                  )),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 14),

          // List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
                : _filtered.isEmpty
                    ? const Center(child: Text('No tours found', style: TextStyle(color: Colors.white54)))
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                        itemCount: _filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (_, i) => _TourListCard(
                          tour: _filtered[i],
                          onTap: () => Navigator.pushNamed(
                            context,
                            '/tour-details',
                            arguments: _filtered[i],
                          ),
                        ),
                      ),
          ),
        ]),
      ),
    );
  }
}

// ── Tour Card Widget ───────────────────────────────
class _TourListCard extends StatelessWidget {
  final Map<String, dynamic> tour;
  final VoidCallback onTap;
  const _TourListCard({required this.tour, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isNetwork = tour['isNetwork'] == true;
    final img = tour['img']?.toString() ?? '';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
              child: SizedBox(
                height: 160,
                width: double.infinity,
                child: isNetwork
                    ? Image.network(img, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _placeholder())
                    : Image.asset(img, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _placeholder()),
              ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tour['name']?.toString() ?? '',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Row(children: [
                    const Icon(Icons.location_on, color: AppColors.gold, size: 14),
                    const SizedBox(width: 4),
                    Text(tour['loc']?.toString() ?? '',
                        style: const TextStyle(color: Colors.white54, fontSize: 12)),
                    const Spacer(),
                    const Icon(Icons.star, color: AppColors.gold, size: 14),
                    const SizedBox(width: 4),
                    Text(tour['rating']?.toString() ?? '',
                        style: const TextStyle(color: Colors.white54, fontSize: 12)),
                  ]),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.goldDim,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text('${tour['days']}D Tour',
                            style: const TextStyle(color: AppColors.gold, fontSize: 12)),
                      ),
                      Text(tour['price']?.toString() ?? '',
                          style: const TextStyle(
                              color: AppColors.gold,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
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

  Widget _placeholder() => Container(
    color: const Color(0xFF2A1F0E),
    child: const Center(child: Icon(Icons.image, color: Colors.white24, size: 40)),
  );
}

// ── Extension عشان mapIndexed ─────────────────────
extension IterableExtension<T> on Iterable<T> {
  Iterable<R> mapIndexed<R>(R Function(int i, T e) f) {
    var i = 0;
    return map((e) => f(i++, e));
  }
}