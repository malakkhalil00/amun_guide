// 📁 lib/screens/payment/payment_receipts_screen.dart

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_assets.dart';
import '../../core/services/payment_service.dart';
import '../../core/widgets/amun_app_bar.dart';
import '../../core/widgets/amun_button.dart';
import '../../core/widgets/amun_filter_chip.dart';

class PaymentReceiptsScreen extends StatefulWidget {
  const PaymentReceiptsScreen({super.key});

  @override
  State<PaymentReceiptsScreen> createState() => _PaymentReceiptsScreenState();
}

class _PaymentReceiptsScreenState extends State<PaymentReceiptsScreen> {
  int _activeFilter = 0;
  final _filters = ['All', 'Pending', 'Approved', 'Rejected'];
  final _paymentService = PaymentService();
  bool _isLoading = true;

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
        _receipts = items.map<_Receipt>((p) => _Receipt(
          id: p['id']?.toString() ?? '',
          tour: p['payable']?['title'] ?? p['tour_name'] ?? 'Tour Payment',
          amount: '\$${p['amount'] ?? 0}',
          date: p['created_at']?.toString().substring(0, 10) ?? '',
          image: p['receipt_image'] ?? '',
          status: p['status'] ?? 'Pending',
        )).toList();
      });
    } catch (e) {
      debugPrint('Error loading payments: $e');
      // Fallback to static data
      setState(() {
        _receipts = [
          _Receipt(id: 'TRX-88392', tour: 'Luxor & Aswan Adventure', amount: '\$450.00', date: '12 Oct 2024', image: AppAssets.receipt1, status: 'Pending'),
          _Receipt(id: 'TRX-77281', tour: 'Giza Pyramids Day Tour', amount: '\$150.00', date: '05 Oct 2024', image: AppAssets.receipt2, status: 'Approved'),
        ];
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<_Receipt> get _filtered => _activeFilter == 0
      ? _receipts
      : _receipts.where((r) => r.status == _filters[_activeFilter]).toList();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: const AmunAppBar(title: 'Payment Receipts'),
      body: Column(children: [

        // ─── Upload Button ───────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: AmunButton(
            label: 'Upload New Receipt',
            onTap: () => _showUploadSheet(context),
            icon: Icons.upload_file_outlined,
          ),
        ),

        const SizedBox(height: 16),

        // ─── Filters ─────────────────────────────
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

        // ─── List ─────────────────────────────────
        Expanded(
          child: _filtered.isEmpty
              ? _buildEmpty()
              : ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            itemCount: _filtered.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) => _receiptCard(_filtered[i], context),
          ),
        ),
      ]),
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
      child: Row(children: [

        // Receipt thumbnail
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            width: 60, height: 60,
            child: Image.asset(r.image, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                    color: AppColors.bgInput,
                    child: const Icon(Icons.receipt_long,
                        color: Colors.white24, size: 28))),
          ),
        ),

        const SizedBox(width: 12),

        // Info
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(r.tour,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 3),
            Text('ID: ${r.id}',
                style: const TextStyle(
                    color: Colors.white38, fontSize: 11)),
            const SizedBox(height: 3),
            Text(r.date,
                style: const TextStyle(
                    color: Colors.white38, fontSize: 11)),
          ]),
        ),

        // Amount + Status
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(r.amount,
              style: const TextStyle(
                  color: AppColors.gold,
                  fontWeight: FontWeight.bold,
                  fontSize: 14)),
          const SizedBox(height: 6),
          _statusBadge(r.status),
        ]),
      ]),
    );
  }

  Widget _statusBadge(String status) {
    Color color;
    switch (status) {
      case 'Approved': color = Colors.green; break;
      case 'Rejected': color = Colors.red;   break;
      default:         color = AppColors.gold;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(status,
          style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined,
              color: Colors.white24, size: 80),
          SizedBox(height: 16),
          Text('No receipts found',
              style: TextStyle(color: Colors.white54, fontSize: 16)),
        ],
      ),
    );
  }

  void _showUploadSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 20),
          const Text('Upload Receipt',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          _uploadOption(Icons.camera_alt_outlined, 'Take Photo'),
          const SizedBox(height: 12),
          _uploadOption(Icons.photo_library_outlined, 'Choose from Gallery'),
          const SizedBox(height: 12),
          _uploadOption(Icons.file_present_outlined, 'Upload File (PDF)'),
          const SizedBox(height: 24),
        ]),
      ),
    );
  }

  Widget _uploadOption(IconData icon, String label) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.bgInput,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(children: [
          Icon(icon, color: AppColors.gold, size: 22),
          const SizedBox(width: 14),
          Text(label,
              style: const TextStyle(color: Colors.white, fontSize: 14)),
          const Spacer(),
          const Icon(Icons.arrow_forward_ios,
              color: Colors.white24, size: 14),
        ]),
      ),
    );
  }
}

class _Receipt {
  final String id, tour, amount, date, image, status;
  const _Receipt({
    required this.id,
    required this.tour,
    required this.amount,
    required this.date,
    required this.image,
    required this.status,
  });
}