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

  // ✅ كل الـ logic محمي
  Future<void> _loadPlaces() async {
    setState(() => _isLoading = true);
    try {
      final response = await _placesService.getAllPlaces();
      final data = response.data;
      final List items = data['data'] ?? data ?? [];
      setState(() => _places = _mapItems(items));
    } catch (e) {
      debugPrint('Error loading places: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

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
      if (mounted) setState(() => _places = _mapItems(items));
    } catch (e) {
      debugPrint('Search error: $e');
      final q = query.toLowerCase();
      setState(() {
        _places = _places
            .where(
              (p) =>
                  (p['name'] ?? '').toLowerCase().contains(q) ||
                  (p['loc'] ?? '').toLowerCase().contains(q) ||
                  (p['cat'] ?? '').toLowerCase().contains(q),
            )
            .toList();
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _onFilterChanged(int index) async {
    setState(() => _activeFilter = index);
    if (index == 0) await _loadPlaces();
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
    final hasFilter = _minPrice > 0 || _maxPrice < 500;
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bgCard,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
      child: Column(
        children: [
          // Title row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // const Text(
                  //   '',
                  //   style: TextStyle(
                  //     color: Colors.white54,
                  //     fontSize: 13,
                  //     letterSpacing: 0.3,
                  //   ),
                  // ),
                  // const SizedBox(height: 2),
                  const Text(
                    ' Explore Egypt',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
              // Grid/List toggle
              Container(
                decoration: BoxDecoration(
                  color: AppColors.bgInput,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    _toggleBtn(Icons.grid_view_rounded, true),
                    _toggleBtn(Icons.view_list_rounded, false),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Search bar
          Container(
            decoration: BoxDecoration(
              color: AppColors.bgInput,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _isSearching ? AppColors.gold : AppColors.border,
                width: _isSearching ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                const SizedBox(width: 16),
                const Icon(
                  Icons.search_rounded,
                  color: AppColors.gold,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    onChanged: _onSearchChanged,
                    onTapOutside: (_) => FocusScope.of(context).unfocus(),
                    decoration: const InputDecoration(
                      hintText: 'Search places...',
                      hintStyle: TextStyle(color: Colors.white38, fontSize: 14),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                if (_isSearching)
                  GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      setState(() => _isSearching = false);
                      _loadPlaces();
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.bgCard,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: Colors.white54,
                        size: 14,
                      ),
                    ),
                  ),
                // Filter button
                GestureDetector(
                  onTap: _showFilterSheet,
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: hasFilter ? AppColors.gold : AppColors.goldDim,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderGold),
                    ),
                    child: Icon(
                      Icons.tune_rounded,
                      color: hasFilter ? Colors.black : AppColors.gold,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Filter chips
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

          const SizedBox(height: 12),

          // Results count
          Row(
            children: [
              Container(
                width: 3,
                height: 16,
                decoration: BoxDecoration(
                  color: AppColors.gold,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _isLoading ? 'Loading...' : '${_filtered.length} Places Found',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading) {
      return _isGrid
          ? GridView.builder(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 0.78,
              ),
              itemCount: 6,
              itemBuilder: (_, __) => const SkeletonPlaceCard(),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              itemCount: 4,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
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
            const SizedBox(height: 6),
            const Text(
              'Try a different keyword or filter',
              style: TextStyle(color: Colors.white24, fontSize: 12),
            ),
          ],
        ),
      );
    }

    return _isGrid
        ? GridView.builder(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 0.78,
            ),
            itemCount: _filtered.length,
            itemBuilder: (_, i) => PlaceCard(
              id: _filtered[i]['id'] is int
                  ? _filtered[i]['id']
                  : int.tryParse(_filtered[i]['id']?.toString() ?? ''),
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
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            itemCount: _filtered.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) => PlaceCard(
              id: _filtered[i]['id'] is int
                  ? _filtered[i]['id']
                  : int.tryParse(_filtered[i]['id']?.toString() ?? ''),
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
