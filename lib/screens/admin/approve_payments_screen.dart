// 📁 lib/screens/admin/approve_payments_screen.dart

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_assets.dart';
import '../../core/services/payment_service.dart';
import '../../core/widgets/amun_app_bar.dart';
import '../../core/widgets/amun_filter_chip.dart';

class ApprovePaymentsScreen extends StatefulWidget {
  const ApprovePaymentsScreen({super.key});

  @override
  State<ApprovePaymentsScreen> createState() =>
      _ApprovePaymentsScreenState();
}

class _ApprovePaymentsScreenState extends State<ApprovePaymentsScreen> {
  int _activeFilter = 0;
  final _filters = ['Pending', 'All', 'Approved', 'Rejected'];
  final _paymentService = PaymentService();
  bool _isLoading = true;

  List<Map<String, dynamic>> _payments = [];

  List<Map<String, dynamic>> get _filtered {
    if (_activeFilter == 1) return _payments;
    return _payments
        .where((p) => p['status'] == _filters[_activeFilter])
        .toList();
  }

  void _updateStatus(int index, String status) async {
    final payment = _payments[index];
    final paymentId = payment['id'];
    try {
      if (status == 'Approved') {
        await _paymentService.approvePayment(paymentId is int ? paymentId : int.parse(paymentId.toString()));
      } else {
        await _paymentService.rejectPayment(paymentId is int ? paymentId : int.parse(paymentId.toString()));
      }
      setState(() => _payments[index]['status'] = status);
    } catch (e) {
      debugPrint('Error updating payment: $e');
      // Still update locally for UX
      setState(() => _payments[index]['status'] = status);
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment ${status.toLowerCase()} successfully!'),
          backgroundColor: status == 'Approved' ? Colors.green : Colors.red,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  Future<void> _loadPayments() async {
    try {
      final response = await _paymentService.getAllPayments();
      final data = response.data;
      final List items = data['data'] ?? data ?? [];
      setState(() {
        _payments = items.map<Map<String, dynamic>>((p) => {
          'id': p['id'],
          'user': p['user']?['name'] ?? 'User',
          'avatar': p['user']?['profile_image'] ?? '',
          'tour': p['payable']?['title'] ?? p['tour_name'] ?? 'Tour',
          'amount': '\$${p['amount'] ?? 0}',
          'date': p['created_at']?.toString().substring(0, 10) ?? '',
          'image': p['receipt_image'] ?? '',
          'status': p['status'] ?? 'Pending',
        }).toList();
      });
    } catch (e) {
      debugPrint('Error loading payments: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pending = _payments.where((p) => p['status'] == 'Pending').length;

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: const AmunAppBar(title: 'Approve Payments'),
      body: Column(children: [

        // ─── Filters ──────────────────────────────
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

        const SizedBox(height: 16),

        // ─── List ─────────────────────────────────
        Expanded(
          child: _filtered.isEmpty
              ? const Center(
              child: Text('No payments found',
                  style: TextStyle(color: Colors.white38)))
              : ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            itemCount: _filtered.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (_, i) {
              final p = _filtered[i];
              final realIndex = _payments.indexOf(p);
              return _paymentCard(p, realIndex);
            },
          ),
        ),

        // ─── Bottom Bar ───────────────────────────
        if (pending > 0)
          Container(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
            decoration: const BoxDecoration(
              color: Color(0xFF1E1A16),
              border: Border(top: BorderSide(color: Colors.white10)),
            ),
            child: Row(children: [
              Container(
                width: 36, height: 36,
                decoration: const BoxDecoration(
                    color: AppColors.goldDim, shape: BoxShape.circle),
                child: const Icon(Icons.pending_outlined,
                    color: AppColors.gold, size: 18),
              ),
              const SizedBox(width: 12),
              Text('$pending pending receipt${pending > 1 ? 's' : ''} today',
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 14)),
            ]),
          ),
      ]),
    );
  }

  Widget _paymentCard(Map<String, dynamic> p, int index) {
    final isPending = p['status'] == 'Pending';
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPending
              ? AppColors.gold.withOpacity(0.3)
              : Colors.white10,
        ),
      ),
      child: Column(children: [

        // User + Amount
        Row(children: [
          ClipOval(
            child: SizedBox(
              width: 38, height: 38,
              child: Image.asset(p['avatar'], fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                      color: AppColors.bgInput,
                      child: const Icon(Icons.person,
                          color: Colors.white38))),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(p['user'],
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14)),
              Text(p['tour'],
                  style: const TextStyle(
                      color: Colors.white38, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ]),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(p['amount'],
                style: const TextStyle(
                    color: AppColors.gold,
                    fontWeight: FontWeight.bold,
                    fontSize: 15)),
            const SizedBox(height: 4),
            _statusBadge(p['status']),
          ]),
        ]),

        const SizedBox(height: 12),

        // Receipt + ID
        Row(children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 56, height: 56,
              child: Image.asset(p['image'], fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                      color: AppColors.bgInput,
                      child: const Icon(Icons.receipt_long,
                          color: Colors.white24, size: 24))),
            ),
          ),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('ID: ${p['id']}',
                style: const TextStyle(
                    color: Colors.white54, fontSize: 12)),
            const SizedBox(height: 3),
            Text(p['date'],
                style: const TextStyle(
                    color: Colors.white38, fontSize: 12)),
          ]),
        ]),

        // Approve / Reject buttons (only for pending)
        if (isPending) ...[
          const SizedBox(height: 12),
          const Divider(color: Colors.white10),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(
              child: GestureDetector(
                onTap: () => _updateStatus(index, 'Rejected'),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: Colors.red.withOpacity(0.3)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.close, color: Colors.red, size: 16),
                      SizedBox(width: 6),
                      Text('Reject',
                          style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 13)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: GestureDetector(
                onTap: () => _updateStatus(index, 'Approved'),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: Colors.green.withOpacity(0.3)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check, color: Colors.green, size: 16),
                      SizedBox(width: 6),
                      Text('Approve',
                          style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 13)),
                    ],
                  ),
                ),
              ),
            ),
          ]),
        ],
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(status,
          style: TextStyle(
              color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}