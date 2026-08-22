import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';
import 'dashboard_header_widget.dart';

class DashboardKpiRowWidget extends StatelessWidget {
  const DashboardKpiRowWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final bookings = allBookingsMockData;
    final now = DateTime.now();

    // Calculate KPIs
    final thisMonthBookings = bookings.where((b) {
      final d = b['eventDate'] as DateTime;
      return d.month == now.month && d.year == now.year;
    }).toList();

    double monthlyRevenue = 0;
    double pendingBalance = 0;
    int upcomingCount = 0;

    for (final b in bookings) {
      final d = b['eventDate'] as DateTime;
      final advance = (b['advancePaid'] as double);
      final total = (b['totalAmount'] as double);
      final balance = total - advance;

      if (d.month == now.month && d.year == now.year) {
        monthlyRevenue += advance;
      }
      if (d.isAfter(now) && b['status'] != 'cancelled') {
        upcomingCount++;
        if (balance > 0 && b['status'] != 'completed') {
          pendingBalance += balance;
        }
      }
    }

    final kpis = [
      {
        'label': 'Monthly\nRevenue',
        'value': '₹${_formatAmount(monthlyRevenue)}',
        'icon': Icons.currency_rupee_rounded,
        'color': AppTheme.primary,
        'bgColor': AppTheme.primaryContainer,
        'isAlert': false,
      },
      {
        'label': 'Upcoming\nEvents',
        'value': '$upcomingCount',
        'icon': Icons.event_rounded,
        'color': AppTheme.secondary,
        'bgColor': AppTheme.secondaryContainer,
        'isAlert': false,
      },
      {
        'label': 'Pending\nBalance',
        'value': '₹${_formatAmount(pendingBalance)}',
        'icon': Icons.account_balance_wallet_outlined,
        'color': AppTheme.warning,
        'bgColor': AppTheme.warningContainer,
        'isAlert': pendingBalance > 0,
      },
    ];

    return Row(
      children: kpis.asMap().entries.map((entry) {
        final i = entry.key;
        final kpi = entry.value;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i < kpis.length - 1 ? 10 : 0),
            child: _KpiCard(kpi: kpi),
          ),
        );
      }).toList(),
    );
  }

  String _formatAmount(double amount) {
    final intVal = amount.round();
    final formatted = intVal.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
    return '$formatted/-';
  }
}

class _KpiCard extends StatelessWidget {
  final Map<String, dynamic> kpi;

  const _KpiCard({required this.kpi});

  @override
  Widget build(BuildContext context) {
    final color = kpi['color'] as Color;
    final bgColor = kpi['bgColor'] as Color;
    final isAlert = kpi['isAlert'] as bool;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: isAlert
            ? Border.all(color: AppTheme.warning.withAlpha(100), width: 1.5)
            : null,
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
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(kpi['icon'] as IconData, color: color, size: 18),
          ),
          const SizedBox(height: 10),
          Text(
            kpi['value'] as String,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A1A),
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            kpi['label'] as String,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF9E9E9E),
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}
