// 📁 lib/screens/tourist/dashboard_screen.dart

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_assets.dart';
import '../../core/services/dio_client.dart';
import '../../core/services/tours_service.dart';
import '../../core/services/places_service.dart';
import '../../core/services/tour_booking_service.dart';
import '../../core/widgets/tour_card.dart';
import '../../core/widgets/place_card.dart';
import '../../core/widgets/hotel_card.dart';
import '../../core/widgets/section_header.dart';

class DashboardScreen extends StatefulWidget {
  final VoidCallback? onExplore;
  final VoidCallback? onTours;

  const DashboardScreen({super.key, this.onExplore, this.onTours});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _userName = 'Explorer';
  String _userImage = '';
  int _points = 0;

  List<Map<String, dynamic>> _tours = [];
  bool _isLoadingTours = true;

  List<Map<String, dynamic>> _places = [];
  bool _isLoadingPlaces = true;

  Map<String, dynamic>? _upcomingTrip;
  bool _isLoadingTrip = true;

  // Search
  final _searchController = TextEditingController();
  bool _isSearching = false;
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoadingSearch = false;

  final _toursService = ToursService();
  final _placesService = PlacesService();
  final _bookingService = TourBookingService();

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadTours();
    _loadPlaces();
    _loadUpcomingTrip();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
            AppAssets.pyramids,
            AppAssets.karnak,
            AppAssets.abuSimbel,
            AppAssets.alexandria,
            AppAssets.philae,
          ];
          _tours = items.take(5).toList().asMap().entries.map<Map<String, dynamic>>((entry) {
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
            AppAssets.siwa,
            AppAssets.nileSunset,
            AppAssets.valley,
          ];
          _places = items.take(3).toList().asMap().entries.map<Map<String, dynamic>>((entry) {
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

  // ══════════════════════════════════════
  // SEARCH
  // ══════════════════════════════════════

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
      // Search tours
      final toursResponse = await _toursService.searchTours(query);
      final toursData = toursResponse.data;
      final List tourItems = toursData['data'] ?? toursData ?? [];

      // Search places
      final placesResponse = await _placesService.searchPlaces(query);
      final placesData = placesResponse.data;
      final List placeItems = placesData['data'] ?? placesData ?? [];

      final allImages = [
        AppAssets.pyramids, AppAssets.karnak, AppAssets.abuSimbel,
        AppAssets.alexandria, AppAssets.philae, AppAssets.siwa,
        AppAssets.nileSunset, AppAssets.valley, AppAssets.museum,
        AppAssets.luxorNight,
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
          'description': p['description'] ?? '',
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
      // Fallback: filter locally from loaded data
      final q = query.toLowerCase();
      final localResults = <Map<String, dynamic>>[];

      for (final t in _tours) {
        if ((t['name'] ?? '').toLowerCase().contains(q) ||
            (t['loc'] ?? '').toLowerCase().contains(q)) {
          localResults.add({...t, 'type': 'tour'});
        }
      }
      for (final p in _places) {
        if ((p['name'] ?? '').toLowerCase().contains(q) ||
            (p['loc'] ?? '').toLowerCase().contains(q)) {
          localResults.add({...p, 'type': 'place'});
        }
      }

      if (mounted) {
        setState(() {
          _searchResults = localResults;
          _isLoadingSearch = false;
        });
      }
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _isSearching = false;
      _searchResults = [];
    });
  }

  // ══════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(context)),
          if (_isSearching)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
              sliver: SliverToBoxAdapter(child: _buildSearchResults(context)),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 20),
                  _buildUpcomingTrip(),
                  if (_upcomingTrip != null) const SizedBox(height: 28),
                  _buildCategories(context),
                  const SizedBox(height: 28),
                  SectionHeader(
                    title: 'Popular Tours',
                    actionLabel: 'See all',
                    onAction: widget.onTours,
                  ),
                  const SizedBox(height: 14),
                  _buildToursRow(context),
                  const SizedBox(height: 28),
                  SectionHeader(
                    title: 'Trending Places',
                    actionLabel: 'See all',
                    onAction: widget.onExplore,
                  ),
                  const SizedBox(height: 14),
                  if (_isLoadingPlaces)
                    const Center(
                      child: CircularProgressIndicator(color: AppColors.gold),
                    )
                  else if (_places.isEmpty)
                    const Text(
                      'No trending places found.',
                      style: TextStyle(color: Colors.white54),
                    )
                  else
                    ..._places.map(
                      (place) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: HotelCard(
                          image: place['img'] ?? '',
                          name: place['name'] ?? '',
                          location: place['loc'] ?? '',
                          stars: double.tryParse(place['rating'] ?? '0')?.toInt() ?? 5,
                          price: place['price'] ?? '',
                          onTap: () => Navigator.pushNamed(
                            context,
                            '/place-details',
                            arguments: place,
                          ),
                        ),
                      ),
                    ),
                ]),
              ),
            ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════
  // HEADER + SEARCH BAR
  // ══════════════════════════════════════

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
      decoration: const BoxDecoration(
        color: Color(0xFF1E1A16),
        border: Border(bottom: BorderSide(color: Colors.white10)),
      ),
      child: Column(
        children: [
          // Top row: greeting + avatar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hi, $_userName! 👋',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (_points > 0) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.stars, color: AppColors.gold, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '$_points points',
                          style: const TextStyle(color: AppColors.gold, fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/profile'),
                child: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.gold, width: 2),
                  ),
                  child: ClipOval(
                    child: _userImage.isNotEmpty && _userImage.startsWith('http')
                        ? Image.network(
                            _userImage,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.person, color: Colors.white54),
                          )
                        : Image.asset(
                            AppAssets.sarah,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.person, color: Colors.white54),
                          ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Search bar — شغال فعلاً
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
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: const InputDecoration(
                      hintText: 'Where to go?',
                      hintStyle: TextStyle(color: Colors.white38, fontSize: 14),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 13),
                    ),
                    onChanged: (v) => _doSearch(v),
                    onTapOutside: (_) => FocusScope.of(context).unfocus(),
                  ),
                ),
                if (_isSearching)
                  GestureDetector(
                    onTap: _clearSearch,
                    child: const Padding(
                      padding: EdgeInsets.only(right: 14),
                      child: Icon(Icons.close, color: Colors.white38, size: 20),
                    ),
                  )
                else
                  const SizedBox(width: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════
  // SEARCH RESULTS
  // ══════════════════════════════════════

  Widget _buildSearchResults(BuildContext context) {
    if (_isLoadingSearch) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator(color: AppColors.gold)),
      );
    }

    if (_searchResults.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, color: Colors.white24, size: 48),
              SizedBox(height: 12),
              Text(
                'No results found',
                style: TextStyle(color: Colors.white38, fontSize: 15),
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
          '${_searchResults.length} results for "${_searchController.text}"',
          style: const TextStyle(color: Colors.white54, fontSize: 13),
        ),
        const SizedBox(height: 16),
        ..._searchResults.map((item) {
          final isTour = item['type'] == 'tour';
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GestureDetector(
              onTap: () => Navigator.pushNamed(
                context,
                isTour ? '/tour-details' : '/place-details',
                arguments: item,
              ),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1A16),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  children: [
                    // Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: SizedBox(
                        width: 72,
                        height: 72,
                        child: Image.asset(
                          item['img']?.toString() ?? AppAssets.pyramids,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: const Color(0xFF2A2520),
                            child: const Icon(Icons.image, color: Colors.white24),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isTour
                                      ? AppColors.gold.withOpacity(0.15)
                                      : Colors.teal.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  isTour ? 'Tour' : 'Place',
                                  style: TextStyle(
                                    color: isTour ? AppColors.gold : Colors.teal,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              if (isTour) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.white10,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    item['tag'] ?? '',
                                    style: const TextStyle(
                                        color: Colors.white54, fontSize: 10),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item['name'] ?? '',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              const Icon(Icons.location_on,
                                  color: Colors.white38, size: 12),
                              const SizedBox(width: 3),
                              Text(
                                item['loc'] ?? '',
                                style: const TextStyle(
                                    color: Colors.white38, fontSize: 11),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.star,
                                      color: AppColors.gold, size: 12),
                                  const SizedBox(width: 3),
                                  Text(
                                    item['rating'] ?? '0',
                                    style: const TextStyle(
                                        color: Colors.white54, fontSize: 11),
                                  ),
                                ],
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
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios,
                        color: Colors.white12, size: 14),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  // ══════════════════════════════════════
  // UPCOMING TRIP
  // ══════════════════════════════════════

  Widget _buildUpcomingTrip() {
    if (_isLoadingTrip) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.gold),
      );
    }
    if (_upcomingTrip == null) return const SizedBox.shrink();

    final status = (_upcomingTrip!['status'] as String).toUpperCase();
    final statusColor = status == 'APPROVED'
        ? Colors.green
        : status == 'PENDING'
            ? AppColors.gold
            : Colors.orange;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.flight_takeoff, color: AppColors.gold, size: 16),
              const SizedBox(width: 8),
              const Text(
                'Upcoming Trip',
                style: TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                    fontWeight: FontWeight.w500),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor.withOpacity(0.3)),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _upcomingTrip!['tour_name'] ?? '',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.calendar_today, color: Colors.white38, size: 13),
              const SizedBox(width: 6),
              Text(
                _upcomingTrip!['date'] ?? '',
                style: const TextStyle(color: Colors.white38, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: Colors.white10),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Booking ID',
                style: TextStyle(color: Colors.white38, fontSize: 12),
              ),
              Text(
                'AMG-${_upcomingTrip!['id']}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════
  // CATEGORIES
  // ══════════════════════════════════════

  Widget _buildCategories(BuildContext context) {
    final cats = [
      {'icon': Icons.account_balance_outlined, 'label': 'Temples', 'query': 'temple'},
      {'icon': Icons.landscape_outlined, 'label': 'Deserts', 'query': 'desert'},
      {'icon': Icons.sailing_outlined, 'label': 'Nile', 'query': 'nile'},
      {'icon': Icons.beach_access_outlined, 'label': 'Beaches', 'query': 'beach'},
      {'icon': Icons.museum_outlined, 'label': 'Museums', 'query': 'museum'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Explore Egypt',
          actionLabel: 'See all',
          onAction: widget.onExplore,
        ),
        const SizedBox(height: 14),
        Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: List.generate(cats.length, (i) {
    final colors = [
      const Color(0xffc5a358), // Temples - أخضر
      const Color(0xffc5a358), // Temples - أخضر
      const Color(0xffc5a358), // Temples - أخضر
      const Color(0xffc5a358), // Temples - أخضر
      const Color(0xffc5a358), // Temples - أخضر
    ];
    return GestureDetector(
      onTap: () {
        _searchController.text = cats[i]['query'] as String;
        _doSearch(cats[i]['query'] as String);
      },
      child: Column(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: colors[i].withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(color: colors[i].withOpacity(0.5), width: 1.5),
            ),
            child: Icon(
              cats[i]['icon'] as IconData,
              color: colors[i],
              size: 24,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            cats[i]['label'] as String,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
        ],
      ),
    );
  }),
),
      ],
    );
  }

  // ══════════════════════════════════════
  // TOURS ROW
  // ══════════════════════════════════════

  Widget _buildToursRow(BuildContext context) {
    if (_isLoadingTours) {
      return const SizedBox(
        height: 210,
        child: Center(child: CircularProgressIndicator(color: Color(0xFFC5A358))),
      );
    }

    if (_tours.isEmpty) {
      return const SizedBox(
        height: 210,
        child: Center(
          child: Text(
            'No popular tours found.',
            style: TextStyle(color: Colors.white54),
          ),
        ),
      );
    }

    return SizedBox(
      height: 210,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _tours.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (_, i) => TourCard(
          image: _tours[i]['img']?.toString() ?? '',
          name: _tours[i]['name']?.toString() ?? '',
          location: _tours[i]['loc']?.toString() ?? '',
          rating: _tours[i]['rating']?.toString() ?? '',
          price: _tours[i]['price']?.toString() ?? '',
          tag: _tours[i]['tag']?.toString() ?? '',
          onTap: () => Navigator.pushNamed(
            context,
            '/tour-details',
            arguments: _tours[i],
          ),
        ),
      ),
    );
  }
}