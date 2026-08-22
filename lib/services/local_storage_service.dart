import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists all booking data locally on the device using shared_preferences.
/// Bookings survive app restarts and are tied to this device.
class LocalStorageService {
  static const String _bookingsKey = 'bharath_bookings_v1';

  static LocalStorageService? _instance;
  static LocalStorageService get instance {
    _instance ??= LocalStorageService._();
    return _instance!;
  }

  LocalStorageService._();

  /// Load all bookings from local storage. Returns an empty list if none saved.
  Future<List<Map<String, dynamic>>> loadBookings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_bookingsKey);
      if (raw == null || raw.isEmpty) return [];

      final List<dynamic> decoded = jsonDecode(raw);
      return decoded.map<Map<String, dynamic>>((item) {
        final map = Map<String, dynamic>.from(item as Map);
        // Convert ISO date string back to DateTime
        if (map['eventDate'] is String) {
          map['eventDate'] = DateTime.parse(map['eventDate'] as String);
        }
        // Ensure numeric types are correct
        map['totalAmount'] = (map['totalAmount'] as num?)?.toDouble() ?? 0.0;
        map['advancePaid'] = (map['advancePaid'] as num?)?.toDouble() ?? 0.0;
        map['guestCount'] = (map['guestCount'] as num?)?.toInt() ?? 0;
        return map;
      }).toList();
    } catch (_) {
      return [];
    }
  }

  /// Save all bookings to local storage.
  Future<void> saveBookings(List<Map<String, dynamic>> bookings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final serializable = bookings.map((b) {
        final map = Map<String, dynamic>.from(b);
        // Convert DateTime to ISO string for JSON serialization
        if (map['eventDate'] is DateTime) {
          map['eventDate'] = (map['eventDate'] as DateTime).toIso8601String();
        }
        return map;
      }).toList();
      await prefs.setString(_bookingsKey, jsonEncode(serializable));
    } catch (_) {
      // Silently fail — data will still work in memory for this session
    }
  }
}
