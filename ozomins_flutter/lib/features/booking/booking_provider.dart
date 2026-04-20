import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/app_constants.dart';
import '../../data/services/firestore_service.dart';
import '../../data/models/booking_model.dart';

/// Firestore-backed state management for the booking flow.
class BookingProvider extends ChangeNotifier {
  final FirestoreService _db = FirestoreService();

  ServiceType _selectedService = ServiceType.cleaning;
  String _address = '';
  String _description = '';
  String _schedule = 'now';
  bool _isLoading = false;
  bool _isBooked = false;
  String? _lastBookingId;
  String? _errorMessage;

  ServiceType get selectedService => _selectedService;
  String get address => _address;
  String get description => _description;
  String get schedule => _schedule;
  bool get isLoading => _isLoading;
  bool get isBooked => _isBooked;
  String? get lastBookingId => _lastBookingId;
  String? get errorMessage => _errorMessage;

  int get estimatedPrice {
    int base = _selectedService.startingPrice;
    if (base == 0) return 0;
    if (_description.length > 50) base += 50;
    return base;
  }

  String get priceDisplay {
    if (_selectedService == ServiceType.recycling) {
      return 'You earn ₹';
    }
    return '₹$estimatedPrice';
  }

  void selectService(ServiceType service) {
    _selectedService = service;
    notifyListeners();
  }

  void setAddress(String addr) {
    _address = addr;
    notifyListeners();
  }

  void setDescription(String desc) {
    _description = desc;
    notifyListeners();
  }

  void setSchedule(String sched) {
    _schedule = sched;
    notifyListeners();
  }

  /// Create a real booking directly in Firestore.
  Future<bool> confirmBooking() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _errorMessage = 'Please sign in first.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Pick a random worker for demo (production: use assignment algorithm)
      final workers = await _db.searchWorkers(_selectedService.label);
      final workerName = workers.isNotEmpty ? workers.first.name : 'Rajan Kumar';
      final workerId = workers.isNotEmpty ? workers.first.id : 'default_worker';

      final booking = BookingModel(
        id: '', // Firestore auto-assigns
        userId: user.uid,
        serviceType: _selectedService.label,
        workerName: workerName,
        workerId: workerId,
        address: _address.isNotEmpty ? _address : 'Koramangala, Bengaluru',
        notes: _description,
        amount: estimatedPrice,
        status: 'confirmed',
        createdAt: DateTime.now(),
      );

      final bookingId = await _db.createBooking(booking);
      _lastBookingId = bookingId;

      // Update user eco stats in Firestore
      await _db.updateEcoStats(user.uid, co2Delta: 2.0, recycledDelta: 0.7);

      _isLoading = false;
      _isBooked = true;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('❌ Booking failed: $e');
      _errorMessage = 'Could not confirm booking. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Cancel the last booking.
  Future<void> cancelLastBooking() async {
    if (_lastBookingId != null) {
      await _db.cancelBooking(_lastBookingId!);
    }
  }

  void reset() {
    _isBooked = false;
    _description = '';
    _schedule = 'now';
    _lastBookingId = null;
    _errorMessage = null;
    notifyListeners();
  }
}
