// 📁 lib/screens/payment/complete_payment_screen.dart

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/payment_service.dart';
import '../../core/widgets/amun_app_bar.dart';
import '../../core/widgets/amun_button.dart';

class CompletePaymentScreen extends StatefulWidget {
  final int? bookingId;
  final double? amount;
  final String? tourName;

  const CompletePaymentScreen({
    super.key,
    this.bookingId,
    this.amount,
    this.tourName,
  });

  @override
  State<CompletePaymentScreen> createState() => _CompletePaymentScreenState();
}

class _CompletePaymentScreenState extends State<CompletePaymentScreen> {
  final _paymentService  = PaymentService();
  final _urlController   = TextEditingController();
  final _notesController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _urlController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submitPayment() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      _showError('Please enter the receipt image URL');
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
        amount:          widget.amount ?? 0.0,
        payableType:     'tour_bookings',
        payableId:       bookingId,
        receiptImageUrl: url,
        notes:           _notesController.text.trim(),
      );

      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        '/payment-success',
        arguments: {
          'transactionId': response.data['data']?['id']?.toString() ?? '',
          'tourName':      widget.tourName ?? '',
          'amount':        widget.amount?.toStringAsFixed(0) ?? '',
          'submittedAt':   DateTime.now().toString().substring(0, 16),
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

            // ── Booking Banner ──────────────────
            if (widget.bookingId != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.goldDim,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderGold),
                ),
                child: Row(children: [
                  const Icon(Icons.confirmation_number_outlined,
                      color: AppColors.gold, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.tourName ?? 'Tour Booking',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13)),
                        const SizedBox(height: 2),
                        Text(
                          'Total Amount: \$${widget.amount?.toStringAsFixed(0) ?? '0'}',
                          style: const TextStyle(
                              color: AppColors.gold, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: 24),
            ],

            // ── Payment Information ─────────────
            const Text('Payment Information',
                style: TextStyle(
                    color: AppColors.gold,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            // Receipt URL
            const Text('Receipt Image URL',
                style: TextStyle(color: Colors.white70, fontSize: 13)),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1E1A16),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.gold.withOpacity(0.25)),
              ),
              child: TextField(
                controller: _urlController,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                keyboardType: TextInputType.url,
                decoration: InputDecoration(
                  hintText: 'https://...',
                  hintStyle: TextStyle(
                      color: Colors.white.withOpacity(0.25), fontSize: 13),
                  prefixIcon: const Icon(Icons.link,
                      color: Colors.white38, size: 18),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Notes
            const Text('Notes',
                style: TextStyle(color: Colors.white70, fontSize: 13)),
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
                      color: Colors.white.withOpacity(0.25), fontSize: 13),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ── Confirm Button ──────────────────
            _isSubmitting
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.gold))
                : AmunButton(
                    label: 'Confirm Payment',
                    onTap: _submitPayment,
                    icon: Icons.check_circle_outline,
                  ),
          ],
        ),
      ),
    );
  }
}