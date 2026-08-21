import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';

class BookingListItemWidget extends StatelessWidget {
  final Map<String, dynamic> booking;
  final VoidCallback onTap;

  const BookingListItemWidget({
    required this.booking,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final eventType = booking['eventType'] as String;
    final eventColor = AppTheme.eventTypeColor(eventType);
    final date = booking['eventDate'] as DateTime;
    final advance = (booking['advancePaid'] as double?) ?? 0.0;
    final total = (booking['totalAmount'] as double?) ?? 0.0;
    final balance = total - advance;
    final status = booking['status'] as String;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        splashColor: eventColor.withAlpha(26),
        highlightColor: eventColor.withAlpha(13),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceLight,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(13),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Colored event type square — NearbyEventCard anatomy
              Container(
                width: 64,
                height: 88,
                decoration: BoxDecoration(
                  color: eventColor.withAlpha(26),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(14),
                    bottomLeft: Radius.circular(14),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(_eventIcon(eventType), color: eventColor, size: 22),
                    const SizedBox(height: 4),
                    Text(
                      eventType.length > 6
                          ? '${eventType.substring(0, 6)}..'
                          : eventType,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: eventColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Info column
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              booking['clientName'] as String,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1A1A1A),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          _StatusPill(status: status),
                          const SizedBox(width: 10),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 11,
                            color: const Color(0xFF9E9E9E),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDate(date),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: const Color(0xFF9E9E9E),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.people_outline_rounded,
                            size: 11,
                            color: const Color(0xFF9E9E9E),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '${booking['guestCount']}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: const Color(0xFF9E9E9E),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          _FinancialChip(
                            label: 'Adv',
                            value: '₹${_fmt(advance)}',
                            color: AppTheme.success,
                          ),
                          const SizedBox(width: 6),
                          _FinancialChip(
                            label: 'Bal',
                            value: '₹${_fmt(balance)}',
                            color: balance > 0
                                ? AppTheme.warning
                                : AppTheme.success,
                            isAlert: balance > 0,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
    return '${d.day} ${months[d.month]} ${d.year}';
  }

  String _fmt(double v) {
    if (v >= 100000) return '${(v / 100000).toStringAsFixed(1)}L';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}K';
    return v.toStringAsFixed(0);
  }
}

class _StatusPill extends StatelessWidget {
  final String status;

  const _StatusPill({required this.status});

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
        label = 'Done';
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}

class _FinancialChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool isAlert;

  const _FinancialChip({
    required this.label,
    required this.value,
    required this.color,
    this.isAlert = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(6),
        border: isAlert
            ? Border.all(color: color.withAlpha(80), width: 1)
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w400,
              color: color.withAlpha(180),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
