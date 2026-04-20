import 'package:cloud_firestore/cloud_firestore.dart';

/// Model for a service booking.
class BookingModel {
  final String id;
  final String userId;
  final String serviceType;
  final String workerName;
  final String workerId;
  final String address;
  final String notes;
  final int amount;
  final String status; // pending, confirmed, inProgress, completed, cancelled
  final DateTime createdAt;
  final DateTime? completedAt;
  final double? rating;

  const BookingModel({
    required this.id,
    required this.userId,
    required this.serviceType,
    required this.workerName,
    required this.workerId,
    required this.address,
    required this.notes,
    required this.amount,
    required this.status,
    required this.createdAt,
    this.completedAt,
    this.rating,
  });

  factory BookingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BookingModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      serviceType: data['serviceType'] ?? '',
      workerName: data['workerName'] ?? '',
      workerId: data['workerId'] ?? '',
      address: data['address'] ?? '',
      notes: data['notes'] ?? '',
      amount: data['amount'] ?? 0,
      status: data['status'] ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
      rating: (data['rating'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'userId': userId,
        'serviceType': serviceType,
        'workerName': workerName,
        'workerId': workerId,
        'address': address,
        'notes': notes,
        'amount': amount,
        'status': status,
        'createdAt': Timestamp.fromDate(createdAt),
        if (completedAt != null)
          'completedAt': Timestamp.fromDate(completedAt!),
        if (rating != null) 'rating': rating,
      };

  BookingModel copyWith({String? status, double? rating, DateTime? completedAt}) {
    return BookingModel(
      id: id,
      userId: userId,
      serviceType: serviceType,
      workerName: workerName,
      workerId: workerId,
      address: address,
      notes: notes,
      amount: amount,
      status: status ?? this.status,
      createdAt: createdAt,
      completedAt: completedAt ?? this.completedAt,
      rating: rating ?? this.rating,
    );
  }
}
