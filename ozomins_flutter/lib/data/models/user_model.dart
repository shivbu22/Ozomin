import 'package:cloud_firestore/cloud_firestore.dart';

/// Model for a user profile.
class UserModel {
  final String uid;
  final String name;
  final String phone;
  final String email;
  final List<String> savedAddresses;
  final int totalBookings;
  final double co2Saved; // in kg
  final double totalRecycled; // in kg
  final double avgRating;
  final DateTime createdAt;

  const UserModel({
    required this.uid,
    required this.name,
    required this.phone,
    this.email = '',
    this.savedAddresses = const [],
    this.totalBookings = 0,
    this.co2Saved = 0.0,
    this.totalRecycled = 0.0,
    this.avgRating = 5.0,
    required this.createdAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      email: data['email'] ?? '',
      savedAddresses: List<String>.from(data['savedAddresses'] ?? []),
      totalBookings: data['totalBookings'] ?? 0,
      co2Saved: (data['co2Saved'] as num?)?.toDouble() ?? 0.0,
      totalRecycled: (data['totalRecycled'] as num?)?.toDouble() ?? 0.0,
      avgRating: (data['avgRating'] as num?)?.toDouble() ?? 5.0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'name': name,
        'phone': phone,
        'email': email,
        'savedAddresses': savedAddresses,
        'totalBookings': totalBookings,
        'co2Saved': co2Saved,
        'totalRecycled': totalRecycled,
        'avgRating': avgRating,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  UserModel copyWith({
    String? name,
    String? email,
    List<String>? savedAddresses,
    int? totalBookings,
    double? co2Saved,
    double? totalRecycled,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      phone: phone,
      email: email ?? this.email,
      savedAddresses: savedAddresses ?? this.savedAddresses,
      totalBookings: totalBookings ?? this.totalBookings,
      co2Saved: co2Saved ?? this.co2Saved,
      totalRecycled: totalRecycled ?? this.totalRecycled,
      avgRating: avgRating,
      createdAt: createdAt,
    );
  }
}
