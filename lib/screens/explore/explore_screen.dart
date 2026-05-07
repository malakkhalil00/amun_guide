// 📁 lib/screens/explore/explore_screen.dart

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_assets.dart';
import '../../core/services/places_service.dart';
import '../../core/widgets/amun_filter_chip.dart';
import '../../core/widgets/place_card.dart';
import '../../core/widgets/section_header.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  int _activeFilter = 0;
  bool _isGrid = true;
  bool _isLoading = true;
  final _searchController = TextEditingController();
  final _placesService = PlacesService();

  final _filters = ['All', 'Temples', 'Deserts', 'Nile', 'Beaches', 'Museums'];

  List<Map<String, dynamic>> _places = [];

  @override
  void initState() {
    super.initState();
    _loadPlaces();
  }

  Future<void> _loadPlaces() async {
    setState(() => _isLoading = true);
    try {
      final response = await _placesService.getAllPlaces();
      final data = response.data;
      final List items = data['data'] ?? data ?? [];
      setState(() {
        _places = items.map<Map<String, dynamic>>((p) => {
          'id': p['id'],
          'img': p['image'] ?? p['image_url'] ?? 'assets/images/pyramids.jpg',
          'name': p['title'] ?? p['name'] ?? '',
          'loc': p['location'] ?? 'Egypt',
          'rating': (p['rating'] ?? 0).toString(),
          'price': '\$${p['ticket_price'] ?? 0}/pax',
          'cat': p['category'] ?? 'Temples',
          'description': p['description'] ?? '',
        }).toList();
      });
    } catch (e) {
      debugPrint('Error loading places: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _searchPlaces(String query) async {
    if (query.isEmpty) {
      _loadPlaces();
      return;
    }
    setState(() => _isLoading = true);
    try {
      final response = await _placesService.searchPlaces(query);
      final data = response.data;
      final List items = data['data'] ?? data ?? [];
      setState(() {
        _places = items.map<Map<String, dynamic>>((p) => {
          'id': p['id'],
          'img': p['image'] ?? p['image_url'] ?? '',
          'name': p['title'] ?? p['name'] ?? '',
          'loc': p['location'] ?? 'Egypt',
          'rating': (p['rating'] ?? 0).toString(),
          'price': '\$${p['ticket_price'] ?? 0}/pax',
          'cat': p['category'] ?? 'Temples',
          'description': p['description'] ?? '',
        }).toList();
      });
    } catch (e) {
      debugPrint('Error searching: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> get _filtered => _activeFilter == 0
      ? _places
      : _places.where((p) => p['cat'] == _filters[_activeFilter]).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: Column(children: [

          // ─── Header ─────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Column(children: [

              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Explore Egypt',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold)),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.bgCard,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Row(children: [
                    _toggleBtn(Icons.grid_view, true),
                    _toggleBtn(Icons.view_list, false),
                  ]),
                ),
              ]),

              const SizedBox(height: 14),

              // Search
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.bgInput,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(children: [
                  const Icon(Icons.search, color: Colors.white38, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      onSubmitted: _searchPlaces,
                      onChanged: (v) {
                        if (v.isEmpty) _loadPlaces();
                      },
                      decoration: const InputDecoration(
                        hintText: 'Search places, tours...',
                        hintStyle: TextStyle(color: Colors.white38, fontSize: 14),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _searchPlaces(_searchController.text),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.gold,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.tune, color: Colors.black, size: 16),
                    ),
                  ),
                ]),
              ),

              const SizedBox(height: 12),

              // Filters
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

              const SizedBox(height: 14),

              SectionHeader(title: '${_filtered.length} Places Found'),
            ]),
          ),

          const SizedBox(height: 12),

          // ─── Results ────────────────────────────
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
                : _filtered.isEmpty
                    ? const Center(child: Text('No places found', style: TextStyle(color: Colors.white38)))
                    : _isGrid
                        ? GridView.builder(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 14,
                              mainAxisSpacing: 14,
                              childAspectRatio: 0.78,
                            ),
                            itemCount: _filtered.length,
                            itemBuilder: (_, i) => PlaceCard(
                              id: _filtered[i]['id'] is int ? _filtered[i]['id'] : int.tryParse(_filtered[i]['id']?.toString() ?? ''),
                              image: _filtered[i]['img'] ?? '',
                              name: _filtered[i]['name'] ?? '',
                              location: _filtered[i]['loc'] ?? '',
                              rating: _filtered[i]['rating'] ?? '',
                              price: _filtered[i]['price'] ?? '',
                              category: _filtered[i]['cat'] ?? '',
                              style: PlaceCardStyle.grid,
isNetworkImage: (_filtered[i]['img'] ?? '').toString().isNotEmpty,                              onTap: () => Navigator.pushNamed(
                                context,
                                '/place-details',
                                arguments: _filtered[i],
                              ),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                            itemCount: _filtered.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (_, i) => PlaceCard(
                              id: _filtered[i]['id'] is int ? _filtered[i]['id'] : int.tryParse(_filtered[i]['id']?.toString() ?? ''),
                              image: _filtered[i]['img'] ?? '',
                              name: _filtered[i]['name'] ?? '',
                              location: _filtered[i]['loc'] ?? '',
                              rating: _filtered[i]['rating'] ?? '',
                              price: _filtered[i]['price'] ?? '',
                              category: _filtered[i]['cat'] ?? '',
                              style: PlaceCardStyle.list,
isNetworkImage: (_filtered[i]['img'] ?? '').toString().isNotEmpty,                              onTap: () => Navigator.pushNamed(
                                context,
                                '/place-details',
                                arguments: _filtered[i],
                              ),
                            ),
                          ),
          ),
        ]),
      ),
    );
  }

  Widget _toggleBtn(IconData icon, bool isGrid) {
    final active = _isGrid == isGrid;
    return GestureDetector(
      onTap: () => setState(() => _isGrid = isGrid),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: active ? AppColors.gold : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: active ? Colors.black : Colors.white38, size: 18),
      ),
    );
  }
}