// 📁 lib/screens/tourist/saved_places_screen.dart

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_assets.dart';
import '../../core/services/likes_service.dart';
import '../../core/services/places_service.dart';
import '../../core/widgets/amun_app_bar.dart';
import '../../core/widgets/amun_button.dart' as btn;
import '../../core/widgets/amun_filter_chip.dart';
import '../../core/widgets/place_card.dart';

class SavedPlacesScreen extends StatefulWidget {
  const SavedPlacesScreen({super.key});

  @override
  State<SavedPlacesScreen> createState() => _SavedPlacesScreenState();
}

class _SavedPlacesScreenState extends State<SavedPlacesScreen> {
  int _activeFilter = 0;
  bool _isLoading = true;
  final _filters = ['All', 'Top Rated', 'Nearby', 'Budget'];
  final _likesService = LikesService();
  List<Map<String, dynamic>> _saved = [];

  @override
  void initState() {
    super.initState();
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    setState(() => _isLoading = true);
    try {
      final response = await _likesService.getUserLikes();
      final data = response.data;
      final List items = data['data'] ?? [];

      final placesService = PlacesService();
      final List<Map<String, dynamic>> results = [];

      for (final like in items) {
        final int placeId = like['likeable_id'];
        try {
          final placeResponse = await placesService.getPlace(placeId);
          final p = placeResponse.data['data'] ?? placeResponse.data ?? {};
          results.add({
            'id': p['id'] ?? placeId,
            'img': p['image'] ?? p['image_url'] ?? '',
            'name': p['title'] ?? p['name'] ?? 'Saved Item',
            'loc': p['location'] ?? 'Egypt',
            'rating': (p['rating'] ?? 0).toString(),
            'price': '\$${p['ticket_price'] ?? p['price'] ?? 0}',
            'cat': p['category'] ?? 'Saved',
          });
        } catch (e) {
          debugPrint('Error loading place $placeId: $e');
        }
      }

      if (mounted) setState(() => _saved = results);
    } catch (e) {
      debugPrint('Error loading saved: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: const AmunAppBar(title: 'Saved Places', showBack: true),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.gold),
            )
          : _saved.isEmpty
          ? _buildEmpty(context)
          : _buildList(context),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              AppAssets.emptySaved,
              height: 180,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.bookmark_outline,
                color: Colors.white24,
                size: 100,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No saved treasures yet',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Start exploring and save your\nfavorite places here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white38,
                fontSize: 14,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 32),
            btn.AmunButton(
              label: 'Explore Places',
              onTap: () => Navigator.pushNamed(context, '/explore'),
              icon: Icons.explore_outlined,
              fullWidth: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context) {
    return Column(
      children: [
        // Filters
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(
                _filters.length,
                (i) => AmunFilterChip(
                  label: _filters[i],
                  isActive: _activeFilter == i,
                  onTap: () => setState(() => _activeFilter = i),
                ),
              ),
            ),
          ),
        ),

        // Grid
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 0.78,
            ),
            itemCount: _saved.length,
            itemBuilder: (_, i) {
              final place = _saved[i];
              return GestureDetector(
                onTap: () => Navigator.pushNamed(
                  context,
                  '/place-details',
                  arguments: place,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // ── Photo ──────────────────────────────
                      place['img'].toString().startsWith('http')
                          ? Image.network(
                              place['img'],
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  Container(color: AppColors.bgCard),
                            )
                          : Container(
                              color: AppColors.bgCard,
                              child: const Icon(
                                Icons.image_outlined,
                                color: Colors.white24,
                                size: 40,
                              ),
                            ),

                      // ── Gradient ───────────────────────────
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black38,
                              Colors.transparent,
                              Colors.black87,
                            ],
                            stops: [0.0, 0.4, 1.0],
                          ),
                        ),
                      ),

                      // ── Top row: rating + bookmark ─────────
                      Positioned(
                        top: 10,
                        left: 10,
                        right: 10,
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black45,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.star_rounded,
                                    color: AppColors.gold,
                                    size: 11,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    place['rating'] ?? '0',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: Colors.black45,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.bookmark_rounded,
                                color: AppColors.gold,
                                size: 15,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ── Bottom: name + location + price + button ──
                      Positioned(
                        bottom: 10,
                        left: 10,
                        right: 10,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              place['name'] ?? '',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on_rounded,
                                  color: AppColors.gold,
                                  size: 11,
                                ),
                                const SizedBox(width: 3),
                                Expanded(
                                  child: Text(
                                    place['loc'] ?? '',
                                    style: const TextStyle(
                                      color: Colors.white60,
                                      fontSize: 11,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Price',
                                      style: TextStyle(
                                        color: Colors.white54,
                                        fontSize: 10,
                                      ),
                                    ),
                                    Text(
                                      place['price'] ?? '',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.gold,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Text(
                                    'Book Now',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
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
            },
          ),
        ),
      ],
    );
  }
}
