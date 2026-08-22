import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/app_export.dart';
import '../../../services/supabase_service.dart';
import '../../dashboard_screen/widgets/add_booking_bottom_sheet.dart';
import '../../dashboard_screen/widgets/dashboard_header_widget.dart';

import 'invoice_stub_helper.dart'
    if (dart.library.js_interop) 'invoice_web_helper.dart'
    as invoice_web;

class BookingDetailBottomSheet extends StatefulWidget {
  final Map<String, dynamic> booking;

  const BookingDetailBottomSheet({required this.booking, super.key});

  @override
  State<BookingDetailBottomSheet> createState() =>
      _BookingDetailBottomSheetState();
}

class _BookingDetailBottomSheetState extends State<BookingDetailBottomSheet> {
  late Map<String, dynamic> _booking;

  static const String _defaultTermsAndConditions =
      'RENTAL TERMS & CONDITIONS\n'
      '\n'
      '1. EXTRA CHARGES (Not Included in Standard Rent)\n'
      'The following items are billed separately if used: Generator, Cooler, Chair Covers, Speakers, Vegetarian Dining Hall.\n'
      '\n'
      '2. SECURITY DEPOSIT FOR EQUIPMENT\n'
      'A refundable deposit of ₹25,000 must be paid in advance if any equipment or appliances are taken or used from the premises. This will be refunded after the event, provided there is no damage, loss, or missing items.\n'
      '\n'
      '3. RENTAL TIMINGS\n'
      'Morning Shift: 5:00 AM – 5:00 PM\n'
      'Night Shift: 5:00 PM – 12:00 Midnight\n'
      'Note: Please adhere to the above timings. Any extensions must be approved in advance.\n'
      '\n'
      '4. RULES & DAMAGE LIABILITY\n'
      'Management will inspect the venue and equipment before and after the event. The client is fully responsible for any damage or loss caused to the venue, furniture, or appliances during the rental period.\n'
      '\n'
      '5. Personal Belongings & Valuables\n'
      'Guests must take care of their own belongings at all times. '
      'Management is not responsible for any loss, theft, or damage to personal items like cash, gold, mobile phones,laptops, cameras, tablet or other valuable items. '
      'Guests are advised to keep their valuables secure,Strictly speaking, management is not responsible.';

  @override
  void initState() {
    super.initState();
    _booking = Map<String, dynamic>.from(widget.booking);
  }

  String _fmt(double v) {
    final intVal = v.round();
    final formatted = intVal.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
    return '$formatted/-';
  }

  String _fmtFull(double v) {
    final intVal = v.round();
    final formatted = intVal.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
    return '$formatted/-';
  }

  String _formatDateFull(DateTime d) {
    const months = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    const days = [
      '',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return '${days[d.weekday]}, ${d.day} ${months[d.month]} ${d.year}';
  }

  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.errorContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.cancel_outlined,
                color: AppTheme.error,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Cancel Booking',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to cancel the booking for "${_booking['clientName']}"? This action cannot be undone.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            color: const Color(0xFF5A4A50),
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Keep Booking',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF9E9E9E),
              ),
            ),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              _cancelBooking();
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Cancel Booking',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _cancelBooking() {
    // Update status in shared data
    final idx = allBookingsMockData.indexWhere(
      (b) => b['id'] == _booking['id'],
    );
    if (idx != -1) {
      allBookingsMockData[idx]['status'] = 'cancelled';
    }
    setState(() {
      _booking['status'] = 'cancelled';
    });
    // Persist to Supabase
    SupabaseService.instance.updateBookingStatus(
      _booking['id'] as String,
      'cancelled',
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Booking for "${_booking['clientName']}" has been cancelled.',
        ),
        backgroundColor: AppTheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.errorContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.delete_outline_rounded,
                color: AppTheme.error,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Delete Booking',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: Text(
          'Permanently delete the booking for "${_booking['clientName']}"? This cannot be undone.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            color: const Color(0xFF5A4A50),
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Keep',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF9E9E9E),
              ),
            ),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              _deleteBooking();
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Delete',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _deleteBooking() {
    final id = _booking['id'] as String;
    allBookingsMockData.removeWhere((b) => b['id'] == id);
    // Persist to Supabase
    SupabaseService.instance.deleteBooking(id);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Booking deleted successfully.'),
        backgroundColor: AppTheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _collectBalance() async {
    final total = (_booking['totalAmount'] as double?) ?? 0.0;
    final advance = (_booking['advancePaid'] as double?) ?? 0.0;
    final balance = total - advance;

    if (balance <= 0) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.successContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.payments_outlined,
                color: AppTheme.success,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Collect Balance',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mark balance of ₹${_fmtFull(balance)} as collected from "${_booking['clientName']}"?',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: const Color(0xFF5A4A50),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.successContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: AppTheme.success,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This will update the advance paid to the full total amount.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: AppTheme.success,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF9E9E9E),
              ),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.success,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Confirm Collection',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _booking['advancePaid'] = total;
      });
      final idx = allBookingsMockData.indexWhere(
        (b) => b['id'] == _booking['id'],
      );
      if (idx != -1) {
        allBookingsMockData[idx]['advancePaid'] = total;
      }
      await SupabaseService.instance.updateBooking(_booking);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Balance of ₹${_fmtFull(balance)} collected successfully!',
            ),
            backgroundColor: AppTheme.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  Future<void> _generateInvoice() async {
    final total = (_booking['totalAmount'] as double?) ?? 0.0;
    final advance = (_booking['advancePaid'] as double?) ?? 0.0;
    final balance = total - advance;

    // If there is a balance due, ask whether to collect it before generating
    bool balanceCollected = false;
    double effectiveAdvance = advance;

    if (balance > 0 && mounted) {
      final result = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.successContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.payments_outlined,
                  color: AppTheme.success,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Balance Collection',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'There is a pending balance of ₹${_fmtFull(balance)}.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: const Color(0xFF5A4A50),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Has the balance been collected from the client?',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A1A1A),
                  height: 1.5,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, 'skip'),
              child: Text(
                'Not Yet',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF9E9E9E),
                ),
              ),
            ),
            OutlinedButton(
              onPressed: () => Navigator.pop(ctx, 'invoice_only'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primary,
                side: const BorderSide(color: AppTheme.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Generate Only',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
              ),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, 'collect'),
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.success,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Collected ✓',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      );

      if (result == 'collect') {
        balanceCollected = true;
        effectiveAdvance = total; // fully paid
        // Update booking in memory and persist
        setState(() {
          _booking['advancePaid'] = total;
        });
        final idx = allBookingsMockData.indexWhere(
          (b) => b['id'] == _booking['id'],
        );
        if (idx != -1) {
          allBookingsMockData[idx]['advancePaid'] = total;
        }
        await SupabaseService.instance.updateBooking(_booking);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Balance marked as collected!'),
              backgroundColor: AppTheme.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      } else if (result == null) {
        // Dialog dismissed — do nothing
        return;
      }
      // 'skip' or 'invoice_only' → generate invoice with existing balance
    }

    // Show Terms & Conditions editor before generating invoice
    if (!mounted) return;
    final termsController = TextEditingController(
      text: _defaultTermsAndConditions,
    );
    final termsResult = await showDialog<String>(
      context: context,
      builder: (ctx) => _TermsEditorDialog(controller: termsController),
    );
    termsController.dispose();

    if (termsResult == null) return; // User cancelled

    final date = _booking['eventDate'] as DateTime;
    final clientName = _booking['clientName'] as String;
    final phone = _booking['phone'] as String? ?? '';
    final eventType = _booking['eventType'] as String;
    final guestCount = _booking['guestCount'] as int? ?? 0;
    final notes = _booking['notes'] as String? ?? '';
    final status = _booking['status'] as String;
    final bookingId = _booking['id'] as String? ?? 'N/A';
    final invoiceDate = DateTime.now();
    final effectiveBalance = total - effectiveAdvance;

    final htmlContent = _buildInvoiceHtml(
      clientName: clientName,
      phone: phone,
      eventType: eventType,
      guestCount: guestCount,
      total: total,
      advance: effectiveAdvance,
      balance: effectiveBalance,
      notes: notes,
      status: status,
      bookingId: bookingId,
      date: date,
      invoiceDate: invoiceDate,
      balanceCollected: balanceCollected,
      termsAndConditions: termsResult,
    );

    final invoiceData = {
      'clientName': clientName,
      'phone': phone,
      'eventType': eventType,
      'guestCount': guestCount,
      'totalAmount': total,
      'advance': effectiveAdvance,
      'balance': effectiveBalance,
      'notes': notes,
      'status': status,
      'bookingId': bookingId,
      'eventDateStr': _formatDateFull(date),
      'invoiceDateStr':
          '${invoiceDate.day}/${invoiceDate.month}/${invoiceDate.year}',
      'termsAndConditions': termsResult,
      'functionTime': (_booking['functionTime'] as String?) ?? '',
    };

    await _downloadInvoice(
      htmlContent,
      'Invoice_${bookingId}_$clientName',
      invoiceData: invoiceData,
    );
  }

  String _buildInvoiceHtml({
    required String clientName,
    required String phone,
    required String eventType,
    required int guestCount,
    required double total,
    required double advance,
    required double balance,
    required String notes,
    required String status,
    required String bookingId,
    required DateTime date,
    required DateTime invoiceDate,
    bool balanceCollected = false,
    String termsAndConditions = '',
  }) {
    final termsHtml = termsAndConditions.trim().isNotEmpty
        ? termsAndConditions
              .split('\n')
              .where((line) => line.trim().isNotEmpty)
              .map((line) => '<li>${line.trim()}</li>')
              .join('\n')
        : '';

    return '''<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Invoice - $clientName</title>
<style>
  * { margin: 0; padding: 0; box-sizing: border-box; }
  body { font-family: 'Segoe UI', Arial, sans-serif; background: #f5f5f5; color: #1a1a1a; }
  .page { max-width: 700px; margin: 30px auto; background: #fff; border-radius: 12px; overflow: hidden; box-shadow: 0 4px 20px rgba(0,0,0,0.1); }
  .header { background: linear-gradient(135deg, #8B1A4A, #C2185B); color: white; padding: 36px 40px; }
  .header h1 { font-size: 28px; font-weight: 700; letter-spacing: 1px; }
  .header p { font-size: 13px; opacity: 0.8; margin-top: 4px; }
  .invoice-meta { display: flex; justify-content: space-between; padding: 24px 40px; background: #fafafa; border-bottom: 1px solid #eee; }
  .meta-block label { font-size: 11px; color: #9e9e9e; text-transform: uppercase; letter-spacing: 0.5px; }
  .meta-block p { font-size: 14px; font-weight: 600; margin-top: 2px; }
  .status-badge { display: inline-block; padding: 4px 12px; border-radius: 20px; font-size: 12px; font-weight: 600; text-transform: capitalize; }
  .status-confirmed { background: #e8f5e9; color: #2e7d32; }
  .status-pending { background: #fff8e1; color: #f57f17; }
  .status-completed { background: #f0f0f0; color: #6b7280; }
  .status-cancelled { background: #fce4ec; color: #c62828; }
  .section { padding: 24px 40px; border-bottom: 1px solid #eee; }
  .section h2 { font-size: 13px; font-weight: 700; color: #8B1A4A; text-transform: uppercase; letter-spacing: 0.5px; margin-bottom: 14px; }
  .info-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 14px; }
  .info-item label { font-size: 11px; color: #9e9e9e; }
  .info-item p { font-size: 14px; font-weight: 600; margin-top: 2px; }
  table { width: 100%; border-collapse: collapse; }
  th { background: #f5f5f5; padding: 10px 14px; text-align: left; font-size: 12px; color: #9e9e9e; text-transform: uppercase; letter-spacing: 0.5px; }
  td { padding: 12px 14px; font-size: 14px; border-bottom: 1px solid #f0f0f0; }
  .amount { text-align: right; font-weight: 600; }
  .total-row td { font-weight: 700; font-size: 15px; border-top: 2px solid #eee; border-bottom: none; }
  .balance-row td { color: ${balance > 0 ? '#f57f17' : '#2e7d32'}; }
  .notes-box { background: #fafafa; border-radius: 8px; padding: 14px; font-size: 13px; color: #5a4a50; line-height: 1.6; }
  .terms-list { list-style: none; padding: 0; margin: 0; }
  .terms-list li { font-size: 12px; color: #5a4a50; line-height: 1.7; padding: 4px 0; border-bottom: 1px dashed #f0f0f0; }
  .terms-list li:last-child { border-bottom: none; }
  .footer { padding: 20px 40px; text-align: center; font-size: 12px; color: #9e9e9e; background: #fafafa; }
  @media print { body { background: white; } .page { box-shadow: none; margin: 0; border-radius: 0; } }
</style>
</head>
<body>
<div class="page">
  <div class="header">
    <h1>BHARATH CONVENTION HALL</h1>
    <p>Tax Invoice / Receipt</p>
  </div>
  <div class="invoice-meta">
    <div class="meta-block">
      <label>Invoice No.</label>
      <p>$bookingId</p>
    </div>
    <div class="meta-block">
      <label>Invoice Date</label>
      <p>${invoiceDate.day}/${invoiceDate.month}/${invoiceDate.year}</p>
    </div>
    <div class="meta-block">
      <label>Status</label>
      <p><span class="status-badge status-$status">$status</span></p>
    </div>
  </div>

  <div class="section">
    <h2>Client Details</h2>
    <div class="info-grid">
      <div class="info-item">
        <label>Client Name</label>
        <p>$clientName</p>
      </div>
      <div class="info-item">
        <label>Phone</label>
        <p>${phone.isNotEmpty ? '+91 $phone' : 'Not provided'}</p>
      </div>
    </div>
  </div>

  <div class="section">
    <h2>Event Details</h2>
    <div class="info-grid">
      <div class="info-item">
        <label>Event Type</label>
        <p>$eventType</p>
      </div>
      <div class="info-item">
        <label>Event Date</label>
        <p>${_formatDateFull(date)}</p>
      </div>
      <div class="info-item">
        <label>Guest Count</label>
        <p>$guestCount Guests</p>
      </div>
      <div class="info-item">
        <label>Booking ID</label>
        <p>$bookingId</p>
      </div>
    </div>
  </div>

  <div class="section">
    <h2>Payment Summary</h2>
    <table>
      <thead>
        <tr>
          <th>Description</th>
          <th class="amount">Amount (₹)</th>
        </tr>
      </thead>
      <tbody>
        <tr>
          <td>Hall Booking — $eventType ($guestCount guests)</td>
          <td class="amount">₹${_fmtFull(total)}</td>
        </tr>
        <tr>
          <td>Advance Paid</td>
          <td class="amount" style="color:#2e7d32">- ₹${_fmtFull(advance)}</td>
        </tr>
        <tr class="total-row">
          <td>Total Amount</td>
          <td class="amount">₹${_fmtFull(total)}</td>
        </tr>
        <tr class="balance-row">
          <td>${balance > 0 ? 'Balance Due' : 'Fully Paid ✓'}</td>
          <td class="amount">₹${_fmtFull(balance)}</td>
        </tr>
      </tbody>
    </table>
  </div>

  ${notes.isNotEmpty ? '''<div class="section">
    <h2>Notes</h2>
    <div class="notes-box">$notes</div>
  </div>''' : ''}

  ${termsHtml.isNotEmpty ? '''<div class="section">
    <h2>Terms &amp; Conditions</h2>
    <ul class="terms-list">
$termsHtml
    </ul>
  </div>''' : ''}

  <div class="footer">
    <p>Thank you for choosing Bharath Convention Hall</p>
    <p style="margin-top:4px">This is a computer-generated invoice. For queries, please contact the hall management.</p>
  </div>
</div>
</body>
</html>''';
  }

  void _emailInvoice() {
    final clientName = _booking['clientName'] as String? ?? '';
    final bookingId = _booking['id'] as String? ?? 'N/A';
    final phone = _booking['phone'] as String? ?? '';
    final eventType = _booking['eventType'] as String? ?? '';
    final date = _booking['eventDate'] as DateTime;
    final total = (_booking['totalAmount'] as double?) ?? 0.0;
    final advance = (_booking['advancePaid'] as double?) ?? 0.0;
    final balance = total - advance;

    final subject = Uri.encodeComponent(
      'Invoice $bookingId — Bharath Convention Hall',
    );
    final body = Uri.encodeComponent(
      'Dear $clientName,\n\n'
      'Please find below your booking invoice details:\n\n'
      'Booking ID: $bookingId\n'
      'Event Type: $eventType\n'
      'Event Date: ${_formatDateFull(date)}\n'
      'Total Amount: ₹${_fmtFull(total)}\n'
      'Advance Paid: ₹${_fmtFull(advance)}\n'
      'Balance Due: ₹${_fmtFull(balance)}\n'
      '${phone.isNotEmpty ? 'Phone: +91 $phone\n' : ''}'
      '\nThank you for choosing Bharath Convention Hall.\n'
      'For any queries, please contact the hall management.',
    );

    // Build mailto link and attempt to open
    final mailtoUrl = 'mailto:?subject=$subject&body=$body';
    invoice_web.InvoiceDownloader.openUrl(mailtoUrl);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Opening email client with invoice details…'),
        backgroundColor: AppTheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _printInvoice() async {
    final date = _booking['eventDate'] as DateTime;
    final clientName = _booking['clientName'] as String;
    final phone = _booking['phone'] as String? ?? '';
    final eventType = _booking['eventType'] as String;
    final guestCount = _booking['guestCount'] as int? ?? 0;
    final total = (_booking['totalAmount'] as double?) ?? 0.0;
    final advance = (_booking['advancePaid'] as double?) ?? 0.0;
    final balance = total - advance;
    final notes = _booking['notes'] as String? ?? '';
    final status = _booking['status'] as String;
    final bookingId = _booking['id'] as String? ?? 'N/A';
    final invoiceDate = DateTime.now();

    final htmlContent = _buildInvoiceHtml(
      clientName: clientName,
      phone: phone,
      eventType: eventType,
      guestCount: guestCount,
      total: total,
      advance: advance,
      balance: balance,
      notes: notes,
      status: status,
      bookingId: bookingId,
      date: date,
      invoiceDate: invoiceDate,
    );

    if (kIsWeb) {
      invoice_web.InvoiceDownloader.print(htmlContent);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Opening print dialog…'),
            backgroundColor: AppTheme.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } else {
      await invoice_web.InvoiceDownloader.print(htmlContent);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Share the invoice to print or save it.'),
            backgroundColor: AppTheme.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  Future<void> _downloadInvoice(
    String htmlContent,
    String filename, {
    Map<String, dynamic>? invoiceData,
  }) async {
    if (kIsWeb) {
      try {
        await _triggerWebDownload(htmlContent, '$filename.html');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Invoice downloaded: $filename.html'),
              backgroundColor: AppTheme.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Invoice ready. Check your downloads folder.',
              ),
              backgroundColor: AppTheme.primary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      }
    } else {
      if (invoiceData != null) {
        await invoice_web.InvoiceDownloader.downloadPdf(
          invoiceData,
          '$filename.pdf',
        );
      } else {
        await invoice_web.InvoiceDownloader.download(
          htmlContent,
          '$filename.html',
        );
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'PDF Invoice ready — choose where to save or share it.',
            ),
            backgroundColor: AppTheme.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  // ignore: avoid_web_libraries_in_flutter
  Future<void> _triggerWebDownload(String htmlContent, String filename) async {
    await invoice_web.InvoiceDownloader.download(htmlContent, filename);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final eventType = _booking['eventType'] as String;
    final eventColor = AppTheme.eventTypeColor(eventType);
    final date = _booking['eventDate'] as DateTime;
    final advance = (_booking['advancePaid'] as double?) ?? 0.0;
    final total = (_booking['totalAmount'] as double?) ?? 0.0;
    final balance = total - advance;
    final status = _booking['status'] as String;
    final clientName = _booking['clientName'] as String;
    final phone = _booking['phone'] as String? ?? '';
    final guestCount = _booking['guestCount'] as int? ?? 0;
    final notes = _booking['notes'] as String? ?? '';
    final isCancelled = status == 'cancelled';

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppTheme.surfaceLight,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
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
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: eventColor.withAlpha(26),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _eventIcon(eventType),
                        color: eventColor,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(clientName, style: theme.textTheme.titleMedium),
                          Text(
                            eventType,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              color: eventColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _StatusBadge(status: status),
                    const SizedBox(width: 8),
                    // More options menu
                    PopupMenuButton<String>(
                      icon: const Icon(
                        Icons.more_vert_rounded,
                        color: Color(0xFF9E9E9E),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      onSelected: (value) {
                        if (value == 'cancel') _showCancelDialog();
                        if (value == 'delete') _showDeleteDialog();
                        if (value == 'invoice') _generateInvoice();
                      },
                      itemBuilder: (ctx) => [
                        PopupMenuItem(
                          value: 'invoice',
                          child: Row(
                            children: [
                              Icon(
                                Icons.receipt_long_outlined,
                                size: 18,
                                color: AppTheme.primary,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Download Invoice',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (!isCancelled)
                          PopupMenuItem(
                            value: 'cancel',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.cancel_outlined,
                                  size: 18,
                                  color: AppTheme.warning,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Cancel Booking',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: AppTheme.warning,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete_outline_rounded,
                                size: 18,
                                color: AppTheme.error,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Delete Booking',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.error,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Color(0xFF9E9E9E),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 20),
              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Info grid
                      _BookingInfoGrid(
                        date: date,
                        guestCount: guestCount,
                        total: total,
                        advance: advance,
                        balance: balance,
                        eventColor: eventColor,
                        functionTime:
                            _booking['functionTime'] as String? ?? 'Day',
                      ),
                      const SizedBox(height: 20),
                      // Contact section
                      _SectionHeader(title: 'Contact'),
                      const SizedBox(height: 10),
                      _ContactRow(
                        icon: Icons.phone_outlined,
                        label: 'Phone',
                        value: phone.isNotEmpty ? '+91 $phone' : 'Not provided',
                        onCopy: phone.isNotEmpty
                            ? () {
                                Clipboard.setData(ClipboardData(text: phone));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Phone number copied'),
                                  ),
                                );
                              }
                            : null,
                      ),
                      const SizedBox(height: 20),
                      // Financial summary
                      _SectionHeader(title: 'Payment Summary'),
                      const SizedBox(height: 10),
                      _PaymentSummaryCard(
                        total: total,
                        advance: advance,
                        balance: balance,
                        onCollectBalance: balance > 0 && !isCancelled
                            ? _collectBalance
                            : null,
                      ),
                      if (notes.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        _SectionHeader(title: 'Notes'),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceVariantLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            notes,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              color: const Color(0xFF5A4A50),
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      // Invoice button — always visible
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _generateInvoice,
                          icon: const Icon(
                            Icons.receipt_long_outlined,
                            size: 18,
                          ),
                          label: const Text('Download Invoice'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.primary,
                            side: const BorderSide(
                              color: AppTheme.primary,
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Action buttons row
                      if (!isCancelled)
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  Navigator.pop(context);
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    builder: (_) => AddBookingBottomSheet(
                                      existingBooking: _booking,
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.edit_outlined, size: 18),
                                label: const Text('Edit'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppTheme.primary,
                                  side: const BorderSide(
                                    color: AppTheme.primary,
                                    width: 1.5,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _showCancelDialog,
                                icon: const Icon(
                                  Icons.cancel_outlined,
                                  size: 18,
                                ),
                                label: const Text('Cancel'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppTheme.warning,
                                  side: BorderSide(
                                    color: AppTheme.warning,
                                    width: 1.5,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: () {
                                  final idx = allBookingsMockData.indexWhere(
                                    (b) => b['id'] == _booking['id'],
                                  );
                                  if (idx != -1) {
                                    allBookingsMockData[idx]['status'] =
                                        'completed';
                                  }
                                  // Persist to local storage
                                  saveBookingsToStorage();
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Marked as completed!'),
                                      backgroundColor: AppTheme.success,
                                    ),
                                  );
                                },
                                icon: const Icon(
                                  Icons.check_circle_outline_rounded,
                                  size: 18,
                                ),
                                label: const Text('Done'),
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppTheme.success,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      if (isCancelled) ...[
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: _showDeleteDialog,
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              size: 18,
                            ),
                            label: const Text('Delete Booking'),
                            style: FilledButton.styleFrom(
                              backgroundColor: AppTheme.error,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  IconData _eventIcon(String type) {
    switch (type.toLowerCase()) {
      case 'wedding':
        return Icons.favorite_rounded;
      case 'reception':
        return Icons.celebration_rounded;
      case 'engagement':
        return Icons.diamond_outlined;
      case 'birthday':
        return Icons.cake_rounded;
      case 'corporate':
        return Icons.business_center_outlined;
      default:
        return Icons.event_rounded;
    }
  }
}

/// Three-button invoice action row shown on mobile/tablet only.
class _InvoiceActionsWidget extends StatelessWidget {
  final VoidCallback onEmail;
  final VoidCallback onPrint;
  final VoidCallback onDownload;

  const _InvoiceActionsWidget({
    required this.onEmail,
    required this.onPrint,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Invoice',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF9E9E9E),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _InvoiceActionButton(
                icon: Icons.email_outlined,
                label: 'Email',
                onTap: onEmail,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _InvoiceActionButton(
                icon: Icons.print_outlined,
                label: 'Print',
                onTap: onPrint,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _InvoiceActionButton(
                icon: Icons.download_outlined,
                label: 'Download',
                onTap: onDownload,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _InvoiceActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _InvoiceActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppTheme.primary,
        side: const BorderSide(color: AppTheme.primary, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppTheme.primary,
        letterSpacing: 0.3,
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg, fg;
    String label;
    switch (status) {
      case 'confirmed':
        bg = AppTheme.successContainer;
        fg = AppTheme.success;
        label = 'Confirmed';
        break;
      case 'pending':
        bg = AppTheme.warningContainer;
        fg = AppTheme.warning;
        label = 'Pending';
        break;
      case 'completed':
        bg = const Color(0xFFF0F0F0);
        fg = const Color(0xFF6B7280);
        label = 'Completed';
        break;
      case 'cancelled':
        bg = AppTheme.errorContainer;
        fg = AppTheme.error;
        label = 'Cancelled';
        break;
      default:
        bg = const Color(0xFFF0F0F0);
        fg = const Color(0xFF6B7280);
        label = status;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}

// Booking info grid — 2x2 anatomy locked from TicketInfoGrid reference
class _BookingInfoGrid extends StatelessWidget {
  final DateTime date;
  final int guestCount;
  final double total;
  final double advance;
  final double balance;
  final Color eventColor;
  final String functionTime;

  const _BookingInfoGrid({
    required this.date,
    required this.guestCount,
    required this.total,
    required this.advance,
    required this.balance,
    required this.eventColor,
    required this.functionTime,
  });

  @override
  Widget build(BuildContext context) {
    final cells = [
      {'label': 'Event Date', 'value': _formatDate(date), 'isAccent': false},
      {
        'label': 'Function Time',
        'value': functionTime == 'Night'
            ? '🌙 Night Function'
            : '☀️ Day Function',
        'isAccent': false,
      },
      {
        'label': 'Guest Count',
        'value': '$guestCount guests',
        'isAccent': false,
      },
      {'label': 'Total Amount', 'value': '₹${_fmt(total)}', 'isAccent': true},
      {
        'label': 'Balance Due',
        'value': balance > 0 ? '₹${_fmt(balance)}' : 'Fully Paid',
        'isAccent': false,
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.outlineVariantLight, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _GridCell(
                  cell: cells[0],
                  eventColor: eventColor,
                  isTop: true,
                  isLeft: true,
                ),
              ),
              Container(
                width: 1,
                height: 64,
                color: AppTheme.outlineVariantLight,
              ),
              Expanded(
                child: _GridCell(
                  cell: cells[1],
                  eventColor: eventColor,
                  isTop: true,
                  isLeft: false,
                ),
              ),
            ],
          ),
          Container(height: 1, color: AppTheme.outlineVariantLight),
          Row(
            children: [
              Expanded(
                child: _GridCell(
                  cell: cells[2],
                  eventColor: eventColor,
                  isTop: false,
                  isLeft: true,
                ),
              ),
              Container(
                width: 1,
                height: 64,
                color: AppTheme.outlineVariantLight,
              ),
              Expanded(
                child: _GridCell(
                  cell: cells[3],
                  eventColor: eventColor,
                  isTop: false,
                  isLeft: false,
                ),
              ),
            ],
          ),
          Container(height: 1, color: AppTheme.outlineVariantLight),
          Row(
            children: [
              Expanded(
                child: _GridCell(
                  cell: cells[4],
                  eventColor: eventColor,
                  isTop: false,
                  isLeft: true,
                ),
              ),
              Container(
                width: 1,
                height: 64,
                color: AppTheme.outlineVariantLight,
              ),
              Expanded(
                child: Container(
                  height: 64,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
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

  String _fmt(double v) {
    final intVal = v.round();
    final formatted = intVal.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
    return '$formatted/-';
  }
}

class _GridCell extends StatelessWidget {
  final Map<String, dynamic> cell;
  final Color eventColor;
  final bool isTop;
  final bool isLeft;

  const _GridCell({
    required this.cell,
    required this.eventColor,
    required this.isTop,
    required this.isLeft,
  });

  @override
  Widget build(BuildContext context) {
    final isAccent = cell['isAccent'] as bool;

    BorderRadius radius = BorderRadius.zero;
    if (isTop && isLeft) {
      radius = const BorderRadius.only(topLeft: Radius.circular(14));
    } else if (isTop && !isLeft) {
      radius = const BorderRadius.only(topRight: Radius.circular(14));
    } else if (!isTop && isLeft) {
      radius = const BorderRadius.only(bottomLeft: Radius.circular(14));
    } else {
      radius = const BorderRadius.only(bottomRight: Radius.circular(14));
    }

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isAccent ? eventColor.withAlpha(26) : Colors.transparent,
        borderRadius: radius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            cell['label'] as String,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF9E9E9E),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            cell['value'] as String,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isAccent ? eventColor : const Color(0xFF1A1A1A),
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onCopy;

  const _ContactRow({
    required this.icon,
    required this.label,
    required this.value,
    this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariantLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    color: const Color(0xFF9E9E9E),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
          ),
          if (onCopy != null)
            IconButton(
              onPressed: onCopy,
              icon: const Icon(
                Icons.copy_rounded,
                size: 18,
                color: AppTheme.primary,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            ),
        ],
      ),
    );
  }
}

class _PaymentSummaryCard extends StatelessWidget {
  final double total;
  final double advance;
  final double balance;
  final VoidCallback? onCollectBalance;

  const _PaymentSummaryCard({
    required this.total,
    required this.advance,
    required this.balance,
    this.onCollectBalance,
  });

  @override
  Widget build(BuildContext context) {
    final advancePct = total > 0 ? (advance / total) : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariantLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.outlineVariantLight, width: 1),
      ),
      child: Column(
        children: [
          _PaymentRow(
            label: 'Total Amount',
            value: '₹${_fmt(total)}',
            isBold: true,
            color: const Color(0xFF1A1A1A),
          ),
          const SizedBox(height: 8),
          _PaymentRow(
            label: 'Advance Paid',
            value: '₹${_fmt(advance)}',
            isBold: false,
            color: AppTheme.success,
          ),
          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 8),
          _PaymentRow(
            label: balance > 0 ? 'Balance Due' : 'Fully Paid ✓',
            value: balance > 0 ? '₹${_fmt(balance)}' : '₹0',
            isBold: true,
            color: balance > 0 ? AppTheme.warning : AppTheme.success,
          ),
          const SizedBox(height: 12),
          // Progress bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Payment Progress',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: const Color(0xFF9E9E9E),
                    ),
                  ),
                  Text(
                    '${(advancePct * 100).toStringAsFixed(0)}%',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: advancePct.clamp(0.0, 1.0),
                  backgroundColor: AppTheme.outlineVariantLight,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppTheme.primary,
                  ),
                  minHeight: 8,
                ),
              ),
            ],
          ),
          if (onCollectBalance != null) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onCollectBalance,
                icon: const Icon(Icons.payments_outlined, size: 18),
                label: Text(
                  'Collect Balance  ₹${_fmt(balance)}',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.success,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _fmt(double v) {
    final intVal = v.round();
    final formatted = intVal.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
    return '$formatted/-';
  }
}

class _PaymentRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color color;

  const _PaymentRow({
    required this.label,
    required this.value,
    required this.isBold,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
            color: isBold ? const Color(0xFF1A1A1A) : const Color(0xFF5A4A50),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: color,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}

/// Dialog that lets the owner review and edit Terms & Conditions before
/// the invoice is generated. Returns the edited text or null if cancelled.
class _TermsEditorDialog extends StatefulWidget {
  final TextEditingController controller;

  const _TermsEditorDialog({required this.controller});

  @override
  State<_TermsEditorDialog> createState() => _TermsEditorDialogState();
}

class _TermsEditorDialogState extends State<_TermsEditorDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withAlpha(26),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.gavel_rounded,
                    color: AppTheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Terms & Conditions',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Review and edit the terms before generating the invoice. Each line will appear as a separate point.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: const Color(0xFF9E9E9E),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 14),
            Container(
              constraints: const BoxConstraints(maxHeight: 300),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE0E0E0)),
                borderRadius: BorderRadius.circular(10),
                color: const Color(0xFFFAFAFA),
              ),
              child: TextField(
                controller: widget.controller,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: const Color(0xFF1A1A1A),
                  height: 1.6,
                ),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(12),
                  border: InputBorder.none,
                  hintText: 'Enter terms and conditions...',
                  hintStyle: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: const Color(0xFFBDBDBD),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF9E9E9E),
                      side: const BorderSide(color: Color(0xFFE0E0E0)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () =>
                        Navigator.pop(context, widget.controller.text),
                    icon: const Icon(Icons.download_rounded, size: 18),
                    label: Text(
                      'Download',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}