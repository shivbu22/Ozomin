import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'firestore_service.dart';

/// Firebase Cloud Messaging service for push notifications.
class FCMService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// Initialize FCM — call once on app start.
  Future<void> initialize() async {
    // Request permission (required for iOS, handled on Android)
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('✅ FCM: Notification permission granted');
    } else {
      debugPrint('⚠️ FCM: Notification permission denied');
    }

    // Get the FCM token (for sending targeted notifications)
    final token = await _messaging.getToken();
    debugPrint('🔑 FCM Token: $token');
    if (token != null) _saveToken(token);

    // Listen for token refreshes
    _messaging.onTokenRefresh.listen((newToken) {
      debugPrint('🔄 FCM Token refreshed: $newToken');
      _saveToken(newToken);
    });

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background/terminated messages
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // Check if app was opened from a terminated state via notification
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageOpenedApp(initialMessage);
    }
  }

  void _saveToken(String token) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await FirestoreService().updateFCMToken(uid, token);
      debugPrint('✅ FCM Token saved to Firestore');
    }
  }

  /// Handle messages received while app is in foreground.
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('📬 Foreground message: ${message.notification?.title}');
    debugPrint('   Body: ${message.notification?.body}');
    debugPrint('   Data: ${message.data}');

    // The notification type determines what action to take
    final type = message.data['type'] ?? '';
    switch (type) {
      case 'booking_confirmed':
        debugPrint('   → Booking confirmed notification');
        break;
      case 'worker_assigned':
        debugPrint('   → Worker assigned notification');
        break;
      case 'worker_arrived':
        debugPrint('   → Worker arrived notification');
        break;
      case 'service_completed':
        debugPrint('   → Service completed notification');
        break;
      default:
        debugPrint('   → General notification');
    }
  }

  /// Handle when user taps notification (app was in background/terminated).
  void _handleMessageOpenedApp(RemoteMessage message) {
    debugPrint('👆 Notification tapped: ${message.notification?.title}');
    final type = message.data['type'] ?? '';
    final bookingId = message.data['bookingId'] ?? '';

    debugPrint('   Type: $type, BookingId: $bookingId');
    // TODO: Navigate to appropriate screen based on notification type
  }

  /// Subscribe to a topic (e.g., "deals", "eco_tips").
  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
    debugPrint('📌 Subscribed to topic: $topic');
  }

  /// Unsubscribe from a topic.
  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
    debugPrint('📌 Unsubscribed from topic: $topic');
  }
}
