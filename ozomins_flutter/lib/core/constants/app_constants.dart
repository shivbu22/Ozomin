// App-wide constants for the Ozomins application.

enum ServiceType {
  // Cleaning
  cleaning('Home Cleaning', '🧹', 149),
  deepClean('Deep Cleaning', '🧴', 499),
  officeClean('Office Clean', '🏢', 349),
  subscription('Subscription', '📅', 999),

  // Waste & Garbage
  garbage('Garbage', '🗑️', 99),
  recycling('Recycling', '♻️', 0),
  eWaste('E-Waste', '📱', 0),
  dryWetWaste('Dry & Wet Waste', '🧴', 79),
  bulkPickup('Bulk Pickup', '🚛', 299),

  // Eco Services
  ecoFriendly('Eco-Friendly', '🌿', 199),
  compost('Compost', '🌱', 149),
  solarCleaning('Solar Cleaning', '☀️', 399),
  societyWaste('Society Mgmt', '🏘️', 1499),

  // B2B
  b2bContract('B2B Contract', '📝', 4999),
  staffOutsourcing('Staff Hire', '👷', 2999),

  // Smart
  ecoRewards('Eco Rewards', '🏆', 0),
  wasteTracking('Waste Tracking', '📊', 199);

  final String label;
  final String emoji;
  final int startingPrice;

  const ServiceType(this.label, this.emoji, this.startingPrice);
}

class AppConstants {
  AppConstants._();

  static const String appName = 'Ozomins';
  static const String tagline = 'Eco services delivered in minutes';
  static const String city = 'Bengaluru';
  static const String defaultAddress = 'Koramangala, BLR';

  // Animation durations
  static const Duration animFast = Duration(milliseconds: 200);
  static const Duration animNormal = Duration(milliseconds: 350);
  static const Duration animSlow = Duration(milliseconds: 600);
  static const Duration splashDuration = Duration(milliseconds: 2500);

  // Spacing
  static const double paddingXS = 4;
  static const double paddingSM = 8;
  static const double paddingMD = 16;
  static const double paddingLG = 24;
  static const double paddingXL = 32;
  static const double paddingXXL = 48;

  // Radius
  static const double radiusSM = 8;
  static const double radiusMD = 12;
  static const double radiusLG = 16;
  static const double radiusXL = 24;
  static const double radiusFull = 100;
}
