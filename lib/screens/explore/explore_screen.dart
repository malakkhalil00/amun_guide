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
  bool _isSearching = false;

  final _searchController = TextEditingController();
  final _placesService = PlacesService();

  final _filters = ['All', 'Temples', 'Deserts', 'Nile', 'Beaches', 'Museums'];

  List<Map<String, dynamic>> _places = [];

  // Filter sheet state
  double _minPrice = 0;
  double _maxPrice = 500;
  String _sortBy = 'rating'; // rating, price_asc, price_desc

  @override
  void initState() {
    super.initState();
    _loadPlaces();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ══════════════════════════════════════
  // LOAD ALL PLACES
  // ══════════════════════════════════════

  Future<void> _loadPlaces() async {
    setState(() => _isLoading = true);
    try {
      final response = await _placesService.getAllPlaces();
      final data = response.data;
      final List items = data['data'] ?? data ?? [];
      setState(() {
        _places = _mapItems(items);
      });
    } catch (e) {
      debugPrint('Error loading places: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ══════════════════════════════════════
  // SEARCH — fires on every keystroke
  // ══════════════════════════════════════

  Future<void> _onSearchChanged(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _isSearching = false);
      _loadPlaces();
      return;
    }

    setState(() {
      _isSearching = true;
      _isLoading = true;
    });

    try {
      final response = await _placesService.searchPlaces(query);
      final data = response.data;
      final List items = data['data'] ?? data ?? [];
      if (mounted) {
        setState(() {
          _places = _mapItems(items);
        });
      }
    } catch (e) {
      debugPrint('Search error: $e');
      // local fallback
      final q = query.toLowerCase();
      setState(() {
        _places = _places
            .where((p) =>
                (p['name'] ?? '').toLowerCase().contains(q) ||
                (p['loc'] ?? '').toLowerCase().contains(q) ||
                (p['cat'] ?? '').toLowerCase().contains(q))
            .toList();
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ══════════════════════════════════════
  // FILTER BY CATEGORY — calls API
  // ══════════════════════════════════════

  Future<void> _onFilterChanged(int index) async {
  setState(() {
    _activeFilter = index;
  });
  // الفلتر بيتعمل local عن طريق _filtered getter — مش محتاج API call
}

  // ══════════════════════════════════════
  // TUNE BOTTOM SHEET
  // ══════════════════════════════════════

  void _showFilterSheet() {
    double tempMin = _minPrice;
    double tempMax = _maxPrice;
    String tempSort = _sortBy;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1A16),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Filter & Sort',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setSheet(() {
                        tempMin = 0;
                        tempMax = 500;
                        tempSort = 'rating';
                      });
                    },
                    child: const Text(
                      'Reset',
                      style: TextStyle(color: AppColors.gold, fontSize: 13),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Price Range
              const Text(
                'Price Range',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '\$${tempMin.toInt()}',
                    style: const TextStyle(color: AppColors.gold, fontSize: 13),
                  ),
                  Text(
                    '\$${tempMax.toInt()}',
                    style: const TextStyle(color: AppColors.gold, fontSize: 13),
                  ),
                ],
              ),
              RangeSlider(
                values: RangeValues(tempMin, tempMax),
                min: 0,
                max: 500,
                divisions: 50,
                activeColor: AppColors.gold,
                inactiveColor: Colors.white12,
                onChanged: (v) => setSheet(() {
                  tempMin = v.start;
                  tempMax = v.end;
                }),
              ),
              const SizedBox(height: 20),

              // Sort By
              const Text(
                'Sort By',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _sortChip('Top Rated', 'rating', tempSort, (v) => setSheet(() => tempSort = v)),
                  const SizedBox(width: 8),
                  _sortChip('Price ↑', 'price_asc', tempSort, (v) => setSheet(() => tempSort = v)),
                  const SizedBox(width: 8),
                  _sortChip('Price ↓', 'price_desc', tempSort, (v) => setSheet(() => tempSort = v)),
                ],
              ),
              const SizedBox(height: 28),

              // Apply Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _minPrice = tempMin;
                      _maxPrice = tempMax;
                      _sortBy = tempSort;
                    });
                    Navigator.pop(ctx);
                    _applyFilters();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Apply Filters',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sortChip(String label, String value, String current, Function(String) onTap) {
    final isActive = current == value;
    return GestureDetector(
      onTap: () => onTap(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.gold : Colors.white10,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.black : Colors.white54,
            fontSize: 12,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Future<void> _applyFilters() async {
    setState(() => _isLoading = true);
    try {
      final response = await _placesService.filterPlaces(
        minPrice: _minPrice,
        maxPrice: _maxPrice,
      );
      final data = response.data;
      final List items = data['data'] ?? data ?? [];
      List<Map<String, dynamic>> results = _mapItems(items);

      // Sort locally
      if (_sortBy == 'price_asc') {
        results.sort((a, b) {
          final aP = double.tryParse(a['price']?.toString().replaceAll(RegExp(r'[^\d.]'), '') ?? '0') ?? 0;
          final bP = double.tryParse(b['price']?.toString().replaceAll(RegExp(r'[^\d.]'), '') ?? '0') ?? 0;
          return aP.compareTo(bP);
        });
      } else if (_sortBy == 'price_desc') {
        results.sort((a, b) {
          final aP = double.tryParse(a['price']?.toString().replaceAll(RegExp(r'[^\d.]'), '') ?? '0') ?? 0;
          final bP = double.tryParse(b['price']?.toString().replaceAll(RegExp(r'[^\d.]'), '') ?? '0') ?? 0;
          return bP.compareTo(aP);
        });
      } else {
        results.sort((a, b) {
          final aR = double.tryParse(a['rating'] ?? '0') ?? 0;
          final bR = double.tryParse(b['rating'] ?? '0') ?? 0;
          return bR.compareTo(aR);
        });
      }

      if (mounted) setState(() => _places = results);
    } catch (e) {
      debugPrint('Apply filter error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ══════════════════════════════════════
  // HELPERS
  // ══════════════════════════════════════

  List<Map<String, dynamic>> _mapItems(List items) {
    final images = [
      AppAssets.pyramids, AppAssets.karnak, AppAssets.abuSimbel,
      AppAssets.alexandria, AppAssets.philae, AppAssets.siwa,
      AppAssets.nileSunset, AppAssets.luxorNight, AppAssets.valley,
      AppAssets.museum,
    ];
    return items.asMap().entries.map<Map<String, dynamic>>((entry) {
      final i = entry.key;
      final p = entry.value;
      return {
        'id': p['id'],
        'img': images[i % images.length],
        'name': p['title'] ?? p['name'] ?? '',
        'loc': p['location'] ?? 'Egypt',
        'rating': (p['rating'] ?? 0).toString(),
        'price': '\$${p['ticket_price'] ?? 0}/pax',
        'cat': p['category'] ?? 'Temples',
        'description': p['description'] ?? '',
      };
    }).toList();
  }

  List<Map<String, dynamic>> get _filtered => _activeFilter == 0
      ? _places
      : _places.where((p) => p['cat'] == _filters[_activeFilter]).toList();

  // ══════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: Column(
          children: [
            // ─── Header ─────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Explore Egypt',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.bgCard,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: Row(
                          children: [
                            _toggleBtn(Icons.grid_view, true),
                            _toggleBtn(Icons.view_list, false),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Search bar — fires on every keystroke
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.bgInput,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: _isSearching
                            ? AppColors.gold.withOpacity(0.5)
                            : Colors.white10,
                      ),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 16),
                        const Icon(Icons.search, color: Colors.white38, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                            onChanged: _onSearchChanged,
                            onTapOutside: (_) => FocusScope.of(context).unfocus(),
                            decoration: const InputDecoration(
                              hintText: 'Search places...',
                              hintStyle: TextStyle(
                                color: Colors.white38,
                                fontSize: 14,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(vertical: 13),
                            ),
                          ),
                        ),
                        // Clear button when searching
                        if (_isSearching)
                          GestureDetector(
                            onTap: () {
                              _searchController.clear();
                              setState(() => _isSearching = false);
                              _loadPlaces();
                            },
                            child: const Padding(
                              padding: EdgeInsets.only(right: 8),
                              child: Icon(Icons.close, color: Colors.white38, size: 18),
                            ),
                          ),
                        // Tune/Filter button
                        GestureDetector(
                          onTap: _showFilterSheet,
                          child: Container(
                            margin: const EdgeInsets.only(right: 6),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: (_minPrice > 0 || _maxPrice < 500)
                                  ? AppColors.gold
                                  : AppColors.gold.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.tune,
                              color: (_minPrice > 0 || _maxPrice < 500)
                                  ? Colors.black
                                  : AppColors.gold,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Filter chips — calls API on tap
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(
                        _filters.length,
                        (i) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: AmunFilterChip(
                            label: _filters[i],
                            isActive: _activeFilter == i,
                            onTap: () => _onFilterChanged(i),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  SectionHeader(
                    title: _isLoading
                        ? 'Loading...'
                        : '${_filtered.length} Places Found',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ─── Results ────────────────────────────
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.gold),
                    )
                  : _filtered.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.search_off,
                                  color: Colors.white24, size: 48),
                              const SizedBox(height: 12),
                              Text(
                                _isSearching
                                    ? 'No results for "${_searchController.text}"'
                                    : 'No places found',
                                style: const TextStyle(color: Colors.white38),
                              ),
                            ],
                          ),
                        )
                      : _isGrid
                          ? GridView.builder(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 14,
                                mainAxisSpacing: 14,
                                childAspectRatio: 0.78,
                              ),
                              itemCount: _filtered.length,
                              itemBuilder: (_, i) => PlaceCard(
                                id: _filtered[i]['id'] is int
                                    ? _filtered[i]['id']
                                    : int.tryParse(
                                        _filtered[i]['id']?.toString() ?? ''),
                                image: _filtered[i]['img'] ?? '',
                                name: _filtered[i]['name'] ?? '',
                                location: _filtered[i]['loc'] ?? '',
                                rating: _filtered[i]['rating'] ?? '',
                                price: _filtered[i]['price'] ?? '',
                                category: _filtered[i]['cat'] ?? '',
                                style: PlaceCardStyle.grid,
                                isNetworkImage: false,
                                onTap: () => Navigator.pushNamed(
                                  context,
                                  '/place-details',
                                  arguments: _filtered[i],
                                ),
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                              itemCount: _filtered.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (_, i) => PlaceCard(
                                id: _filtered[i]['id'] is int
                                    ? _filtered[i]['id']
                                    : int.tryParse(
                                        _filtered[i]['id']?.toString() ?? ''),
                                image: _filtered[i]['img'] ?? '',
                                name: _filtered[i]['name'] ?? '',
                                location: _filtered[i]['loc'] ?? '',
                                rating: _filtered[i]['rating'] ?? '',
                                price: _filtered[i]['price'] ?? '',
                                category: _filtered[i]['cat'] ?? '',
                                style: PlaceCardStyle.list,
                                isNetworkImage: false,
                                onTap: () => Navigator.pushNamed(
                                  context,
                                  '/place-details',
                                  arguments: _filtered[i],
                                ),
                              ),
                            ),
            ),
          ],
        ),
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
        child: Icon(
          icon,
          color: active ? Colors.black : Colors.white38,
          size: 18,
        ),
      ),
    );
  }
}