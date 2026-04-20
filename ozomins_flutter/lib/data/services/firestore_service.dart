import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booking_model.dart';
import '../models/worker_model.dart';
import '../models/user_model.dart';

/// Centralized Firestore service for all database operations.
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Collection References ──────────────────────────────────
  CollectionReference<Map<String, dynamic>> get _usersCol =>
      _db.collection('users');
  CollectionReference<Map<String, dynamic>> get _workersCol =>
      _db.collection('workers');
  CollectionReference<Map<String, dynamic>> get _bookingsCol =>
      _db.collection('bookings');

  // ═══════════════════════════════════════════════════════════
  // USERS
  // ═══════════════════════════════════════════════════════════

  /// Create or update a user profile.
  Future<void> setUser(UserModel user) async {
    await _usersCol.doc(user.uid).set(user.toFirestore(), SetOptions(merge: true));
  }

  /// Get user by UID.
  Future<UserModel?> getUser(String uid) async {
    final doc = await _usersCol.doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  /// Stream user profile (for real-time updates).
  Stream<UserModel?> streamUser(String uid) {
    return _usersCol.doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc);
    });
  }

  /// Update user eco stats after a completed booking.
  Future<void> updateEcoStats(String uid,
      {double co2Delta = 0, double recycledDelta = 0}) async {
    await _usersCol.doc(uid).update({
      'totalBookings': FieldValue.increment(1),
      'co2Saved': FieldValue.increment(co2Delta),
      'totalRecycled': FieldValue.increment(recycledDelta),
    });
  }

  /// Update FCM Token for push notifications.
  Future<void> updateFCMToken(String uid, String token) async {
    await _usersCol.doc(uid).update({'fcmToken': token});
  }

  // ═══════════════════════════════════════════════════════════
  // WORKERS
  // ═══════════════════════════════════════════════════════════

  /// Get all available workers.
  Future<List<WorkerModel>> getAvailableWorkers() async {
    final snap = await _workersCol
        .where('isAvailable', isEqualTo: true)
        .orderBy('rating', descending: true)
        .limit(20)
        .get();
    return snap.docs.map((d) => WorkerModel.fromFirestore(d)).toList();
  }

  /// Search workers by skill.
  Future<List<WorkerModel>> searchWorkers(String skill) async {
    final snap = await _workersCol
        .where('skills', arrayContains: skill)
        .where('isAvailable', isEqualTo: true)
        .get();
    return snap.docs.map((d) => WorkerModel.fromFirestore(d)).toList();
  }

  /// Get a single worker by ID.
  Future<WorkerModel?> getWorker(String workerId) async {
    final doc = await _workersCol.doc(workerId).get();
    if (!doc.exists) return null;
    return WorkerModel.fromFirestore(doc);
  }

  /// Stream nearby workers count.
  Stream<int> streamNearbyWorkersCount() {
    return _workersCol
        .where('isAvailable', isEqualTo: true)
        .snapshots()
        .map((snap) => snap.docs.length);
  }

  // ═══════════════════════════════════════════════════════════
  // BOOKINGS
  // ═══════════════════════════════════════════════════════════

  /// Create a new booking.
  Future<String> createBooking(BookingModel booking) async {
    final doc = await _bookingsCol.add(booking.toFirestore());
    return doc.id;
  }

  /// Get booking history for a user.
  Future<List<BookingModel>> getUserBookings(String userId) async {
    final snap = await _bookingsCol
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .get();
    return snap.docs.map((d) => BookingModel.fromFirestore(d)).toList();
  }

  /// Stream active bookings (for tracking).
  Stream<List<BookingModel>> streamActiveBookings(String userId) {
    return _bookingsCol
        .where('userId', isEqualTo: userId)
        .where('status', whereIn: ['pending', 'confirmed', 'inProgress'])
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => BookingModel.fromFirestore(d)).toList());
  }

  /// Update booking status.
  Future<void> updateBookingStatus(String bookingId, String status) async {
    final update = <String, dynamic>{'status': status};
    if (status == 'completed') {
      update['completedAt'] = FieldValue.serverTimestamp();
    }
    await _bookingsCol.doc(bookingId).update(update);
  }

  /// Rate a completed booking.
  Future<void> rateBooking(String bookingId, double rating) async {
    await _bookingsCol.doc(bookingId).update({'rating': rating});
  }

  /// Cancel a booking.
  Future<void> cancelBooking(String bookingId) async {
    await _bookingsCol.doc(bookingId).update({
      'status': 'cancelled',
    });
  }

  // ═══════════════════════════════════════════════════════════
  // SEED DATA (for development)
  // ═══════════════════════════════════════════════════════════

  /// Seeds the Firestore with mock workers (call once during development).
  Future<void> seedWorkers() async {
    final batch = _db.batch();
    final workers = [
      {
        'name': 'Rajan Kumar',
        'initial': 'R',
        'skills': ['Cleaning', 'Garbage'],
        'rating': 4.9,
        'jobCount': 312,
        'phone': '+919876543210',
        'isAvailable': true,
        'latitude': 12.9141,
        'longitude': 77.6372,
        'pricePerHour': 120,
      },
      {
        'name': 'Priya Devi',
        'initial': 'P',
        'skills': ['Recycling', 'Garbage'],
        'rating': 4.8,
        'jobCount': 219,
        'phone': '+919876543211',
        'isAvailable': true,
        'latitude': 12.9256,
        'longitude': 77.6504,
        'pricePerHour': 100,
      },
      {
        'name': 'Suresh Babu',
        'initial': 'S',
        'skills': ['Transport', 'Emergency'],
        'rating': 4.7,
        'jobCount': 445,
        'phone': '+919876543212',
        'isAvailable': true,
        'latitude': 12.9080,
        'longitude': 77.6200,
        'pricePerHour': 180,
      },
      {
        'name': 'Meena Krishnan',
        'initial': 'M',
        'skills': ['Deep Cleaning', 'Office'],
        'rating': 5.0,
        'jobCount': 89,
        'phone': '+919876543213',
        'isAvailable': true,
        'latitude': 12.9350,
        'longitude': 77.6100,
        'pricePerHour': 150,
      },
    ];

    for (final w in workers) {
      batch.set(_workersCol.doc(), w);
    }
    await batch.commit();
  }
}
