import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseService get instance => _instance ??= SupabaseService._();

  SupabaseService._();

  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  // Initialize Supabase - call this in main()
  static Future<void> initialize() async {
    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
      throw Exception(
        'SUPABASE_URL and SUPABASE_ANON_KEY must be defined using --dart-define.',
      );
    }
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  }

  // Get Supabase client
  SupabaseClient get client => Supabase.instance.client;

  // ─── Bookings CRUD ────────────────────────────────────────────────────────

  /// Fetch all bookings ordered by event_date descending.
  Future<List<Map<String, dynamic>>> fetchBookings() async {
    try {
      final response = await client
          .from('bookings')
          .select()
          .order('event_date', ascending: false);
      return _parseBookings(response as List<dynamic>);
    } catch (e) {
      return [];
    }
  }

  /// Insert a new booking. Returns the inserted row or null on failure.
  Future<Map<String, dynamic>?> insertBooking(
    Map<String, dynamic> booking,
  ) async {
    try {
      final row = _toDbRow(booking);
      final response = await client
          .from('bookings')
          .insert(row)
          .select()
          .single();
      return _parseBookingRow(response);
    } catch (e) {
      return null;
    }
  }

  /// Update an existing booking by id.
  Future<bool> updateBooking(Map<String, dynamic> booking) async {
    try {
      final row = _toDbRow(booking);
      await client.from('bookings').update(row).eq('id', booking['id']);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Update only the status field of a booking.
  Future<bool> updateBookingStatus(String id, String status) async {
    try {
      await client
          .from('bookings')
          .update({'booking_status': status})
          .eq('id', id);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Delete a booking by id.
  Future<bool> deleteBooking(String id) async {
    try {
      await client.from('bookings').delete().eq('id', id);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Generate the next sequential booking ID in BCH-XXX format.
  Future<String> generateNextBookingId() async {
    try {
      final response = await client
          .from('bookings')
          .select('id')
          .order('created_at', ascending: false);
      final rows = response as List<dynamic>;
      int maxNum = 0;
      for (final row in rows) {
        final id = row['id'] as String? ?? '';
        if (id.startsWith('BCH-')) {
          final numStr = id.substring(4);
          final num = int.tryParse(numStr) ?? 0;
          if (num > maxNum) maxNum = num;
        }
      }
      final nextNum = maxNum + 1;
      return 'BCH-${nextNum.toString().padLeft(3, '0')}';
    } catch (e) {
      // Fallback: use timestamp-based BCH ID
      final ts = DateTime.now().millisecondsSinceEpoch % 1000;
      return 'BCH-${ts.toString().padLeft(3, '0')}';
    }
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  /// Convert in-memory booking map (with DateTime) → DB row (with date string).
  Map<String, dynamic> _toDbRow(Map<String, dynamic> b) {
    final eventDate = b['eventDate'] as DateTime;
    return {
      'id': b['id'],
      'client_name': b['clientName'] ?? '',
      'phone': b['phone'] ?? '',
      'event_type': b['eventType'] ?? 'Wedding',
      'event_date':
          '${eventDate.year}-${eventDate.month.toString().padLeft(2, '0')}-${eventDate.day.toString().padLeft(2, '0')}',
      'function_time': b['functionTime'] ?? 'Day',
      'guest_count': b['guestCount'] ?? 0,
      'total_amount': b['totalAmount'] ?? 0.0,
      'advance_paid': b['advancePaid'] ?? 0.0,
      'booking_status': b['status'] ?? 'confirmed',
      'notes': b['notes'] ?? '',
    };
  }

  /// Convert DB row → in-memory booking map (with DateTime).
  Map<String, dynamic> _parseBookingRow(Map<String, dynamic> row) {
    return {
      'id': row['id'] as String,
      'clientName': row['client_name'] as String,
      'phone': row['phone'] as String? ?? '',
      'eventType': row['event_type'] as String,
      'eventDate': DateTime.parse(row['event_date'] as String),
      'functionTime': row['function_time'] as String? ?? 'Day',
      'guestCount': (row['guest_count'] as num?)?.toInt() ?? 0,
      'totalAmount': (row['total_amount'] as num?)?.toDouble() ?? 0.0,
      'advancePaid': (row['advance_paid'] as num?)?.toDouble() ?? 0.0,
      'status': row['booking_status'] as String? ?? 'confirmed',
      'notes': row['notes'] as String? ?? '',
    };
  }

  List<Map<String, dynamic>> _parseBookings(List<dynamic> rows) {
    return rows
        .map((r) => _parseBookingRow(r as Map<String, dynamic>))
        .toList();
  }
}
