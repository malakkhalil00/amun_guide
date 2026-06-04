// 📁 lib/screens/booking/my_bookings_screen.dart

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/tour_booking_service.dart';
import '../tourist/main_navigation.dart';
import '../payment/complete_payment_screen.dart';

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
    _tabController = TabController(length: 4, vsync: this); // ← 4 tabs
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

  List<Map<String, dynamic>> _filtered(String status) => status == 'all'
      ? _bookings
      : _bookings.where((b) => b['status'] == status).toList();

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
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            tabs: [
              Tab(text: 'All (${_bookings.length})'),
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
                  _buildList(_filtered('all'), 'all'),
                  _buildList(_filtered('pending'), 'pending'),
                  _buildList(_filtered('approved'), 'approved'),
                  _buildList(_filtered('rejected'), 'rejected'),
                ],
              ),
      ),
    );
  }

  Widget _buildList(List<Map<String, dynamic>> items, String status) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              status == 'all'
                  ? Icons.receipt_long_outlined
                  : status == 'pending'
                  ? Icons.hourglass_empty_rounded
                  : status == 'approved'
                  ? Icons.check_circle_outline
                  : Icons.cancel_outlined,
              color: Colors.white12,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              status == 'all' ? 'No bookings yet' : 'No $status bookings',
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

    final statusColor = isPending
        ? Colors.orange
        : isApproved
        ? Colors.green
        : isRejected
        ? Colors.red
        : Colors.white38;

    final statusLabel = isPending
        ? 'Pending'
        : isApproved
        ? 'Approved'
        : isRejected
        ? 'Rejected'
        : status;

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
              : isRejected
              ? Colors.red.withOpacity(0.2)
              : Colors.white10,
        ),
      ),
      child: Column(
        children: [
          // ── Header ──────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
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

          // ── Details Row ─────────────────────
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

          // ── Buttons ─────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                // "View Details" — كل الحالات
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pushNamed(
                      context,
                      '/booking-confirmed',
                      arguments: {
                        'bookingId': b['id'],
                        'tourName': b['tourName'],
                        'travelers': travelers,
                        'totalPrice': totalPrice,
                        'selectedDate': b['selectedDate'],
                      },
                    ),
                    icon: const Icon(Icons.info_outline, size: 15),
                    label: const Text('View Details'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white70,
                      side: BorderSide(color: Colors.white.withOpacity(0.15)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      textStyle: const TextStyle(fontSize: 13),
                    ),
                  ),
                ),

                // "Receipt" — Approved فقط
                if (isApproved) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CompletePaymentScreen(
                            bookingId: int.tryParse(b['id']) ?? 0,
                            amount: totalPrice,
                            tourName: b['tourName'],
                          ),
                        ),
                      ),
                      icon: const Icon(Icons.upload_file_rounded, size: 15),
                      label: const Text('Receipt'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        foregroundColor: Colors.black,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        textStyle: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // ── Rejected note ────────────────────
          if (isRejected)
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
      ),
    );
  }

  Widget _infoChip(IconData icon, String label) => Row(
    children: [
      Icon(icon, color: Colors.white38, size: 13),
      const SizedBox(width: 5),
      Text(label, style: const TextStyle(color: Colors.white38, fontSize: 12)),
    ],
  );

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
}
