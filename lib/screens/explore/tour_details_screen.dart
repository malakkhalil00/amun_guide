// 📁 lib/screens/explore/tour_details_screen.dart

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/tours_service.dart';
import '../../core/constants/app_assets.dart';
import '../explore/map_screen.dart';

class TourDetailsScreen extends StatefulWidget {
  const TourDetailsScreen({super.key});

  @override
  State<TourDetailsScreen> createState() => _TourDetailsScreenState();
}

class _TourDetailsScreenState extends State<TourDetailsScreen>
    with TickerProviderStateMixin {
  bool _isSaved = false;
  bool _isLoading = true;
  final _toursService = ToursService();

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

  late AnimationController _contentController;
  late Animation<double> _contentFade;
  late Animation<double> _contentSlide;

  late AnimationController _saveController;
  late Animation<double> _saveScale;

  @override
  void initState() {
    super.initState();

    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _contentFade = CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeOut,
    );
    _contentSlide = Tween<double>(begin: 30, end: 0).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeOutCubic),
    );

    _saveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _saveScale = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _saveController, curve: Curves.easeOutBack),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    final args = ModalRoute.of(context)?.settings.arguments;
    int? tourId;
    if (args is Map<String, dynamic>) {
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
            _rating = (tour['rating'] ?? _rating).toString();
            _reviewsCount =
                tour['reviews_count'] ?? tour['bookings_count'] ?? 0;
            _durationDays = tour['duration_days'] ?? tour['days'] ?? 1;
            if (tour['guide'] != null) {
              _guide = Map<String, dynamic>.from(tour['guide']);
            }
            if (tour['places'] != null && tour['places'] is List) {
              final placeImages = [
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
              final placesList = tour['places'] as List;
              _places = placesList.asMap().entries.map<Map<String, dynamic>>((
                entry,
              ) {
                final i = entry.key;
                final p = entry.value;
                return {
                  'id': p['id'],
                  'img': placeImages[i % placeImages.length],
                  'name': p['title'] ?? p['name'] ?? '',
                  'desc': p['description'] ?? '',
                  'loc': p['location'] ?? 'Egypt',
                  'rating': (p['rating'] ?? 0).toString(),
                  'price': '\$${p['ticket_price'] ?? 0}',
                  'cat': p['category'] ?? 'Temples',
                  'latitude': p['latitude'],
                  'longitude': p['longitude'],
                };
              }).toList();
            }
          });
        }
      } catch (e) {
        debugPrint('Error loading tour details: $e');
      }
    }

    if (mounted) {
      setState(() => _isLoading = false);
      _contentController.forward();
    }
  }

  // ── الجديد: بدل _joinTour القديم ──────────────
  void _openBookingSummary() {
    Navigator.pushNamed(
      context,
      '/booking-summary',
      arguments: {
        'id': _tourId,
        'name': _title,
        'guideName': _guide['name'] ?? '',
        'price':
            double.tryParse(
              _price.replaceAll('\$', '').replaceAll(',', '').trim(),
            ) ??
            0.0,
        'duration_days': _durationDays,
        'location': _location,
        'image': _image,
      },
    );
  }

  @override
  void dispose() {
    _contentController.dispose();
    _saveController.dispose();
    super.dispose();
  }

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
    if (_isLoading) return _buildSkeleton();

    final ratingNum = double.tryParse(_rating) ?? 0;
    final fullStars = ratingNum.floor();
    final hasHalf = (ratingNum - fullStars) >= 0.3;

    return Scaffold(
      backgroundColor: const Color(0xFF151411),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // ── Hero ─────────────────────────────
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                backgroundColor: const Color(0xFF151411),
                elevation: 0,
                leading: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
                actions: [
                  GestureDetector(
                    onTap: () {
                      _saveController.forward().then(
                        (_) => _saveController.reverse(),
                      );
                      setState(() => _isSaved = !_isSaved);
                    },
                    child: AnimatedBuilder(
                      animation: _saveScale,
                      builder: (_, child) => Transform.scale(
                        scale: _saveScale.value,
                        child: child,
                      ),
                      child: Container(
                        margin: const EdgeInsets.only(
                          right: 12,
                          top: 8,
                          bottom: 8,
                        ),
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        child: Icon(
                          _isSaved
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: _isSaved ? Colors.red : Colors.white,
                          size: 20,
                        ),
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
                              errorBuilder: (_, __, ___) =>
                                  Container(color: const Color(0xFF2A1F0E)),
                            ),
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.25),
                                Colors.transparent,
                                const Color(0xFF151411),
                              ],
                              stops: const [0.0, 0.5, 1.0],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 16,
                        left: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.gold,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.verified_rounded,
                                color: Colors.black,
                                size: 14,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                '$_durationDays Day Tour',
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
                    ],
                  ),
                ),
              ),

              // ── Content ──────────────────────────
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 130),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    AnimatedBuilder(
                      animation: _contentFade,
                      builder: (_, child) => Opacity(
                        opacity: _contentFade.value,
                        child: Transform.translate(
                          offset: Offset(0, _contentSlide.value),
                          child: child,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  _title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 26,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'Playfair Display',
                                    height: 1.2,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
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
                                  Text(
                                    'per person',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.35),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_rounded,
                                color: AppColors.gold.withOpacity(0.8),
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _location,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Row(
                                children: List.generate(
                                  5,
                                  (i) => Icon(
                                    i < fullStars
                                        ? Icons.star_rounded
                                        : (i == fullStars && hasHalf
                                              ? Icons.star_half_rounded
                                              : Icons.star_border_rounded),
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
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _reviewsCount > 0
                                    ? '($_reviewsCount reviews)'
                                    : '(No reviews yet)',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.35),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          _buildDivider(),
                          if (_guide.isNotEmpty) ...[
                            const SizedBox(height: 24),
                            _buildSectionTitle('Your Guide'),
                            const SizedBox(height: 14),
                            _buildGuideCard(),
                            const SizedBox(height: 24),
                            _buildDivider(),
                          ],
                          if (_description.isNotEmpty) ...[
                            const SizedBox(height: 24),
                            _buildSectionTitle('About the Tour'),
                            const SizedBox(height: 12),
                            Text(
                              _description,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.55),
                                fontSize: 14,
                                height: 1.75,
                              ),
                            ),
                            const SizedBox(height: 24),
                            _buildDivider(),
                          ],
                          if (_places.isNotEmpty) ...[
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildSectionTitle('Places Included'),
                                GestureDetector(
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => MapScreen(
                                        tourTitle: _title,
                                        places: _places,
                                      ),
                                    ),
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.gold.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: AppColors.gold.withOpacity(0.3),
                                      ),
                                    ),
                                    child: const Row(
                                      children: [
                                        Icon(
                                          Icons.map_rounded,
                                          color: AppColors.gold,
                                          size: 13,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          'View Map',
                                          style: TextStyle(
                                            color: AppColors.gold,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            ..._places.map((p) => _buildPlaceItem(p)),
                          ],
                        ],
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          ),

          // ── Bottom Bar ──────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                20,
                16,
                20,
                MediaQuery.of(context).padding.bottom + 16,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF151411).withOpacity(0.97),
                border: Border(
                  top: BorderSide(color: Colors.white.withOpacity(0.07)),
                ),
              ),
              child: Row(
                children: [
                  // Upload Receipt
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          Navigator.pushNamed(context, '/my-bookings'),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: AppColors.gold.withOpacity(0.45),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: const Icon(
                        Icons.upload_file_rounded,
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
                  // Join Tour — بيفتح Booking Summary
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _openBookingSummary,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Join Tour',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          letterSpacing: 0.3,
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

  Widget _buildSectionTitle(String title) => Text(
    title,
    style: const TextStyle(
      color: Colors.white,
      fontSize: 18,
      fontWeight: FontWeight.w700,
      fontFamily: 'Playfair Display',
    ),
  );

  Widget _buildDivider() => Container(
    height: 1,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Colors.transparent,
          Colors.white.withOpacity(0.08),
          Colors.transparent,
        ],
      ),
    ),
  );

  Widget _buildGuideCard() {
    final guideName = _guide['name'] ?? 'Certified Egyptologist';
    final guideImage = _guide['profile_image'] ?? _guide['image'] ?? '';
    final guideRating = (_guide['rating'] ?? 5.0).toString();
    final guideBio =
        _guide['bio'] ??
        _guide['description'] ??
        'Expert in New Kingdom history...';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1A16),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gold.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.gold, width: 1.5),
            ),
            child: ClipOval(
              child: guideImage.isNotEmpty && guideImage.startsWith('http')
                  ? Image.network(
                      guideImage,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFF2A1F0E),
                        child: const Icon(
                          Icons.person,
                          color: AppColors.gold,
                          size: 28,
                        ),
                      ),
                    )
                  : Image.asset(
                      'assets/images/guide_ahmed.jpg',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFF2A1F0E),
                        child: const Icon(
                          Icons.person,
                          color: AppColors.gold,
                          size: 28,
                        ),
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
                  guideName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  guideBio,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.45),
                    fontSize: 12,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: AppColors.gold,
                      size: 13,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      guideRating,
                      style: const TextStyle(
                        color: AppColors.gold,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.gold.withOpacity(0.12),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.gold.withOpacity(0.3)),
            ),
            child: const Icon(
              Icons.chat_bubble_outline_rounded,
              color: AppColors.gold,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceItem(Map<String, dynamic> place) {
    final img = place['img']?.toString() ?? '';
    final isNetwork = img.startsWith('http');
    return GestureDetector(
      onTap: () =>
          Navigator.pushNamed(context, '/place-details', arguments: place),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1A16),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.07)),
        ),
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
                        errorBuilder: (_, __, ___) => _imgError(),
                      )
                    : Image.asset(
                        img,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _imgError(),
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
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    place['desc']?.toString() ?? '',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 12,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: AppColors.gold.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColors.gold,
                size: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imgError() => Container(
    color: const Color(0xFF2A1F0E),
    child: const Icon(Icons.image, color: Colors.white24, size: 28),
  );

  Widget _buildSkeleton() {
    return Scaffold(
      backgroundColor: const Color(0xFF151411),
      body: Column(
        children: [
          _ShimmerBox(height: 300, borderRadius: 0),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ShimmerBox(height: 28, width: 240, borderRadius: 8),
                const SizedBox(height: 12),
                _ShimmerBox(height: 16, width: 160, borderRadius: 6),
                const SizedBox(height: 20),
                _ShimmerBox(
                  height: 14,
                  width: double.infinity,
                  borderRadius: 6,
                ),
                const SizedBox(height: 8),
                _ShimmerBox(height: 14, width: 280, borderRadius: 6),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ShimmerBox extends StatefulWidget {
  final double height;
  final double? width;
  final double borderRadius;
  const _ShimmerBox({
    required this.height,
    this.width,
    required this.borderRadius,
  });

  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox>
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
        width: widget.width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: const [
              Color(0xFF1E1A16),
              Color(0xFF2A2419),
              Color(0xFF1E1A16),
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
