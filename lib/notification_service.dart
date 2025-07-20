import 'package:windows_notification/windows_notification.dart';
import 'package:windows_notification/notification_message.dart';

class WindowsNotificationService {
  static final WindowsNotificationService _instance =
      WindowsNotificationService._internal();

  factory WindowsNotificationService() => _instance;

  late final WindowsNotification _winNotifyPlugin;

  WindowsNotificationService._internal() {
    _winNotifyPlugin = WindowsNotification(applicationId: "MP4X");
  }

  /// Gửi thông báo đơn giản (title + body)
  Future<void> showNotification({
    required String id,
    required String title,
    required String body,
  }) async {
    final message = NotificationMessage.fromPluginTemplate(id, title, body);
    await _winNotifyPlugin.showNotificationPluginTemplate(message);
  }

  Future<void> showNotificationWithImage({
    required String id,
    required String title,
    required String body,
    required String imagePath,
  }) async {
    final message = NotificationMessage.fromPluginTemplate(id, title, body);
    await _winNotifyPlugin.showNotificationPluginTemplate(message);
  }
}
