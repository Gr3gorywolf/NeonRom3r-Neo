import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:neonrom3r/constants/app_constants.dart';
import 'package:package_info_plus/package_info_plus.dart';

class NotificationsService {
  NotificationsService._();

  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'neonrom3r_channel';
  static const String _channelName = 'NeonROM3r Notifications';
  static const String _channelDescription =
      'Notifications for game activity and system events';

  static void _onDidReceiveNotificationResponse(
      NotificationResponse notificationResponse) {}

  static Future<void> init() async {
    final packageInfo = await PackageInfo.fromPlatform();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');

    const darwinInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const linuxInit =
        LinuxInitializationSettings(defaultActionName: 'Open notification');

    final windowsInit = WindowsInitializationSettings(
      appName: AppConstants.appName,
      appUserModelId: packageInfo.packageName,
      guid: AppConstants.appGuid,
    );

    final settings = InitializationSettings(
      android: androidInit,
      iOS: darwinInit,
      macOS: darwinInit,
      linux: linuxInit,
      windows: windowsInit,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
    );

    if (Platform.isAndroid) {
      await _notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }
  }

  static Future<void> showNotification({
    required String title,
    required String body,
    String? image, // ruta local del archivo
  }) async {
    final androidDetails = await _androidDetails(image);
    final darwinDetails = _darwinDetails(image);
    final linuxDetails = _linuxDetails(image);
    final windowsDetails = _windowsDetails(image);

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
      linux: linuxDetails,
      windows: windowsDetails,
    );

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      notificationDetails,
    );
  }

  // android

  static Future<AndroidNotificationDetails> _androidDetails(
      String? image) async {
    if (image != null && File(image).existsSync()) {
      return AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        styleInformation: BigPictureStyleInformation(
          FilePathAndroidBitmap(image),
        ),
        importance: Importance.max,
        priority: Priority.high,
      );
    }

    return const AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.max,
      priority: Priority.high,
    );
  }

  // mac & ios

  static DarwinNotificationDetails _darwinDetails(String? image) {
    if (image != null && File(image).existsSync()) {
      return DarwinNotificationDetails(
        attachments: [DarwinNotificationAttachment(image)],
      );
    }

    return const DarwinNotificationDetails();
  }

  // linux

  static LinuxNotificationDetails _linuxDetails(String? image) {
    return LinuxNotificationDetails(
      urgency: LinuxNotificationUrgency.normal,
    );
  }

  // windows

  static WindowsNotificationDetails _windowsDetails(String? image) {
    return WindowsNotificationDetails(
        images: image != null && File(image).existsSync()
            ? [WindowsImage(Uri.parse(image), altText: 'Notification Image')]
            : []);
  }
}
