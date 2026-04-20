import 'package:cloud_firestore/cloud_firestore.dart';

/// Model for a service worker.
class WorkerModel {
  final String id;
  final String name;
  final String initial;
  final List<String> skills;
  final double rating;
  final int jobCount;
  final String phone;
  final bool isAvailable;
  final double latitude;
  final double longitude;
  final int pricePerHour;

  const WorkerModel({
    required this.id,
    required this.name,
    required this.initial,
    required this.skills,
    required this.rating,
    required this.jobCount,
    required this.phone,
    required this.isAvailable,
    required this.latitude,
    required this.longitude,
    required this.pricePerHour,
  });

  factory WorkerModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WorkerModel(
      id: doc.id,
      name: data['name'] ?? '',
      initial: data['initial'] ?? '',
      skills: List<String>.from(data['skills'] ?? []),
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      jobCount: data['jobCount'] ?? 0,
      phone: data['phone'] ?? '',
      isAvailable: data['isAvailable'] ?? true,
      latitude: (data['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (data['longitude'] as num?)?.toDouble() ?? 0.0,
      pricePerHour: data['pricePerHour'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'name': name,
        'initial': initial,
        'skills': skills,
        'rating': rating,
        'jobCount': jobCount,
        'phone': phone,
        'isAvailable': isAvailable,
        'latitude': latitude,
        'longitude': longitude,
        'pricePerHour': pricePerHour,
      };

  /// Calculate distance text from user location
  String distanceFrom(double userLat, double userLng) {
    // Simplified distance calculation (Haversine would be better)
    final dx = (latitude - userLat).abs();
    final dy = (longitude - userLng).abs();
    final km = (dx * dx + dy * dy) * 111; // rough degrees-to-km
    if (km < 1) return '${(km * 1000).round()} m';
    return '${km.toStringAsFixed(1)} km';
  }
}
