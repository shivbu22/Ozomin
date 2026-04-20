import '../core/constants/app_constants.dart';

/// Mock data model for a service worker.
class WorkerData {
  final String name;
  final String initial;
  final List<String> skills;
  final double rating;
  final int jobCount;
  final String distance;
  final String eta;
  final int pricePerHour;
  final List<double> avatarGradient; // HSL-like indices for gradient
  final int gradientIndex;

  const WorkerData({
    required this.name,
    required this.initial,
    required this.skills,
    required this.rating,
    required this.jobCount,
    required this.distance,
    required this.eta,
    required this.pricePerHour,
    this.avatarGradient = const [],
    this.gradientIndex = 0,
  });
}

/// Mock data model for a past job.
class JobData {
  final String id;
  final ServiceType service;
  final String workerName;
  final DateTime date;
  final String status; // completed, cancelled, in_progress
  final int amount;
  final double ratingGiven;
  final String address;

  const JobData({
    required this.id,
    required this.service,
    required this.workerName,
    required this.date,
    required this.status,
    required this.amount,
    required this.ratingGiven,
    required this.address,
  });
}

/// Static mock data that powers the app in demo mode.
class MockData {
  MockData._();

  static const List<WorkerData> workers = [
    WorkerData(
      name: 'Rajan Kumar',
      initial: 'R',
      skills: ['Cleaning', 'Garbage'],
      rating: 4.9,
      jobCount: 312,
      distance: '0.4 km',
      eta: '~5 min',
      pricePerHour: 120,
      gradientIndex: 0,
    ),
    WorkerData(
      name: 'Priya Devi',
      initial: 'P',
      skills: ['Recycling', 'Garbage'],
      rating: 4.8,
      jobCount: 219,
      distance: '0.6 km',
      eta: '~7 min',
      pricePerHour: 100,
      gradientIndex: 1,
    ),
    WorkerData(
      name: 'Suresh Babu',
      initial: 'S',
      skills: ['Bulk Pickup', 'Garbage'],
      rating: 4.7,
      jobCount: 445,
      distance: '1.1 km',
      eta: '~12 min',
      pricePerHour: 180,
      gradientIndex: 2,
    ),
    WorkerData(
      name: 'Meena Krishnan',
      initial: 'M',
      skills: ['Deep Cleaning', 'Office'],
      rating: 5.0,
      jobCount: 89,
      distance: '1.4 km',
      eta: '~15 min',
      pricePerHour: 150,
      gradientIndex: 3,
    ),
  ];

  static List<JobData> jobHistory = [
    JobData(
      id: 'EC2891',
      service: ServiceType.cleaning,
      workerName: 'Rajan Kumar',
      date: DateTime.now().subtract(const Duration(days: 1)),
      status: 'completed',
      amount: 240,
      ratingGiven: 5.0,
      address: '12/3, HSR Layout, Bengaluru',
    ),
    JobData(
      id: 'EC2834',
      service: ServiceType.recycling,
      workerName: 'Priya Devi',
      date: DateTime.now().subtract(const Duration(days: 3)),
      status: 'completed',
      amount: 0,
      ratingGiven: 4.5,
      address: 'Koramangala 4th Block',
    ),
    JobData(
      id: 'EC2756',
      service: ServiceType.garbage,
      workerName: 'Rajan Kumar',
      date: DateTime.now().subtract(const Duration(days: 5)),
      status: 'completed',
      amount: 120,
      ratingGiven: 5.0,
      address: '12/3, HSR Layout, Bengaluru',
    ),
    JobData(
      id: 'EC2701',
      service: ServiceType.bulkPickup,
      workerName: 'Suresh Babu',
      date: DateTime.now().subtract(const Duration(days: 8)),
      status: 'cancelled',
      amount: 0,
      ratingGiven: 0,
      address: 'BTM Layout 2nd Stage',
    ),
    JobData(
      id: 'EC2680',
      service: ServiceType.bulkPickup,
      workerName: 'Suresh Babu',
      date: DateTime.now().subtract(const Duration(days: 12)),
      status: 'completed',
      amount: 450,
      ratingGiven: 4.8,
      address: 'Jayanagar 4th Block',
    ),
  ];

  // Eco impact stats
  static const int totalServices = 7;
  static const String totalRecycled = '12kg';
  static const String totalEarned = '₹480';

  // Nearby stats
  static const int nearbyWorkers = 52;
  static const String avgResponse = '5 min';
}
