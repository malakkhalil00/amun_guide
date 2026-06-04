// 📁 lib/screens/booking/booking_summary_screen.dart

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/tour_booking_service.dart';

class BookingSummaryScreen extends StatefulWidget {
  const BookingSummaryScreen({super.key});

  @override
  State<BookingSummaryScreen> createState() => _BookingSummaryScreenState();
}

class _BookingSummaryScreenState extends State<BookingSummaryScreen> {
  int _travelers = 1;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  bool _isLoading = false;
  final _bookingService = TourBookingService();

  // Tour data from arguments
  int _tourId = 0;
  String _tourName = '';
  String _guideName = '';
  double _pricePerPerson = 0;
  int _durationDays = 1;
  String _location = '';
  String _tourImageUrl = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      _tourId = args['id'] ?? args['tourId'] ?? 0;
      _tourName = args['name'] ?? args['title'] ?? '';
      _guideName = args['guideName'] ?? args['guide_name'] ?? '';
      _pricePerPerson = (args['price'] ?? 0).toDouble();
      _durationDays = args['duration_days'] ?? args['durationDays'] ?? 1;
      _location = args['location'] ?? '';
      _tourImageUrl = args['image'] ?? args['img'] ?? '';
    }
  }

  double get _totalPrice => _pricePerPerson * _travelers;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.gold,
              onPrimary: Colors.black,
              surface: Color(0xFF1E1A16),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _confirmBooking() async {
    if (_tourId <= 0) return;
    setState(() => _isLoading = true);
    try {
      final response = await _bookingService.createBooking(
        tourId: _tourId,
        participantsCount: _travelers,
      );
      final data = response.data;
      final booking = data['data'] ?? data;
      if (mounted) {
        Navigator.pushReplacementNamed(
          context,
          '/complete-payment',
          arguments: {
            'bookingId': booking['id'] is int
                ? booking['id']
                : int.tryParse(booking['id']?.toString() ?? '0') ?? 0,
            'tourName': _tourName,
            'amount': _totalPrice,
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Booking failed: ${e.toString().contains('422') ? 'Already booked or invalid data' : 'Please try again'}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateStr =
        '${_selectedDate.day} ${_monthName(_selectedDate.month)} ${_selectedDate.year}';

    return Scaffold(
      backgroundColor: const Color(0xFF151411),
      appBar: AppBar(
        backgroundColor: const Color(0xFF151411),
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
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
          'Booking Summary',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Tour Card ────────────────────────
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1A16),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.gold.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: SizedBox(
                            width: 70,
                            height: 70,
                            child: _tourImageUrl.startsWith('http')
                                ? Image.network(
                                    _tourImageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        _imgPlaceholder(),
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
                                _tourName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  height: 1.3,
                                ),
                              ),
                              if (_guideName.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.person_outline,
                                      color: AppColors.gold,
                                      size: 13,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _guideName,
                                      style: const TextStyle(
                                        color: AppColors.gold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              if (_location.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on_outlined,
                                      color: Colors.white.withOpacity(0.4),
                                      size: 13,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _location,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.4),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.schedule_outlined,
                                    color: Colors.white38,
                                    size: 13,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '$_durationDays Day Tour',
                                    style: const TextStyle(
                                      color: Colors.white38,
                                      fontSize: 12,
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

                  const SizedBox(height: 24),

                  // ── Date Picker ──────────────────────
                  _sectionLabel('Select Date'),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: _pickDate,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1A16),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.gold.withOpacity(0.25),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.gold.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.calendar_today_outlined,
                              color: AppColors.gold,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              dateStr,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.edit_outlined,
                            color: Colors.white38,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Travelers Counter ────────────────
                  _sectionLabel('Number of Travelers'),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1A16),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.gold.withOpacity(0.25),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.gold.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.people_outline,
                            color: AppColors.gold,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            '$_travelers Traveler${_travelers > 1 ? 's' : ''}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            _counterBtn(Icons.remove, () {
                              if (_travelers > 1) setState(() => _travelers--);
                            }),
                            const SizedBox(width: 12),
                            Text(
                              '$_travelers',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 12),
                            _counterBtn(Icons.add, () {
                              if (_travelers < 20) setState(() => _travelers++);
                            }),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Price Breakdown ──────────────────
                  _sectionLabel('Price Breakdown'),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1A16),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.gold.withOpacity(0.25),
                      ),
                    ),
                    child: Column(
                      children: [
                        _priceRow(
                          '\$$_pricePerPerson × $_travelers traveler${_travelers > 1 ? 's' : ''}',
                          '\$${_totalPrice.toStringAsFixed(0)}',
                        ),
                        const SizedBox(height: 12),
                        Container(height: 1, color: Colors.white10),
                        const SizedBox(height: 12),
                        _priceRow(
                          'Total',
                          '\$${_totalPrice.toStringAsFixed(0)}',
                          isTotal: true,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Info note
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.gold.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: AppColors.gold,
                          size: 16,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'After confirming, you\'ll need to upload your payment receipt. Your booking will be reviewed by the guide.',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.55),
                              fontSize: 12,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Bottom Button ────────────────────────
          Container(
            padding: EdgeInsets.fromLTRB(
              20,
              16,
              20,
              MediaQuery.of(context).padding.bottom + 16,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF151411).withOpacity(0.97),
              border: Border(
                top: BorderSide(color: Colors.white.withOpacity(0.07)),
              ),
            ),
            child: ElevatedButton(
              onPressed: _isLoading ? null : _confirmBooking,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gold,
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.black,
                      ),
                    )
                  : const Text(
                      'Confirm Booking',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(
    text,
    style: const TextStyle(
      color: Colors.white,
      fontSize: 15,
      fontWeight: FontWeight.w600,
    ),
  );

  Widget _counterBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppColors.gold.withOpacity(0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.gold.withOpacity(0.3)),
        ),
        child: Icon(icon, color: AppColors.gold, size: 16),
      ),
    );
  }

  Widget _priceRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isTotal ? Colors.white : Colors.white54,
            fontSize: isTotal ? 15 : 13,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isTotal ? AppColors.gold : Colors.white,
            fontSize: isTotal ? 18 : 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _imgPlaceholder() => Container(
    color: const Color(0xFF2A1F0E),
    child: const Icon(
      Icons.landscape_outlined,
      color: Colors.white24,
      size: 28,
    ),
  );

  String _monthName(int m) => [
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
  ][m];
}
