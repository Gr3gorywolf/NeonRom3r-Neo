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
  static final Map<String, int> _tagIds = {};

  static void _onDidReceiveNotificationResponse(
      NotificationResponse notificationResponse) {}
  static int getIdForTag(String tag) {
    return _tagIds.putIfAbsent(
        tag, () => DateTime.now().millisecondsSinceEpoch ~/ 1000);
  }

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
      bool silent = false,
      String? tag}) async {
    var notificationsEnabledSetting =
        await SettingsService().get<bool>(SettingsKeys.ENABLE_NOTIFICATIONS);
    if (notificationsEnabledSetting == false) {
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

    final androidDetails =
        await _androidDetails(image, progressPercent, tag, silent);
    final darwinDetails = _darwinDetails(image);
    final linuxDetails = _linuxDetails(image);

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
      linux: linuxDetails,
    );
    var id = tag != null
        ? getIdForTag(tag)
        : DateTime.now().millisecondsSinceEpoch ~/ 1000;
    await _notifications.show(
      id,
      title,
      body,
      notificationDetails,
    );
  }

  static Future<void> cancelNotificationByTag(String tag) async {
    final id = _tagIds[tag];
    if (id != null) {
      await _notifications.cancel(id, tag: tag);
    }
  }

  // android

  static Future<AndroidNotificationDetails> _androidDetails(
    String? image,
    int? progressPercent,
    String? tag,
    bool silent,
  ) async {
    BigPictureStyleInformation? styleInfo;

    if (image != null && File(image).existsSync()) {
      styleInfo = BigPictureStyleInformation(
        FilePathAndroidBitmap(image),
      );
    }

    return AndroidNotificationDetails(
      _channelId,
      _channelName,
      tag: tag,
      groupKey: 'yamata_launcher_group',
      channelDescription: _channelDescription,
      styleInformation: styleInfo,
      importance: silent ? Importance.low : Importance.max,
      silent: silent,
      priority: silent ? Priority.low : Priority.high,
      autoCancel: progressPercent == null,
      playSound: progressPercent == null,
      ongoing: progressPercent != null,
      indeterminate: progressPercent == 0,
      maxProgress: 100,
      progress: progressPercent ?? 0,
      showProgress: progressPercent != null,
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
