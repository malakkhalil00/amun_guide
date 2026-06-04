// 📁 lib/screens/tourist/saved_places_screen.dart

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_assets.dart';
import '../../core/services/likes_service.dart';
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
      final List items = data['data'] ?? data ?? [];

      setState(() {
        _saved = items.map<Map<String, dynamic>>((like) {
          final p = like['likeable'] ?? like['place'] ?? like['tour'] ?? {};
          return {
            'id': p['id'] ?? like['id'],
            'img': p['image'] ?? p['image_url'] ?? '',
            'name': p['title'] ?? p['name'] ?? 'Saved Item',
            'loc': p['location'] ?? 'Egypt',
            'rating': (p['rating'] ?? 0).toString(),
            'price': '\$${p['ticket_price'] ?? p['price'] ?? 0}',
            'cat': p['category'] ?? 'Saved',
          };
        }).toList();
      });
    } catch (e) {
      debugPrint('Error loading saved places: $e');
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
            itemBuilder: (_, i) => PlaceCard(
              id: _saved[i]['id'] is int
                  ? _saved[i]['id']
                  : int.tryParse(_saved[i]['id']?.toString() ?? ''),
              image: _saved[i]['img'],
              name: _saved[i]['name'],
              location: _saved[i]['loc'],
              rating: _saved[i]['rating'],
              price: _saved[i]['price'],
              category: _saved[i]['cat'],
              isSaved: true,
              isNetworkImage: true,
              onTap: () => Navigator.pushNamed(
                context,
                '/place-details',
                arguments: _saved[i],
              ),
              onSave: () async {
                // Optimistic removal happens within PlaceCard, but we want to remove it from the list
                setState(() => _saved.removeAt(i));
              },
            ),
          ),
        ),
      ],
    );
  }
}
