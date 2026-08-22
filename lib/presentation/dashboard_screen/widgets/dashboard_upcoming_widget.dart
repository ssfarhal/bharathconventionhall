import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/empty_state_widget.dart';
import 'dashboard_header_widget.dart';

class DashboardUpcomingWidget extends StatelessWidget {
  const DashboardUpcomingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final upcoming =
        allBookingsMockData
            .where(
              (b) =>
                  (b['eventDate'] as DateTime).isAfter(now) &&
                  b['status'] != 'cancelled',
            )
            .toList()
          ..sort(
            (a, b) => (a['eventDate'] as DateTime).compareTo(
              b['eventDate'] as DateTime,
            ),
          );

    final display = upcoming.take(4).toList();

    if (display.isEmpty) {
      return const SizedBox(
        height: 200,
        child: EmptyStateWidget(
          icon: Icons.event_available_rounded,
          title: 'No upcoming bookings',
          subtitle:
              'Add new bookings to see them here. Tap the button below to get started.',
        ),
      );
    }

    return Column(
      children: display
          .map(
            (b) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _UpcomingBookingCard(booking: b),
            ),
          )
          .toList(),
    );
  }
}

class _UpcomingBookingCard extends StatelessWidget {
  final Map<String, dynamic> booking;

  const _UpcomingBookingCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    final eventType = booking['eventType'] as String;
    final eventColor = AppTheme.eventTypeColor(eventType);
    final date = booking['eventDate'] as DateTime;
    final advance = booking['advancePaid'] as double;
    final total = booking['totalAmount'] as double;
    final balance = total - advance;
    final status = booking['status'] as String;
    final daysUntil = date.difference(DateTime.now()).inDays;

    return Container(
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
          // Colored event type indicator — anatomy from NearbyEventCard
          Container(
            width: 64,
            height: 80,
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
                Text(
                  '${date.day}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: eventColor,
                  ),
                ),
                Text(
                  _monthShort(date.month),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: eventColor,
                  ),
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
                      _statusChip(status),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Icon(
                        Icons.celebration_rounded,
                        size: 12,
                        color: eventColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        eventType,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: eventColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.people_outline_rounded,
                        size: 12,
                        color: const Color(0xFF9E9E9E),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${booking['guestCount']}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: const Color(0xFF9E9E9E),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _functionTimeChip(
                        booking['functionTime'] as String? ?? 'Day',
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'Balance: ₹${_fmt(balance)}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: balance > 0
                              ? AppTheme.warning
                              : AppTheme.success,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        daysUntil == 0
                            ? 'Today'
                            : daysUntil == 1
                            ? 'Tomorrow'
                            : 'In $daysUntil days',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: daysUntil <= 2
                              ? AppTheme.warning
                              : const Color(0xFF9E9E9E),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(String status) {
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
      default:
        bg = const Color(0xFFF0F0F0);
        fg = const Color(0xFF6B7280);
        label = status;
    }
    return Container(
      margin: const EdgeInsets.only(right: 10),
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

  Widget _functionTimeChip(String functionTime) {
    final isNight = functionTime == 'Night';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isNight
            ? const Color(0xFF1A237E).withAlpha(20)
            : const Color(0xFFF57F17).withAlpha(20),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isNight ? Icons.nightlight_round : Icons.wb_sunny_rounded,
            size: 10,
            color: isNight ? const Color(0xFF3949AB) : const Color(0xFFF57F17),
          ),
          const SizedBox(width: 3),
          Text(
            isNight ? 'Night' : 'Day',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isNight
                  ? const Color(0xFF3949AB)
                  : const Color(0xFFF57F17),
            ),
          ),
        ],
      ),
    );
  }

  String _monthShort(int m) {
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
    return months[m];
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
