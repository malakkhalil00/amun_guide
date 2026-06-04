import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_assets.dart';
import '../../core/services/dio_client.dart';
import '../../core/services/tours_service.dart';
import '../../core/services/places_service.dart';
import '../../core/services/tour_booking_service.dart';
import '../../core/widgets/animated_page_wrapper.dart';
import '../../core/widgets/app_skeleton.dart';

// ════════════════════════════════════════════════════════════════
// DASHBOARD SCREEN — Amun Guide
// Full tourism-discovery redesign. All APIs & business logic
// preserved from original. Only the UI layer is rewritten.
// ════════════════════════════════════════════════════════════════

class DashboardScreen extends StatefulWidget {
  final VoidCallback? onExplore;
  final VoidCallback? onTours;

  const DashboardScreen({super.key, this.onExplore, this.onTours});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  // ── User ────────────────────────────────────────────────────
  String _userName = 'Explorer';
  String _userImage = '';
  int _points = 0;

  // ── Tours ───────────────────────────────────────────────────
  List<Map<String, dynamic>> _tours = [];
  bool _isLoadingTours = true;

  // ── Places ──────────────────────────────────────────────────
  List<Map<String, dynamic>> _places = [];
  bool _isLoadingPlaces = true;

  // ── Upcoming Trip ───────────────────────────────────────────
  Map<String, dynamic>? _upcomingTrip;
  bool _isLoadingTrip = true;

  // ── Search ──────────────────────────────────────────────────
  final _searchController = TextEditingController();
  bool _isSearching = false;
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoadingSearch = false;

  // ── Category filter ─────────────────────────────────────────
  int _activeCat = 0;

  // ── Services ────────────────────────────────────────────────
  final _toursService = ToursService();
  final _placesService = PlacesService();
  final _bookingService = TourBookingService();

  // ── Animation ───────────────────────────────────────────────
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  // ────────────────────────────────────────────────────────────
  // LIFECYCLE
  // ────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();

    _loadUserData();
    _loadTours();
    _loadPlaces();
    _loadUpcomingTrip();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  // ────────────────────────────────────────────────────────────
  // DATA LOADING  — unchanged from original
  // ────────────────────────────────────────────────────────────

  Future<void> _loadUserData() async {
    final data = await DioClient.getUserData();
    if (mounted) {
      setState(() {
        _userName = data['name']?.toString().split(' ').first ?? 'Explorer';
        _userImage = data['profile_image'] ?? '';
        _points = data['points'] ?? 0;
      });
    }
  }

  Future<void> _loadTours() async {
    try {
      final response = await _toursService.getAllTours();
      final data = response.data;
      final List items = data['data'] ?? data ?? [];
      if (mounted) {
        setState(() {
          final images = [
            AppAssets.pyramids, AppAssets.karnak,
            AppAssets.abuSimbel, AppAssets.alexandria, AppAssets.philae,
          ];
          _tours = items.take(5).toList().asMap().entries
              .map<Map<String, dynamic>>((entry) {
            final i = entry.key;
            final t = entry.value;
            return {
              'id': t['id'],
              'img': images[i % images.length],
              'isNetwork': false,
              'name': t['title'] ?? t['name'] ?? '',
              'loc': t['location'] ?? '',
              'rating': (t['rating'] ?? 0).toString(),
              'price': '\$${t['price'] ?? 0}/pax',
              'tag': '${t['duration_days'] ?? 1}D',
            };
          }).toList();
        });
      }
    } catch (e) {
      debugPrint('Error loading tours: $e');
    } finally {
      if (mounted) setState(() => _isLoadingTours = false);
    }
  }

  Future<void> _loadPlaces() async {
    try {
      final response = await _placesService.getTrendingPlaces();
      final data = response.data;
      final List items = data['data'] ?? data ?? [];
      if (mounted) {
        setState(() {
          final images = [
            AppAssets.siwa, AppAssets.nileSunset, AppAssets.valley,
          ];
          _places = items.take(6).toList().asMap().entries
              .map<Map<String, dynamic>>((entry) {
            final i = entry.key;
            final p = entry.value;
            return {
              'id': p['id'],
              'img': images[i % images.length],
              'isNetwork': false,
              'name': p['title'] ?? p['name'] ?? '',
              'loc': p['location'] ?? '',
              'rating': (p['rating'] ?? 0).toString(),
              'price': '\$${p['ticket_price'] ?? 0}',
            };
          }).toList();
        });
      }
    } catch (e) {
      debugPrint('Error loading places: $e');
    } finally {
      if (mounted) setState(() => _isLoadingPlaces = false);
    }
  }

  Future<void> _loadUpcomingTrip() async {
    try {
      final response = await _bookingService.getMyBookings();
      final data = response.data;
      final List items = data['data'] ?? data ?? [];
      final upcoming = items.firstWhere(
        (b) => b['status'] != 'rejected' && b['status'] != 'cancelled',
        orElse: () => null,
      );
      if (upcoming != null) {
        final tour = upcoming['tour'] ?? {};
        if (mounted) {
          setState(() {
            _upcomingTrip = {
              'id': upcoming['id'],
              'date': upcoming['booking_date'] ??
                  upcoming['created_at']?.split('T').first ?? 'Upcoming',
              'tour_name': tour['title'] ?? tour['name'] ?? 'Tour',
              'status': upcoming['status'] ?? 'pending',
            };
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading upcoming trip: $e');
    } finally {
      if (mounted) setState(() => _isLoadingTrip = false);
    }
  }

  // ────────────────────────────────────────────────────────────
  // SEARCH — unchanged from original
  // ────────────────────────────────────────────────────────────

  Future<void> _doSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _isSearching = false;
        _searchResults = [];
      });
      return;
    }
    setState(() {
      _isSearching = true;
      _isLoadingSearch = true;
    });
    try {
      final toursResponse = await _toursService.searchTours(query);
      final List tourItems =
          toursResponse.data['data'] ?? toursResponse.data ?? [];
      final placesResponse = await _placesService.searchPlaces(query);
      final List placeItems =
          placesResponse.data['data'] ?? placesResponse.data ?? [];

      final allImages = [
        AppAssets.pyramids, AppAssets.karnak, AppAssets.abuSimbel,
        AppAssets.alexandria, AppAssets.philae, AppAssets.siwa,
        AppAssets.nileSunset, AppAssets.valley,
      ];
      final results = <Map<String, dynamic>>[];

      for (int i = 0; i < tourItems.length; i++) {
        final t = tourItems[i];
        results.add({
          'type': 'tour',
          'id': t['id'],
          'img': allImages[i % allImages.length],
          'name': t['title'] ?? t['name'] ?? '',
          'loc': t['location'] ?? 'Egypt',
          'rating': (t['rating'] ?? 0).toString(),
          'price': '\$${t['price'] ?? 0}/pax',
          'tag': '${t['duration_days'] ?? 1}D',
        });
      }
      for (int i = 0; i < placeItems.length; i++) {
        final p = placeItems[i];
        results.add({
          'type': 'place',
          'id': p['id'],
          'img': allImages[(tourItems.length + i) % allImages.length],
          'name': p['title'] ?? p['name'] ?? '',
          'loc': p['location'] ?? 'Egypt',
          'rating': (p['rating'] ?? 0).toString(),
          'price': '\$${p['ticket_price'] ?? 0}',
          'cat': p['category'] ?? 'Temples',
        });
      }
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isLoadingSearch = false;
        });
      }
    } catch (e) {
      debugPrint('Search error: $e');
      if (mounted) setState(() => _isLoadingSearch = false);
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _isSearching = false;
      _searchResults = [];
    });
  }

  // ════════════════════════════════════════════════════════════
  // BUILD
  // ════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: AnimatedPageWrapper(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── Hero Header (always visible) ──────────────
              SliverToBoxAdapter(child: _buildHeroHeader(context)),

              // ── Content ───────────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.only(bottom: 100),
                sliver: _isSearching
                    ? SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                          child: _buildSearchResults(context),
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildListDelegate([
                          // S1: Category chips
                          const SizedBox(height: 20),
                          _buildCategoryChips(),

                          // S2: Featured Destinations (Portrait grid)
                          const SizedBox(height: 28),
                          _buildSectionLabel(
                            'Featured Destinations',
                            actionLabel: 'See all',
                            onAction: widget.onExplore,
                          ),
                          const SizedBox(height: 14),
                          _buildFeaturedDestinations(context),

                          // S3: Popular Tours (Landscape horizontal)
                          const SizedBox(height: 32),
                          _buildSectionLabel(
                            'Popular Tours',
                            actionLabel: 'See all',
                            onAction: widget.onTours,
                          ),
                          const SizedBox(height: 14),
                          _buildPopularTours(context),

                          // S4: Upcoming Booking (Timeline)
                          if (!_isLoadingTrip && _upcomingTrip != null) ...[
                            const SizedBox(height: 32),
                            _buildSectionLabel('Upcoming Trip'),
                            const SizedBox(height: 14),
                            _buildUpcomingTimeline(context),
                          ],

                          // S5: AI Assistant Banner
                          const SizedBox(height: 32),
                          _buildAIBanner(context),

                          // S6: Travel Inspiration (Masonry)
                          const SizedBox(height: 32),
                          _buildSectionLabel(
                            'Travel Inspiration',
                            actionLabel: 'Explore',
                            onAction: widget.onExplore,
                          ),
                          const SizedBox(height: 14),
                          _buildMasonryInspiration(context),

                          const SizedBox(height: 20),
                        ]),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  // S0 — HERO HEADER
  // ════════════════════════════════════════════════════════════

  Widget _buildHeroHeader(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        border: const Border(
          bottom: BorderSide(color: AppColors.border, width: 0.5),
        ),
      ),
      child: Stack(
        children: [
          // Top gold shimmer line
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              height: 2,
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [
                  Colors.transparent,
                  AppColors.gold,
                  Colors.transparent,
                ]),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 58, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Top row: location + points + avatar ──────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Location pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.goldDim,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.borderGold),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.location_on_rounded,
                              color: AppColors.gold, size: 13),
                          SizedBox(width: 4),
                          Text(
                            'Egypt',
                            style: TextStyle(
                              color: AppColors.gold,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Right side: points + avatar
                    Row(
                      children: [
                        if (_points > 0)
                          Container(
                            margin: const EdgeInsets.only(right: 10),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.goldDim,
                              borderRadius: BorderRadius.circular(20),
                              border:
                                  Border.all(color: AppColors.borderGold),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.stars_rounded,
                                    color: AppColors.gold, size: 13),
                                const SizedBox(width: 4),
                                Text('$_points pts',
                                    style: const TextStyle(
                                      color: AppColors.gold,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    )),
                              ],
                            ),
                          ),
                        GestureDetector(
                          onTap: () =>
                              Navigator.pushNamed(context, '/profile'),
                          child: Container(
                            width: 40, height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: AppColors.gold, width: 1.5),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      AppColors.gold.withValues(alpha: 0.2),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: _userImage.isNotEmpty &&
                                      _userImage.startsWith('http')
                                  ? Image.network(_userImage,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          const Icon(Icons.person,
                                              color: Colors.white54))
                                  : Image.asset(AppAssets.sarah,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          const Icon(Icons.person,
                                              color: Colors.white54)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // ── Headline ──────────────────────────────────
                RichText(
                  text: TextSpan(
                    children: [
                      const TextSpan(
                        text: 'Discover your\n',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          height: 1.15,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const TextSpan(
                        text: 'next adventure',
                        style: TextStyle(
                          color: AppColors.gold,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          height: 1.15,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 6),
                Text(
                  'Hello, $_userName 👋  — Where are you headed?',
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 18),

                // ── Search bar ────────────────────────────────
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.bgInput,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: _isSearching
                          ? AppColors.gold
                          : AppColors.border,
                      width: _isSearching ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 14),
                      const Icon(Icons.search_rounded,
                          color: AppColors.gold, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 14),
                          decoration: const InputDecoration(
                            hintText: 'Search places, tours, experiences…',
                            hintStyle: TextStyle(
                                color: Colors.white30, fontSize: 13),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding:
                                EdgeInsets.symmetric(vertical: 15),
                          ),
                          onChanged: _doSearch,
                          onTapOutside: (_) =>
                              FocusScope.of(context).unfocus(),
                        ),
                      ),
                      if (_isSearching)
                        GestureDetector(
                          onTap: _clearSearch,
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            width: 28, height: 28,
                            decoration: BoxDecoration(
                              color: AppColors.bgCard,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.border),
                            ),
                            child: const Icon(Icons.close_rounded,
                                color: Colors.white54, size: 14),
                          ),
                        )
                      else
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.gold,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.tune_rounded,
                              color: Colors.black, size: 18),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  // SECTION LABEL HELPER
  // ════════════════════════════════════════════════════════════

  Widget _buildSectionLabel(
    String title, {
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.3,
            ),
          ),
          if (actionLabel != null && onAction != null)
            GestureDetector(
              onTap: onAction,
              child: Row(
                children: [
                  Text(
                    actionLabel,
                    style: const TextStyle(
                      color: AppColors.gold,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 3),
                  const Icon(Icons.arrow_forward_ios_rounded,
                      color: AppColors.gold, size: 11),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  // S1 — CATEGORY CHIPS
  // ════════════════════════════════════════════════════════════

  Widget _buildCategoryChips() {
    final cats = [
      {'emoji': '🏛', 'label': 'Temples', 'query': 'temple'},
      {'emoji': '🏖', 'label': 'Beaches', 'query': 'beach'},
      {'emoji': '🏜', 'label': 'Desert', 'query': 'desert'},
      {'emoji': '🕌', 'label': 'Museums', 'query': 'museum'},
      {'emoji': '🌊', 'label': 'Nile', 'query': 'nile'},
      {'emoji': '🏔', 'label': 'Mountains', 'query': 'mountain'},
    ];

    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: cats.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final active = _activeCat == i;
          return GestureDetector(
            onTap: () {
              setState(() => _activeCat = i);
              _searchController.text = cats[i]['query']!;
              _doSearch(cats[i]['query']!);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
              decoration: BoxDecoration(
                color: active ? AppColors.gold : AppColors.bgCard,
                borderRadius: BorderRadius.circular(21),
                border: Border.all(
                  color: active ? AppColors.gold : AppColors.border,
                  width: active ? 0 : 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(cats[i]['emoji']!,
                      style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 6),
                  Text(
                    cats[i]['label']!,
                    style: TextStyle(
                      color: active ? Colors.black : Colors.white70,
                      fontSize: 13,
                      fontWeight: active
                          ? FontWeight.bold
                          : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  // S2 — FEATURED DESTINATIONS  (Portrait Cards — 2 col grid)
  // ════════════════════════════════════════════════════════════

  Widget _buildFeaturedDestinations(BuildContext context) {
    if (_isLoadingPlaces) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.72,
          ),
          itemCount: 4,
          itemBuilder: (_, __) => const SkeletonPlaceCard(),
        ),
      );
    }

    if (_places.isEmpty) {
      return const _EmptyState(message: 'No destinations found');
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.72,
        ),
        itemCount: _places.length,
        itemBuilder: (_, i) => _PortraitPlaceCard(
          place: _places[i],
          onTap: () => Navigator.pushNamed(
            context, '/place-details',
            arguments: _places[i],
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  // S3 — POPULAR TOURS  (Landscape Cards — horizontal scroll)
  // ════════════════════════════════════════════════════════════

  Widget _buildPopularTours(BuildContext context) {
    if (_isLoadingTours) {
      return SizedBox(
        height: 175,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: 3,
          separatorBuilder: (_, __) => const SizedBox(width: 14),
          itemBuilder: (_, __) => const SkeletonTourCard(),
        ),
      );
    }

    if (_tours.isEmpty) {
      return const _EmptyState(message: 'No popular tours found');
    }

    return SizedBox(
      height: 175,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _tours.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (_, i) => _LandscapeTourCard(
          tour: _tours[i],
          onTap: () => Navigator.pushNamed(
            context, '/tour-details',
            arguments: _tours[i],
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  // S4 — UPCOMING TRIP  (Timeline style)
  // ════════════════════════════════════════════════════════════

  Widget _buildUpcomingTimeline(BuildContext context) {
    final trip = _upcomingTrip!;
    final status = (trip['status'] as String).toUpperCase();
    final statusColor = status == 'APPROVED'
        ? const Color(0xFF4CAF50)
        : status == 'PENDING'
            ? AppColors.gold
            : Colors.orange;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () =>
            Navigator.pushNamed(context, '/tour-details', arguments: trip),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Timeline axis ─────────────────────────────
            Column(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.goldDim,
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: AppColors.borderGold, width: 1.5),
                  ),
                  child: const Icon(Icons.flight_takeoff_rounded,
                      color: AppColors.gold, size: 20),
                ),
                Container(
                  width: 1.5,
                  height: 60,
                  color: AppColors.borderGold,
                ),
                Container(
                  width: 8, height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.gold,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),

            const SizedBox(width: 14),

            // ── Trip card ─────────────────────────────────
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.borderGold),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.bgCard,
                      AppColors.gold.withValues(alpha: 0.06),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status + ID
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: statusColor.withValues(alpha: 0.35)),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'AMG-${trip['id']}',
                          style: const TextStyle(
                            color: AppColors.gold,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Tour name
                    Text(
                      trip['tour_name'] ?? '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.2,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Date row
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined,
                            color: Colors.white38, size: 12),
                        const SizedBox(width: 5),
                        Text(
                          trip['date'] ?? '',
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 12,
                          ),
                        ),
                        const Spacer(),
                        const Icon(Icons.arrow_forward_ios_rounded,
                            color: AppColors.gold, size: 12),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  // S5 — AI ASSISTANT BANNER  (Full-width premium card)
  // ════════════════════════════════════════════════════════════

  Widget _buildAIBanner(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, '/ai-chat'),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1A1035), Color(0xFF0F0F1E)],
            ),
            border: Border.all(
              color: const Color(0xFF6C47FF).withValues(alpha: 0.45),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Icon block ────────────────────────────────
              Container(
                width: 60, height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF6C47FF), Color(0xFF9B59B6)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6C47FF).withValues(alpha: 0.4),
                      blurRadius: 16,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: const Icon(Icons.auto_awesome_rounded,
                    color: Colors.white, size: 28),
              ),

              const SizedBox(width: 16),

              // ── Text block ────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'AI Travel Assistant',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 7),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6C47FF)
                                .withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              color: const Color(0xFF6C47FF)
                                  .withValues(alpha: 0.5),
                            ),
                          ),
                          child: const Text(
                            'AI',
                            style: TextStyle(
                              color: Color(0xFF9B8FFF),
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Ask anything about Egypt,\ntours & ancient history.',
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              // ── CTA arrow ─────────────────────────────────
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF6C47FF).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color:
                        const Color(0xFF6C47FF).withValues(alpha: 0.4),
                  ),
                ),
                child: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Color(0xFF9B8FFF),
                  size: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  // S6 — TRAVEL INSPIRATION  (Masonry 2-col variable heights)
  // ════════════════════════════════════════════════════════════

  Widget _buildMasonryInspiration(BuildContext context) {
    // Static inspiration items — mixed places + tours data
    // Heights alternate to create masonry feel
    final List<_InspirationItem> items = [
      _InspirationItem(
        img: AppAssets.pyramids, tag: 'Wonders',
        name: 'Great Pyramids', height: 200,
      ),
      _InspirationItem(
        img: AppAssets.siwa, tag: 'Adventure',
        name: 'Siwa Oasis', height: 150,
      ),
      _InspirationItem(
        img: AppAssets.nileSunset, tag: 'Scenic',
        name: 'Nile at Sunset', height: 155,
      ),
      _InspirationItem(
        img: AppAssets.karnak, tag: 'History',
        name: 'Karnak Temple', height: 210,
      ),
      _InspirationItem(
        img: AppAssets.abuSimbel, tag: 'Culture',
        name: 'Abu Simbel', height: 170,
      ),
      _InspirationItem(
        img: AppAssets.valley, tag: 'Mystery',
        name: 'Valley of Kings', height: 160,
      ),
    ];

    // Split into two columns
    final leftCol = <_InspirationItem>[];
    final rightCol = <_InspirationItem>[];
    for (int i = 0; i < items.length; i++) {
      if (i.isEven) {
        leftCol.add(items[i]);
      } else {
        rightCol.add(items[i]);
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left column
          Expanded(
            child: Column(
              children: leftCol
                  .map((item) => _MasonryCard(
                        item: item,
                        onTap: () {
                          _searchController.text = item.tag.toLowerCase();
                          _doSearch(item.tag.toLowerCase());
                        },
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(width: 12),
          // Right column — offset start for Pinterest feel
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 50),
              child: Column(
                children: rightCol
                    .map((item) => _MasonryCard(
                          item: item,
                          onTap: () {
                            _searchController.text =
                                item.tag.toLowerCase();
                            _doSearch(item.tag.toLowerCase());
                          },
                        ))
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  // SEARCH RESULTS — preserved from original, UI polished
  // ════════════════════════════════════════════════════════════

  Widget _buildSearchResults(BuildContext context) {
    if (_isLoadingSearch) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: CircularProgressIndicator(color: AppColors.gold),
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return SizedBox(
        height: 240,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border),
                ),
                child: const Icon(Icons.search_off_rounded,
                    color: Colors.white24, size: 30),
              ),
              const SizedBox(height: 14),
              const Text('No results found',
                  style: TextStyle(
                      color: Colors.white38, fontSize: 15)),
              const SizedBox(height: 4),
              const Text('Try a different keyword',
                  style:
                      TextStyle(color: Colors.white24, fontSize: 12)),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${_searchResults.length} results for '
          '"${_searchController.text}"',
          style: const TextStyle(color: Colors.white38, fontSize: 13),
        ),
        const SizedBox(height: 14),
        ..._searchResults.map((item) {
          final isTour = item['type'] == 'tour';
          return GestureDetector(
            onTap: () => Navigator.pushNamed(
              context,
              isTour ? '/tour-details' : '/place-details',
              arguments: item,
            ),
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 70, height: 70,
                      child: Image.asset(
                        item['img']?.toString() ??
                            AppAssets.pyramids,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            Container(color: AppColors.bgInput),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: isTour
                                ? AppColors.goldDim
                                : Colors.teal
                                    .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isTour ? 'Tour' : 'Place',
                            style: TextStyle(
                              color: isTour
                                  ? AppColors.gold
                                  : Colors.teal,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(item['name'] ?? '',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 3),
                        Text(item['loc'] ?? '',
                            style: const TextStyle(
                                color: Colors.white38,
                                fontSize: 11)),
                      ],
                    ),
                  ),
                  Text(
                    item['price'] ?? '',
                    style: const TextStyle(
                      color: AppColors.gold,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════
// PORTRAIT PLACE CARD  (Section 2 — Featured Destinations)
// Tall, full-bleed, gradient overlay, bookmark icon
// ════════════════════════════════════════════════════════════════

class _PortraitPlaceCard extends StatelessWidget {
  final Map<String, dynamic> place;
  final VoidCallback onTap;

  const _PortraitPlaceCard({required this.place, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ── Photo ──────────────────────────────────────
            Image.asset(
              place['img'] ?? AppAssets.pyramids,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  Container(color: AppColors.bgCard),
            ),

            // ── Gradient overlay ───────────────────────────
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black87],
                  stops: [0.45, 1.0],
                ),
              ),
            ),

            // ── Bookmark icon (top-right) ──────────────────
            Positioned(
              top: 10, right: 10,
              child: Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.4),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.bookmark_outline_rounded,
                    color: Colors.white70, size: 16),
              ),
            ),

            // ── Rating badge (top-left) ────────────────────
            Positioned(
              top: 10, left: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star_rounded,
                        color: AppColors.gold, size: 11),
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
            ),

            // ── Bottom text ────────────────────────────────
            Positioned(
              bottom: 12, left: 12, right: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place['name'] ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded,
                          color: AppColors.gold, size: 11),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// LANDSCAPE TOUR CARD  (Section 3 — Popular Tours)
// Wide, short, full-bleed, tour name + price + duration + rating
// ════════════════════════════════════════════════════════════════

class _LandscapeTourCard extends StatelessWidget {
  final Map<String, dynamic> tour;
  final VoidCallback onTap;

  const _LandscapeTourCard({required this.tour, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 270,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // ── Photo ────────────────────────────────────
              Image.asset(
                tour['img'] ?? AppAssets.pyramids,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Container(color: AppColors.bgCard),
              ),

              // ── Gradient overlay ─────────────────────────
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.transparent],
                    stops: [0.3, 1.0],
                  ),
                ),
              ),

              // ── Duration tag (top-left) ───────────────────
              Positioned(
                top: 10, left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 9, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.gold,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    tour['tag'] ?? '',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              // ── Rating badge (top-right) ───────────────────
              Positioned(
                top: 10, right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          color: AppColors.gold, size: 11),
                      const SizedBox(width: 3),
                      Text(
                        tour['rating'] ?? '0',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Bottom: name + price ──────────────────────
              Positioned(
                bottom: 12, left: 12, right: 12,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tour['name'] ?? '',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              const Icon(Icons.location_on_rounded,
                                  color: AppColors.gold, size: 11),
                              const SizedBox(width: 3),
                              Expanded(
                                child: Text(
                                  tour['loc'] ?? '',
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
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.gold,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        tour['price'] ?? '',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// MASONRY CARD  (Section 6 — Travel Inspiration)
// Variable height, full-bleed photo, tag chip overlay
// ════════════════════════════════════════════════════════════════

class _InspirationItem {
  final String img;
  final String tag;
  final String name;
  final double height;
  const _InspirationItem({
    required this.img,
    required this.tag,
    required this.name,
    required this.height,
  });
}

class _MasonryCard extends StatelessWidget {
  final _InspirationItem item;
  final VoidCallback onTap;

  const _MasonryCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: item.height,
        margin: const EdgeInsets.only(bottom: 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // ── Photo ──────────────────────────────────
              Image.asset(
                item.img,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Container(color: AppColors.bgCard),
              ),

              // ── Subtle overlay ─────────────────────────
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.65),
                    ],
                    stops: const [0.5, 1.0],
                  ),
                ),
              ),

              // ── Tag chip (top-left) ────────────────────
              Positioned(
                top: 10, left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.15)),
                  ),
                  child: Text(
                    item.tag,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              // ── Name (bottom) ──────────────────────────
              Positioned(
                bottom: 10, left: 10, right: 10,
                child: Text(
                  item.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.2,
                    shadows: [
                      Shadow(
                        color: Colors.black54,
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// EMPTY STATE HELPER
// ════════════════════════════════════════════════════════════════

class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: Center(
        child: Text(
          message,
          style: const TextStyle(color: Colors.white38, fontSize: 13),
        ),
      ),
    );
  }
}