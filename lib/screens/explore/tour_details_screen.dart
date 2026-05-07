// 📁 lib/screens/explore/tour_details_screen.dart

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/tours_service.dart';
import '../../core/services/tour_booking_service.dart';

class TourDetailsScreen extends StatefulWidget {
  const TourDetailsScreen({super.key});

  @override
  State<TourDetailsScreen> createState() => _TourDetailsScreenState();
}

class _TourDetailsScreenState extends State<TourDetailsScreen> {
  bool _isSaved = false;
  bool _isLoading = true;
  bool _isBooking = false;
  final _toursService = ToursService();
  final _bookingService = TourBookingService();

  // ── Tour data ──────────────────────────────────
  String _title = '';
  String _price = '';
  String _location = '';
  String _description = '';
  String _image = '';
  String _rating = '';
  int _reviewsCount = 0;
  int _tourId = 0;
  int _durationDays = 1;
  Map<String, dynamic> _guide = {};
  List<Map<String, dynamic>> _places = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    // Get route arguments (could be a tour id or a map with basic info)
    final args = ModalRoute.of(context)?.settings.arguments;

    int? tourId;
    if (args is Map<String, dynamic>) {
      // Pre-fill from arguments while fetching
      setState(() {
        _tourId = args['id'] ?? 0;
        _title = args['name']?.toString() ?? args['title']?.toString() ?? '';
        _price = args['price']?.toString() ?? '';
        _location =
            args['loc']?.toString() ?? args['location']?.toString() ?? '';
        _image = args['img']?.toString() ?? args['image']?.toString() ?? '';
        _rating = args['rating']?.toString() ?? '';
      });
      tourId = _tourId;
    } else if (args is int) {
      tourId = args;
    }

    // Fetch full details from API
    if (tourId != null && tourId > 0) {
      try {
        final response = await _toursService.getTour(tourId);
        final data = response.data;
        final tour = data['data'] ?? data;

        if (mounted) {
          setState(() {
            _tourId = tour['id'] ?? tourId;
            _title = tour['title'] ?? tour['name'] ?? _title;
            _price = '\$${tour['price'] ?? tour['ticket_price'] ?? ''}';
            _location = tour['location'] ?? _location;
            _description = tour['description'] ?? '';
            final apiImg = (tour['image'] ?? tour['image_url'] ?? '').toString();
_image = apiImg.isNotEmpty ? apiImg : 'assets/images/pyramids.jpg';
            _rating = (tour['rating'] ?? _rating).toString();
            _reviewsCount =
                tour['reviews_count'] ?? tour['bookings_count'] ?? 0;
            _durationDays = tour['duration_days'] ?? tour['days'] ?? 1;

            // Guide info
            if (tour['guide'] != null) {
              _guide = Map<String, dynamic>.from(tour['guide']);
            }

            // Places included
            if (tour['places'] != null && tour['places'] is List) {
              _places = (tour['places'] as List)
                  .map<Map<String, dynamic>>(
                    (p) => {
                      'id': p['id'],
                      'img': p['image'] ?? p['image_url'] ?? '',
                      'name': p['title'] ?? p['name'] ?? '',
                      'desc': p['description'] ?? '',
                    },
                  )
                  .toList();
            }
          });
        }
      } catch (e) {
        debugPrint('Error loading tour details: $e');
      }
    }

    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _joinTour() async {
    if (_tourId <= 0) {
      Navigator.pushNamed(context, '/payment-success');
      return;
    }

    setState(() => _isBooking = true);
    try {
      await _bookingService.createBooking(
        tourId: _tourId,
        participantsCount: 1,
      );
      if (mounted) {
        Navigator.pushNamed(context, '/payment-success');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Booking failed: ${e.toString().contains('already') ? 'Already booked' : 'Please try again'}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isBooking = false);
    }
  }

  // ── Helper: network or asset image ─────────────
  Widget _buildImage(
    String src, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
  }) {
    final isNetwork = src.startsWith('http');
    final errorWidget = Container(
      color: const Color(0xFF2A1F0E),
      child: const Icon(Icons.image, color: Colors.white24, size: 40),
    );

    return isNetwork
        ? Image.network(
            src,
            fit: fit,
            width: width,
            height: height,
            errorBuilder: (_, __, ___) => errorWidget,
          )
        : Image.asset(
            src,
            fit: fit,
            width: width,
            height: height,
            errorBuilder: (_, __, ___) => errorWidget,
          );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFF1A1208),
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.gold),
        ),
      );
    }

    final ratingNum = double.tryParse(_rating) ?? 0;
    final fullStars = ratingNum.floor();
    final hasHalf = (ratingNum - fullStars) >= 0.3;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1208),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // ── Hero Image ──────────────────────────────────
              SliverAppBar(
                expandedHeight: 260,
                pinned: true,
                backgroundColor: const Color(0xFF1A1208),
                elevation: 0,
                leading: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                ),
                actions: [
                  GestureDetector(
                    onTap: () => setState(() => _isSaved = !_isSaved),
                    child: Container(
                      margin: const EdgeInsets.only(
                        right: 12,
                        top: 8,
                        bottom: 8,
                      ),
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isSaved ? Icons.favorite : Icons.favorite_border,
                        color: _isSaved ? Colors.red : Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: EdgeInsets.zero,
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      _image.isNotEmpty
                          ? _buildImage(_image)
                          : Image.asset(
                              'assets/images/pyramids.jpg',
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: const Color(0xFF2A1F0E),
                                child: const Icon(
                                  Icons.image,
                                  color: Colors.white24,
                                  size: 80,
                                ),
                              ),
                            ),
                      // Gradient
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Color(0xFF1A1208)],
                            stops: [0.4, 1.0],
                          ),
                        ),
                      ),
                      // Premium Badge
                      Positioned(
                        bottom: 16,
                        left: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.gold,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${_durationDays}D Tour',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.verified,
                                color: Colors.black,
                                size: 14,
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Title in AppBar
                      const Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: SafeArea(
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 14),
                              child: Text(
                                'Tour Details',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Content ─────────────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 120),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // ── Title & Price ──────────────────────
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            _title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              _price,
                              style: const TextStyle(
                                color: AppColors.gold,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              'per person',
                              style: TextStyle(
                                color: Colors.white38,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Location
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: AppColors.gold,
                          size: 15,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _location,
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Rating
                    Row(
                      children: [
                        Row(
                          children: List.generate(
                            5,
                            (i) => Icon(
                              i < fullStars
                                  ? Icons.star
                                  : (i == fullStars && hasHalf
                                        ? Icons.star_half
                                        : Icons.star_border),
                              color: AppColors.gold,
                              size: 18,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _rating,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _reviewsCount > 0
                          ? 'Based on $_reviewsCount reviews'
                          : 'No reviews yet',
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 12,
                      ),
                    ),

                    const SizedBox(height: 6),
                    const Divider(color: Colors.white10, height: 30),

                    // ── Your Guide ──────────────────────────
                    if (_guide.isNotEmpty) ...[
                      const Text(
                        'Your Guide',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 14),
                      _buildGuideCard(),
                      const SizedBox(height: 24),
                    ],

                    // ── About the Tour ──────────────────────
                    if (_description.isNotEmpty) ...[
                      const Text(
                        'About the Tour',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _description,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 14,
                          height: 1.7,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // ── Places Included ─────────────────────
                    if (_places.isNotEmpty) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Places Included',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {},
                            child: const Text(
                              'View Map',
                              style: TextStyle(
                                color: AppColors.gold,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      ..._places.map((place) => _buildPlaceItem(place)),
                    ],
                  ]),
                ),
              ),
            ],
          ),

          // ── Bottom Bar ─────────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                20,
                14,
                20,
                MediaQuery.of(context).padding.bottom + 14,
              ),
              decoration: const BoxDecoration(
                color: Color(0xFF1A1208),
                border: Border(top: BorderSide(color: Colors.white10)),
              ),
              child: Row(
                children: [
                  // Upload Receipt
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          Navigator.pushNamed(context, '/payment-receipts'),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: AppColors.gold.withOpacity(0.5),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      icon: const Icon(
                        Icons.upload_file,
                        color: AppColors.gold,
                        size: 18,
                      ),
                      label: const Text(
                        'Upload Receipt',
                        style: TextStyle(
                          color: AppColors.gold,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Join Tour
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isBooking ? null : _joinTour,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 0,
                      ),
                      child: _isBooking
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.black,
                              ),
                            )
                          : const Text(
                              'Join Tour',
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
        ],
      ),
    );
  }

  // ── Guide Card ─────────────────────────────────────────
  Widget _buildGuideCard() {
    final guideName = _guide['name'] ?? 'Certified Egyptologist';
    final guideImage = _guide['profile_image'] ?? _guide['image'] ?? '';
    final guideRating = (_guide['rating'] ?? 5.0).toString();
    final guideBio =
        _guide['bio'] ??
        _guide['description'] ??
        'Expert in New Kingdom history...';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          // Guide avatar
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.gold, width: 2),
            ),
            child: ClipOval(
              child: guideImage.isNotEmpty && guideImage.startsWith('http')
                  ? Image.network(
                      guideImage,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFFE8D5A3),
                        child: const Icon(
                          Icons.person,
                          color: Colors.brown,
                          size: 30,
                        ),
                      ),
                    )
                  : Image.asset(
                      'assets/images/guide_ahmed.jpg',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFFE8D5A3),
                        child: const Icon(
                          Icons.person,
                          color: Colors.brown,
                          size: 30,
                        ),
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 14),
          // Guide info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        guideRating,
                        style: const TextStyle(
                          color: AppColors.gold,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 3),
                      const Icon(Icons.star, color: AppColors.gold, size: 12),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  guideName,
                  style: const TextStyle(
                    color: AppColors.gold,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  guideBio,
                  style: const TextStyle(color: Colors.black54, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.chat_bubble_outline,
              color: Colors.white,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  // ── Place Item ─────────────────────────────────────────
  Widget _buildPlaceItem(Map<String, dynamic> place) {
    final img = place['img']?.toString() ?? '';
    final isNetwork = img.startsWith('http');

    return GestureDetector(
      onTap: () =>
          Navigator.pushNamed(context, '/tour-', arguments: place),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 70,
                height: 70,
                child: isNetwork
                    ? Image.network(
                        img,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: const Color(0xFF2A1F0E),
                          child: const Icon(Icons.image, color: Colors.white24),
                        ),
                      )
                    : Image.asset(
                        img,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: const Color(0xFF2A1F0E),
                          child: const Icon(Icons.image, color: Colors.white24),
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place['name']?.toString() ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    place['desc']?.toString() ?? '',
                    style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 12,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white24,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
