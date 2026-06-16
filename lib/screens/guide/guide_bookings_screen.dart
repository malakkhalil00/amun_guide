// 📁 lib/screens/guide/guide_bookings_screen.dart

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/tour_booking_service.dart';

class GuideBookingsScreen extends StatefulWidget {
  const GuideBookingsScreen({super.key});

  @override
  State<GuideBookingsScreen> createState() => _GuideBookingsScreenState();
}

class _GuideBookingsScreenState extends State<GuideBookingsScreen>
    with SingleTickerProviderStateMixin {
  final _bookingService = TourBookingService();

  List<Map<String, dynamic>> _bookings = [];
  bool _isLoading = true;
  String _filterStatus = 'all';

  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  int _totalCount = 0;
  int _pendingCount = 0;
  int _approvedCount = 0;
  int _rejectedCount = 0;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
    _loadBookings();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  // ══════════════════════════════════════════════════════════
  // API CALLS
  // ══════════════════════════════════════════════════════════

  Future<void> _loadBookings() async {
    setState(() => _isLoading = true);
    try {
      final response = await _bookingService.getAllBookings();
      final data = response.data;
      final List items = data['data'] ?? data ?? [];

      final parsed = items.map<Map<String, dynamic>>((b) => {
        // ✅ id stored as int from the start to avoid casting issues
        'id': b['id'] is int ? b['id'] : int.tryParse(b['id'].toString()) ?? 0,
        'tourist': b['user']?['name'] ?? b['tourist']?['name'] ?? 'Tourist',
        'tourist_email': b['user']?['email'] ?? '',
        'tourist_phone': b['user']?['phone'] ?? '',
        'tour': b['tour']?['title'] ?? b['tour']?['name'] ?? 'Tour',
        'tour_id': b['tour_id'] ?? b['tour']?['id'],
        'date': b['booking_date'] ?? b['selected_date'] ??
            b['created_at']?.toString().split('T').first ?? '',
        'status': b['status'] ?? 'pending',
        'participants': b['participants_count'] ?? b['traveler_count'] ?? 1,
        'price': b['total_price'] ?? b['price'] ?? 0,
        'meeting_point': b['meeting_point'] ?? '',
        'payment_status': b['payment_status'] ?? 'pending',
        'created_at': b['created_at']?.toString().split('T').first ?? '',
      }).toList();

      if (mounted) {
        setState(() {
          _bookings = parsed;
          _totalCount = parsed.length;
          _pendingCount =
              parsed.where((b) => b['status'] == 'pending').length;
          _approvedCount =
              parsed.where((b) => b['status'] == 'approved').length;
          _rejectedCount =
              parsed.where((b) => b['status'] == 'rejected').length;
        });
      }
    } catch (e) {
      debugPrint('Bookings error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ✅ FIX: accept dynamic id and safely cast to int
  Future<void> _approveBooking(dynamic id) async {
    final bookingId = id is int ? id : int.tryParse(id.toString()) ?? 0;
    if (bookingId == 0) {
      _showSnack('Invalid booking ID', Colors.red);
      return;
    }
    try {
      await _bookingService.approveBooking(bookingId);
      _showSnack('Booking approved ✓', AppColors.gold);
      _loadBookings();
    } catch (e) {
      debugPrint('Approve error: $e');
      _showSnack('Failed to approve booking', Colors.red);
    }
  }

  // ✅ FIX: accept dynamic id and safely cast to int
  Future<void> _rejectBooking(dynamic id) async {
    final bookingId = id is int ? id : int.tryParse(id.toString()) ?? 0;
    if (bookingId == 0) {
      _showSnack('Invalid booking ID', Colors.red);
      return;
    }
    final confirm = await _showConfirmDialog(
      title: 'Reject Booking',
      message: 'Are you sure you want to reject this booking request?',
      confirmText: 'Reject',
      confirmColor: Colors.red,
    );
    if (!confirm) return;
    try {
      await _bookingService.rejectBooking(bookingId);
      _showSnack('Booking rejected', Colors.red.shade300);
      _loadBookings();
    } catch (e) {
      debugPrint('Reject error: $e');
      _showSnack('Failed to reject booking', Colors.red);
    }
  }

  Future<bool> _showConfirmDialog({
    required String title,
    required String message,
    required String confirmText,
    required Color confirmColor,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        content:
            Text(message, style: const TextStyle(color: Colors.white60)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel',
                style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(confirmText,
                style: TextStyle(color: confirmColor)),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _showSnack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  List<Map<String, dynamic>> get _filtered {
    if (_filterStatus == 'all') return _bookings;
    return _bookings.where((b) => b['status'] == _filterStatus).toList();
  }

  // ══════════════════════════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════════════════════════

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
            SliverToBoxAdapter(child: _buildStatsRow()),
            SliverToBoxAdapter(child: _buildFilterChips()),
            if (_isLoading)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, __) => _buildSkeleton(),
                    childCount: 4,
                  ),
                ),
              )
            else if (_filtered.isEmpty)
              SliverToBoxAdapter(child: _buildEmpty())
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => _buildBookingCard(_filtered[i]),
                    childCount: _filtered.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // HEADER
  // ══════════════════════════════════════════════════════════

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, MediaQuery.of(context).padding.top + 16, 20, 20),
      decoration: const BoxDecoration(
        color: AppColors.bgCard,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.goldDim,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderGold),
            ),
            child: const Icon(Icons.book_online_rounded,
                color: AppColors.gold, size: 20),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Booking Requests',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                Text('Manage tourist bookings',
                    style:
                        TextStyle(color: Colors.white38, fontSize: 12)),
              ],
            ),
          ),
          GestureDetector(
            onTap: _loadBookings,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.bgInput,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(Icons.refresh_rounded,
                  color: Colors.white54, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // STATS ROW
  // ══════════════════════════════════════════════════════════

  Widget _buildStatsRow() {
    final stats = [
      {'label': 'Total', 'value': _totalCount, 'color': AppColors.gold},
      {'label': 'Pending', 'value': _pendingCount, 'color': Colors.orange},
      {'label': 'Approved', 'value': _approvedCount, 'color': Colors.green},
      {'label': 'Rejected', 'value': _rejectedCount, 'color': Colors.red},
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: stats.map((s) {
          final color = s['color'] as Color;
          return Expanded(
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border:
                    Border.all(color: color.withValues(alpha: 0.25)),
              ),
              child: Column(
                children: [
                  Text('${s['value']}',
                      style: TextStyle(
                          color: color,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text('${s['label']}',
                      style: const TextStyle(
                          color: Colors.white38, fontSize: 10)),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // FILTER CHIPS
  // ══════════════════════════════════════════════════════════

  Widget _buildFilterChips() {
    final filters = [
      {'label': 'All', 'value': 'all'},
      {'label': 'Pending', 'value': 'pending'},
      {'label': 'Approved', 'value': 'approved'},
      {'label': 'Rejected', 'value': 'rejected'},
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.map((f) {
            final isActive = _filterStatus == f['value'];
            return GestureDetector(
              onTap: () =>
                  setState(() => _filterStatus = f['value']!),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.gold : AppColors.bgCard,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: isActive
                          ? AppColors.gold
                          : AppColors.border),
                ),
                child: Text(f['label']!,
                    style: TextStyle(
                        color: isActive ? Colors.black : Colors.white60,
                        fontSize: 13,
                        fontWeight: isActive
                            ? FontWeight.bold
                            : FontWeight.w500)),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // BOOKING CARD
  // ══════════════════════════════════════════════════════════

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    final status = booking['status'] as String;
    final isPending = status == 'pending';
    final statusColor = status == 'approved'
        ? Colors.green
        : status == 'pending'
            ? Colors.orange
            : Colors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: isPending
                ? Colors.orange.withValues(alpha: 0.3)
                : AppColors.border),
      ),
      child: Column(
        children: [
          // ── Top section ────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tourist info + status badge
                Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: AppColors.goldDim,
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: AppColors.borderGold),
                      ),
                      child: const Icon(Icons.person_rounded,
                          color: AppColors.gold, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(booking['tourist'] ?? '',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold)),
                          if ((booking['tourist_email'] as String)
                              .isNotEmpty)
                            Text(booking['tourist_email'],
                                style: const TextStyle(
                                    color: Colors.white38,
                                    fontSize: 11)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color:
                            statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: statusColor.withValues(alpha: 0.3)),
                      ),
                      child: Text(status.toUpperCase(),
                          style: TextStyle(
                              color: statusColor,
                              fontSize: 10,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),

                const SizedBox(height: 14),
                const Divider(color: AppColors.border, height: 1),
                const SizedBox(height: 14),

                // Tour name
                Row(
                  children: [
                    const Icon(Icons.map_outlined,
                        color: AppColors.gold, size: 15),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(booking['tour'] ?? '',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Details row
                Row(
                  children: [
                    _detailChip(Icons.calendar_today_outlined,
                        booking['date'] ?? '', Colors.white54),
                    const SizedBox(width: 8),
                    _detailChip(
                        Icons.people_outline_rounded,
                        '${booking['participants']} pax',
                        Colors.white54),
                    const SizedBox(width: 8),
                    _detailChip(Icons.attach_money_rounded,
                        '\$${booking['price']}', AppColors.gold),
                  ],
                ),

                if ((booking['meeting_point'] as String).isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          color: Colors.white38, size: 13),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(booking['meeting_point'],
                            style: const TextStyle(
                                color: Colors.white38, fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // ── Action buttons (pending only) ──────────────
          if (isPending)
            Container(
              decoration: const BoxDecoration(
                border:
                    Border(top: BorderSide(color: AppColors.border)),
              ),
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      // ✅ passes booking['id'] which is already int
                      onTap: () => _rejectBooking(booking['id']),
                      child: Container(
                        padding:
                            const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color:
                                  Colors.red.withValues(alpha: 0.3)),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.close_rounded,
                                color: Colors.red, size: 16),
                            SizedBox(width: 6),
                            Text('Reject',
                                style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      // ✅ passes booking['id'] which is already int
                      onTap: () => _approveBooking(booking['id']),
                      child: Container(
                        padding:
                            const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: Colors.green
                                  .withValues(alpha: 0.3)),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_rounded,
                                color: Colors.green, size: 16),
                            SizedBox(width: 6),
                            Text('Approve',
                                style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _detailChip(IconData icon, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 13),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(color: color, fontSize: 12)),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════
  // SKELETON
  // ══════════════════════════════════════════════════════════

  Widget _buildSkeleton() {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      height: 160,
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // EMPTY
  // ══════════════════════════════════════════════════════════

  Widget _buildEmpty() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 0),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.borderGold),
            ),
            child: const Icon(Icons.book_online_outlined,
                color: AppColors.gold, size: 36),
          ),
          const SizedBox(height: 16),
          Text(
            _filterStatus == 'all'
                ? 'No booking requests yet'
                : 'No ${_filterStatus} bookings',
            style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Booking requests from tourists\nwill appear here',
            style:
                TextStyle(color: Colors.white38, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}