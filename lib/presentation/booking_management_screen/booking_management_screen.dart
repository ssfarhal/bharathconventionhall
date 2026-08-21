import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_theme.dart';
import '../../widgets/empty_state_widget.dart';
import '../dashboard_screen/widgets/add_booking_bottom_sheet.dart';
import '../dashboard_screen/widgets/dashboard_header_widget.dart';
import './widgets/booking_detail_bottom_sheet.dart';
import './widgets/booking_list_item_widget.dart';

enum _FilterType { all, upcoming, completed, pendingBalance }

class BookingManagementScreen extends StatefulWidget {
  const BookingManagementScreen({super.key});

  @override
  State<BookingManagementScreen> createState() =>
      _BookingManagementScreenState();
}

class _BookingManagementScreenState extends State<BookingManagementScreen> {
  // TODO: Replace with [Riverpod/Bloc] for production
  _FilterType _activeFilter = _FilterType.all;
  String _searchQuery = '';
  bool _isSearching = false;
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredBookings {
    final now = DateTime.now();
    var result = List<Map<String, dynamic>>.from(allBookingsMockData);

    // Apply search
    if (_searchQuery.isNotEmpty) {
      result = result.where((b) {
        final name = (b['clientName'] as String).toLowerCase();
        final type = (b['eventType'] as String).toLowerCase();
        final q = _searchQuery.toLowerCase();
        return name.contains(q) || type.contains(q);
      }).toList();
    }

    // Apply filter
    switch (_activeFilter) {
      case _FilterType.upcoming:
        result = result
            .where(
              (b) =>
                  (b['eventDate'] as DateTime).isAfter(now) &&
                  b['status'] != 'cancelled',
            )
            .toList();
        break;
      case _FilterType.completed:
        result = result.where((b) => b['status'] == 'completed').toList();
        break;
      case _FilterType.pendingBalance:
        result = result.where((b) {
          final advance = b['advancePaid'] as double;
          final total = b['totalAmount'] as double;
          return (total - advance) > 0 && b['status'] != 'completed';
        }).toList();
        break;
      case _FilterType.all:
        break;
    }

    // Sort by date ascending
    result.sort(
      (a, b) =>
          (a['eventDate'] as DateTime).compareTo(b['eventDate'] as DateTime),
    );

    return result;
  }

  void _openAddBooking() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddBookingBottomSheet(),
    ).then((_) {
      if (mounted) setState(() {});
    });
  }

  void _openBookingDetail(Map<String, dynamic> booking) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BookingDetailBottomSheet(booking: booking),
    ).then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filtered = _filteredBookings;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _BookingAppBar(
              isSearching: _isSearching,
              searchCtrl: _searchCtrl,
              onSearchToggle: () {
                setState(() {
                  _isSearching = !_isSearching;
                  if (!_isSearching) {
                    _searchQuery = '';
                    _searchCtrl.clear();
                  }
                });
              },
              onSearchChanged: (v) => setState(() => _searchQuery = v),
            ),
            // Filter chips
            _FilterChipsWidget(
              activeFilter: _activeFilter,
              onFilterChanged: (f) => setState(() => _activeFilter = f),
              bookings: allBookingsMockData,
            ),
            // Booking count
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(
                    '${filtered.length} booking${filtered.length != 1 ? 's' : ''}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF9E9E9E),
                    ),
                  ),
                ],
              ),
            ),
            // List
            Expanded(
              child: filtered.isEmpty
                  ? EmptyStateWidget(
                      icon: Icons.event_note_outlined,
                      title: 'No bookings found',
                      subtitle: _searchQuery.isNotEmpty
                          ? 'No results for "$_searchQuery". Try a different name or event type.'
                          : 'No bookings match the selected filter. Add a new booking to get started.',
                      ctaLabel: 'Add Booking',
                      onCta: _openAddBooking,
                    )
                  : RefreshIndicator(
                      color: AppTheme.primary,
                      onRefresh: () async {
                        // TODO: Replace with real data refresh [Riverpod/Bloc]
                        await Future.delayed(const Duration(milliseconds: 600));
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final booking = filtered[index];
                          return TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: 1),
                            duration: Duration(
                              milliseconds: 300 + (index * 50).clamp(0, 400),
                            ),
                            curve: Curves.easeOutCubic,
                            builder: (context, value, child) {
                              return Transform.translate(
                                offset: Offset(0, 20 * (1 - value)),
                                child: Opacity(opacity: value, child: child),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: BookingListItemWidget(
                                booking: booking,
                                onTap: () => _openBookingDetail(booking),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddBooking,
        icon: const Icon(Icons.add_rounded),
        label: Text(
          'New Booking',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
    );
  }
}

class _BookingAppBar extends StatelessWidget {
  final bool isSearching;
  final TextEditingController searchCtrl;
  final VoidCallback onSearchToggle;
  final ValueChanged<String> onSearchChanged;

  const _BookingAppBar({
    required this.isSearching,
    required this.searchCtrl,
    required this.onSearchToggle,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      color: AppTheme.surfaceLight,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          if (!isSearching) ...[
            Text(
              'Bookings',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A1A1A),
              ),
            ),
            const Spacer(),
            IconButton(
              onPressed: onSearchToggle,
              icon: const Icon(Icons.search_rounded, color: AppTheme.primary),
              style: IconButton.styleFrom(
                backgroundColor: AppTheme.primaryContainer,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ] else ...[
            Expanded(
              child: TextField(
                controller: searchCtrl,
                onChanged: onSearchChanged,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search by client or event type...',
                  hintStyle: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    color: const Color(0xFF9E9E9E),
                  ),
                  prefixIcon: const Icon(Icons.search_rounded, size: 20),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  filled: true,
                  fillColor: AppTheme.surfaceVariantLight,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: onSearchToggle,
              child: Text(
                'Cancel',
                style: GoogleFonts.plusJakartaSans(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _FilterChipsWidget extends StatelessWidget {
  final _FilterType activeFilter;
  final ValueChanged<_FilterType> onFilterChanged;
  final List<Map<String, dynamic>> bookings;

  const _FilterChipsWidget({
    required this.activeFilter,
    required this.onFilterChanged,
    required this.bookings,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final upcomingCount = bookings
        .where(
          (b) =>
              (b['eventDate'] as DateTime).isAfter(now) &&
              b['status'] != 'cancelled',
        )
        .length;
    final pendingCount = bookings.where((b) {
      final advance = b['advancePaid'] as double;
      final total = b['totalAmount'] as double;
      return (total - advance) > 0 && b['status'] != 'completed';
    }).length;

    final filters = [
      {'type': _FilterType.all, 'label': 'All', 'count': bookings.length},
      {
        'type': _FilterType.upcoming,
        'label': 'Upcoming',
        'count': upcomingCount,
      },
      {'type': _FilterType.completed, 'label': 'Completed', 'count': null},
      {
        'type': _FilterType.pendingBalance,
        'label': 'Pending Balance',
        'count': pendingCount,
      },
    ];

    return Container(
      color: AppTheme.surfaceLight,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.asMap().entries.map((entry) {
            final i = entry.key;
            final filter = entry.value;
            final isActive = activeFilter == filter['type'];
            final count = filter['count'] as int?;

            return Padding(
              padding: EdgeInsets.only(right: i < filters.length - 1 ? 8 : 0),
              child: GestureDetector(
                onTap: () => onFilterChanged(filter['type'] as _FilterType),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppTheme.primary
                        : AppTheme.surfaceVariantLight,
                    borderRadius: BorderRadius.circular(8),
                    border: isActive
                        ? null
                        : Border.all(color: AppTheme.outlineLight, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        filter['label'] as String,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isActive
                              ? Colors.white
                              : const Color(0xFF5A4A50),
                        ),
                      ),
                      if (count != null && count > 0) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isActive
                                ? Colors.white.withAlpha(51)
                                : AppTheme.primary.withAlpha(26),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$count',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isActive ? Colors.white : AppTheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
