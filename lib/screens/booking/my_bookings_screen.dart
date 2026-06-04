// 📁 lib/screens/booking/my_bookings_screen.dart

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/tour_booking_service.dart';
import '../tourist/main_navigation.dart';
import '../payment/payment_receipts_screen.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _bookingService = TourBookingService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _bookings = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadBookings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadBookings() async {
    setState(() => _isLoading = true);
    try {
      final response = await _bookingService.getMyBookings();
      final data = response.data;
      final List items = data['data'] ?? data ?? [];
      setState(() {
        _bookings = items
            .map<Map<String, dynamic>>(
              (b) => {
                'id': b['id']?.toString() ?? '',
                'tourName': b['tour']?['title'] ?? b['tour_name'] ?? 'Tour',
                'guideName': b['guide']?['name'] ?? b['guide_name'] ?? '',
                'tourImage': b['tour']?['image'] ?? '',
                'status': (b['status'] ?? 'pending').toString().toLowerCase(),
                'travelers':
                    b['participants_count'] ?? b['traveler_count'] ?? 1,
                'totalPrice': (b['total_price'] ?? b['amount'] ?? 0).toDouble(),
                'selectedDate': b['selected_date'] ?? b['created_at'] ?? '',
                'meetingPoint': b['meeting_point'] ?? '',
                'location': b['tour']?['location'] ?? '',
              },
            )
            .toList();
      });
    } catch (e) {
      debugPrint('Error loading bookings: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Cancel Booking ──────────────────────────────────────────────────────────
  Future<void> _cancelBooking(String bookingId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1A16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 22),
            SizedBox(width: 10),
            Text(
              'Cancel Booking',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to cancel this booking?\nThis action cannot be undone.',
          style: TextStyle(color: Colors.white54, fontSize: 13, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Keep It',
              style: TextStyle(color: Colors.white38),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.withOpacity(0.15),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: Colors.red.withOpacity(0.4)),
              ),
            ),
            child: const Text(
              'Yes, Cancel',
              style: TextStyle(color: Colors.red, fontSize: 13),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _bookingService.cancelBooking(int.parse(bookingId));
      if (!mounted) return;
      setState(() {
        final idx = _bookings.indexWhere((b) => b['id'] == bookingId);
        if (idx != -1) _bookings[idx]['status'] = 'cancelled';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.white, size: 16),
              SizedBox(width: 10),
              Text('Booking cancelled successfully'),
            ],
          ),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
      // Reload to sync with backend
      _loadBookings();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white, size: 16),
              SizedBox(width: 10),
              Text('Failed to cancel booking. Try again.'),
            ],
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
      debugPrint('Cancel error: $e');
    }
  }
  // ───────────────────────────────────────────────────────────────────────────

  List<Map<String, dynamic>> _filtered(String status) =>
      _bookings.where((b) => b['status'] == status).toList();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const MainNavigation()),
            (route) => false,
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF151411),
        appBar: AppBar(
          backgroundColor: const Color(0xFF151411),
          elevation: 0,
          leading: GestureDetector(
            onTap: () => Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const MainNavigation()),
              (route) => false,
            ),
            child: Container(
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
          title: const Text(
            'My Bookings',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: _loadBookings,
              icon: const Icon(
                Icons.refresh_rounded,
                color: Colors.white54,
                size: 20,
              ),
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: AppColors.gold,
            indicatorWeight: 2,
            labelColor: AppColors.gold,
            unselectedLabelColor: Colors.white38,
            labelStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            tabs: [
              Tab(text: 'Pending (${_filtered('pending').length})'),
              Tab(text: 'Approved (${_filtered('approved').length})'),
              Tab(text: 'Rejected (${_filtered('rejected').length})'),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.gold),
              )
            : TabBarView(
                controller: _tabController,
                children: [
                  _buildList(_filtered('pending'), 'pending'),
                  _buildList(_filtered('approved'), 'approved'),
                  _buildList(_filtered('rejected'), 'rejected'),
                ],
              ),
      ), // end Scaffold
    ); // end PopScope
  }

  Widget _buildList(List<Map<String, dynamic>> items, String status) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              status == 'pending'
                  ? Icons.hourglass_empty_rounded
                  : status == 'approved'
                  ? Icons.check_circle_outline
                  : Icons.cancel_outlined,
              color: Colors.white12,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'No $status bookings',
              style: const TextStyle(color: Colors.white38, fontSize: 15),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadBookings,
      color: AppColors.gold,
      backgroundColor: const Color(0xFF1E1A16),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (_, i) => _bookingCard(items[i]),
      ),
    );
  }

  Widget _bookingCard(Map<String, dynamic> b) {
    final status = b['status'] as String;
    final isApproved = status == 'approved';
    final isPending = status == 'pending';
    final isRejected = status == 'rejected';

    Color statusColor = isPending
        ? Colors.orange
        : isApproved
        ? Colors.green
        : Colors.red;

    String statusLabel = isPending
        ? 'Pending Approval'
        : isApproved
        ? 'Approved'
        : 'Rejected';

    final dateStr = _formatDate(b['selectedDate']);
    final travelers = b['travelers'] ?? 1;
    final totalPrice = (b['totalPrice'] ?? 0.0) as double;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1A16),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isApproved
              ? Colors.green.withOpacity(0.3)
              : isPending
              ? AppColors.gold.withOpacity(0.2)
              : Colors.red.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          // ── Header ──────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Tour image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 60,
                    height: 60,
                    child: b['tourImage'].toString().startsWith('http')
                        ? Image.network(
                            b['tourImage'],
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _imgPlaceholder(),
                          )
                        : _imgPlaceholder(),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        b['tourName'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (b['guideName'].toString().isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            const Icon(
                              Icons.person_outline,
                              color: AppColors.gold,
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              b['guideName'],
                              style: const TextStyle(
                                color: AppColors.gold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (b['location'].toString().isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              color: Colors.white.withOpacity(0.35),
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              b['location'],
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.35),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withOpacity(0.4)),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Divider ─────────────────────────
          const Divider(color: Colors.white10, height: 1),

          // ── Details ─────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _infoChip(Icons.calendar_today_outlined, dateStr),
                const SizedBox(width: 12),
                _infoChip(
                  Icons.people_outline,
                  '$travelers person${travelers > 1 ? 's' : ''}',
                ),
                const Spacer(),
                Text(
                  '\$${totalPrice.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: AppColors.gold,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // ── Cancel Button (Pending only) ─────
          if (isPending) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: OutlinedButton(
                onPressed: () => _cancelBooking(b['id']),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 46),
                  side: BorderSide(color: Colors.red.withOpacity(0.5)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cancel_outlined, color: Colors.red, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'Cancel Booking',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          // ── Upload Receipt Button (Approved only) ──
          if (isApproved) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PaymentReceiptsScreen(
                      bookingId: int.parse(b['id']),
                      amount: b['totalPrice'],
                      tourName: b['tourName'],
                    ),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  minimumSize: const Size(double.infinity, 46),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.upload_file_rounded,
                      color: Colors.black,
                      size: 16,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Upload Payment Receipt',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          // ── Rejected reason note ─────────────
          if (isRejected) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.red, size: 14),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Your booking was rejected. You can try booking again.',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, color: Colors.white38, size: 13),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(color: Colors.white38, fontSize: 12),
        ),
      ],
    );
  }

  Widget _imgPlaceholder() => Container(
    color: const Color(0xFF2A1F0E),
    child: const Icon(
      Icons.landscape_outlined,
      color: Colors.white24,
      size: 24,
    ),
  );

  String _formatDate(String? iso) {
    if (iso == null || iso.isEmpty) return '';
    try {
      final d = DateTime.parse(iso);
      const months = [
        '',
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${d.day} ${months[d.month]} ${d.year}';
    } catch (_) {
      return iso.length > 10 ? iso.substring(0, 10) : iso;
    }
  }
} // end of _MyBookingsScreenState
