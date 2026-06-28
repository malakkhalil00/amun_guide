// 📁 lib/screens/payment/complete_payment_screen.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/payment_service.dart';
import '../../core/widgets/amun_app_bar.dart';
import '../../core/widgets/amun_button.dart';

class CompletePaymentScreen extends StatefulWidget {
  final int? bookingId;
  final double? amount;
  final String? tourName;
  final String? guideName;
  final String? selectedDate;
  final int? travelers;

  const CompletePaymentScreen({
    super.key,
    this.bookingId,
    this.amount,
    this.tourName,
    this.guideName,
    this.selectedDate,
    this.travelers,
  });

  @override
  State<CompletePaymentScreen> createState() => _CompletePaymentScreenState();
}

class _CompletePaymentScreenState extends State<CompletePaymentScreen> {
  final _paymentService = PaymentService();
  final _notesController = TextEditingController();
  bool _isSubmitting = false;
  String? _receiptImagePath;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickReceiptImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _receiptImagePath = picked.path);
    }
  }

  Future<void> _submitPayment() async {
    final receiptPath = _receiptImagePath;
    if (receiptPath == null || receiptPath.isEmpty) {
      _showError('Please select the receipt image');
      return;
    }
    final bookingId = widget.bookingId;
    if (bookingId == null) {
      _showError('No booking selected.');
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      final response = await _paymentService.storePayment(
        amount: widget.amount ?? 0.0,
        payableType: 'tour_bookings',
        payableId: bookingId,
        receiptImagePath: receiptPath,
        notes: _notesController.text.trim(),
      );
      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        '/payment-success',
        arguments: {
          'transactionId': response.data['data']?['id']?.toString() ?? '',
          'tourName': widget.tourName ?? '',
          'amount': widget.amount?.toStringAsFixed(0) ?? '',
          'submittedAt': DateTime.now().toString().substring(0, 16),
        },
      );
    } catch (e) {
      debugPrint('Submit error: $e');
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/payment-failed');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: const AmunAppBar(title: 'Complete Payment'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Trip Details ────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1A16),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.gold.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Trip Details',
                    style: TextStyle(
                      color: AppColors.gold,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _detailRow(Icons.tour_outlined, widget.tourName ?? ''),
                  const SizedBox(height: 8),
                  _detailRow(Icons.person_outline, widget.guideName ?? ''),
                  const SizedBox(height: 8),
                  _detailRow(
                    Icons.calendar_today_outlined,
                    _formatDate(widget.selectedDate),
                  ),
                  const SizedBox(height: 8),
                  _detailRow(
                    Icons.people_outline,
                    '${widget.travelers ?? 1} traveler${(widget.travelers ?? 1) > 1 ? 's' : ''}',
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(color: Colors.white10),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Amount',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      Text(
                        '\$${widget.amount?.toStringAsFixed(0) ?? '0'}',
                        style: const TextStyle(
                          color: AppColors.gold,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Payment Methods ─────────────────
            const Text(
              'Payment Method',
              style: TextStyle(
                color: AppColors.gold,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            _paymentMethodCard(
              icon: Icons.phone_android_rounded,
              title: 'Vodafone Cash',
              subtitle: '010XXXXXXXX',
              color: const Color(0xFFE60000),
            ),
            const SizedBox(height: 10),
            _paymentMethodCard(
              icon: Icons.account_balance_rounded,
              title: 'Instapay',
              subtitle: '@yourinstapay',
              color: const Color(0xFF1B3FA0),
            ),

            const SizedBox(height: 24),

            // ── Receipt URL ─────────────────────
            const Text(
              'Payment Information',
              style: TextStyle(
                color: AppColors.gold,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Receipt Image',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickReceiptImage,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1A16),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.gold.withOpacity(0.25)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.gold.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: _receiptImagePath == null
                          ? const Icon(
                              Icons.upload_file,
                              color: AppColors.gold,
                              size: 24,
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                File(_receiptImagePath!),
                                fit: BoxFit.cover,
                              ),
                            ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        _receiptImagePath == null
                            ? 'Tap to select receipt image'
                            : _receiptImagePath!.split(RegExp(r'[\\/]')).last,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: _receiptImagePath == null
                              ? Colors.white38
                              : Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.image_outlined,
                      color: Colors.white38,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── Notes ───────────────────────────
            const Text(
              'Notes (optional)',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1E1A16),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white10),
              ),
              child: TextField(
                controller: _notesController,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Optional notes...',
                  hintStyle: TextStyle(
                    color: Colors.white.withOpacity(0.25),
                    fontSize: 13,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ── Confirm Button ──────────────────
            _isSubmitting
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.gold),
                  )
                : AmunButton(
                    label: 'Confirm Payment',
                    onTap: _submitPayment,
                    icon: Icons.check_circle_outline,
                  ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String text) {
    if (text.isEmpty) return const SizedBox.shrink();
    return Row(
      children: [
        Icon(icon, color: Colors.white38, size: 15),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ),
      ],
    );
  }

  Widget _paymentMethodCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1A16),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(color: Colors.white38, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
