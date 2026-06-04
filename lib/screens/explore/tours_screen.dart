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

class _ToursScreenState extends State<ToursScreen>
    with SingleTickerProviderStateMixin {
  final _toursService = ToursService();
  final _searchController = TextEditingController();

  bool _isLoading = true;
  bool _isSearching = false;
  int _activeFilter = 0;

  final _filters = ['All', '1D', '2-3D', '4-7D', '7D+'];

  List<Map<String, dynamic>> _tours = [];
  List<Map<String, dynamic>> _allTours = [];

  double _minPrice = 0;
  double _maxPrice = 1000;
  String _sortBy = 'rating';

  // ── Animation ──────────────────────────────────
  late AnimationController _listAnimController;

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
    _listAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _loadTours();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _listAnimController.dispose();
    super.dispose();
  }

  // ══════════════════════════════════════
  // LOAD — unchanged
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
      _listAnimController.forward(from: 0);
    } catch (e) {
      debugPrint('Error loading tours: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ══════════════════════════════════════
  // SEARCH — unchanged
  // ══════════════════════════════════════

  Future<void> _onSearchChanged(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _isSearching = false;
        _tours = _allTours;
      });
      _listAnimController.forward(from: 0);
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
        _listAnimController.forward(from: 0);
      }
    } catch (e) {
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
      _listAnimController.forward(from: 0);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ══════════════════════════════════════
  // FILTER SHEET — unchanged logic, restyled
  // ══════════════════════════════════════

  void _showFilterSheet() {
    double tempMin = _minPrice;
    double tempMax = _maxPrice;
    String tempSort = _sortBy;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1A16),
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
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white12,
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
                      fontFamily: 'Playfair Display',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setSheet(() {
                      tempMin = 0;
                      tempMax = 1000;
                      tempSort = 'rating';
                    }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: AppColors.gold.withOpacity(0.4)),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Reset',
                        style: TextStyle(
                            color: AppColors.gold, fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Price Range
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Price Range',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '\$${tempMin.toInt()} — \$${tempMax.toInt()}',
                      style: const TextStyle(
                          color: AppColors.gold, fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SliderTheme(
                data: SliderThemeData(
                  activeTrackColor: AppColors.gold,
                  inactiveTrackColor: Colors.white10,
                  thumbColor: AppColors.gold,
                  overlayColor: AppColors.gold.withOpacity(0.1),
                  trackHeight: 2,
                ),
                child: RangeSlider(
                  values: RangeValues(tempMin, tempMax),
                  min: 0,
                  max: 1000,
                  divisions: 100,
                  onChanged: (v) =>
                      setSheet(() {
                        tempMin = v.start;
                        tempMax = v.end;
                      }),
                ),
              ),
              const SizedBox(height: 24),

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
                  _sortChip('Top Rated', 'rating', tempSort,
                      (v) => setSheet(() => tempSort = v)),
                  const SizedBox(width: 8),
                  _sortChip('Price ↑', 'price_asc', tempSort,
                      (v) => setSheet(() => tempSort = v)),
                  const SizedBox(width: 8),
                  _sortChip('Price ↓', 'price_desc', tempSort,
                      (v) => setSheet(() => tempSort = v)),
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
                    padding: const EdgeInsets.symmetric(vertical: 16),
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
                      letterSpacing: 0.5,
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

  Widget _sortChip(String label, String value, String current,
      Function(String) onTap) {
    final isActive = current == value;
    return GestureDetector(
      onTap: () => onTap(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.gold : Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive
                ? AppColors.gold
                : Colors.white.withOpacity(0.1),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.black : Colors.white54,
            fontSize: 12,
            fontWeight:
                isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════
  // APPLY FILTERS — unchanged
  // ══════════════════════════════════════

  void _applyFilters() {
    List<Map<String, dynamic>> results = List.from(_allTours);
    results = results.where((t) {
      final price = double.tryParse(
              t['price']?.toString().replaceAll(RegExp(r'[^\d.]'), '') ??
                  '0') ??
          0;
      return price >= _minPrice && price <= _maxPrice;
    }).toList();

    if (_sortBy == 'price_asc') {
      results.sort((a, b) {
        final aP = double.tryParse(a['price']
                    ?.toString()
                    .replaceAll(RegExp(r'[^\d.]'), '') ??
                '0') ??
            0;
        final bP = double.tryParse(b['price']
                    ?.toString()
                    .replaceAll(RegExp(r'[^\d.]'), '') ??
                '0') ??
            0;
        return aP.compareTo(bP);
      });
    } else if (_sortBy == 'price_desc') {
      results.sort((a, b) {
        final aP = double.tryParse(a['price']
                    ?.toString()
                    .replaceAll(RegExp(r'[^\d.]'), '') ??
                '0') ??
            0;
        final bP = double.tryParse(b['price']
                    ?.toString()
                    .replaceAll(RegExp(r'[^\d.]'), '') ??
                '0') ??
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
    _listAnimController.forward(from: 0);
  }

  // ══════════════════════════════════════
  // HELPERS — unchanged
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
        case 1: return d == 1;
        case 2: return d >= 2 && d <= 3;
        case 3: return d >= 4 && d <= 7;
        case 4: return d > 7;
        default: return true;
      }
    }).toList();
  }

  // ══════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF151411),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _isLoading
                  ? _buildSkeletonList()
                  : _filtered.isEmpty
                      ? _buildEmpty()
                      : _buildList(),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Guided Tours',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Playfair Display',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        width: 28,
                        height: 2,
                        decoration: BoxDecoration(
                          color: AppColors.gold,
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Expert guides · Unforgettable journeys',
                        style: TextStyle(
                          color: AppColors.gold.withOpacity(0.7),
                          fontSize: 11,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Tours count badge
              if (!_isLoading)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: AppColors.gold.withOpacity(0.25)),
                  ),
                  child: Text(
                    '${_filtered.length} Tours',
                    style: const TextStyle(
                      color: AppColors.gold,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),

          // Search bar
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1E1A16),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _isSearching
                    ? AppColors.gold.withOpacity(0.5)
                    : Colors.white.withOpacity(0.08),
              ),
              boxShadow: _isSearching
                  ? [
                      BoxShadow(
                        color: AppColors.gold.withOpacity(0.08),
                        blurRadius: 12,
                        spreadRadius: 0,
                      )
                    ]
                  : [],
            ),
            child: Row(
              children: [
                const SizedBox(width: 16),
                Icon(
                  Icons.search,
                  color: _isSearching
                      ? AppColors.gold
                      : Colors.white38,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 14),
                    onChanged: _onSearchChanged,
                    onTapOutside: (_) =>
                        FocusScope.of(context).unfocus(),
                    decoration: const InputDecoration(
                      hintText: 'Search tours...',
                      hintStyle: TextStyle(
                          color: Colors.white38, fontSize: 14),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 14),
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
                      child: Icon(Icons.close,
                          color: Colors.white38, size: 18),
                    ),
                  ),
                GestureDetector(
                  onTap: _showFilterSheet,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.all(6),
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: (_minPrice > 0 || _maxPrice < 1000)
                          ? AppColors.gold
                          : AppColors.gold.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.tune_rounded,
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
          const SizedBox(height: 14),

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
                    onTap: () {
                      setState(() => _activeFilter = i);
                      _listAnimController.forward(from: 0);
                    },
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ── List ──────────────────────────────────────
  Widget _buildList() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
      itemCount: _filtered.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (_, i) {
        // Stagger animation per card
        final delay = (i * 0.08).clamp(0.0, 0.7);
        final animation = CurvedAnimation(
          parent: _listAnimController,
          curve: Interval(delay, (delay + 0.4).clamp(0.0, 1.0),
              curve: Curves.easeOutCubic),
        );
        return AnimatedBuilder(
          animation: animation,
          builder: (ctx, child) => Opacity(
            opacity: animation.value,
            child: Transform.translate(
              offset: Offset(0, 24 * (1 - animation.value)),
              child: child,
            ),
          ),
          child: _TourListCard(
            tour: _filtered[i],
            onTap: () => Navigator.pushNamed(
              context,
              '/tour-details',
              arguments: _filtered[i],
            ),
          ),
        );
      },
    );
  }

  // ── Skeleton ──────────────────────────────────
  Widget _buildSkeletonList() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
      itemCount: 4,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (_, __) => const _TourCardSkeleton(),
    );
  }

  // ── Empty state ───────────────────────────────
  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: AppColors.gold.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.search_off_rounded,
                color: Colors.white24, size: 32),
          ),
          const SizedBox(height: 16),
          Text(
            _isSearching
                ? 'No results for "${_searchController.text}"'
                : 'No tours found',
            style: const TextStyle(
                color: Colors.white54, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters',
            style: TextStyle(
                color: Colors.white.withOpacity(0.25),
                fontSize: 12),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════
// TOUR CARD — redesigned
// ══════════════════════════════════════

class _TourListCard extends StatelessWidget {
  final Map<String, dynamic> tour;
  final VoidCallback onTap;
  const _TourListCard({required this.tour, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isNetwork = tour['isNetwork'] == true;
    final img = tour['img']?.toString() ?? '';
    final startDate = tour['start_date']?.toString() ?? '';
    final isPast = startDate.isNotEmpty &&
        DateTime.tryParse(startDate)?.isBefore(DateTime.now()) == true;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E1A16),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withOpacity(0.07)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image ──────────────────────────────
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(22)),
              child: Stack(
                children: [
                  SizedBox(
                    height: 200,
                    width: double.infinity,
                    child: isNetwork
                        ? Image.network(img,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _placeholder())
                        : Image.asset(img,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _placeholder()),
                  ),
                  // Gradient overlay
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.55),
                          ],
                          stops: const [0.45, 1.0],
                        ),
                      ),
                    ),
                  ),
                  // Duration badge — top left
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.55),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: AppColors.gold.withOpacity(0.4)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.schedule_rounded,
                              color: AppColors.gold, size: 12),
                          const SizedBox(width: 4),
                          Text(
                            '${tour['days']}D Tour',
                            style: const TextStyle(
                              color: AppColors.gold,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Price badge — top right
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.gold,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        tour['price']?.toString() ?? '',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  // Past badge
                  if (isPast)
                    Positioned(
                      bottom: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
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
                  // Rating — bottom right on image
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            color: AppColors.gold, size: 15),
                        const SizedBox(width: 3),
                        Text(
                          tour['rating']?.toString() ?? '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Info ───────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tour['name']?.toString() ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Playfair Display',
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on_rounded,
                          color: AppColors.gold.withOpacity(0.8),
                          size: 14),
                      const SizedBox(width: 4),
                      Text(
                        tour['loc']?.toString() ?? '',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 12,
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
            child: Icon(Icons.image, color: Colors.white24, size: 40)),
      );
}

// ══════════════════════════════════════
// SKELETON CARD
// ══════════════════════════════════════

class _TourCardSkeleton extends StatefulWidget {
  const _TourCardSkeleton();

  @override
  State<_TourCardSkeleton> createState() => _TourCardSkeletonState();
}

class _TourCardSkeletonState extends State<_TourCardSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnim;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    _shimmerAnim = Tween<double>(begin: -1.5, end: 1.5).animate(
      CurvedAnimation(
          parent: _shimmerController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmerAnim,
      builder: (_, __) {
        final shimmerGradient = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: const [
            Color(0xFF1E1A16),
            Color(0xFF2A2419),
            Color(0xFF1E1A16),
          ],
          stops: [
            (_shimmerAnim.value - 0.3).clamp(0.0, 1.0),
            (_shimmerAnim.value).clamp(0.0, 1.0),
            (_shimmerAnim.value + 0.3).clamp(0.0, 1.0),
          ],
        );
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E1A16),
            borderRadius: BorderRadius.circular(22),
            border:
                Border.all(color: Colors.white.withOpacity(0.06)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image skeleton
              Container(
                height: 200,
                decoration: BoxDecoration(
                  gradient: shimmerGradient,
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(22)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 18,
                      width: 200,
                      decoration: BoxDecoration(
                        gradient: shimmerGradient,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 12,
                      width: 120,
                      decoration: BoxDecoration(
                        gradient: shimmerGradient,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}