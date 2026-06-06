// 📁 lib/screens/explore/explore_screen.dart

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_assets.dart';
import '../../core/services/places_service.dart';
import '../../core/widgets/amun_filter_chip.dart';
import '../../core/widgets/place_card.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/animated_page_wrapper.dart';
import '../../core/widgets/app_skeleton.dart';

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

  double _minPrice = 0;
  double _maxPrice = 500;
  String _sortBy = 'rating';

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

  Future<void> _loadPlaces() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final response = await _placesService.getAllPlaces();
      final data = response.data;
      final List items = data['data'] ?? data ?? [];
      if (mounted) {
        setState(() {
          _places = _mapItems(items);
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading places: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _onSearchChanged(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _isSearching = false);
      await _loadPlaces();
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
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Search error: $e');
      if (mounted) setState(() => _isLoading = false);
      // مش بنعمل retry — بس بنوقف الـ loading
    }
  }

  Future<void> _onFilterChanged(int index) async {
    setState(() => _activeFilter = index);
    if (index == 0) {
      await _loadPlaces();
    } else {
      setState(() {});
    }
  }

  void _showFilterSheet() {
    double tempMin = _minPrice;
    double tempMax = _maxPrice;
    String tempSort = _sortBy;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 3,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        AppColors.gold,
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
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
                    onTap: () => setSheet(() {
                      tempMin = 0;
                      tempMax = 500;
                      tempSort = 'rating';
                    }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.goldDim,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.borderGold),
                      ),
                      child: const Text(
                        'Reset',
                        style: TextStyle(
                          color: AppColors.gold,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
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
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.bgInput,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '\$${tempMin.toInt()}',
                      style: const TextStyle(
                        color: AppColors.gold,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.bgInput,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '\$${tempMax.toInt()}',
                      style: const TextStyle(
                        color: AppColors.gold,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              RangeSlider(
                values: RangeValues(tempMin, tempMax),
                min: 0,
                max: 500,
                divisions: 50,
                activeColor: AppColors.gold,
                inactiveColor: AppColors.border,
                onChanged: (v) => setSheet(() {
                  tempMin = v.start;
                  tempMax = v.end;
                }),
              ),
              const SizedBox(height: 20),
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
                  _sortChip(
                    'Top Rated',
                    'rating',
                    tempSort,
                    (v) => setSheet(() => tempSort = v),
                  ),
                  const SizedBox(width: 8),
                  _sortChip(
                    'Price ↑',
                    'price_asc',
                    tempSort,
                    (v) => setSheet(() => tempSort = v),
                  ),
                  const SizedBox(width: 8),
                  _sortChip(
                    'Price ↓',
                    'price_desc',
                    tempSort,
                    (v) => setSheet(() => tempSort = v),
                  ),
                ],
              ),
              const SizedBox(height: 28),
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
                      borderRadius: BorderRadius.circular(14),
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

  Widget _sortChip(
    String label,
    String value,
    String current,
    Function(String) onTap,
  ) {
    final isActive = current == value;
    return GestureDetector(
      onTap: () => onTap(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.gold : AppColors.bgInput,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? AppColors.gold : AppColors.border,
          ),
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
      if (_sortBy == 'price_asc') {
        results.sort((a, b) {
          final aP =
              double.tryParse(
                a['price']?.toString().replaceAll(RegExp(r'[^\d.]'), '') ?? '0',
              ) ??
              0;
          final bP =
              double.tryParse(
                b['price']?.toString().replaceAll(RegExp(r'[^\d.]'), '') ?? '0',
              ) ??
              0;
          return aP.compareTo(bP);
        });
      } else if (_sortBy == 'price_desc') {
        results.sort((a, b) {
          final aP =
              double.tryParse(
                a['price']?.toString().replaceAll(RegExp(r'[^\d.]'), '') ?? '0',
              ) ??
              0;
          final bP =
              double.tryParse(
                b['price']?.toString().replaceAll(RegExp(r'[^\d.]'), '') ?? '0',
              ) ??
              0;
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

  List<Map<String, dynamic>> _mapItems(List items) {
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

  List<Map<String, dynamic>> get _filtered {
    if (_activeFilter == 0) return _places;
    final filterName = _filters[_activeFilter].toLowerCase();
    return _places.where((p) {
      final cat = (p['cat'] ?? '').toString().toLowerCase();
      final name = (p['name'] ?? '').toString().toLowerCase();
      final loc = (p['loc'] ?? '').toString().toLowerCase();
      return cat.contains(filterName) ||
          name.contains(filterName) ||
          loc.contains(filterName);
    }).toList();
  }
  // ══════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: AnimatedPageWrapper(
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 12),
              Expanded(child: _buildBody(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final hasFilter = _minPrice > 0 || _maxPrice < 1000;
    return Container(
      color: AppColors.bgCard,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Explore',
                style: TextStyle(
                  color: AppColors.gold,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              Row(
                children: [
                  // Search icon button
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.gold,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.search_rounded,
                        color: Color(0xFF1A1A2E),
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Filter icon button
                  GestureDetector(
                    onTap: _showFilterSheet,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: hasFilter ? AppColors.gold : Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.tune_rounded,
                        color: hasFilter ? Colors.black : AppColors.gold,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 10),

          // // Search bar
          // Row(
          //   children: [
          //     Expanded(
          //       child: Container(
          //         height: 52,
          //         decoration: BoxDecoration(
          //           color: Colors.white,
          //           borderRadius: BorderRadius.circular(30),
          //           boxShadow: [
          //             BoxShadow(
          //               color: Colors.black.withValues(alpha: 0.08),
          //               blurRadius: 12,
          //               offset: const Offset(0, 4),
          //             ),
          //           ],
          //         ),
          //         child: Row(
          //           children: [
          //             const SizedBox(width: 20),
          //             Expanded(
          //               child: TextField(
          //                 controller: _searchController,
          //                 style: const TextStyle(
          //                   color: Color(0xFF1A1A2E),
          //                   fontSize: 14,
          //                 ),
          //                 onChanged: _onSearchChanged,
          //                 onTapOutside: (_) => FocusScope.of(context).unfocus(),
          //                 decoration: const InputDecoration(
          //                   hintText: 'Search places...',
          //                   hintStyle: TextStyle(
          //                     color: Color(0xFFAAAAAA),
          //                     fontSize: 14,
          //                   ),
          //                   border: InputBorder.none,
          //                   isDense: true,
          //                   contentPadding: EdgeInsets.symmetric(vertical: 16),
          //                 ),
          //               ),
          //             ),
          //             if (_isSearching)
          //               GestureDetector(
          //                 onTap: () {
          //                   _searchController.clear();
          //                   setState(() => _isSearching = false);
          //                   _loadPlaces();
          //                 },
          //                 child: const Padding(
          //                   padding: EdgeInsets.only(right: 8),
          //                   child: Icon(
          //                     Icons.close_rounded,
          //                     color: Color(0xFFAAAAAA),
          //                     size: 18,
          //                   ),
          //                 ),
          //               ),
          //             GestureDetector(
          //               onTap: () {},
          //               child: Container(
          //                 width: 44,
          //                 height: 44,
          //                 margin: const EdgeInsets.all(4),
          //                 decoration: const BoxDecoration(
          //                   color: Color(0xFF1A1A2E),
          //                   shape: BoxShape.circle,
          //                 ),
          //                 child: const Icon(
          //                   Icons.search_rounded,
          //                   color: Colors.white,
          //                   size: 20,
          //                 ),
          //               ),
          //             ),
          //           ],
          //         ),
          //       ),
          //     ),
          //   ],
          // ),
          const SizedBox(height: 20),

          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(
                _filters.length,
                (i) => Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: GestureDetector(
                    onTap: () => _onFilterChanged(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: _activeFilter == i
                            ? AppColors.gold
                            : AppColors.bgInput,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        _filters[i],
                        style: TextStyle(
                          color: _activeFilter == i
                              ? AppColors.bgInput
                              : AppColors.gold,
                          fontSize: 13,
                          fontWeight: _activeFilter == i
                              ? FontWeight.bold
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Results count
          if (!_isLoading)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                '${_filtered.length} Places Found',
                style: const TextStyle(
                  color: Color(0xFF888888),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading) {
      return ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        itemCount: 4,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (_, __) => const SkeletonListCard(),
      );
    }

    if (_filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(
                Icons.search_off_rounded,
                color: Colors.white24,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _isSearching
                  ? 'No results for "${_searchController.text}"'
                  : 'No places found',
              style: const TextStyle(color: Colors.white38, fontSize: 15),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
      itemCount: _filtered.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (_, i) => _ExploreCard(
        place: _filtered[i],
        onTap: () => Navigator.pushNamed(
          context,
          '/place-details',
          arguments: _filtered[i],
        ),
      ),
    );
  }

  Widget _toggleBtn(IconData icon, bool isGrid) {
    final active = _isGrid == isGrid;
    return GestureDetector(
      onTap: () => setState(() => _isGrid = isGrid),
      child: Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: active ? AppColors.gold : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
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

class _ExploreCard extends StatelessWidget {
  final Map<String, dynamic> place;
  final VoidCallback onTap;

  const _ExploreCard({required this.place, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header: icon + name + location ──────────
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.goldDim,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.borderGold),
                    ),
                    child: const Icon(
                      Icons.location_city_rounded,
                      color: AppColors.gold,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          place['name'] ?? '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
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
                                  color: Colors.white38,
                                  fontSize: 11,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Rating
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.goldDim,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.borderGold),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: AppColors.gold,
                          size: 12,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          place['rating'] ?? '0',
                          style: const TextStyle(
                            color: AppColors.gold,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Photo ────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: Image.asset(
                    place['img'] ?? '',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.bgInput,
                      child: const Icon(
                        Icons.image,
                        color: Colors.white24,
                        size: 40,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ── Bottom: price + specs + button ───────────
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Price
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        place['price'] ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 3),
                        child: Text(
                          'per person',
                          style: TextStyle(color: Colors.white38, fontSize: 11),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Specs row
                  // Specs row
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _specChip(
                        Icons.category_rounded,
                        place['cat'] ?? 'Temple',
                      ),
                      _specChip(
                        Icons.star_border_rounded,
                        '${place['rating'] ?? '0'} Rating',
                      ),
                      _specChip(Icons.location_on_outlined, 'Egypt'),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // See Details button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'See Details',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _specChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.bgInput,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white38, size: 12),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
