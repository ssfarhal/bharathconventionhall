import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';
import '../../../services/supabase_service.dart';
import 'dashboard_header_widget.dart';

class AddBookingBottomSheet extends StatefulWidget {
  final Map<String, dynamic>? existingBooking;

  const AddBookingBottomSheet({this.existingBooking, super.key});

  @override
  State<AddBookingBottomSheet> createState() => _AddBookingBottomSheetState();
}

class _AddBookingBottomSheetState extends State<AddBookingBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _clientNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _guestCountCtrl = TextEditingController();
  final _totalAmountCtrl = TextEditingController();
  final _advanceCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  String _selectedEventType = 'Wedding';
  DateTime? _selectedDate;
  String _selectedFunctionTime = 'Day';
  bool _isSubmitting = false;

  final List<String> _eventTypes = [
    'Wedding',
    'Reception',
    'Engagement',
    'Birthday',
    'Corporate',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.existingBooking != null) {
      final b = widget.existingBooking!;
      _clientNameCtrl.text = b['clientName'] ?? '';
      _phoneCtrl.text = b['phone'] ?? '';
      _guestCountCtrl.text = '${b['guestCount'] ?? ''}';
      _totalAmountCtrl.text = '${b['totalAmount'] ?? ''}';
      _advanceCtrl.text = '${b['advancePaid'] ?? ''}';
      _notesCtrl.text = b['notes'] ?? '';
      _selectedEventType = b['eventType'] ?? 'Wedding';
      _selectedDate = b['eventDate'] as DateTime?;
      _selectedFunctionTime = b['functionTime'] ?? 'Day';
    }
  }

  @override
  void dispose() {
    _clientNameCtrl.dispose();
    _phoneCtrl.dispose();
    _guestCountCtrl.dispose();
    _totalAmountCtrl.dispose();
    _advanceCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(
            context,
          ).colorScheme.copyWith(primary: AppTheme.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an event date')),
      );
      return;
    }
    setState(() => _isSubmitting = true);

    final advance = double.tryParse(_advanceCtrl.text.trim()) ?? 0.0;
    final total = double.tryParse(_totalAmountCtrl.text.trim()) ?? 0.0;

    if (widget.existingBooking == null) {
      // Add new booking
      final bookingId = await SupabaseService.instance.generateNextBookingId();
      final newBooking = {
        'id': bookingId,
        'clientName': _clientNameCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'eventType': _selectedEventType,
        'eventDate': _selectedDate!,
        'functionTime': _selectedFunctionTime,
        'guestCount': int.tryParse(_guestCountCtrl.text.trim()) ?? 0,
        'totalAmount': total,
        'advancePaid': advance,
        'status': 'confirmed',
        'notes': _notesCtrl.text.trim(),
      };

      // Save to Supabase
      final saved = await SupabaseService.instance.insertBooking(newBooking);
      if (saved != null) {
        allBookingsMockData.add(saved);
      } else {
        // Fallback: keep in memory even if Supabase fails
        allBookingsMockData.add(newBooking);
      }
    } else {
      // Update existing booking
      final idx = allBookingsMockData.indexWhere(
        (b) => b['id'] == widget.existingBooking!['id'],
      );
      if (idx != -1) {
        final updated = {
          ...allBookingsMockData[idx],
          'clientName': _clientNameCtrl.text.trim(),
          'phone': _phoneCtrl.text.trim(),
          'eventType': _selectedEventType,
          'eventDate': _selectedDate!,
          'functionTime': _selectedFunctionTime,
          'guestCount': int.tryParse(_guestCountCtrl.text.trim()) ?? 0,
          'totalAmount': total,
          'advancePaid': advance,
          'notes': _notesCtrl.text.trim(),
        };
        allBookingsMockData[idx] = updated;
        await SupabaseService.instance.updateBooking(updated);
      }
    }

    if (mounted) {
      setState(() => _isSubmitting = false);
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.existingBooking == null
                ? 'Booking created successfully!'
                : 'Booking updated successfully!',
          ),
          backgroundColor: AppTheme.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFCCCCCC),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.existingBooking == null
                        ? 'New Booking'
                        : 'Edit Booking',
                    style: theme.textTheme.titleLarge,
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                    color: const Color(0xFF6B7280),
                  ),
                ],
              ),
            ),
            const Divider(height: 16),
            // Form
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionLabel('Client Details'),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _clientNameCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Client Name *',
                          prefixIcon: Icon(Icons.person_outline_rounded),
                        ),
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _phoneCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Phone Number *',
                          prefixIcon: Icon(Icons.phone_outlined),
                          prefixText: '+91 ',
                        ),
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Required';
                          if (v.length < 10) {
                            return 'Enter valid 10-digit number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      _sectionLabel('Event Details'),
                      const SizedBox(height: 10),
                      // Event type selector
                      DropdownButtonFormField<String>(
                        initialValue: _selectedEventType,
                        decoration: const InputDecoration(
                          labelText: 'Event Type *',
                          prefixIcon: Icon(Icons.celebration_outlined),
                        ),
                        items: _eventTypes
                            .map(
                              (e) => DropdownMenuItem(
                                value: e,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        color: AppTheme.eventTypeColor(e),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(e),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _selectedEventType = v!),
                      ),
                      const SizedBox(height: 12),
                      // Date picker
                      GestureDetector(
                        onTap: _pickDate,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceVariantLight,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppTheme.outlineLight,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.calendar_today_outlined,
                                size: 20,
                                color: Color(0xFF5A4A50),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _selectedDate == null
                                      ? 'Select Event Date *'
                                      : _formatDate(_selectedDate!),
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    color: _selectedDate == null
                                        ? const Color(0xFF5A4A50)
                                        : const Color(0xFF1A1A1A),
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right_rounded,
                                color: Color(0xFF9E9E9E),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Day or Night Function selector
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Function Time',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF5A4A50),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(
                                    () => _selectedFunctionTime = 'Day',
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _selectedFunctionTime == 'Day'
                                          ? AppTheme.primary
                                          : AppTheme.surfaceVariantLight,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: _selectedFunctionTime == 'Day'
                                            ? AppTheme.primary
                                            : AppTheme.outlineLight,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.wb_sunny_rounded,
                                          size: 18,
                                          color: _selectedFunctionTime == 'Day'
                                              ? Colors.white
                                              : const Color(0xFF5A4A50),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Day Function',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color:
                                                _selectedFunctionTime == 'Day'
                                                ? Colors.white
                                                : const Color(0xFF5A4A50),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(
                                    () => _selectedFunctionTime = 'Night',
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _selectedFunctionTime == 'Night'
                                          ? AppTheme.primary
                                          : AppTheme.surfaceVariantLight,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: _selectedFunctionTime == 'Night'
                                            ? AppTheme.primary
                                            : AppTheme.outlineLight,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.nightlight_round,
                                          size: 18,
                                          color:
                                              _selectedFunctionTime == 'Night'
                                              ? Colors.white
                                              : const Color(0xFF5A4A50),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Night Function',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color:
                                                _selectedFunctionTime == 'Night'
                                                ? Colors.white
                                                : const Color(0xFF5A4A50),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _guestCountCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Expected Guest Count',
                          prefixIcon: Icon(Icons.people_outline_rounded),
                          suffixText: 'guests',
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                      const SizedBox(height: 20),
                      _sectionLabel('Financial Details'),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _totalAmountCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Total Amount (₹) *',
                          prefixIcon: Icon(Icons.currency_rupee_rounded),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+\.?\d{0,2}'),
                          ),
                        ],
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Required';
                          if (double.tryParse(v) == null) {
                            return 'Invalid amount';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _advanceCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Advance Paid (₹)',
                          prefixIcon: Icon(Icons.payments_outlined),
                          helperText: 'Leave 0 if no advance collected yet',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+\.?\d{0,2}'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _sectionLabel('Additional Notes'),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _notesCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Notes / Special Requirements',
                          prefixIcon: Icon(Icons.notes_rounded),
                          alignLabelWithHint: true,
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 24),
                      // Submit button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: FilledButton(
                          onPressed: _isSubmitting ? null : _submit,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  widget.existingBooking == null
                                      ? 'Confirm Booking'
                                      : 'Update Booking',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
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
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppTheme.primary,
        letterSpacing: 0.3,
      ),
    );
  }

  String _formatDate(DateTime d) {
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
    const days = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${days[d.weekday]}, ${d.day} ${months[d.month]} ${d.year}';
  }
}
