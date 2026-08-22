import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';
import '../../../services/supabase_service.dart';

class DashboardHeaderWidget extends StatelessWidget {
  final String greeting;

  const DashboardHeaderWidget({required this.greeting, super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final todayBookings = _getTodayBookings();
    final isBooked = todayBookings.isNotEmpty;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primary, AppTheme.primary.withAlpha(204)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withAlpha(64),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circle
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withAlpha(20),
              ),
            ),
          ),
          Positioned(
            right: 30,
            bottom: -30,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withAlpha(15),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(38),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isBooked
                                  ? const Color(0xFFFF6B6B)
                                  : const Color(0xFF6BCB77),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isBooked
                                ? 'Hall Booked Today'
                                : 'Hall Available Today',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  greeting,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withAlpha(204),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isBooked
                      ? '${todayBookings.first['clientName']} — ${todayBookings.first['eventType']}'
                      : 'No events scheduled today',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(now),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withAlpha(178),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getTodayBookings() {
    final today = DateTime.now();
    return _allBookings.where((b) {
      final d = b['eventDate'] as DateTime;
      return d.year == today.year &&
          d.month == today.month &&
          d.day == today.day;
    }).toList();
  }

  String _formatDate(DateTime d) {
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
}

// Shared in-memory booking list — backed by Supabase
final List<Map<String, dynamic>> _allBookings = [];
bool _bookingsLoaded = false;

List<Map<String, dynamic>> get allBookingsMockData => _allBookings;

/// Load bookings from Supabase into the in-memory list.
/// Safe to call multiple times — only loads once per session.
Future<void> loadBookingsFromStorage() async {
  if (_bookingsLoaded) return;
  _bookingsLoaded = true;
  try {
    final saved = await SupabaseService.instance.fetchBookings();
    _allBookings.clear();
    _allBookings.addAll(saved);
  } catch (_) {
    // Supabase unavailable — start with empty list
  }
}

/// Force reload bookings from Supabase (used on pull-to-refresh).
Future<void> reloadBookingsFromStorage() async {
  try {
    final saved = await SupabaseService.instance.fetchBookings();
    _allBookings.clear();
    _allBookings.addAll(saved);
  } catch (_) {}
}

/// Legacy alias kept for compatibility — no-op since Supabase persists immediately.
Future<void> saveBookingsToStorage() async {
  // No-op: each mutation calls Supabase directly; in-memory list stays in sync.
}
