// 📁 lib/screens/booking/booking_confirmed_screen.dart

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class BookingConfirmedScreen extends StatefulWidget {
  const BookingConfirmedScreen({super.key});

  @override
  State<BookingConfirmedScreen> createState() => _BookingConfirmedScreenState();
}

class _BookingConfirmedScreenState extends State<BookingConfirmedScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _scaleAnim = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final bookingId = args?['bookingId']?.toString() ?? '';
    final tourName = args?['tourName']?.toString() ?? 'Your Tour';
    final travelers = args?['travelers'] ?? 1;
    final totalPrice = (args?['totalPrice'] ?? 0).toDouble();
    final dateStr = _formatDate(args?['selectedDate']);

    return Scaffold(
      backgroundColor: const Color(0xFF151411),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: FadeTransition(
            opacity: _fadeAnim,
            child: Column(
              children: [
                const Spacer(),

                // ── Animated Check ───────────────────
                ScaleTransition(
                  scale: _scaleAnim,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.gold.withOpacity(0.12),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.gold, width: 2.5),
                    ),
                    child: const Icon(Icons.check_rounded,
                        color: AppColors.gold, size: 52),
                  ),
                ),

                const SizedBox(height: 28),

                const Text('Booking Request Sent!',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Playfair Display')),

                const SizedBox(height: 10),

                Text(
                  'Your booking has been submitted.\nUpload your payment receipt from My Bookings.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 14,
                      height: 1.6),
                ),

                const SizedBox(height: 28),

                // ── Booking Details Card ─────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1A16),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.gold.withOpacity(0.25)),
                  ),
                  child: Column(children: [
                    if (bookingId.isNotEmpty) ...[
                      _detailRow('Booking ID', '#$bookingId'),
                      _divider(),
                    ],
                    _detailRow('Tour', tourName),
                    _divider(),
                    _detailRow('Date', dateStr),
                    _divider(),
                    _detailRow('Travelers',
                        '$travelers person${travelers > 1 ? 's' : ''}'),
                    _divider(),
                    _detailRow('Total',
                        '\$${totalPrice.toStringAsFixed(0)}',
                        valueColor: AppColors.gold),
                    _divider(),
                    _detailRow('Status', 'Pending Approval',
                        valueColor: Colors.orange),
                  ]),
                ),

                const SizedBox(height: 16),

                // ── Info Note ────────────────────────
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.withOpacity(0.2)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline,
                          color: Colors.orange, size: 16),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Your receipt will be reviewed by an admin. After payment approval, the guide can approve your booking.',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.55),
                              fontSize: 12,
                              height: 1.5),
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // ── Buttons ──────────────────────────
                // زرار My Bookings — الأهم
                ElevatedButton(
                  onPressed: () => Navigator.pushNamedAndRemoveUntil(
                      context, '/home', (r) => false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    minimumSize: const Size(double.infinity, 54),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.home_outlined, color: Colors.black, size: 18),
                      SizedBox(width: 8),
                      Text('Back to Home',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(color: Colors.white38, fontSize: 13)),
          Text(value,
              style: TextStyle(
                  color: valueColor ?? Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _divider() => const Padding(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Divider(color: Colors.white10, height: 1),
      );

  String _formatDate(String? iso) {
    if (iso == null) return '';
    try {
      final d = DateTime.parse(iso);
      const months = [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${d.day} ${months[d.month]} ${d.year}';
    } catch (_) {
      return '';
    }
  }
}
