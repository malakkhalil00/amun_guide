// 📁 lib/screens/payment/payment_success_screen.dart

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/amun_button.dart';

class PaymentSuccessScreen extends StatefulWidget {
  const PaymentSuccessScreen({super.key});

  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  // بيانات من الـ arguments
  String _transactionId = '';
  String _tourName = '';
  String _amount = '';
  String _submittedAt = '';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _scaleAnim =
        CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _controller.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      _transactionId = args['transactionId']?.toString() ?? '';
      _tourName = args['tourName']?.toString() ?? '';
      _amount = args['amount']?.toString() ?? '';
      _submittedAt = args['submittedAt']?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // ── Animated Checkmark ───────────────
              ScaleTransition(
                scale: _scaleAnim,
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    color: AppColors.goldDim,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.gold, width: 3),
                  ),
                  child: const Icon(Icons.check_rounded,
                      color: AppColors.gold, size: 60),
                ),
              ),

              const SizedBox(height: 32),

              const Text('Receipt Uploaded!',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold)),

              const SizedBox(height: 12),

              const Text(
                'Your receipt has been submitted\nsuccessfully and is under review.',
                textAlign: TextAlign.center,
                style:
                    TextStyle(color: Colors.white54, fontSize: 15, height: 1.6),
              ),

              const SizedBox(height: 32),

              // ── Transaction Details ──────────────
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(children: [
                  if (_transactionId.isNotEmpty) ...[
                    _detailRow('Transaction ID', '#$_transactionId'),
                    const Divider(color: Colors.white10, height: 24),
                  ],
                  if (_tourName.isNotEmpty) ...[
                    _detailRow('Tour', _tourName),
                    const Divider(color: Colors.white10, height: 24),
                  ],
                  if (_amount.isNotEmpty) ...[
                    _detailRow('Amount', '\$$_amount',
                        valueColor: AppColors.gold),
                    const Divider(color: Colors.white10, height: 24),
                  ],
                  _detailRow('Status', 'Under Review',
                      valueColor: Colors.orange),
                  if (_submittedAt.isNotEmpty) ...[
                    const Divider(color: Colors.white10, height: 24),
                    _detailRow('Submitted', _submittedAt),
                  ],
                ]),
              ),

              const Spacer(),

              // ── Buttons ──────────────────────────
              AmunButton(
                label: 'Back to Dashboard',
                onTap: () => Navigator.pushNamedAndRemoveUntil(
                    context, '/home', (route) => false),
                icon: Icons.home_outlined,
              ),

              const SizedBox(height: 12),

              AmunButton(
                label: 'View All Receipts',
                onTap: () => Navigator.pushReplacementNamed(
                    context, '/payment-receipts'),
                variant: AmunButtonVariant.outlined,
                icon: Icons.receipt_long_outlined,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(color: Colors.white38, fontSize: 13)),
        Flexible(
          child: Text(value,
              textAlign: TextAlign.end,
              style: TextStyle(
                  color: valueColor ?? Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13)),
        ),
      ],
    );
  }
}