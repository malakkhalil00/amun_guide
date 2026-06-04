// 📁 lib/screens/payment/payment_receipts_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/payment_service.dart';
import '../../core/widgets/amun_app_bar.dart';
import '../../core/widgets/amun_button.dart';
import '../../core/widgets/amun_filter_chip.dart';

class PaymentReceiptsScreen extends StatefulWidget {
  // ← بتاخد دول من شاشة My Bookings
  final int? bookingId;
  final double? amount;
  final String? tourName;

  const PaymentReceiptsScreen({
    super.key,
    this.bookingId,
    this.amount,
    this.tourName,
  });

  @override
  State<PaymentReceiptsScreen> createState() => _PaymentReceiptsScreenState();
}

class _PaymentReceiptsScreenState extends State<PaymentReceiptsScreen> {
  int _activeFilter = 0;
  final _filters = ['All', 'Pending', 'Approved', 'Rejected'];
  final _paymentService = PaymentService();
  bool _isLoading = true;
  bool _isUploading = false;
  List<_Receipt> _receipts = [];

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  Future<void> _loadPayments() async {
    setState(() => _isLoading = true);
    try {
      final response = await _paymentService.getMyPayments();
      final data = response.data;
      final List items = data['data'] ?? data ?? [];
      setState(() {
        _receipts = items
            .map<_Receipt>(
              (p) => _Receipt(
                id: p['id']?.toString() ?? '',
                tour:
                    p['payable']?['title'] ?? p['tour_name'] ?? 'Tour Payment',
                amount: '\$${p['amount'] ?? 0}',
                date: p['created_at']?.toString().substring(0, 10) ?? '',
                imageUrl: p['receipt_image'] ?? '',
                status: p['status'] ?? 'Pending',
              ),
            )
            .toList();
      });
    } catch (e) {
      debugPrint('Error loading payments: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Upload Receipt ────────────────────────────────────────────────────────
  Future<void> _pickAndUpload(ImageSource source) async {
    Navigator.pop(context); // أغلق الـ bottom sheet

    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1200,
    );
    if (picked == null) return;

    // لو مفيش bookingId معناها بيفتح الشاشة بدون booking context
    final bookingId = widget.bookingId;
    final amount = widget.amount ?? 0.0;

    if (bookingId == null) {
      _showError('No booking selected.');
      return;
    }

    setState(() => _isUploading = true);

    try {
      final response = await _paymentService.storePayment(
        amount: amount,
        payableType: 'App\\Models\\TourBooking',
        payableId: bookingId,
        receiptImagePath: picked.path,
      );

      if (!mounted) return;
      final data = response.data['data'] ?? response.data;
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
      debugPrint('Upload error: $e');
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/payment-failed');
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }
  // ─────────────────────────────────────────────────────────────────────────

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

  List<_Receipt> get _filtered => _activeFilter == 0
      ? _receipts
      : _receipts.where((r) => r.status == _filters[_activeFilter]).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: const AmunAppBar(title: 'Payment Receipts'),
      body: Stack(
        children: [
          Column(
            children: [
              // ── لو جاي من Booking معين: اعرض ملخص ──
              if (widget.bookingId != null) ...[
                _bookingBanner(),
                const SizedBox(height: 8),
              ],

              // ── Upload Button ─────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: AmunButton(
                  label: 'Upload New Receipt',
                  onTap: () => _showUploadSheet(context),
                  icon: Icons.upload_file_outlined,
                ),
              ),

              const SizedBox(height: 16),

              // ── Filters ───────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(
                      _filters.length,
                      (i) => AmunFilterChip(
                        label: _filters[i],
                        isActive: _activeFilter == i,
                        onTap: () => setState(() => _activeFilter = i),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ── List ──────────────────────────────
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: AppColors.gold),
                      )
                    : _filtered.isEmpty
                    ? _buildEmpty()
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                        itemCount: _filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (_, i) =>
                            _receiptCard(_filtered[i], context),
                      ),
              ),
            ],
          ),

          // ── Loading Overlay أثناء الرفع ──────────
          if (_isUploading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: AppColors.gold),
                    SizedBox(height: 16),
                    Text(
                      'Uploading receipt...',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Banner يوضح بيانات الـ Booking ──────────────────────────────────────
  Widget _bookingBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.goldDim,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGold),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.gold, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.tourName ?? 'Tour Booking',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Amount due: \$${widget.amount?.toStringAsFixed(0) ?? '0'}',
                  style: const TextStyle(color: AppColors.gold, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _receiptCard(_Receipt r, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          // Receipt thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 60,
              height: 60,
              child: r.imageUrl.startsWith('http')
                  ? Image.network(
                      r.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _receiptPlaceholder(),
                    )
                  : _receiptPlaceholder(),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  r.tour,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  'ID: ${r.id}',
                  style: const TextStyle(color: Colors.white38, fontSize: 11),
                ),
                const SizedBox(height: 3),
                Text(
                  r.date,
                  style: const TextStyle(color: Colors.white38, fontSize: 11),
                ),
              ],
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                r.amount,
                style: const TextStyle(
                  color: AppColors.gold,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 6),
              _statusBadge(r.status),
            ],
          ),
        ],
      ),
    );
  }

  Widget _receiptPlaceholder() => Container(
    color: AppColors.bgInput,
    child: const Icon(Icons.receipt_long, color: Colors.white24, size: 28),
  );

  Widget _statusBadge(String status) {
    Color color;
    switch (status) {
      case 'Approved':
        color = Colors.green;
        break;
      case 'Rejected':
        color = Colors.red;
        break;
      default:
        color = AppColors.gold;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, color: Colors.white24, size: 80),
          SizedBox(height: 16),
          Text(
            'No receipts found',
            style: TextStyle(color: Colors.white54, fontSize: 16),
          ),
        ],
      ),
    );
  }

  void _showUploadSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Upload Receipt',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _uploadOption(
              Icons.camera_alt_outlined,
              'Take Photo',
              () => _pickAndUpload(ImageSource.camera),
            ),
            const SizedBox(height: 12),
            _uploadOption(
              Icons.photo_library_outlined,
              'Choose from Gallery',
              () => _pickAndUpload(ImageSource.gallery),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _uploadOption(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.bgInput,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.gold, size: 22),
            const SizedBox(width: 14),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
            const Spacer(),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white24,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}

class _Receipt {
  final String id, tour, amount, date, imageUrl, status;
  const _Receipt({
    required this.id,
    required this.tour,
    required this.amount,
    required this.date,
    required this.imageUrl,
    required this.status,
  });
}
