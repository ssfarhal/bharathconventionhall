import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import './widgets/add_booking_bottom_sheet.dart';
import './widgets/dashboard_header_widget.dart';
import './widgets/dashboard_kpi_row_widget.dart';
import './widgets/dashboard_upcoming_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // TODO: Replace with [Riverpod/Bloc] for production
  final bool _isLoading = false;

  Future<void> _onRefresh() async {
    // Small delay to show the refresh indicator
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) setState(() {});
  }

  void _openAddBooking() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddBookingBottomSheet(),
    ).then((result) {
      if (result == true) {
        setState(() {}); // Refresh dashboard after booking is added
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final greeting = _getGreeting(now.hour);

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          color: AppTheme.primary,
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: AppTheme.backgroundLight,
                elevation: 0,
                scrolledUnderElevation: 1,
                floating: true,
                snap: true,
                title: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/bharath_Logo-1787316700785.png',
                      height: 36,
                      width: 36,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Bharath Convention Hall',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
                actions: [
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_outlined,
                      color: AppTheme.primary,
                    ),
                    onPressed: () {},
                  ),
                  const SizedBox(width: 4),
                ],
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: 8),
                    DashboardHeaderWidget(greeting: greeting),
                    const SizedBox(height: 16),
                    DashboardKpiRowWidget(),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Upcoming Events',
                          style: theme.textTheme.titleMedium,
                        ),
                        TextButton(
                          onPressed: () =>
                              context.go(AppRoutes.bookingManagementScreen),
                          child: Text(
                            'View all',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    DashboardUpcomingWidget(),
                    const SizedBox(height: 100),
                  ]),
                ),
              ),
            ],
          ),
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

  String _getGreeting(int hour) {
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }
}
