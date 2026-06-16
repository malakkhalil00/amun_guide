// 📁 lib/screens/guide/guide_tour_form_screen.dart

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/tours_service.dart';

class GuideTourFormScreen extends StatefulWidget {
  /// Pass tour data for edit mode, null for create mode
  final Map<String, dynamic>? tour;

  const GuideTourFormScreen({super.key, this.tour});

  @override
  State<GuideTourFormScreen> createState() => _GuideTourFormScreenState();
}

class _GuideTourFormScreenState extends State<GuideTourFormScreen> {
  final _toursService = ToursService();
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _durationCtrl = TextEditingController();
  final _maxGroupCtrl = TextEditingController();
  final _meetingPointCtrl = TextEditingController();
  final _imageUrlCtrl = TextEditingController();

  String _paymentMethod = 'cash';
  String _status = 'active';
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  bool _isLoading = false;
  bool get _isEdit => widget.tour != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) _populateFields();
  }

  void _populateFields() {
    final t = widget.tour!;
    _titleCtrl.text = t['title'] ?? '';
    _descCtrl.text = t['description'] ?? '';
    _locationCtrl.text = t['location'] ?? '';
    _priceCtrl.text = t['price']?.toString() ?? '';
    _durationCtrl.text = t['duration']?.toString() ?? t['duration_days']?.toString() ?? '';
    _maxGroupCtrl.text = t['max_group_size']?.toString() ?? '';
    _meetingPointCtrl.text = t['meeting_point'] ?? '';
    _imageUrlCtrl.text = t['image_url'] ?? t['tour_image_url'] ?? '';
    _paymentMethod = t['payment_method'] ?? 'cash';
    _status = t['status'] ?? 'active';
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _locationCtrl.dispose();
    _priceCtrl.dispose();
    _durationCtrl.dispose();
    _maxGroupCtrl.dispose();
    _meetingPointCtrl.dispose();
    _imageUrlCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.gold,
            onPrimary: Colors.black,
            surface: AppColors.bgCard,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? const TimeOfDay(hour: 9, minute: 0),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.gold,
            onPrimary: Colors.black,
            surface: AppColors.bgCard,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final data = {
        'title': _titleCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'location': _locationCtrl.text.trim(),
        'price': double.tryParse(_priceCtrl.text.trim()) ?? 0,
        'duration_days': int.tryParse(_durationCtrl.text.trim()) ?? 1,
        'max_group_size': int.tryParse(_maxGroupCtrl.text.trim()) ?? 10,
        'meeting_point': _meetingPointCtrl.text.trim(),
        'payment_method': _paymentMethod,
        'status': _status,
        if (_imageUrlCtrl.text.trim().isNotEmpty)
          'image_url': _imageUrlCtrl.text.trim(),
        if (_selectedDate != null)
          'start_date': _selectedDate!.toIso8601String().split('T').first,
        if (_selectedTime != null)
          'start_time':
              '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}',
      };

      if (_isEdit) {
        await _toursService.updateTour(widget.tour!['id'], data);
        _showSnack('Tour updated successfully ✓', AppColors.gold);
      } else {
        await _toursService.createTour(data);
        _showSnack('Tour created successfully ✓', AppColors.gold);
      }

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      _showSnack(_isEdit ? 'Failed to update tour' : 'Failed to create tour',
          Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  // ════════════════════════════════════════════════════════════
  // BUILD
  // ════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _buildHeader()),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
            sliver: SliverToBoxAdapter(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionLabel('Basic Info'),
                    const SizedBox(height: 12),
                    _inputField(
                      controller: _titleCtrl,
                      label: 'Tour Title',
                      hint: 'e.g. Pyramids & Sphinx Day Tour',
                      icon: Icons.title_rounded,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Title is required' : null,
                    ),
                    const SizedBox(height: 12),
                    _inputField(
                      controller: _descCtrl,
                      label: 'Description',
                      hint: 'Describe the tour experience...',
                      icon: Icons.description_outlined,
                      maxLines: 4,
                    ),
                    const SizedBox(height: 12),
                    _inputField(
                      controller: _locationCtrl,
                      label: 'Location',
                      hint: 'e.g. Cairo, Egypt',
                      icon: Icons.location_on_outlined,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Location is required' : null,
                    ),
                    const SizedBox(height: 24),

                    _sectionLabel('Pricing & Duration'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _inputField(
                            controller: _priceCtrl,
                            label: 'Price per Person (\$)',
                            hint: '0.00',
                            icon: Icons.attach_money_rounded,
                            keyboardType: TextInputType.number,
                            validator: (v) =>
                                v == null || v.isEmpty ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _inputField(
                            controller: _durationCtrl,
                            label: 'Duration (days)',
                            hint: '1',
                            icon: Icons.schedule_rounded,
                            keyboardType: TextInputType.number,
                            validator: (v) =>
                                v == null || v.isEmpty ? 'Required' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _inputField(
                      controller: _maxGroupCtrl,
                      label: 'Max Group Size',
                      hint: '10',
                      icon: Icons.people_outline_rounded,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 24),

                    _sectionLabel('Schedule'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _datePicker()),
                        const SizedBox(width: 12),
                        Expanded(child: _timePicker()),
                      ],
                    ),
                    const SizedBox(height: 24),

                    _sectionLabel('Meeting Point'),
                    const SizedBox(height: 12),
                    _inputField(
                      controller: _meetingPointCtrl,
                      label: 'Meeting Point',
                      hint: 'e.g. Giza Plateau Entrance Gate',
                      icon: Icons.flag_outlined,
                    ),
                    const SizedBox(height: 24),

                    _sectionLabel('Payment Method'),
                    const SizedBox(height: 12),
                    _paymentMethodPicker(),
                    const SizedBox(height: 24),

                    _sectionLabel('Tour Image URL (optional)'),
                    const SizedBox(height: 12),
                    _inputField(
                      controller: _imageUrlCtrl,
                      label: 'Image URL',
                      hint: 'https://...',
                      icon: Icons.image_outlined,
                    ),
                    const SizedBox(height: 24),

                    if (_isEdit) ...[
                      _sectionLabel('Status'),
                      const SizedBox(height: 12),
                      _statusPicker(),
                      const SizedBox(height: 24),
                    ],

                    // Submit button
                    GestureDetector(
                      onTap: _isLoading ? null : _submit,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        decoration: BoxDecoration(
                          color: _isLoading
                              ? AppColors.goldDark
                              : AppColors.gold,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.gold.withValues(alpha: 0.35),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (_isLoading)
                              const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.black,
                                  strokeWidth: 2,
                                ),
                              )
                            else
                              Icon(
                                _isEdit
                                    ? Icons.save_rounded
                                    : Icons.add_circle_rounded,
                                color: Colors.black,
                                size: 22,
                              ),
                            const SizedBox(width: 10),
                            Text(
                              _isLoading
                                  ? 'Please wait...'
                                  : _isEdit
                                      ? 'Save Changes'
                                      : 'Create Tour',
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  // HEADER
  // ════════════════════════════════════════════════════════════

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, MediaQuery.of(context).padding.top + 16, 20, 20),
      decoration: const BoxDecoration(
        color: AppColors.bgCard,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.bgInput,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white, size: 16),
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_isEdit ? 'Edit Tour' : 'Create New Tour',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              Text(_isEdit ? 'Update tour details' : 'Fill in tour information',
                  style: const TextStyle(color: Colors.white38, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  // COMPONENTS
  // ════════════════════════════════════════════════════════════

  Widget _sectionLabel(String text) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            color: AppColors.gold,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(text,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(color: Colors.white54, fontSize: 13),
        hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
        prefixIcon: Icon(icon, color: AppColors.gold, size: 18),
        filled: true,
        fillColor: AppColors.bgCard,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.gold),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }

  Widget _datePicker() {
    return GestureDetector(
      onTap: _pickDate,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: _selectedDate != null ? AppColors.gold : AppColors.border),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined,
                color: AppColors.gold, size: 16),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Start Date',
                      style:
                          TextStyle(color: Colors.white38, fontSize: 11)),
                  const SizedBox(height: 2),
                  Text(
                    _selectedDate != null
                        ? '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}'
                        : 'Select date',
                    style: TextStyle(
                        color: _selectedDate != null
                            ? Colors.white
                            : Colors.white38,
                        fontSize: 13,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _timePicker() {
    return GestureDetector(
      onTap: _pickTime,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: _selectedTime != null ? AppColors.gold : AppColors.border),
        ),
        child: Row(
          children: [
            const Icon(Icons.access_time_rounded,
                color: AppColors.gold, size: 16),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Start Time',
                      style:
                          TextStyle(color: Colors.white38, fontSize: 11)),
                  const SizedBox(height: 2),
                  Text(
                    _selectedTime != null
                        ? _selectedTime!.format(context)
                        : 'Select time',
                    style: TextStyle(
                        color: _selectedTime != null
                            ? Colors.white
                            : Colors.white38,
                        fontSize: 13,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _paymentMethodPicker() {
    final methods = [
      {'value': 'cash', 'label': 'Cash', 'icon': Icons.money_rounded},
      {'value': 'card', 'label': 'Card', 'icon': Icons.credit_card_rounded},
      {'value': 'both', 'label': 'Both', 'icon': Icons.payment_rounded},
    ];

    return Row(
      children: methods.map((m) {
        final isActive = _paymentMethod == m['value'];
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _paymentMethod = m['value'] as String),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: isActive ? AppColors.goldDim : AppColors.bgCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: isActive ? AppColors.gold : AppColors.border),
              ),
              child: Column(
                children: [
                  Icon(m['icon'] as IconData,
                      color: isActive ? AppColors.gold : Colors.white38,
                      size: 20),
                  const SizedBox(height: 6),
                  Text(m['label'] as String,
                      style: TextStyle(
                          color: isActive ? AppColors.gold : Colors.white38,
                          fontSize: 12,
                          fontWeight: isActive
                              ? FontWeight.bold
                              : FontWeight.normal)),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _statusPicker() {
    final statuses = [
      {'value': 'active', 'label': 'Active', 'color': Colors.green},
      {'value': 'draft', 'label': 'Draft', 'color': Colors.white38},
      {'value': 'cancelled', 'label': 'Cancelled', 'color': Colors.red},
    ];

    return Row(
      children: statuses.map((s) {
        final isActive = _status == s['value'];
        final color = s['color'] as Color;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _status = s['value'] as String),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isActive
                    ? color.withValues(alpha: 0.1)
                    : AppColors.bgCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: isActive
                        ? color.withValues(alpha: 0.4)
                        : AppColors.border),
              ),
              child: Center(
                child: Text(s['label'] as String,
                    style: TextStyle(
                        color: isActive ? color : Colors.white38,
                        fontSize: 13,
                        fontWeight: isActive
                            ? FontWeight.bold
                            : FontWeight.normal)),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}