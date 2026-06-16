import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_assets.dart';
import '../../core/services/dio_client.dart';
import '../../core/services/tours_service.dart';
import '../../core/services/tour_booking_service.dart';

class GuideDashboardScreen extends StatefulWidget {
  const GuideDashboardScreen({super.key});

  @override
  State<GuideDashboardScreen> createState() => _GuideDashboardScreenState();
}

class _GuideDashboardScreenState extends State<GuideDashboardScreen>
    with SingleTickerProviderStateMixin {
  // ── State ────────────────────────────────────────────────
  String _guideName = 'Guide';
  String _guideImage = '';

  int _totalTours = 0;
  int _activeTours = 0;
  int _pendingRequests = 0;
  int _approvedBookings = 0;
  double _totalRevenue = 0;

  List<Map<String, dynamic>> _recentBookings = [];
  List<Map<String, dynamic>> _myTours = [];

  bool _isLoadingStats = true;
  bool _isLoadingTours = true;
  bool _isLoadingBookings = true;

  final _toursService = ToursService();
  final _bookingService = TourBookingService();

  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  // ── Lifecycle ────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();

    _loadGuideData();
    _loadStats();
    _loadMyTours();
    _loadRecentBookings();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  // ── API calls (unchanged) ────────────────────────────────
  Future<void> _loadGuideData() async {
    final data = await DioClient.getUserData();
    if (mounted) {
      setState(() {
        _guideName = data['name']?.toString().split(' ').first ?? 'Guide';
        _guideImage = data['profile_image'] ?? '';
      });
    }
  }

  Future<void> _loadStats() async {
    try {
      final response = await _bookingService.getStatistics();
      final data = response.data;
      final stats = data['data'] ?? data ?? {};
      if (mounted) {
        setState(() {
          _pendingRequests = stats['pending'] ?? stats['pending_count'] ?? 0;
          _approvedBookings = stats['approved'] ?? stats['approved_count'] ?? 0;
          _totalRevenue =
              double.tryParse(stats['total_revenue']?.toString() ?? '0') ?? 0;
        });
      }
    } catch (e) {
      debugPrint('Stats error: $e');
    } finally {
      if (mounted) setState(() => _isLoadingStats = false);
    }
  }

  Future<void> _loadMyTours() async {
    try {
      final response = await _toursService.getMyTours();
      final data = response.data;
      final List items = data['data'] ?? data ?? [];
      if (mounted) {
        setState(() {
          _totalTours = items.length;
          _activeTours = items
              .where(
                (t) => t['status'] == 'active' || t['status'] == 'published',
              )
              .length;
          _myTours = items
              .take(3)
              .map<Map<String, dynamic>>(
                (t) => {
                  'id': t['id'],
                  'title': t['title'] ?? t['name'] ?? '',
                  'location': t['location'] ?? 'Egypt',
                  'price': t['price'] ?? 0,
                  'duration': t['duration_days'] ?? 1,
                  'status': t['status'] ?? 'active',
                },
              )
              .toList();
        });
      }
    } catch (e) {
      debugPrint('Tours error: $e');
    } finally {
      if (mounted) setState(() => _isLoadingTours = false);
    }
  }

  Future<void> _loadRecentBookings() async {
    try {
      final response = await _bookingService.getAllBookings();
      final data = response.data;
      final List items = data['data'] ?? data ?? [];
      if (mounted) {
        setState(() {
          _recentBookings = items
              .take(3)
              .map<Map<String, dynamic>>(
                (b) => {
                  'id': b['id'],
                  'tourist': b['user']?['name'] ?? 'Tourist',
                  'tour':
                      b['tour']?['title'] ?? b['tour']?['name'] ?? 'Tour',
                  'date':
                      b['booking_date'] ??
                      b['created_at']?.toString().split('T').first ??
                      '',
                  'status': b['status'] ?? 'pending',
                  'participants': b['participants_count'] ?? 1,
                },
              )
              .toList();
        });
      }
    } catch (e) {
      debugPrint('Bookings error: $e');
    } finally {
      if (mounted) setState(() => _isLoadingBookings = false);
    }
  }

  // ════════════════════════════════════════════════════════
  // BUILD
  // ════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Top bar ──────────────────────────────────
            SliverToBoxAdapter(child: _buildTopBar()),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // ── Hero revenue card ─────────────────
                  _buildHeroCard(),
                  const SizedBox(height: 16),

                  // ── Search bar ────────────────────────
                  _buildSearchBar(),
                  const SizedBox(height: 24),

                  // ── Current Tour ──────────────────────
                  _buildSectionTitle('Current Tour'),
                  const SizedBox(height: 12),
                  _buildCurrentTour(),
                  const SizedBox(height: 24),

                  // ── Recent Requests ───────────────────
                  _buildSectionHeader(
                    title: 'Recent Requests',
                    onSeeAll: () => Navigator.pushNamed(context, '/my-bookings'),
                  ),
                  const SizedBox(height: 12),
                  _buildRecentRequests(),
                  const SizedBox(height: 24),

                  // ── My Tours ──────────────────────────
                  _buildSectionHeader(
                    title: 'My Tours',
                    onSeeAll: () => Navigator.pushNamed(context, '/guide-tours'),
                  ),
                  const SizedBox(height: 12),
                  _buildMyToursList(),
                  const SizedBox(height: 20),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  // TOP BAR  (Hello + name + location + bell)
  // ════════════════════════════════════════════════════════
  Widget _buildTopBar() {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
        child: Row(
          children: [
            // Avatar
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/profile'),
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.gold, width: 1.5),
                ),
                child: ClipOval(
                  child: _guideImage.isNotEmpty &&
                          _guideImage.startsWith('http')
                      ? Image.network(
                          _guideImage,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _avatarFallback(),
                        )
                      : _avatarFallback(),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Greeting
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Hello,',
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 11,
                    ),
                  ),
                  Text(
                    _guideName.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Row(
                    children: const [
                      Icon(
                        Icons.location_on_outlined,
                        color: Colors.white30,
                        size: 11,
                      ),
                      SizedBox(width: 2),
                      Text(
                        'Luxor, Egypt',
                        style: TextStyle(
                          color: Colors.white30,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Bell
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/notifications'),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF181410),
                      border: Border.all(color: const Color(0xFF2A2418)),
                    ),
                    child: const Icon(
                      Icons.notifications_outlined,
                      color: AppColors.gold,
                      size: 20,
                    ),
                  ),
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: AppColors.gold,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.bgDark,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _avatarFallback() {
    return Container(
      color: const Color(0xFF2A2418),
      child: const Icon(Icons.person, color: AppColors.gold, size: 22),
    );
  }

  // ════════════════════════════════════════════════════════
  // HERO CARD  (revenue + Top Up + New Tour + Bookings)
  // ════════════════════════════════════════════════════════
  Widget _buildHeroCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF181410),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderGold),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Revenue row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Revenue',
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        '\$${_totalRevenue.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.remove_red_eye_outlined,
                        color: Colors.white24,
                        size: 18,
                      ),
                    ],
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/my-payments'),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.gold,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Top Up',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: _heroActionBtn(
                  icon: Icons.add_circle_outline_rounded,
                  label: 'New Tour',
                  onTap: () => Navigator.pushNamed(context, '/create-tour'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _heroActionBtn(
                  icon: Icons.book_online_outlined,
                  label: 'Bookings',
                  onTap: () => Navigator.pushNamed(context, '/my-bookings'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroActionBtn({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: const Color(0xFF242118),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF3A3220)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.gold, size: 18),
            const SizedBox(width: 7),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  // SEARCH BAR
  // ════════════════════════════════════════════════════════
  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/guide-tours'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
              decoration: BoxDecoration(
                color: const Color(0xFF181410),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFF2A2418)),
              ),
              child: Row(
                children: const [
                  Icon(Icons.search, color: Color(0xFF4A4030), size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Search Tours',
                    style: TextStyle(color: Color(0xFF3A3020), fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/guide-tours'),
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.gold,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.tune_rounded,
              color: Colors.black,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  // ════════════════════════════════════════════════════════
  // CURRENT TOUR  (progress tracker card)
  // ════════════════════════════════════════════════════════
  Widget _buildCurrentTour() {
    final activeTour = _myTours.firstWhere(
      (t) => t['status'] == 'active' || t['status'] == 'published',
      orElse: () => {},
    );

    if (_isLoadingTours) return _shimmerCard(height: 140);

    if (activeTour.isEmpty) {
      return _emptyCard(
        icon: Icons.map_outlined,
        message: 'No active tour — create one!',
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF181410),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2418)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ID row + badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tour ID:',
                    style: TextStyle(color: Colors.white38, fontSize: 10),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'AMN-${activeTour['id'] ?? '001'}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              _statusBadge('Active'),
            ],
          ),
          const SizedBox(height: 14),

          // From / To
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tour:',
                    style: TextStyle(color: Colors.white38, fontSize: 10),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    activeTour['title'] ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    activeTour['location'] ?? '',
                    style: const TextStyle(
                      color: Colors.white30,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Duration:',
                    style: TextStyle(color: Colors.white38, fontSize: 10),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${activeTour['duration']}D',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '\$${activeTour['price']}',
                    style: const TextStyle(
                      color: AppColors.gold,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Progress bar
          _buildProgressBar(step: 1),
        ],
      ),
    );
  }

  Widget _buildProgressBar({required int step}) {
    final labels = ['Created', 'Active', 'Completed'];
    final times = ['10:00am', 'Now', '--'];

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // Track
            Container(
              height: 3,
              decoration: BoxDecoration(
                color: const Color(0xFF2A2418),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Fill
            Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: step == 0
                    ? 0.05
                    : step == 1
                        ? 0.5
                        : 1.0,
                child: Container(
                  height: 3,
                  decoration: BoxDecoration(
                    color: AppColors.gold,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
            // Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(3, (i) {
                final done = i <= step;
                final active = i == step;
                return Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: done
                        ? AppColors.gold
                        : const Color(0xFF2A2418),
                    border: Border.all(
                      color: done
                          ? AppColors.gold
                          : const Color(0xFF3A3220),
                      width: 2,
                    ),
                    boxShadow: active
                        ? [
                            BoxShadow(
                              color: AppColors.gold.withValues(alpha: 0.2),
                              blurRadius: 6,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                );
              }),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(3, (i) {
            return Column(
              children: [
                Text(
                  labels[i],
                  style: TextStyle(
                    color: i <= step ? Colors.white38 : const Color(0xFF3A3020),
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  times[i],
                  style: TextStyle(
                    color: i <= step
                        ? const Color(0xFF4A4030)
                        : const Color(0xFF2A2018),
                    fontSize: 9,
                  ),
                ),
              ],
            );
          }),
        ),
      ],
    );
  }

  // ════════════════════════════════════════════════════════
  // RECENT REQUESTS
  // ════════════════════════════════════════════════════════
  Widget _buildRecentRequests() {
    if (_isLoadingBookings) {
      return Column(
        children: List.generate(
          2,
          (_) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _shimmerCard(height: 72),
          ),
        ),
      );
    }

    if (_recentBookings.isEmpty) {
      return _emptyCard(
        icon: Icons.book_online_outlined,
        message: 'No booking requests yet',
      );
    }

    return Column(
      children: _recentBookings.map((b) => _requestItem(b)).toList(),
    );
  }

  Widget _requestItem(Map<String, dynamic> b) {
    final status = b['status'] as String;
    final isApproved = status == 'approved';
    final isPending = status == 'pending';
    final statusColor = isApproved
        ? const Color(0xFF28B464)
        : isPending
            ? const Color(0xFFDC8C1E)
            : const Color(0xFFE24B4A);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF181410),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2418)),
      ),
      child: Row(
        children: [
          // Left: ID + status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Booking ID:',
                  style: TextStyle(color: Colors.white30, fontSize: 10),
                ),
                const SizedBox(height: 2),
                Text(
                  'BK-${b['id'] ?? '000'}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      status[0].toUpperCase() + status.substring(1),
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Right: Tour + date
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'Tour:',
                style: TextStyle(color: Colors.white30, fontSize: 10),
              ),
              const SizedBox(height: 2),
              Text(
                b['tour'] ?? '',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                b['date'] ?? '',
                style: const TextStyle(
                  color: Colors.white30,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  // MY TOURS LIST
  // ════════════════════════════════════════════════════════
  Widget _buildMyToursList() {
    if (_isLoadingTours) {
      return Column(
        children: List.generate(
          2,
          (_) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _shimmerCard(height: 80),
          ),
        ),
      );
    }

    if (_myTours.isEmpty) {
      return _emptyCard(
        icon: Icons.map_outlined,
        message: 'No tours yet — create your first!',
      );
    }

    return Column(children: _myTours.map((t) => _tourItem(t)).toList());
  }

  Widget _tourItem(Map<String, dynamic> tour) {
    final status = tour['status'] as String;
    final isActive = status == 'active' || status == 'published';

    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        '/edit-tour',
        arguments: tour,
      ),
      child: Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF181410),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive ? AppColors.borderGold : const Color(0xFF2A2418),
        ),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.goldDim
                  : const Color(0xFF1A1810),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isActive
                    ? AppColors.borderGold
                    : const Color(0xFF2A2418),
              ),
            ),
            child: Icon(
              Icons.map_rounded,
              color: isActive ? AppColors.gold : const Color(0xFF5A5040),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tour['title'] ?? '',
                  style: const TextStyle(
                    color: Colors.white,
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
                      Icons.location_on_outlined,
                      color: Colors.white30,
                      size: 11,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      tour['location'] ?? '',
                      style: const TextStyle(
                        color: Colors.white30,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.schedule_outlined,
                      color: Colors.white30,
                      size: 11,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '${tour['duration']}D',
                      style: const TextStyle(
                        color: Colors.white30,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Price + status
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${tour['price']}',
                style: const TextStyle(
                  color: AppColors.gold,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFF28B46420)
                      : const Color(0xFF2A2418),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    color: isActive
                        ? const Color(0xFF28B464)
                        : Colors.white30,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
  }

  // ════════════════════════════════════════════════════════
  // HELPERS — closing GestureDetector added above in _tourItem
  // ════════════════════════════════════════════════════════

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required VoidCallback onSeeAll,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        GestureDetector(
          onTap: onSeeAll,
          child: Row(
            children: const [
              Text(
                'See all',
                style: TextStyle(
                  color: AppColors.gold,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 2),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColors.gold,
                size: 11,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _statusBadge(String label) {
    Color bg;
    Color fg;
    Color border;

    switch (label.toLowerCase()) {
      case 'active':
        bg = const Color(0xFF1EC86415);
        fg = const Color(0xFF28B464);
        border = const Color(0xFF28B46440);
        break;
      case 'pending':
        bg = const Color(0xFFDC8C1E15);
        fg = const Color(0xFFDC8C1E);
        border = const Color(0xFFDC8C1E40);
        break;
      default:
        bg = AppColors.goldDim;
        fg = AppColors.gold;
        border = AppColors.borderGold;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _emptyCard({required IconData icon, required String message}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF181410),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2418)),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF3A3220), size: 34),
          const SizedBox(height: 10),
          Text(
            message,
            style: const TextStyle(color: Color(0xFF4A4030), fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _shimmerCard({required double height}) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF181410),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2418)),
      ),
    );
  }
}