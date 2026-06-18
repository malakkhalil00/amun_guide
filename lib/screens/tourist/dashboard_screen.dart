import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_assets.dart';
import '../../core/services/dio_client.dart';
import '../../core/services/tours_service.dart';
import '../../core/services/places_service.dart';
import '../../core/services/likes_service.dart';

import '../../core/services/tour_booking_service.dart';
import '../../core/widgets/animated_page_wrapper.dart';
import 'dart:typed_data';
import 'dart:convert';
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

  List<Map<String, dynamic>> _savedPlaces = [];
  bool _isLoadingSaved = true;

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
  final _likesService = LikesService();

  // ── Animation ───────────────────────────────────────────────
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  Uint8List? _userImageBytes;
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
    _loadSavedPlaces();
  }

  @override
  void didUpdateWidget(DashboardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _loadUserData();
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
    print('👤 User data loaded: $data');
    if (mounted) {
      setState(() {
        _userName = data['name']?.toString().split(' ').first ?? 'Explorer';
        _userImage = data['profile_image'] ?? '';
        if (_userImage.startsWith('base64:')) {
          _userImageBytes = base64Decode(_userImage.substring(7));
        }
        _points = data['points'] ?? 0;
      });
    }
  }

  Future<void> _loadSavedPlaces() async {
    try {
      final response = await _likesService.getUserLikes();
      final data = response.data;
      final List items = data['data'] ?? [];
      final placesService = PlacesService();
      final List<Map<String, dynamic>> results = [];
      final images = [AppAssets.siwa, AppAssets.nileSunset, AppAssets.valley];
      for (int i = 0; i < items.length; i++) {
        final like = items[i];
        final int placeId = like['likeable_id'];
        try {
          final placeResponse = await placesService.getPlace(placeId);
          final p = placeResponse.data['data'] ?? placeResponse.data ?? {};
          results.add({
            'id': p['id'] ?? placeId,
            'img': images[i % images.length],
            'name': p['title'] ?? p['name'] ?? 'Saved Item',
            'loc': p['location'] ?? 'Egypt',
            'rating': (p['rating'] ?? 0).toString(),
            'price': '\$${p['ticket_price'] ?? p['price'] ?? 0}',
          });
        } catch (e) {
          debugPrint('Error loading place $placeId: $e');
        }
      }
      if (mounted) setState(() => _savedPlaces = results);
    } catch (e) {
      debugPrint('Error loading saved places: $e');
    } finally {
      if (mounted) setState(() => _isLoadingSaved = false);
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
            AppAssets.pyramids,
            AppAssets.karnak,
            AppAssets.abuSimbel,
            AppAssets.alexandria,
            AppAssets.philae,
          ];
          _tours = items
              .take(5)
              .toList()
              .asMap()
              .entries
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
              })
              .toList();
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
            AppAssets.siwa,
            AppAssets.nileSunset,
            AppAssets.valley,
          ];
          _places = items
              .take(6)
              .toList()
              .asMap()
              .entries
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
              })
              .toList();
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
              'date':
                  upcoming['booking_date'] ??
                  upcoming['created_at']?.split('T').first ??
                  'Upcoming',
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
        AppAssets.pyramids,
        AppAssets.karnak,
        AppAssets.abuSimbel,
        AppAssets.alexandria,
        AppAssets.philae,
        AppAssets.siwa,
        AppAssets.nileSunset,
        AppAssets.valley,
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
                          // Saved Places
                          const SizedBox(height: 20),
                          _buildSavedPlaces(context),

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
    final cats = [
      {'emoji': '🏛', 'label': 'Temples', 'query': 'temple'},
      {'emoji': '🏖', 'label': 'Beaches', 'query': 'beach'},
      {'emoji': '🏜', 'label': 'Desert', 'query': 'desert'},
      {'emoji': '🕌', 'label': 'Museums', 'query': 'museum'},
      {'emoji': '🌊', 'label': 'Nile', 'query': 'nile'},
      {'emoji': '🏔', 'label': 'Mountains', 'query': 'mountain'},
    ];

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bgCard,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 52, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Row 1: Avatar + Greeting + Location + Bell ──
            Row(
              children: [
                // Avatar
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFC5A358),
                        width: 1.5,
                      ),
                    ),
                    child: ClipOval(
                      child: _userImageBytes != null
                          ? Image.memory(_userImageBytes!, fit: BoxFit.cover)
                          : _userImage.isNotEmpty &&
                                _userImage.startsWith('http')
                          ? Image.network(
                              _userImage,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.person,
                                color: Colors.white54,
                              ),
                            )
                          : Image.asset(
                              AppAssets.sarah,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.person,
                                color: Colors.white54,
                              ),
                            ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Greeting + Location
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello, $_userName 👋',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: const [
                          Icon(
                            Icons.location_on_rounded,
                            color: AppColors.gold,
                            size: 12,
                          ),
                          SizedBox(width: 3),
                          Text(
                            'Egypt',
                            style: TextStyle(
                              color: AppColors.gold,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Notification bell
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/notifications'),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.bgInput,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Icon(
                      Icons.notifications_outlined,
                      color: Colors.white70,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ── Search + Chips Card ──────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Recently Booked (جوّا الكارد) ──────────
                  if (_upcomingTrip != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        // color: AppColors.bgInput,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.goldDim,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.history_rounded,
                              color: AppColors.gold,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Recently Booked',
                                  style: TextStyle(
                                    color: Colors.white38,
                                    fontSize: 10,
                                  ),
                                ),
                                Text(
                                  _upcomingTrip!['tour_name'] ?? 'Tour',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () =>
                                Navigator.pushNamed(context, '/my-bookings'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.goldDim,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.borderGold),
                              ),
                              child: const Text(
                                'View',
                                style: TextStyle(
                                  color: AppColors.gold,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],

                  // ── Search bar ──────────────────────────────
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 15,
                    ),
                    decoration: BoxDecoration(
                      // color: AppColors.bgInput,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.search_rounded,
                          color: Colors.white38,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Ask anything...',
                              hintStyle: TextStyle(
                                color: Colors.white30,
                                fontSize: 16,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 10,
                              ),
                            ),
                            onChanged: _doSearch,
                            onTapOutside: (_) =>
                                FocusScope.of(context).unfocus(),
                          ),
                        ),
                        if (_isSearching)
                          GestureDetector(
                            onTap: _clearSearch,
                            child: const Icon(
                              Icons.close_rounded,
                              color: Colors.white54,
                              size: 18,
                            ),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.bgCard,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: const Icon(
                              Icons.tune_rounded,
                              color: AppColors.gold,
                              size: 18,
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // ── Chips ───────────────────────────────────
                  SizedBox(
                    height: 44,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
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
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: active
                                  ? AppColors.gold
                                  : AppColors.bgInput,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: active
                                    ? AppColors.gold
                                    : AppColors.border,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  cats[i]['emoji']!,
                                  style: const TextStyle(fontSize: 13),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  cats[i]['label']!,
                                  style: TextStyle(
                                    color: active
                                        ? Colors.black
                                        : Colors.white70,
                                    fontSize: 12,
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
                  ),

                  const SizedBox(height: 4),
                ],
              ),
            ),
          ],
        ),
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
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: AppColors.gold,
                    size: 11,
                  ),
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
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
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
                  Text(cats[i]['emoji']!, style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 6),
                  Text(
                    cats[i]['label']!,
                    style: TextStyle(
                      color: active ? Colors.black : Colors.white70,
                      fontSize: 13,
                      fontWeight: active ? FontWeight.bold : FontWeight.w500,
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
  Widget _buildSavedPlaces(BuildContext context) {
    if (_savedPlaces.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text(
                    'Saved Places',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    radius: 10,
                    backgroundColor: AppColors.gold,
                    child: Text(
                      '${_savedPlaces.length}',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/saved-places'),
                child: const Row(
                  children: [
                    Text(
                      'See all',
                      style: TextStyle(
                        color: AppColors.gold,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 3),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: AppColors.gold,
                      size: 11,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Horizontal cards
        SizedBox(
          height: 220,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _savedPlaces.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (_, i) {
              final place = _savedPlaces[i];
              return GestureDetector(
                onTap: () => Navigator.pushNamed(
                  context,
                  '/place-details',
                  arguments: place,
                ),
                child: SizedBox(
                  width: 180,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Photo
                        Image.asset(
                          place['img'] ?? AppAssets.pyramids,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              Container(color: AppColors.bgCard),
                        ),

                        // Gradient
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

                        // Top: rating + bookmark
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
                                width: 28,
                                height: 28,
                                decoration: const BoxDecoration(
                                  color: Colors.black45,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.bookmark_rounded,
                                  color: AppColors.gold,
                                  size: 14,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Bottom: name + location + price + book
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
                                  fontSize: 13,
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
                                    size: 10,
                                  ),
                                  const SizedBox(width: 3),
                                  Expanded(
                                    child: Text(
                                      place['loc'] ?? '',
                                      style: const TextStyle(
                                        color: Colors.white60,
                                        fontSize: 10,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Price',
                                        style: TextStyle(
                                          color: Colors.white54,
                                          fontSize: 9,
                                        ),
                                      ),
                                      Text(
                                        place['price'] ?? '',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.gold,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'Book Now',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 10,
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
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedDestinations(BuildContext context) {
    if (_isLoadingPlaces) {
      return SizedBox(
        height: 180,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: 3,
          separatorBuilder: (_, __) => const SizedBox(width: 14),
          itemBuilder: (_, __) => const SkeletonPlaceCard(),
        ),
      );
    }

    if (_places.isEmpty) {
      return const _EmptyState(message: 'No destinations found');
    }

    return SizedBox(
      height: 320,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _places.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (_, i) => _RecommendedPlaceCard(
          place: _places[i],
          onTap: () => Navigator.pushNamed(
            context,
            '/place-details',
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
        height: 100,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: 4,
          separatorBuilder: (_, __) => const SizedBox(width: 16),
          itemBuilder: (_, __) => Column(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border),
                ),
              ),
              const SizedBox(height: 8),
              Container(width: 50, height: 10, color: AppColors.bgCard),
            ],
          ),
        ),
      );
    }

    if (_tours.isEmpty) {
      return const _EmptyState(message: 'No popular tours found');
    }

    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _tours.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (_, i) => GestureDetector(
          onTap: () => Navigator.pushNamed(
            context,
            '/tour-details',
            arguments: _tours[i],
          ),
          child: SizedBox(
            width: 72,
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.borderGold, width: 2),
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      _tours[i]['img'] ?? AppAssets.pyramids,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          Container(color: AppColors.bgCard),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _tours[i]['name'] ?? '',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
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
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.goldDim,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.borderGold, width: 1.5),
                  ),
                  child: const Icon(
                    Icons.flight_takeoff_rounded,
                    color: AppColors.gold,
                    size: 20,
                  ),
                ),
                Container(width: 1.5, height: 60, color: AppColors.borderGold),
                Container(
                  width: 8,
                  height: 8,
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
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: statusColor.withValues(alpha: 0.35),
                            ),
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
                        const Icon(
                          Icons.calendar_today_outlined,
                          color: Colors.white38,
                          size: 12,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          trip['date'] ?? '',
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 12,
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: AppColors.gold,
                          size: 12,
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
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF7C3AED), Color(0xFF4C1D95)],
            ),
          ),
          child: Row(
            children: [
              // ── Robot icon ────────────────────────────────
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.smart_toy_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),

              const SizedBox(width: 14),

              // ── Text ──────────────────────────────────────
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
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'AI',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Ask anything about Egypt & ancient history',
                      style: TextStyle(color: Colors.white60, fontSize: 11),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              // ── CTA Button ────────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Text(
                  'Chat',
                  style: TextStyle(
                    color: AppColors.gold,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
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
        img: AppAssets.pyramids,
        tag: 'Wonders',
        name: 'Great Pyramids',
        height: 200,
      ),
      _InspirationItem(
        img: AppAssets.siwa,
        tag: 'Adventure',
        name: 'Siwa Oasis',
        height: 150,
      ),
      _InspirationItem(
        img: AppAssets.nileSunset,
        tag: 'Scenic',
        name: 'Nile at Sunset',
        height: 155,
      ),
      _InspirationItem(
        img: AppAssets.karnak,
        tag: 'History',
        name: 'Karnak Temple',
        height: 210,
      ),
      _InspirationItem(
        img: AppAssets.abuSimbel,
        tag: 'Culture',
        name: 'Abu Simbel',
        height: 170,
      ),
      _InspirationItem(
        img: AppAssets.valley,
        tag: 'Mystery',
        name: 'Valley of Kings',
        height: 160,
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
                  .map(
                    (item) => _MasonryCard(
                      item: item,
                      onTap: () {
                        _searchController.text = item.tag.toLowerCase();
                        _doSearch(item.tag.toLowerCase());
                      },
                    ),
                  )
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
                    .map(
                      (item) => _MasonryCard(
                        item: item,
                        onTap: () {
                          _searchController.text = item.tag.toLowerCase();
                          _doSearch(item.tag.toLowerCase());
                        },
                      ),
                    )
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
        child: Center(child: CircularProgressIndicator(color: AppColors.gold)),
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
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border),
                ),
                child: const Icon(
                  Icons.search_off_rounded,
                  color: Colors.white24,
                  size: 30,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'No results found',
                style: TextStyle(color: Colors.white38, fontSize: 15),
              ),
              const SizedBox(height: 4),
              const Text(
                'Try a different keyword',
                style: TextStyle(color: Colors.white24, fontSize: 12),
              ),
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
        const SizedBox(height: 10),
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
                      width: 70,
                      height: 70,
                      child: Image.asset(
                        item['img']?.toString() ?? AppAssets.pyramids,
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
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isTour
                                ? AppColors.goldDim
                                : Colors.teal.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isTour ? 'Tour' : 'Place',
                            style: TextStyle(
                              color: isTour ? AppColors.gold : Colors.teal,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          item['name'] ?? '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          item['loc'] ?? '',
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 11,
                          ),
                        ),
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
              errorBuilder: (_, __, ___) => Container(color: AppColors.bgCard),
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
              top: 10,
              right: 10,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.4),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.bookmark_outline_rounded,
                  color: Colors.white70,
                  size: 16,
                ),
              ),
            ),

            // ── Rating badge (top-left) ────────────────────
            Positioned(
              top: 10,
              left: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.45),
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
            ),

            // ── Bottom text ────────────────────────────────
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
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
                top: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
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
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
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
                bottom: 12,
                left: 12,
                right: 12,
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
                              const Icon(
                                Icons.location_on_rounded,
                                color: AppColors.gold,
                                size: 11,
                              ),
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
                        horizontal: 10,
                        vertical: 5,
                      ),
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

// ════════════════════════════════════════════════════════════════
// RECOMMENDED PLACE CARD  (Section 2 — Featured Destinations)
// Wide card: صورة كبيرة + اسم + location + سعر + rating
// ════════════════════════════════════════════════════════════════

class _RecommendedPlaceCard extends StatelessWidget {
  final Map<String, dynamic> place;
  final VoidCallback onTap;

  const _RecommendedPlaceCard({required this.place, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 240,
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── صورة كبيرة فوق ──────────────────────────
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(22),
              ),
              child: SizedBox(
                height: 180,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      place['img'] ?? AppAssets.pyramids,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          Container(color: AppColors.bgInput),
                    ),
                    // Rating badge
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.gold,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              color: Colors.black,
                              size: 11,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              place['rating'] ?? '0',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Info تحت ────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(14),
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
                  const SizedBox(height: 4),
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
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Start from',
                            style: TextStyle(
                              color: Colors.white38,
                              fontSize: 10,
                            ),
                          ),
                          Text(
                            place['price'] ?? '',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.gold,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Book',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 12,
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
  }
}

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
                top: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.15),
                    ),
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
                bottom: 10,
                left: 10,
                right: 10,
                child: Text(
                  item.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.2,
                    shadows: [Shadow(color: Colors.black54, blurRadius: 6)],
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
