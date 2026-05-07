// 📁 lib/screens/explore/place_details_screen.dart

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/places_service.dart';

class PlaceDetailsScreen extends StatefulWidget {
  const PlaceDetailsScreen({super.key});

  @override
  State<PlaceDetailsScreen> createState() => _PlaceDetailsScreenState();
}

class _PlaceDetailsScreenState extends State<PlaceDetailsScreen> {
  bool _isSaved = false;
  bool _isExpanded = false;
  bool _isLoading = true;

  final _placesService = PlacesService();

  int _placeId = 0;
  String _title = '';
  String _location = '';
  String _description = '';
  String _image = '';
  String _rating = '';
  int _reviewsCount = 0;
  String _aiInsightTime = '';
  String _aiInsightDesc = '';
  List<String> _gallery = [];
  List<Map<String, dynamic>> _nearby = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    final args = ModalRoute.of(context)?.settings.arguments;

    int? placeId;
    if (args is Map<String, dynamic>) {
      setState(() {
        _placeId = args['id'] ?? 0;
        _title = args['title'] ?? args['name'] ?? '';
        _location = args['location'] ?? args['loc'] ?? '';
        _image = args['image'] ?? args['img'] ?? args['image_url'] ?? '';
        _rating = (args['rating'] ?? 0).toString();
        _description = args['description'] ?? args['desc'] ?? '';
      });
      placeId = _placeId;
    } else if (args is int) {
      placeId = args;
    }

    if (placeId != null && placeId > 0) {
      try {
        final response = await _placesService.getPlace(placeId);
        final data = response.data;
        final place = data['data'] ?? data;

        if (mounted) {
          setState(() {
            _placeId = place['id'] ?? placeId;
            _title = place['title'] ?? place['name'] ?? _title;
            _location = place['location'] ?? _location;
            _description = place['description'] ?? _description;
            _rating = (place['rating'] ?? _rating).toString();
            _reviewsCount =
                place['reviews_count'] ??
                place['comments_count'] ??
                _reviewsCount;

            if (place['gallery'] != null && place['gallery'] is List) {
              _gallery = (place['gallery'] as List)
                  .map((img) => img.toString())
                  .toList();
            }
            if (place['ai_insight'] != null && place['ai_insight'] is Map) {
              _aiInsightTime = place['ai_insight']['time'] ?? '';
              _aiInsightDesc = place['ai_insight']['description'] ?? '';
            }
            if (place['nearby'] != null && place['nearby'] is List) {
              _nearby = List<Map<String, dynamic>>.from(place['nearby']);
            }
          });
        }
      } catch (e) {
        debugPrint('Error loading place details: $e');
      }
    }

    if (mounted) setState(() => _isLoading = false);
  }

  Widget _buildImage(
    String src, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
  }) {
    if (src.isEmpty) {
      return Container(
        color: const Color(0xFF2A1F0E),
        width: width,
        height: height,
        child: const Icon(Icons.image, color: Colors.white24, size: 40),
      );
    }
    final isNetwork = src.startsWith('http');
    final errorWidget = Container(
      color: const Color(0xFF2A1F0E),
      width: width,
      height: height,
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
                expandedHeight: 300,
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
                    onTap: () {},
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.share_outlined,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _isSaved = !_isSaved),
                    child: Container(
                      margin: const EdgeInsets.only(
                        right: 8,
                        top: 8,
                        bottom: 8,
                      ),
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isSaved ? Icons.bookmark : Icons.bookmark_outline,
                        color: _isSaved ? AppColors.gold : Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      _buildImage(_image),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Color(0xFF1A1208)],
                            stops: [0.5, 1.0],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Content ─────────────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    if (_title.isNotEmpty) ...[
                      Text(
                        _title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],

                    if (_location.isNotEmpty) ...[
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: AppColors.gold,
                            size: 16,
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
                      const SizedBox(height: 12),
                    ],

                    if (_rating.isNotEmpty && ratingNum > 0) ...[
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
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (_reviewsCount > 0) ...[
                            const SizedBox(width: 6),
                            Text(
                              '($_reviewsCount reviews)',
                              style: const TextStyle(
                                color: Colors.white38,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],

                    // ── Amun AI Insight ─────────────────────
                    if (_aiInsightDesc.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF221A0A),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.gold.withOpacity(0.35),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: AppColors.gold.withOpacity(0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.auto_awesome,
                                    color: AppColors.gold,
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Amun AI Insight',
                                  style: TextStyle(
                                    color: AppColors.gold,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (_aiInsightTime.isNotEmpty) ...[
                              RichText(
                                text: TextSpan(
                                  style: const TextStyle(
                                    fontSize: 15,
                                    height: 1.4,
                                  ),
                                  children: [
                                    const TextSpan(
                                      text: 'Best time to visit: ',
                                      style: TextStyle(color: Colors.white70),
                                    ),
                                    TextSpan(
                                      text: _aiInsightTime,
                                      style: const TextStyle(
                                        color: AppColors.gold,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 6),
                            ],
                            Text(
                              _aiInsightDesc,
                              style: const TextStyle(
                                color: Colors.white38,
                                fontSize: 13,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // ── About ───────────────────────────────
                    if (_description.isNotEmpty) ...[
                      const Text(
                        'About',
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
                        maxLines: _isExpanded ? null : 4,
                        overflow: _isExpanded
                            ? TextOverflow.visible
                            : TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => setState(() => _isExpanded = !_isExpanded),
                        child: Row(
                          children: [
                            Text(
                              _isExpanded ? 'Show less' : 'Read more',
                              style: const TextStyle(
                                color: AppColors.gold,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              _isExpanded
                                  ? Icons.arrow_upward
                                  : Icons.arrow_forward,
                              color: AppColors.gold,
                              size: 14,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // ── Gallery ─────────────────────────────
                    if (_gallery.isNotEmpty) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Gallery',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {},
                            child: const Text(
                              'View All',
                              style: TextStyle(
                                color: AppColors.gold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 130,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _gallery.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 10),
                          itemBuilder: (_, i) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: _buildImage(
                                _gallery[i],
                                width: 160,
                                height: 130,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // ── Reviews ─────────────────────────────
                    if (_reviewsCount > 0) ...[
                      _buildReviewsSection(ratingNum),
                      const SizedBox(height: 24),
                    ],

                    // ── Nearby Attractions ──────────────────
                    if (_nearby.isNotEmpty) ...[
                      const Text(
                        'Nearby Attractions',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        height: 160,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _nearby.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 12),
                          itemBuilder: (_, i) {
                            return _buildNearbyCard(
                              img:
                                  _nearby[i]['img'] ??
                                  _nearby[i]['image'] ??
                                  '',
                              name:
                                  _nearby[i]['name'] ??
                                  _nearby[i]['title'] ??
                                  '',
                              dist:
                                  _nearby[i]['dist'] ??
                                  _nearby[i]['distance'] ??
                                  '',
                              rating: (_nearby[i]['rating'] ?? 0).toString(),
                            );
                          },
                        ),
                      ),
                    ],
                  ]),
                ),
              ),
            ],
          ),

          // ── Bottom Bar ────────────────────────────────────
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
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pushNamed(context, '/ai-chat'),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: AppColors.gold.withOpacity(0.5),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Ask AI',
                        style: TextStyle(
                          color: AppColors.gold,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pushNamed(
                        context,
                        '/tour-details',
                        arguments: _placeId > 0 ? {'id': _placeId} : null,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Add to Plan',
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

  Widget _buildReviewsSection(double ratingNum) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF221A0A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Reviews',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Column(
                children: [
                  Text(
                    _rating,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: List.generate(
                      5,
                      (i) => Icon(
                        i < ratingNum.floor()
                            ? Icons.star
                            : (i == ratingNum.floor() &&
                                      (ratingNum - ratingNum.floor() >= 0.3)
                                  ? Icons.star_half
                                  : Icons.star_border),
                        color: AppColors.gold,
                        size: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$_reviewsCount reviews',
                    style: const TextStyle(color: Colors.white38, fontSize: 11),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  children: List.generate(5, (i) {
                    final vals = [0.85, 0.65, 0.3, 0.15, 0.05];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          Text(
                            '${5 - i}',
                            style: const TextStyle(
                              color: Colors.white38,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: vals[i],
                                backgroundColor: Colors.white10,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  AppColors.gold,
                                ),
                                minHeight: 6,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNearbyCard({
    required String img,
    required String name,
    required String dist,
    required String rating,
  }) {
    return GestureDetector(
      onTap: () {},
      child: SizedBox(
        width: 150,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: _buildImage(img, width: 150, height: 105),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    dist,
                    style: const TextStyle(color: Colors.white38, fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.star, color: AppColors.gold, size: 11),
                    const SizedBox(width: 2),
                    Text(
                      rating,
                      style: const TextStyle(
                        color: AppColors.gold,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
