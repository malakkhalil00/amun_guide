// 📁 lib/screens/explore/tours_screen.dart

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_assets.dart';
import '../../core/services/tours_service.dart';

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
  bool _showSearch = false;

  int _activeFilter = 0;

  final _filters = ['All', '1D', '2-3D', '4-7D', '7D+'];

  List<Map<String, dynamic>> _tours = [];
  List<Map<String, dynamic>> _allTours = [];

  double _minPrice = 0;
  double _maxPrice = 1000;
  String _sortBy = 'rating';

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
      duration: const Duration(milliseconds: 700),
    );
    _loadTours();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _listAnimController.dispose();
    super.dispose();
  }

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
                      fontWeight: FontWeight.bold,
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
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.bgCard.withValues(alpha: 0.4),
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Reset',
                        style: TextStyle(color: AppColors.gold, fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
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
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.borderGold.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '\$${tempMin.toInt()} — \$${tempMax.toInt()}',
                      style: const TextStyle(
                        color: AppColors.borderGold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              SliderTheme(
                data: SliderThemeData(
                  activeTrackColor: AppColors.borderGold,
                  inactiveTrackColor: Colors.white10,
                  thumbColor: AppColors.gold,
                  overlayColor: AppColors.gold.withValues(alpha: 0.1),
                  trackHeight: 2,
                ),
                child: RangeSlider(
                  values: RangeValues(tempMin, tempMax),
                  min: 0,
                  max: 1000,
                  divisions: 100,
                  onChanged: (v) => setSheet(() {
                    tempMin = v.start;
                    tempMax = v.end;
                  }),
                ),
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.gold
              : Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive
                ? AppColors.gold
                : Colors.white.withValues(alpha: 0.1),
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

  void _applyFilters() {
    List<Map<String, dynamic>> results = List.from(_allTours);
    results = results.where((t) {
      final price =
          double.tryParse(
            t['price']?.toString().replaceAll(RegExp(r'[^\d.]'), '') ?? '0',
          ) ??
          0;
      return price >= _minPrice && price <= _maxPrice;
    }).toList();

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
    _listAnimController.forward(from: 0);
  }

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
      backgroundColor: AppColors.bgCard,
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

  // ── Header ──────────────────────────────────────────────
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
                'Discover',
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
                    onTap: () => setState(() => _showSearch = !_showSearch),
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
                        color: AppColors.bgCard,
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
                        color: hasFilter ? AppColors.gold : AppColors.gold,
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
                        color: hasFilter ? Colors.black : AppColors.bgInput,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (_showSearch)
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.bgCard,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 20),
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
                                color: Color(0xFFAAAAAA),
                                fontSize: 14,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 16,
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
                                Icons.close_rounded,
                                color: Color(0xFFAAAAAA),
                                size: 18,
                              ),
                            ),
                          ),
                        Container(
                          width: 44,
                          height: 44,
                          margin: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppColors.gold,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.search_rounded,
                            color: AppColors.bgCard,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
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
                    onTap: () {
                      setState(() => _activeFilter = i);
                      _listAnimController.forward(from: 0);
                    },
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

          const SizedBox(height: 20),

          // Results count
          if (!_isLoading)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '${_filtered.length} Tours Found',
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

  // ── List ─────────────────────────────────────────────────
  Widget _buildList() {
    // Featured card (أول تور) + بقية الـ tours
    final featured = _filtered.isNotEmpty ? _filtered.first : null;
    final rest = _filtered.length > 1
        ? _filtered.sublist(1)
        : <Map<String, dynamic>>[];

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      children: [
        // Featured large card
        if (featured != null) ...[
          _buildFeaturedCard(featured),
          const SizedBox(height: 28),
        ],

        // "Top Destination" section
        if (rest.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Top Destination',
                style: TextStyle(
                  color: AppColors.gold,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: const Text(
                  'See all',
                  style: TextStyle(color: Color(0xFF888888), fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...rest.asMap().entries.map((entry) {
            final i = entry.key;
            final tour = entry.value;
            final delay = (i * 0.08).clamp(0.0, 0.7);
            final animation = CurvedAnimation(
              parent: _listAnimController,
              curve: Interval(
                delay,
                (delay + 0.4).clamp(0.0, 1.0),
                curve: Curves.easeOutCubic,
              ),
            );
            return AnimatedBuilder(
              animation: animation,
              builder: (ctx, child) => Opacity(
                opacity: animation.value,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - animation.value)),
                  child: child,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _buildDestinationCard(tour),
              ),
            );
          }),
        ],
      ],
    );
  }

  // ── Featured Card (كبير) ──────────────────────────────────
  Widget _buildFeaturedCard(Map<String, dynamic> tour) {
    final img = tour['img']?.toString() ?? '';
    final isNetwork = tour['isNetwork'] == true;

    return GestureDetector(
      onTap: () =>
          Navigator.pushNamed(context, '/tour-details', arguments: tour),
      child: Container(
        height: 260,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Image
              isNetwork
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

              // Gradient overlay
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.7),
                      ],
                      stops: const [0.4, 1.0],
                    ),
                  ),
                ),
              ),

              // Duration badge — top left
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.schedule_rounded,
                        color: Colors.white,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${tour['days']}D Tour',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Rating — top right
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.gold,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: Colors.black,
                        size: 13,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        tour['rating']?.toString() ?? '0',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom info
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              tour['name']?.toString() ?? '',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on_rounded,
                                  color: AppColors.gold,
                                  size: 13,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  tour['loc']?.toString() ?? '',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            tour['price']?.toString() ?? '',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            'per person',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Destination Card (صغير) ──────────────────────────────
  Widget _buildDestinationCard(Map<String, dynamic> tour) {
    final img = tour['img']?.toString() ?? '';
    final isNetwork = tour['isNetwork'] == true;

    return GestureDetector(
      onTap: () =>
          Navigator.pushNamed(context, '/tour-details', arguments: tour),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(20),
              ),
              child: SizedBox(
                width: 90,
                height: 90,
                child: isNetwork
                    ? Image.network(
                        img,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _placeholderSmall(),
                      )
                    : Image.asset(
                        img,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _placeholderSmall(),
                      ),
              ),
            ),

            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tour['name']?.toString() ?? '',
                      style: const TextStyle(
                        color: AppColors.gold,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          color: AppColors.gold,
                          size: 12,
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            tour['loc']?.toString() ?? '',
                            style: const TextStyle(
                              color: Color(0xFF888888),
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Duration
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.bgInput,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${tour['days']}D',
                            style: const TextStyle(
                              color: Color(0xFF555555),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        // Rating
                        Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              color: AppColors.gold,
                              size: 13,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              tour['rating']?.toString() ?? '0',
                              style: const TextStyle(
                                color: AppColors.gold,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        // Price
                        Text(
                          tour['price']?.toString() ?? '',
                          style: const TextStyle(
                            color: AppColors.gold,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Arrow
            Padding(
              padding: const EdgeInsets.only(right: 14),
              child: Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: AppColors.gold,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  color: AppColors.bgCard,
                  size: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Skeleton ─────────────────────────────────────────────
  Widget _buildSkeletonList() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      children: [
        _SkeletonBox(height: 260, borderRadius: 28),
        const SizedBox(height: 28),
        ...List.generate(
          3,
          (i) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _SkeletonBox(height: 90, borderRadius: 20),
          ),
        ),
      ],
    );
  }

  // ── Empty ─────────────────────────────────────────────────
  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_off_rounded,
              color: AppColors.gold,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No tours found',
            style: TextStyle(
              color: AppColors.gold,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Try adjusting your filters',
            style: TextStyle(color: Color(0xFF888888), fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _placeholder() => Container(
    color: const Color(0xFFE0DDD5),
    child: const Center(
      child: Icon(Icons.image, color: AppColors.gold, size: 40),
    ),
  );

  Widget _placeholderSmall() => Container(
    color: const Color(0xFFE0DDD5),
    child: const Center(
      child: Icon(Icons.image, color: AppColors.gold, size: 24),
    ),
  );
}

// ══════════════════════════════════════
// SKELETON BOX
// ══════════════════════════════════════

class _SkeletonBox extends StatefulWidget {
  final double height;
  final double borderRadius;
  const _SkeletonBox({required this.height, required this.borderRadius});

  @override
  State<_SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<_SkeletonBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    _anim = Tween<double>(
      begin: -1.5,
      end: 1.5,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: const [
              Color(0xFFE8E5DE),
              Color(0xFFF0EDE6),
              Color(0xFFE8E5DE),
            ],
            stops: [
              (_anim.value - 0.3).clamp(0.0, 1.0),
              (_anim.value).clamp(0.0, 1.0),
              (_anim.value + 0.3).clamp(0.0, 1.0),
            ],
          ),
        ),
      ),
    );
  }
}
