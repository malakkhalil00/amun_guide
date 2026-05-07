// 📁 lib/screens/tourist/dashboard_screen.dart

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_assets.dart';
import '../../core/services/dio_client.dart';
import '../../core/services/tours_service.dart';
import '../../core/services/places_service.dart';
import '../../core/services/tour_booking_service.dart';
import '../../core/widgets/tour_card.dart';
import '../../core/widgets/hotel_card.dart';
import '../../core/widgets/section_header.dart';

class DashboardScreen extends StatefulWidget {
  final VoidCallback? onExplore;
  const DashboardScreen({super.key, this.onExplore});

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
      debugPrint('🔴 TOURS RESPONSE: ${response.data}');
      debugPrint('🔴 ITEMS COUNT: ${items.length}');
      if (mounted) {
        setState(() {
          _tours = items
              .take(5)
              .map<Map<String, dynamic>>(
                (t) => {
                  'id': t['id'],
                  'img': t['image'] ?? t['image_url'] ?? '',
                  'name': t['title'] ?? t['name'] ?? '',
                  'loc': t['location'] ?? '',
                  'rating': (t['rating'] ?? 0).toString(),
                  'price': '\$${t['price'] ?? 0}/pax',
                  'tag': '${t['duration_days'] ?? 1}D',
                },
              )
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
          _places = items
              .take(3)
              .map<Map<String, dynamic>>(
                (p) => {
                  'id': p['id'],
                  'img': p['image'] ?? p['image_url'] ?? '',
                  'name': p['title'] ?? p['name'] ?? '',
                  'loc': p['location'] ?? '',
                  'rating': (p['rating'] ?? 0).toString(),
                  'price': '\$${p['ticket_price'] ?? 0}',
                },
              )
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

      // Find the first upcoming/pending/approved booking
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(context)),
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
                  onAction: widget.onExplore,
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
                        stars:
                            double.tryParse(place['rating'] ?? '0')?.toInt() ??
                            5,
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

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
      decoration: const BoxDecoration(
        color: Color(0xFF1E1A16),
        border: Border(bottom: BorderSide(color: Colors.white10)),
      ),
      child: Column(
        children: [
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
                        const Icon(
                          Icons.stars,
                          color: AppColors.gold,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$_points points',
                          style: const TextStyle(
                            color: AppColors.gold,
                            fontSize: 13,
                          ),
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
                    child:
                        _userImage.isNotEmpty && _userImage.startsWith('http')
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
          GestureDetector(
            onTap: widget.onExplore,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              decoration: BoxDecoration(
                color: AppColors.bgInput,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                children: const [
                  Icon(Icons.search, color: Colors.white38, size: 20),
                  SizedBox(width: 10),
                  Text(
                    'Where to go?',
                    style: TextStyle(color: Colors.white38, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingTrip() {
    if (_isLoadingTrip) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.gold),
      );
    }
    if (_upcomingTrip == null) {
      return const SizedBox.shrink(); // Hide if no upcoming trips
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.gold,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  (_upcomingTrip!['status'] as String).toUpperCase(),
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                _upcomingTrip!['date'] ?? '',
                style: const TextStyle(color: Colors.white38, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  _upcomingTrip!['tour_name'] ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategories(BuildContext context) {
    final cats = [
      [Icons.account_balance_outlined, 'Temples'],
      [Icons.landscape_outlined, 'Deserts'],
      [Icons.sailing_outlined, 'Nile'],
      [Icons.beach_access_outlined, 'Beaches'],
      [Icons.museum_outlined, 'Museums'],
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
        SizedBox(
          height: 82,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: cats.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (_, i) => GestureDetector(
              onTap: widget.onExplore,
              child: Column(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.goldDim,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.gold.withOpacity(0.3),
                      ),
                    ),
                    child: Icon(
                      cats[i][0] as IconData,
                      color: AppColors.gold,
                      size: 22,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    cats[i][1] as String,
                    style: const TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildToursRow(BuildContext context) {
    if (_isLoadingTours) {
      return const SizedBox(
        height: 210,
        child: Center(child: CircularProgressIndicator(color: AppColors.gold)),
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
