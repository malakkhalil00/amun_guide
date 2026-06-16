// 📁 lib/screens/guide/guide_tours_screen.dart

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_assets.dart';
import '../../core/services/tours_service.dart';
import '../../core/services/tour_booking_service.dart';

class GuideToursScreen extends StatefulWidget {
  const GuideToursScreen({super.key});

  @override
  State<GuideToursScreen> createState() => _GuideToursScreenState();
}

class _GuideToursScreenState extends State<GuideToursScreen>
    with SingleTickerProviderStateMixin {
  final _toursService = ToursService();
  final _bookingService = TourBookingService();

  List<Map<String, dynamic>> _tours = [];
  bool _isLoading = true;
  String _filterStatus = 'all';

  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
    _loadMyTours();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadMyTours() async {
    setState(() => _isLoading = true);
    try {
      final toursResponse = await _toursService.getMyTours();
      final data = toursResponse.data;
      final List items = data['data'] ?? data ?? [];

      // ✅ FIX: جيب الـ bookings عشان نحسب الـ count لكل tour
      Map<dynamic, int> bookingsCountMap = {};
      try {
        final bookingsResponse = await _bookingService.getAllBookings();
        final bData = bookingsResponse.data;
        final List bItems = bData['data'] ?? bData ?? [];
        for (final b in bItems) {
          final tourId = b['tour_id'] ?? b['tour']?['id'];
          if (tourId != null) {
            bookingsCountMap[tourId] = (bookingsCountMap[tourId] ?? 0) + 1;
          }
        }
      } catch (e) {
        debugPrint('Bookings count error: $e');
      }

      if (mounted) {
        final images = [
          AppAssets.pyramids,
          AppAssets.karnak,
          AppAssets.abuSimbel,
          AppAssets.alexandria,
          AppAssets.philae,
          AppAssets.siwa,
          AppAssets.nileSunset,
          AppAssets.valley,
        ];
        setState(() {
          _tours = items.asMap().entries.map<Map<String, dynamic>>((e) {
            final i = e.key;
            final t = e.value;
            final tourId = t['id'];
            return {
              'id': tourId,
              'title': t['title'] ?? t['name'] ?? '',
              'location': t['location'] ?? 'Egypt',
              'price': t['price'] ?? 0,
              'duration': t['duration_days'] ?? 1,
              'status': t['status'] ?? 'active',
              'rating': t['rating'] ?? 0,
              // ✅ FIX: من الـ bookings map أو من الـ API
              'bookings_count': bookingsCountMap[tourId] ??
                  t['bookings_count'] ??
                  t['bookings']?.length ??
                  0,
              'img': images[i % images.length],
            };
          }).toList();
        });
      }
    } catch (e) {
      debugPrint('Error loading tours: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteTour(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Tour',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to delete this tour?',
            style: TextStyle(color: Colors.white60)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _toursService.deleteTour(id);
      _loadMyTours();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Tour deleted successfully'),
          backgroundColor: AppColors.gold,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Failed to delete tour'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
      }
    }
  }

  List<Map<String, dynamic>> get _filteredTours {
    if (_filterStatus == 'all') return _tours;
    return _tours.where((t) => t['status'].toString() == _filterStatus).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(context)),
            SliverToBoxAdapter(child: _buildFilterChips()),
            _isLoading
                ? SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, __) => _buildSkeletonCard(),
                        childCount: 4,
                      ),
                    ),
                  )
                : _filteredTours.isEmpty
                    ? SliverToBoxAdapter(child: _buildEmpty())
                    : SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (_, i) => _buildTourCard(_filteredTours[i]),
                            childCount: _filteredTours.length,
                          ),
                        ),
                      ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            Navigator.pushNamed(context, '/create-tour').then((_) => _loadMyTours()),
        backgroundColor: AppColors.gold,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Tour', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SizedBox(
      height: 180,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(AppAssets.karnak3, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: AppColors.bgDark)),
          ),
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x44000000), Color(0xDD0B0B0F), Color(0xFF0B0B0F)],
                  stops: [0.0, 0.65, 1.0],
                ),
              ),
            ),
          ),
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              height: 3,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, AppColors.gold, Colors.transparent],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.black26,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded,
                              color: Colors.white, size: 14),
                          onPressed: () => Navigator.pop(context),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.goldDim,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.borderGold),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.map_rounded, color: AppColors.gold, size: 13),
                            const SizedBox(width: 5),
                            Text('${_tours.length} Tours',
                                style: const TextStyle(
                                    color: AppColors.gold,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('My Tours',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5)),
                  const SizedBox(height: 4),
                  const Text('Manage and track your tours',
                      style: TextStyle(color: Colors.white54, fontSize: 13)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = [
      {'label': 'All', 'value': 'all'},
      {'label': 'Active', 'value': 'active'},
      {'label': 'Pending', 'value': 'pending'},
      {'label': 'Draft', 'value': 'draft'},
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.map((f) {
            final isActive = _filterStatus == f['value'];
            return GestureDetector(
              onTap: () => setState(() => _filterStatus = f['value']!),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.gold : AppColors.bgCard,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: isActive ? AppColors.gold : AppColors.border),
                ),
                child: Text(f['label']!,
                    style: TextStyle(
                        color: isActive ? Colors.black : Colors.white60,
                        fontSize: 13,
                        fontWeight:
                            isActive ? FontWeight.bold : FontWeight.w500)),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTourCard(Map<String, dynamic> tour) {
    final status = tour['status'].toString();
    final isActive = status == 'active' || status == 'published';
    final statusColor = isActive
        ? Colors.green
        : status == 'pending'
            ? Colors.orange
            : Colors.white38;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: isActive ? AppColors.borderGold : AppColors.border),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Stack(
              children: [
                SizedBox(
                  height: 160,
                  width: double.infinity,
                  child: Image.asset(tour['img'], fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          Container(color: AppColors.bgInput)),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black54],
                        stops: [0.5, 1.0],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 12, left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: statusColor.withValues(alpha: 0.5)),
                    ),
                    child: Row(
                      children: [
                        Container(
                            width: 6, height: 6,
                            decoration: BoxDecoration(
                                color: statusColor, shape: BoxShape.circle)),
                        const SizedBox(width: 5),
                        Text(status.toUpperCase(),
                            style: TextStyle(
                                color: statusColor,
                                fontSize: 10,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 12, right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                        color: AppColors.gold,
                        borderRadius: BorderRadius.circular(10)),
                    child: Text('${tour['duration']}D',
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 11,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
                Positioned(
                  bottom: 12, right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(10)),
                    child: Text('\$${tour['price']}/pax',
                        style: const TextStyle(
                            color: AppColors.gold,
                            fontSize: 12,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tour['title'] ?? '',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.2),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on_rounded,
                        color: AppColors.gold, size: 13),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(tour['location'] ?? '',
                          style: const TextStyle(
                              color: Colors.white54, fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ),
                    const Icon(Icons.people_outline_rounded,
                        color: Colors.white38, size: 13),
                    const SizedBox(width: 4),
                    // ✅ FIX: يظهر الـ count الصح
                    Text('${tour['bookings_count']} bookings',
                        style: const TextStyle(
                            color: Colors.white38, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/edit-tour',
                                arguments: tour)
                            .then((_) => _loadMyTours()),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: AppColors.goldDim,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.borderGold),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.edit_outlined,
                                  color: AppColors.gold, size: 16),
                              SizedBox(width: 6),
                              Text('Edit',
                                  style: TextStyle(
                                      color: AppColors.gold,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pushNamed(
                            context, '/tour-bookings',
                            arguments: tour),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: AppColors.bgCard,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.book_online_outlined,
                                  color: Colors.white54, size: 16),
                              SizedBox(width: 6),
                              Text('Bookings',
                                  style: TextStyle(
                                      color: Colors.white54,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () => _deleteTour(tour['id']),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: Colors.red.withValues(alpha: 0.3)),
                        ),
                        child: const Icon(Icons.delete_outline_rounded,
                            color: Colors.red, size: 18),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      height: 280,
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
    );
  }

  Widget _buildEmpty() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 0),
      child: Column(
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.borderGold),
            ),
            child: const Icon(Icons.map_outlined, color: AppColors.gold, size: 36),
          ),
          const SizedBox(height: 16),
          const Text('No tours yet',
              style: TextStyle(
                  color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Create your first tour and start\nmanaging bookings',
              style: TextStyle(color: Colors.white38, fontSize: 13),
              textAlign: TextAlign.center),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/create-tour')
                .then((_) => _loadMyTours()),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              decoration: BoxDecoration(
                  color: AppColors.gold,
                  borderRadius: BorderRadius.circular(16)),
              child: const Text('Create Tour',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}