// lib/services/notification_service.dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:mysociety/services/user_service.dart';

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final UserService _userService = UserService();

  Future<void> initNotifications(String uid) async {
    // Request permission from the user (important for iOS)
    await _fcm.requestPermission();

    // Get the FCM token for this device
    final fcmToken = await _fcm.getToken();

    // Save the token to the user's document in Firestore
    if (fcmToken != null) {
      _userService.saveUserToken(uid: uid, token: fcmToken);

      // Listen for token refreshes
      _fcm.onTokenRefresh.listen((newToken) {
        _userService.saveUserToken(uid: uid, token: newToken);
      });
    }

    // Subscribe the user to the "notices" topic
    await _fcm.subscribeToTopic('notices');
  }
}