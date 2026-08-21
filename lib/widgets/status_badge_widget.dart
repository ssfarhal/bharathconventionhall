import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum BookingStatus { confirmed, pending, completed, available, cancelled }

class StatusBadgeWidget extends StatelessWidget {
  final BookingStatus status;
  final double? fontSize;

  const StatusBadgeWidget({required this.status, this.fontSize, super.key});

  @override
  Widget build(BuildContext context) {
    final config = _statusConfig(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: config['bg'] as Color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        config['label'] as String,
        style: GoogleFonts.plusJakartaSans(
          fontSize: fontSize ?? 11,
          fontWeight: FontWeight.w600,
          color: config['fg'] as Color,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Map<String, dynamic> _statusConfig(BookingStatus s) {
    switch (s) {
      case BookingStatus.confirmed:
        return {
          'label': 'Confirmed',
          'bg': const Color(0xFFE6F4ED),
          'fg': const Color(0xFF2D7A4F),
        };
      case BookingStatus.pending:
        return {
          'label': 'Pending',
          'bg': const Color(0xFFFFF3DC),
          'fg': const Color(0xFFB45309),
        };
      case BookingStatus.completed:
        return {
          'label': 'Completed',
          'bg': const Color(0xFFF0F0F0),
          'fg': const Color(0xFF6B7280),
        };
      case BookingStatus.available:
        return {
          'label': 'Available',
          'bg': const Color(0xFFE6F4ED),
          'fg': const Color(0xFF2D7A4F),
        };
      case BookingStatus.cancelled:
        return {
          'label': 'Cancelled',
          'bg': const Color(0xFFFDE8E8),
          'fg': const Color(0xFFB91C1C),
        };
    }
  }
}
