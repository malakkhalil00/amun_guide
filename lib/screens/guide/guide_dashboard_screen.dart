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
                  'tour': b['tour']?['title'] ?? b['tour']?['name'] ?? 'Tour',
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

  // ════════════════════════════════════════════════════════════
  // BUILD
  // ════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 24),
                  _buildStatsGrid(),
                  const SizedBox(height: 20),
                  _buildCreateTourBtn(context),
                  const SizedBox(height: 28),
                  _buildQuickActions(context),
                  const SizedBox(height: 28),
                  _buildRecentBookings(context),
                  const SizedBox(height: 28),
                  _buildMyTours(context),
                  const SizedBox(height: 20),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  // HEADER — نفس ثيم الـ tourist بس للـ guide
  // ════════════════════════════════════════════════════════════

  Widget _buildHeader() {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good Morning'
        : hour < 17
        ? 'Good Afternoon'
        : 'Good Evening';

    return SizedBox(
      height: 260,
      child: Stack(
        children: [
          // ── Background image ────────────────────────────
          Positioned.fill(
            child: Image.asset(
              AppAssets.karnak3,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: AppColors.bgDark),
            ),
          ),

          // ── Gradient overlay ────────────────────────────
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x44000000),
                    Color(0xCC0B0B0F),
                    Color(0xFF0B0B0F),
                  ],
                  stops: [0.0, 0.6, 1.0],
                ),
              ),
            ),
          ),

          // ── Gold top line ───────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 3,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    AppColors.gold,
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ── Content ─────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left: greeting + name + badge
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$greeting,',
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _guideName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Certified Guide badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.goldDim,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.borderGold),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.verified_rounded,
                              color: AppColors.gold,
                              size: 12,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Certified Guide',
                              style: TextStyle(
                                color: AppColors.gold,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Revenue pill
                      if (_totalRevenue > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black38,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.15),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.attach_money_rounded,
                                color: AppColors.gold,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '\$${_totalRevenue.toStringAsFixed(0)} revenue',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),

                  // Right: Avatar
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/profile'),
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.gold, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.gold.withValues(alpha: 0.3),
                            blurRadius: 14,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child:
                            _guideImage.isNotEmpty &&
                                _guideImage.startsWith('http')
                            ? Image.network(
                                _guideImage,
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  // STATS GRID
  // ════════════════════════════════════════════════════════════

  Widget _buildStatsGrid() {
    final stats = [
      {
        'label': 'Total Tours',
        'value': _totalTours.toString(),
        'icon': Icons.map_rounded,
        'color': AppColors.gold,
      },
      {
        'label': 'Active Tours',
        'value': _activeTours.toString(),
        'icon': Icons.play_circle_rounded,
        'color': Colors.green,
      },
      {
        'label': 'Pending',
        'value': _pendingRequests.toString(),
        'icon': Icons.pending_rounded,
        'color': Colors.orange,
      },
      {
        'label': 'Approved',
        'value': _approvedBookings.toString(),
        'icon': Icons.check_circle_rounded,
        'color': Colors.teal,
      },
    ];

    if (_isLoadingStats || _isLoadingTours) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.6,
        ),
        itemCount: 4,
        itemBuilder: (_, __) => Container(
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.6,
      ),
      itemCount: stats.length,
      itemBuilder: (_, i) {
        final color = stats[i]['color'] as Color;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.3)),
            boxShadow: [
              BoxShadow(color: color.withValues(alpha: 0.05), blurRadius: 10),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  stats[i]['icon'] as IconData,
                  color: color,
                  size: 20,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stats[i]['value'] as String,
                    style: TextStyle(
                      color: color,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    stats[i]['label'] as String,
                    style: const TextStyle(color: Colors.white38, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ════════════════════════════════════════════════════════════
  // CREATE TOUR BUTTON
  // ════════════════════════════════════════════════════════════

  Widget _buildCreateTourBtn(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/create-tour'),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.gold, AppColors.gold.withValues(alpha: 0.75)],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.gold.withValues(alpha: 0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_rounded, color: Colors.black, size: 24),
            SizedBox(width: 10),
            Text(
              'Create New Tour',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  // QUICK ACTIONS
  // ════════════════════════════════════════════════════════════

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      {
        'icon': Icons.map_outlined,
        'label': 'My Tours',
        'route': '',
        'color': AppColors.gold,
      },
      {
        'icon': Icons.book_online_outlined,
        'label': 'Bookings',
        'route': '',
        'color': Colors.orange,
      },
      {
        'icon': Icons.message_outlined,
        'label': 'Messages',
        'route': '',
        'color': Colors.teal,
      },
      {
        'icon': Icons.person_outline,
        'label': 'Profile',
        'route': '/profile',
        'color': Colors.blue,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Quick Actions'),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: actions.map((a) {
            final color = a['color'] as Color;
            return GestureDetector(
              onTap: () {
                final route = a['route'] as String;
                if (route.isNotEmpty) {
                  Navigator.pushNamed(context, route);
                }
              },
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: color.withValues(alpha: 0.3)),
                    ),
                    child: Icon(a['icon'] as IconData, color: color, size: 26),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    a['label'] as String,
                    style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ════════════════════════════════════════════════════════════
  // RECENT BOOKINGS
  // ════════════════════════════════════════════════════════════

  Widget _buildRecentBookings(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _sectionTitle('Recent Requests'),
            GestureDetector(
              onTap: () {},
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
        const SizedBox(height: 14),
        if (_isLoadingBookings)
          ...List.generate(
            2,
            (_) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
            ),
          )
        else if (_recentBookings.isEmpty)
          _emptyState(
            icon: Icons.book_online_outlined,
            message: 'No booking requests yet',
          )
        else
          ..._recentBookings.map((b) => _bookingItem(b)),
      ],
    );
  }

  Widget _bookingItem(Map<String, dynamic> booking) {
    final status = booking['status'] as String;
    final statusColor = status == 'approved'
        ? Colors.green
        : status == 'pending'
        ? Colors.orange
        : Colors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(color: statusColor.withValues(alpha: 0.3)),
            ),
            child: Icon(Icons.person_rounded, color: statusColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking['tourist'] ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  booking['tour'] ?? '',
                  style: const TextStyle(color: Colors.white38, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${booking['participants']} pax',
                style: const TextStyle(color: Colors.white38, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  // MY TOURS
  // ════════════════════════════════════════════════════════════

  Widget _buildMyTours(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _sectionTitle('My Tours'),
            GestureDetector(
              onTap: () {},
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
        const SizedBox(height: 14),
        if (_isLoadingTours)
          ...List.generate(
            2,
            (_) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
            ),
          )
        else if (_myTours.isEmpty)
          _emptyState(
            icon: Icons.map_outlined,
            message: 'No tours yet — create your first tour!',
          )
        else
          ..._myTours.map((t) => _tourItem(t, context)),
      ],
    );
  }

  Widget _tourItem(Map<String, dynamic> tour, BuildContext context) {
    final status = tour['status'] as String;
    final isActive = status == 'active' || status == 'published';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive ? AppColors.borderGold : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.goldDim,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderGold),
            ),
            child: const Icon(
              Icons.map_rounded,
              color: AppColors.gold,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
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
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      color: Colors.white38,
                      size: 11,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      tour['location'] ?? '',
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.schedule_outlined,
                      color: Colors.white38,
                      size: 11,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '${tour['duration']}D',
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isActive
                      ? Colors.green.withValues(alpha: 0.1)
                      : AppColors.bgInput,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    color: isActive ? Colors.green : Colors.white38,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  // HELPERS
  // ════════════════════════════════════════════════════════════

  Widget _sectionTitle(String text) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            color: AppColors.gold,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _emptyState({required IconData icon, required String message}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white24, size: 36),
          const SizedBox(height: 10),
          Text(
            message,
            style: const TextStyle(color: Colors.white38, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
