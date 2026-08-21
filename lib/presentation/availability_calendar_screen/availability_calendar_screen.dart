import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_theme.dart';
import '../../presentation/dashboard_screen/widgets/dashboard_header_widget.dart';
import './widgets/calendar_grid_widget.dart';
import './widgets/calendar_legend_widget.dart';
import './widgets/date_detail_bottom_sheet.dart';

class AvailabilityCalendarScreen extends StatefulWidget {
  const AvailabilityCalendarScreen({super.key});

  @override
  State<AvailabilityCalendarScreen> createState() =>
      _AvailabilityCalendarScreenState();
}

class _AvailabilityCalendarScreenState
    extends State<AvailabilityCalendarScreen> {
  // TODO: Replace with [Riverpod/Bloc] for production
  DateTime _focusedMonth = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    1,
  );

  void _previousMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 1);
    });
  }

  void _onDateTapped(DateTime date, List<Map<String, dynamic>> bookings) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DateDetailBottomSheet(date: date, bookings: bookings),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final monthNames = [
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

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // AppBar
            Container(
              color: AppTheme.surfaceLight,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Text(
                    'Availability',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.circle,
                          size: 8,
                          color: AppTheme.success,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Live',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Month navigation
                    _MonthNavigationWidget(
                      focusedMonth: _focusedMonth,
                      monthName: monthNames[_focusedMonth.month],
                      onPrevious: _previousMonth,
                      onNext: _nextMonth,
                    ),
                    const SizedBox(height: 12),
                    // Legend
                    const CalendarLegendWidget(),
                    const SizedBox(height: 12),
                    // Calendar grid
                    CalendarGridWidget(
                      focusedMonth: _focusedMonth,
                      onDateTapped: _onDateTapped,
                    ),
                    const SizedBox(height: 20),
                    // Monthly summary
                    _MonthlySummaryWidget(focusedMonth: _focusedMonth),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MonthNavigationWidget extends StatelessWidget {
  final DateTime focusedMonth;
  final String monthName;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const _MonthNavigationWidget({
    required this.focusedMonth,
    required this.monthName,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: onPrevious,
          icon: const Icon(Icons.chevron_left_rounded),
          style: IconButton.styleFrom(
            backgroundColor: AppTheme.surfaceLight,
            foregroundColor: AppTheme.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        Column(
          children: [
            Text(
              monthName,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A1A1A),
              ),
            ),
            Text(
              '${focusedMonth.year}',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF9E9E9E),
              ),
            ),
          ],
        ),
        IconButton(
          onPressed: onNext,
          icon: const Icon(Icons.chevron_right_rounded),
          style: IconButton.styleFrom(
            backgroundColor: AppTheme.surfaceLight,
            foregroundColor: AppTheme.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }
}

class _MonthlySummaryWidget extends StatelessWidget {
  final DateTime focusedMonth;

  const _MonthlySummaryWidget({required this.focusedMonth});

  @override
  Widget build(BuildContext context) {
    // Import bookings from mock data
    final allBookings = _getMonthBookings();
    final daysInMonth = DateUtils.getDaysInMonth(
      focusedMonth.year,
      focusedMonth.month,
    );
    final bookedDays = allBookings
        .where((b) {
          final d = b['eventDate'] as DateTime;
          return d.month == focusedMonth.month && d.year == focusedMonth.year;
        })
        .map((b) => (b['eventDate'] as DateTime).day)
        .toSet()
        .length;
    final availableDays = daysInMonth - bookedDays;
    final occupancy = daysInMonth > 0 ? (bookedDays / daysInMonth * 100) : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Monthly Summary',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _SummaryTile(
                value: '$bookedDays',
                label: 'Booked Days',
                color: AppTheme.primary,
              ),
              const SizedBox(width: 12),
              _SummaryTile(
                value: '$availableDays',
                label: 'Available',
                color: AppTheme.success,
              ),
              const SizedBox(width: 12),
              _SummaryTile(
                value: '${occupancy.toStringAsFixed(0)}%',
                label: 'Occupancy',
                color: AppTheme.secondary,
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: occupancy / 100,
              backgroundColor: AppTheme.outlineVariantLight,
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getMonthBookings() {
    return allBookingsMockData;
  }
}

class _SummaryTile extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _SummaryTile({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: color,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: color.withAlpha(180),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
