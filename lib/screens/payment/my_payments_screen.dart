// 📁 lib/screens/payment/my_payments_screen.dart

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/payment_service.dart';
import '../../core/widgets/amun_app_bar.dart';
import '../../core/widgets/amun_filter_chip.dart';

class MyPaymentsScreen extends StatefulWidget {
  const MyPaymentsScreen({super.key});

  @override
  State<MyPaymentsScreen> createState() => _MyPaymentsScreenState();
}

class _MyPaymentsScreenState extends State<MyPaymentsScreen> {
  final _paymentService = PaymentService();
  final _filters = ['All', 'Pending', 'Approved', 'Rejected'];
  int _activeFilter = 0;
  bool _isLoading = true;
  List<_Payment> _payments = [];

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
        _payments = items.map<_Payment>((p) => _Payment(
          id:      p['id']?.toString() ?? '',
          tour:    p['payable']?['details']?['tour_title'] ??
                   p['payable']?['title'] ??
                   'Tour Payment',
          amount:  '\$${p['amount'] ?? 0}',
          date:    p['created_at']?.toString().substring(0, 10) ?? '',
          status:  p['status_label'] ?? p['status'] ?? 'Pending',
        )).toList();
      });
    } catch (e) {
      debugPrint('Error loading payments: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<_Payment> get _filtered => _activeFilter == 0
      ? _payments
      : _payments.where((p) =>
          p.status.toLowerCase() == _filters[_activeFilter].toLowerCase()
        ).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: const AmunAppBar(title: 'My Payments'),
      body: Column(
        children: [
          // ── Filters ───────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
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

          const SizedBox(height: 12),

          // ── List ──────────────────────────────
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.gold))
                : _filtered.isEmpty
                    ? _buildEmpty()
                    : RefreshIndicator(
                        onRefresh: _loadPayments,
                        color: AppColors.gold,
                        backgroundColor: const Color(0xFF1E1A16),
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
                          itemCount: _filtered.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (_, i) => _paymentCard(_filtered[i]),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _paymentCard(_Payment p) {
    final color = p.status.toLowerCase() == 'approved'
        ? Colors.green
        : p.status.toLowerCase() == 'rejected'
            ? Colors.red
            : AppColors.gold;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1A16),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(children: [
        // Icon
        Container(
          width: 46, height: 46,
          decoration: BoxDecoration(
            color: AppColors.goldDim,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.receipt_long,
              color: AppColors.gold, size: 22),
        ),
        const SizedBox(width: 14),

        // Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(p.tour,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Text('ID: ${p.id}  •  ${p.date}',
                  style: const TextStyle(
                      color: Colors.white38, fontSize: 11)),
            ],
          ),
        ),

        // Amount + Status
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(p.amount,
                style: const TextStyle(
                    color: AppColors.gold,
                    fontWeight: FontWeight.bold,
                    fontSize: 15)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: color.withOpacity(0.4)),
              ),
              child: Text(p.status,
                  style: TextStyle(
                      color: color,
                      fontSize: 11,
                      fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ]),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined,
              color: Colors.white24, size: 64),
          SizedBox(height: 16),
          Text('No payments found',
              style: TextStyle(color: Colors.white38, fontSize: 15)),
        ],
      ),
    );
  }
}

class _Payment {
  final String id, tour, amount, date, status;
  const _Payment({
    required this.id,
    required this.tour,
    required this.amount,
    required this.date,
    required this.status,
  });
}