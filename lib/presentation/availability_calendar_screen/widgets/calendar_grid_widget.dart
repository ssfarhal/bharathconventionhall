import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';
import '../../dashboard_screen/widgets/dashboard_header_widget.dart';

class CalendarGridWidget extends StatelessWidget {
  final DateTime focusedMonth;
  final Function(DateTime date, List<Map<String, dynamic>> bookings)
  onDateTapped;

  const CalendarGridWidget({
    required this.focusedMonth,
    required this.onDateTapped,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateUtils.getDaysInMonth(
      focusedMonth.year,
      focusedMonth.month,
    );
    final firstDayOfMonth = DateTime(focusedMonth.year, focusedMonth.month, 1);
    // Monday = 1, so offset = weekday - 1
    final startOffset = firstDayOfMonth.weekday - 1;

    final bookings = allBookingsMockData;
    final dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(18),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Day of week headers
            Row(
              children: dayLabels
                  .map(
                    (d) => Expanded(
                      child: Center(
                        child: Text(
                          d,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: d == 'Sun'
                                ? AppTheme.error
                                : const Color(0xFF9E9E9E),
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 8),
            // Calendar grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
              ),
              itemCount: startOffset + daysInMonth,
              itemBuilder: (context, index) {
                if (index < startOffset) {
                  return const SizedBox.shrink();
                }
                final day = index - startOffset + 1;
                final date = DateTime(
                  focusedMonth.year,
                  focusedMonth.month,
                  day,
                );
                final dayBookings = bookings.where((b) {
                  final d = b['eventDate'] as DateTime;
                  return d.year == date.year &&
                      d.month == date.month &&
                      d.day == date.day;
                }).toList();

                return _CalendarDayCell(
                  date: date,
                  bookings: dayBookings,
                  onTap: () => onDateTapped(date, dayBookings),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _CalendarDayCell extends StatelessWidget {
  final DateTime date;
  final List<Map<String, dynamic>> bookings;
  final VoidCallback onTap;

  const _CalendarDayCell({
    required this.date,
    required this.bookings,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isToday =
        date.year == now.year && date.month == now.month && date.day == now.day;
    final isPast = date.isBefore(DateTime(now.year, now.month, now.day));
    final isBooked = bookings.isNotEmpty;
    final isPending = isBooked && bookings.any((b) => b['status'] == 'pending');
    final isConfirmed =
        isBooked && bookings.any((b) => b['status'] == 'confirmed');

    Color cellBg;
    Color textColor;
    Color? borderColor;

    if (isToday) {
      cellBg = AppTheme.primary;
      textColor = Colors.white;
      borderColor = null;
    } else if (isConfirmed) {
      cellBg = AppTheme.primary.withAlpha(26);
      textColor = AppTheme.primary;
      borderColor = AppTheme.primary.withAlpha(100);
    } else if (isPending) {
      cellBg = AppTheme.warning.withAlpha(26);
      textColor = AppTheme.warning;
      borderColor = AppTheme.warning.withAlpha(100);
    } else if (isPast) {
      cellBg = Colors.transparent;
      textColor = const Color(0xFFCCCCCC);
      borderColor = null;
    } else {
      cellBg = AppTheme.successContainer.withAlpha(128);
      textColor = AppTheme.success;
      borderColor = null;
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: cellBg,
          borderRadius: BorderRadius.circular(10),
          border: borderColor != null
              ? Border.all(color: borderColor, width: 1.5)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${date.day}',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: textColor,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            if (isBooked && !isToday)
              Container(
                width: 4,
                height: 4,
                margin: const EdgeInsets.only(top: 2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isConfirmed ? AppTheme.primary : AppTheme.warning,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
