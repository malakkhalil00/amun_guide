// 📁 lib/screens/explore/tour_details_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/tours_service.dart';
import '../../core/constants/app_assets.dart';
import '../explore/map_screen.dart';
import 'tourist_guide_chat_screen.dart'; // ← التعديل الوحيد في الـ imports

class TourDetailsScreen extends StatefulWidget {
  const TourDetailsScreen({super.key});

  @override
  State<TourDetailsScreen> createState() => _TourDetailsScreenState();
}

class _TourDetailsScreenState extends State<TourDetailsScreen>
    with TickerProviderStateMixin {
  bool _isSaved = false;
  bool _isLoading = true;
  bool _isDescExpanded = false;
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

  List<String> _galleryImages = [];

  late AnimationController _contentController;
  late Animation<double> _contentFade;
  late Animation<Offset> _contentSlide;

  late AnimationController _saveController;
  late Animation<double> _saveScale;

  static const _fallbackImages = [
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

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _contentFade = CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeOut,
    );
    _contentSlide =
        Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _contentController,
            curve: Curves.easeOutCubic,
          ),
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

  @override
  void dispose() {
    _contentController.dispose();
    _saveController.dispose();
    super.dispose();
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
            _price = (tour['price'] ?? tour['ticket_price'] ?? '').toString();
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
              final placesList = tour['places'] as List;
              _places = placesList.asMap().entries.map<Map<String, dynamic>>((
                entry,
              ) {
                final i = entry.key;
                final p = entry.value;
                return {
                  'id': p['id'],
                  'img': _fallbackImages[i % _fallbackImages.length],
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

    _galleryImages = _places.isNotEmpty
        ? _places.take(4).map((p) => p['img']?.toString() ?? '').toList()
        : _fallbackImages.take(4).toList();

    if (mounted) {
      setState(() => _isLoading = false);
      _contentController.forward();
    }
  }

  String _cleanPrice(String value) {
    final cleaned = value
        .replaceAll(RegExp(r'egp', caseSensitive: false), '')
        .replaceAll('جنيه', '')
        .replaceAll('/pax', '')
        .replaceAll(RegExp(r'pax', caseSensitive: false), '')
        .replaceAll(r'$', '')
        .replaceAll(',', '')
        .trim();
    return cleaned.isEmpty ? '0' : cleaned;
  }

  String get _priceLabel => 'EGP ${_cleanPrice(_price)}';

  void _openBookingSummary() {
    Navigator.pushNamed(
      context,
      '/booking-summary',
      arguments: {
        'id': _tourId,
        'name': _title,
        'guideName': _guide['name'] ?? '',
        'price': double.tryParse(_cleanPrice(_price)) ?? 0.0,
        'duration_days': _durationDays,
        'location': _location,
        'image': _image,
      },
    );
  }

  Widget _buildImg(
    String src, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
  }) {
    if (src.isEmpty) return _imgError(width: width, height: height);
    final isNet = src.startsWith('http');
    final err = _imgError(width: width, height: height);
    return isNet
        ? Image.network(
            src,
            fit: fit,
            width: width,
            height: height,
            errorBuilder: (_, __, ___) => err,
          )
        : Image.asset(
            src,
            fit: fit,
            width: width,
            height: height,
            errorBuilder: (_, __, ___) => err,
          );
  }

  Widget _imgError({double? width, double? height}) => Container(
    width: width,
    height: height,
    color: const Color(0xFFDDD8CE),
    child: const Icon(Icons.image_rounded, color: AppColors.gold, size: 28),
  );

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return _buildSkeleton();

    final screenSize = MediaQuery.of(context).size;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.bgCard,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: SizedBox(
                  height: screenSize.height * 0.55,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(40),
                            bottomRight: Radius.circular(40),
                          ),
                          child: _buildImg(_image),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 200,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                              bottomRight: Radius.circular(90),
                            ),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.55),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 12,
                        bottom: 0,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 60),
                            ..._galleryImages.asMap().entries.map((e) {
                              final isSelected = e.key == 0;
                              return Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  border: isSelected
                                      ? Border.all(
                                          color: AppColors.gold,
                                          width: 2.5,
                                        )
                                      : null,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.25,
                                      ),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(18),
                                  child: _buildImg(e.value),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                      Positioned(
                        top: MediaQuery.of(context).padding.top + 10,
                        left: 16,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.bgCard,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: AppColors.gold,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: MediaQuery.of(context).padding.top + 10,
                        right: 16,
                        child: AnimatedBuilder(
                          animation: _saveScale,
                          builder: (_, child) => Transform.scale(
                            scale: _saveScale.value,
                            child: child,
                          ),
                          child: GestureDetector(
                            onTap: () {
                              _saveController.forward().then(
                                (_) => _saveController.reverse(),
                              );
                              setState(() => _isSaved = !_isSaved);
                            },
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.bgInput,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                _isSaved
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded,
                                color: _isSaved
                                    ? Colors.redAccent
                                    : AppColors.gold,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 20,
                        left: 20,
                        right: 88,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
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
                                Expanded(
                                  child: Text(
                                    _location,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
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
              ),
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _contentFade,
                  child: SlideTransition(
                    position: _contentSlide,
                    child: Container(
                      margin: const EdgeInsets.only(top: 0),
                      padding: EdgeInsets.fromLTRB(20, 24, 20, bottomPad + 100),
                      decoration: const BoxDecoration(color: AppColors.bgCard),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildStatsRow(),
                          const SizedBox(height: 24),
                          _buildDivider(),
                          const SizedBox(height: 24),
                          if (_guide.isNotEmpty) ...[
                            _buildSectionTitle('Your Guide'),
                            const SizedBox(height: 14),
                            _buildGuideCard(),
                            const SizedBox(height: 24),
                            _buildDivider(),
                            const SizedBox(height: 24),
                          ],
                          _buildSectionTitle('Description'),
                          const SizedBox(height: 12),
                          _buildDescription(),
                          const SizedBox(height: 24),
                          _buildDivider(),
                          const SizedBox(height: 24),
                          if (_places.isNotEmpty) ...[
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
                                      color: AppColors.gold,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Row(
                                      children: [
                                        Icon(
                                          Icons.map_rounded,
                                          color: Colors.white,
                                          size: 12,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          'View Map',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
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
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(20, 16, 20, bottomPad + 16),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                border: Border(
                  top: BorderSide(color: Colors.black.withValues(alpha: 0.06)),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Total Price',
                        style: TextStyle(
                          color: Color(0xFF888888),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _priceLabel,
                        style: const TextStyle(
                          color: AppColors.gold,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () =>
                            Navigator.pushNamed(context, '/my-bookings'),
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.black.withValues(alpha: 0.1),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.06),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.upload_file_rounded,
                            color: AppColors.gold,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: _openBookingSummary,
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: AppColors.gold,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.gold,
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 26,
                          ),
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
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        _statItem('Duration', '${_durationDays}D', Icons.schedule_rounded),
        _statDivider(),
        _statItem('Reviews', '$_reviewsCount', Icons.people_outline_rounded),
        _statDivider(),
        _statItem(
          'Rating',
          _rating.isNotEmpty ? _rating : '—',
          Icons.star_rounded,
        ),
      ],
    );
  }

  Widget _statItem(String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: AppColors.gold, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.gold,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(color: Color(0xFF888888), fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _statDivider() => Container(
    width: 1,
    height: 40,
    color: Colors.black.withValues(alpha: 0.08),
  );

  Widget _buildDescription() {
    final text = _description.isNotEmpty
        ? _description
        : 'No description available for this tour.';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 250),
          crossFadeState: _isDescExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          firstChild: Text(
            text,
            style: const TextStyle(
              color: Color(0xFF555555),
              fontSize: 14,
              height: 1.75,
            ),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
          secondChild: Text(
            text,
            style: const TextStyle(
              color: Color(0xFF555555),
              fontSize: 14,
              height: 1.75,
            ),
          ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () => setState(() => _isDescExpanded = !_isDescExpanded),
          child: Text(
            _isDescExpanded ? 'Show less' : 'Read More',
            style: const TextStyle(
              color: AppColors.gold,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // ── Guide card ────────────────────────────────────────────
  Widget _buildGuideCard() {
    final guideName = _guide['name'] ?? 'Certified Guide';
    final guideImage = _guide['profile_image'] ?? _guide['image'] ?? '';
    final guideRating = (_guide['rating'] ?? 5.0).toString();
    final guideBio = _guide['bio'] ?? _guide['description'] ?? 'Expert guide';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgInput,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
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
                      errorBuilder: (_, __, ___) => _guideAvatarFallback(),
                    )
                  : _guideAvatarFallback(),
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
                    color: AppColors.gold,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  guideBio,
                  style: const TextStyle(
                    color: Color(0xFF888888),
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

          // ── زرار الماسدج المفعّل ──────────────────────
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TouristGuideChatScreen(
                    guideId: _guide['id'] ?? 0,
                    guideName: guideName,
                    tourName: _title,
                  ),
                ),
              );
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: AppColors.gold,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chat_bubble_outline_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _guideAvatarFallback() => Container(
    color: AppColors.bgInput,
    child: const Icon(Icons.person_rounded, color: AppColors.gold, size: 28),
  );

  Widget _buildPlaceItem(Map<String, dynamic> place) {
    final img = place['img']?.toString() ?? '';
    final isNet = img.startsWith('http');

    return GestureDetector(
      onTap: () =>
          Navigator.pushNamed(context, '/place-details', arguments: place),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.bgInput,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 68,
                height: 68,
                child: isNet
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
                      color: AppColors.gold,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    place['desc']?.toString() ?? '',
                    style: const TextStyle(
                      color: Color(0xFF888888),
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
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: AppColors.gold,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
                size: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) => Text(
    title,
    style: const TextStyle(
      color: AppColors.gold,
      fontSize: 18,
      fontWeight: FontWeight.bold,
    ),
  );

  Widget _buildDivider() =>
      Container(height: 1, color: Colors.black.withValues(alpha: 0.06));

  Widget _buildSkeleton() {
    return Scaffold(
      backgroundColor: AppColors.bgCard,
      body: Column(
        children: [
          _SkeletonBox(
            height: MediaQuery.of(context).size.height * 0.55,
            borderRadius: 0,
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SkeletonBox(height: 24, borderRadius: 8),
                const SizedBox(height: 12),
                _SkeletonBox(height: 16, borderRadius: 6),
                const SizedBox(height: 20),
                _SkeletonBox(height: 14, borderRadius: 6),
                const SizedBox(height: 8),
                _SkeletonBox(height: 14, borderRadius: 6),
              ],
            ),
          ),
        ],
      ),
    );
  }
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
