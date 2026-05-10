// 📁 lib/screens/explore/tours_screen.dart

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_assets.dart';
import '../../core/services/tours_service.dart';
import '../../core/widgets/amun_filter_chip.dart';

class ToursScreen extends StatefulWidget {
  const ToursScreen({super.key});

  @override
  State<ToursScreen> createState() => _ToursScreenState();
}

class _ToursScreenState extends State<ToursScreen> {
  final _toursService = ToursService();
  final _searchController = TextEditingController();

  bool _isLoading = true;
  bool _isSearching = false;
  int _activeFilter = 0;

  final _filters = ['All', '1D', '2-3D', '4-7D', '7D+'];

  List<Map<String, dynamic>> _tours = [];
  List<Map<String, dynamic>> _allTours = []; // نحتفظ بالكل عشان الفلتر

  // Sort & Filter sheet
  double _minPrice = 0;
  double _maxPrice = 1000;
  String _sortBy = 'rating';

  static const _images = [
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

  @override
  void initState() {
    super.initState();
    _loadTours();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ══════════════════════════════════════
  // LOAD
  // ══════════════════════════════════════

  Future<void> _loadTours() async {
    setState(() => _isLoading = true);
    try {
      final response = await _toursService.getAllTours();
      final data = response.data;
      final List items = data['data'] ?? data ?? [];
      final mapped = _mapItems(items);
      setState(() {
        _tours = mapped;
        _allTours = mapped;
      });
    } catch (e) {
      debugPrint('Error loading tours: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ══════════════════════════════════════
  // SEARCH
  // ══════════════════════════════════════

  Future<void> _onSearchChanged(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _isSearching = false;
        _tours = _allTours;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _isLoading = true;
    });

    try {
      final response = await _toursService.searchTours(query);
      final data = response.data;
      final List items = data['data'] ?? data ?? [];
      if (mounted) {
        setState(() => _tours = _mapItems(items));
      }
    } catch (e) {
      // local fallback
      final q = query.toLowerCase();
      setState(() {
        _tours = _allTours
            .where(
              (t) =>
                  (t['name'] ?? '').toLowerCase().contains(q) ||
                  (t['loc'] ?? '').toLowerCase().contains(q),
            )
            .toList();
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ══════════════════════════════════════
  // FILTER SHEET
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
                      tempMax = 1000;
                      tempSort = 'rating';
                    }),
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
                max: 1000,
                divisions: 100,
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

  void _applyFilters() {
    List<Map<String, dynamic>> results = List.from(_allTours);

    // Filter by price
    results = results.where((t) {
      final price =
          double.tryParse(
            t['price']?.toString().replaceAll(RegExp(r'[^\d.]'), '') ?? '0',
          ) ??
          0;
      return price >= _minPrice && price <= _maxPrice;
    }).toList();

    // Sort
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

    setState(() => _tours = results);
  }

  // ══════════════════════════════════════
  // HELPERS
  // ══════════════════════════════════════

  List<Map<String, dynamic>> _mapItems(List items) {
    return items.asMap().entries.map<Map<String, dynamic>>((entry) {
      final i = entry.key;
      final t = entry.value;
      return {
        'id': t['id'],
        'img': _images[i % _images.length],
        'isNetwork': false,
        'name': t['title'] ?? t['name'] ?? '',
        'loc': t['location'] ?? 'Egypt',
        'rating': (t['rating'] ?? 0).toString(),
        'price': '\$${t['price'] ?? 0}',
        'days': t['duration_days'] ?? t['days'] ?? 1,
        // نحفظ start_date عشان نعرف لو التور مش past
        'start_date': t['start_date'] ?? t['date'] ?? '',
      };
    }).toList();
  }

  List<Map<String, dynamic>> get _filtered {
    if (_activeFilter == 0) return _tours;
    return _tours.where((t) {
      final d = (t['days'] is int)
          ? t['days'] as int
          : int.tryParse(t['days'].toString()) ?? 1;
      switch (_activeFilter) {
        case 1:
          return d == 1;
        case 2:
          return d >= 2 && d <= 3;
        case 3:
          return d >= 4 && d <= 7;
        case 4:
          return d > 7;
        default:
          return true;
      }
    }).toList();
  }

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
                  // Title
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Tours',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Search bar
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1A16),
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
                        const Icon(
                          Icons.search,
                          color: Colors.white38,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                            onChanged: _onSearchChanged,
                            onTapOutside: (_) =>
                                FocusScope.of(context).unfocus(),
                            decoration: const InputDecoration(
                              hintText: 'Search tours...',
                              hintStyle: TextStyle(
                                color: Colors.white38,
                                fontSize: 14,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 13,
                              ),
                            ),
                          ),
                        ),
                        if (_isSearching)
                          GestureDetector(
                            onTap: () {
                              _searchController.clear();
                              setState(() {
                                _isSearching = false;
                                _tours = _allTours;
                              });
                            },
                            child: const Padding(
                              padding: EdgeInsets.only(right: 8),
                              child: Icon(
                                Icons.close,
                                color: Colors.white38,
                                size: 18,
                              ),
                            ),
                          ),
                        GestureDetector(
                          onTap: _showFilterSheet,
                          child: Container(
                            margin: const EdgeInsets.only(right: 6),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: (_minPrice > 0 || _maxPrice < 1000)
                                  ? AppColors.gold
                                  : AppColors.gold.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.tune,
                              color: (_minPrice > 0 || _maxPrice < 1000)
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

                  // Duration filters
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
                            onTap: () => setState(() => _activeFilter = i),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Count
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _isLoading
                          ? 'Loading...'
                          : '${_filtered.length} Tours Found',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ─── List ────────────────────────────────
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
                          const Icon(
                            Icons.search_off,
                            color: Colors.white24,
                            size: 48,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _isSearching
                                ? 'No results for "${_searchController.text}"'
                                : 'No tours found',
                            style: const TextStyle(color: Colors.white38),
                          ),
                        ],
                      ),
                    )
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
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════
// TOUR CARD
// ══════════════════════════════════════

class _TourListCard extends StatelessWidget {
  final Map<String, dynamic> tour;
  final VoidCallback onTap;
  const _TourListCard({required this.tour, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isNetwork = tour['isNetwork'] == true;
    final img = tour['img']?.toString() ?? '';

    // Check if tour is in the past
    final startDate = tour['start_date']?.toString() ?? '';
    final isPast =
        startDate.isNotEmpty &&
        DateTime.tryParse(startDate)?.isBefore(DateTime.now()) == true;

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
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
              child: Stack(
                children: [
                  SizedBox(
                    height: 160,
                    width: double.infinity,
                    child: isNetwork
                        ? Image.network(
                            img,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _placeholder(),
                          )
                        : Image.asset(
                            img,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _placeholder(),
                          ),
                  ),
                  // Past badge
                  if (isPast)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Unavailable',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Info
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tour['name']?.toString() ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: AppColors.gold,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        tour['loc']?.toString() ?? '',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.star, color: AppColors.gold, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        tour['rating']?.toString() ?? '',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.goldDim,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${tour['days']}D Tour',
                          style: const TextStyle(
                            color: AppColors.gold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Text(
                        tour['price']?.toString() ?? '',
                        style: const TextStyle(
                          color: AppColors.gold,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
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

  Widget _placeholder() => Container(
    color: const Color(0xFF2A1F0E),
    child: const Center(
      child: Icon(Icons.image, color: Colors.white24, size: 40),
    ),
  );
}
