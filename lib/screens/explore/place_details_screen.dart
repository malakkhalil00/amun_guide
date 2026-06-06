// 📁 lib/screens/explore/place_details_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';

class PlaceDetailsScreen extends StatefulWidget {
  const PlaceDetailsScreen({super.key});

  @override
  State<PlaceDetailsScreen> createState() => _PlaceDetailsScreenState();
}

class _PlaceDetailsScreenState extends State<PlaceDetailsScreen>
    with SingleTickerProviderStateMixin {
  bool _isSaved = false;
  bool _isExpanded = false;
  bool _isLoading = true;

  int _placeId = 0;
  String _title = '';
  String _location = '';
  String _description = '';
  String _image = '';
  String _rating = '';
  String _category = '';
  String _price = '';

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));

    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is Map<String, dynamic>) {
      _placeId = args['id'] ?? 0;
      _title = args['title'] ?? args['name'] ?? '';
      _location = args['location'] ?? args['loc'] ?? '';
      _image = args['image'] ?? args['img'] ?? args['image_url'] ?? '';
      _rating = (args['rating'] ?? 0).toString();
      _description = args['description'] ?? args['desc'] ?? '';
      _category = args['category'] ?? args['type'] ?? 'Historical Site';
      _price = args['price']?.toString() ?? args['cost']?.toString() ?? '216';
    }

    if (mounted) {
      setState(() => _isLoading = false);
      _animController.forward();
    }
  }

  Widget _buildImage({
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
  }) {
    if (_image.isEmpty) {
      return Container(
        color: const Color(0xFF1A2F45),
        width: width,
        height: height,
        child: const Icon(Icons.image_rounded, color: Colors.white24, size: 48),
      );
    }
    final isNetwork = _image.startsWith('http');
    final fallback = Container(
      color: const Color(0xFF1A2F45),
      width: width,
      height: height,
      child: const Icon(Icons.image_rounded, color: Colors.white24, size: 48),
    );
    return isNetwork
        ? Image.network(
            _image,
            fit: fit,
            width: width,
            height: height,
            errorBuilder: (_, __, ___) => fallback,
          )
        : Image.asset(
            _image,
            fit: fit,
            width: width,
            height: height,
            errorBuilder: (_, __, ___) => fallback,
          );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0D1B2A),
        body: Center(child: CircularProgressIndicator(color: AppColors.gold)),
      );
    }

    final screenHeight = MediaQuery.of(context).size.height;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Background image ─────────────────────────
          Positioned.fill(child: _buildImage(fit: BoxFit.cover)),

          // ── Gradient overlay ─────────────────────────
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.35),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.75),
                    Colors.black.withValues(alpha: 0.96),
                  ],
                  stops: const [0.0, 0.25, 0.55, 0.75],
                ),
              ),
            ),
          ),

          // ── Back + Bookmark (top) ─────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _topButton(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  _topButton(
                    borderColor: _isSaved ? AppColors.gold : Colors.white24,
                    onTap: () => setState(() => _isSaved = !_isSaved),
                    child: Icon(
                      _isSaved
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: _isSaved ? AppColors.gold : Colors.white,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Bottom glass card ─────────────────────────
          Align(
            alignment: Alignment.bottomCenter,
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: Container(
                  width: double.infinity,
                  constraints: BoxConstraints(maxHeight: screenHeight * 0.62),
                  padding: EdgeInsets.fromLTRB(20, 22, 20, bottomPad + 20),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(
                      144,
                      87,
                      61,
                      5,
                    ).withValues(alpha: 0.4),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ── Category + Rating ─────────
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [_categoryBadge(), _ratingBadge()],
                        ),

                        const SizedBox(height: 12),

                        // ── Title ──────────────────────
                        Text(
                          _title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                            letterSpacing: -0.3,
                          ),
                        ),

                        const SizedBox(height: 6),

                        // ── Location ───────────────────
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_rounded,
                              color: AppColors.gold,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                _location,
                                style: const TextStyle(
                                  color: Colors.white60,
                                  fontSize: 13,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        // ── Spec badges ────────────────
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _specBadge(Icons.king_bed_outlined, '4 Beds'),
                            _specBadge(Icons.bathtub_outlined, '2 Baths'),
                            _specBadge(Icons.straighten_rounded, '600 sqft'),
                          ],
                        ),

                        // ── Description ────────────────
                        if (_description.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          const Text(
                            'Description',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          AnimatedCrossFade(
                            duration: const Duration(milliseconds: 250),
                            crossFadeState: _isExpanded
                                ? CrossFadeState.showSecond
                                : CrossFadeState.showFirst,
                            firstChild: Text(
                              _description,
                              style: const TextStyle(
                                color: Colors.white60,
                                fontSize: 12,
                                height: 1.65,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            secondChild: Text(
                              _description,
                              style: const TextStyle(
                                color: Colors.white60,
                                fontSize: 12,
                                height: 1.65,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          GestureDetector(
                            onTap: () =>
                                setState(() => _isExpanded = !_isExpanded),
                            child: Text(
                              _isExpanded ? 'Show less' : 'Read more',
                              style: const TextStyle(
                                color: AppColors.gold,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],

                        const SizedBox(height: 18),

                        // ── Price + Book Now ───────────
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Total Price',
                                    style: TextStyle(
                                      color: Colors.white38,
                                      fontSize: 11,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: '\$$_price',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const TextSpan(
                                          text: '/pax',
                                          style: TextStyle(
                                            color: Colors.white38,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.pushNamed(
                                context,
                                '/tour-details',
                                arguments: _placeId > 0
                                    ? {'id': _placeId}
                                    : null,
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 30,
                                  vertical: 15,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.gold,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Text(
                                  'Book Now',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helper widgets ────────────────────────────────────

  Widget _topButton({
    required VoidCallback onTap,
    required Widget child,
    Color borderColor = Colors.white24,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.42),
          shape: BoxShape.circle,
          border: Border.all(color: borderColor),
        ),
        child: Center(child: child),
      ),
    );
  }

  Widget _categoryBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.location_city_rounded,
            color: Colors.white70,
            size: 12,
          ),
          const SizedBox(width: 5),
          Text(
            _category.isNotEmpty ? _category : 'Historical Site',
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _ratingBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderGold),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, color: AppColors.gold, size: 13),
          const SizedBox(width: 4),
          Text(
            _rating.isNotEmpty ? _rating : '0',
            style: const TextStyle(
              color: AppColors.gold,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _specBadge(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white54, size: 13),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
