import 'dart:io';
import 'dart:math';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:windows_notification/notification_message.dart';
import 'package:windows_notification/windows_notification.dart';
import 'package:yamata_launcher/constants/app_constants.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:yamata_launcher/constants/settings_constants.dart';
import 'package:yamata_launcher/services/settings_service.dart';

class NotificationsService {
  NotificationsService._();

  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'yamata_launcher_channel';
  static const String _channelName = 'yamata_launcher Notifications';
  static const String _channelDescription = 'Notifications for Yamata Launcher';

  static void _onDidReceiveNotificationResponse(
      NotificationResponse notificationResponse) {}

  static Future<void> init() async {
    final packageInfo = await PackageInfo.fromPlatform();

    if (Platform.isWindows) {
      return;
    }

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');

    const darwinInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const linuxInit =
        LinuxInitializationSettings(defaultActionName: 'Open notification');

    final settings = InitializationSettings(
      android: androidInit,
      iOS: darwinInit,
      macOS: darwinInit,
      linux: linuxInit,
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

  static Future<void> showNotification(
      {required String title,
      required String body,
      String? image,
      int? progressPercent,
      String? tag}) async {
    var notificationsEnabledSetting =
        await SettingsService().get<bool>(SettingsKeys.ENABLE_NOTIFICATIONS);
    if (notificationsEnabledSetting == true) {
      return;
    }
    if (Platform.isWindows) {
      final _winNotifyPlugin =
          WindowsNotification(applicationId: "Yamata Launcher");
      NotificationMessage message = NotificationMessage.fromPluginTemplate(
          Random().nextInt(100000).toString(), title, body,
          image: image);
      _winNotifyPlugin.showNotificationPluginTemplate(message);
      return;
    }

    final androidDetails = await _androidDetails(image, progressPercent, tag);
    final darwinDetails = _darwinDetails(image);
    final linuxDetails = _linuxDetails(image);

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
      linux: linuxDetails,
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
      String? image, int? progressPercent, String? tag) async {
    if (image != null && File(image).existsSync()) {
      return AndroidNotificationDetails(
        _channelId,
        _channelName,
        tag: tag,
        channelDescription: _channelDescription,
        groupKey: 'yamata_launcher_group',
        styleInformation: BigPictureStyleInformation(
          FilePathAndroidBitmap(image),
        ),
        importance: Importance.max,
        priority: Priority.high,
        maxProgress: 100,
        progress: progressPercent ?? 0,
        showProgress: progressPercent != null,
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
}
