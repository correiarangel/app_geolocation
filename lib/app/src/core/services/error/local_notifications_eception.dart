abstract class ILocalNotificationException implements Exception {
  final String message;
  final StackTrace stackTrace;

  ILocalNotificationException({
    required this.message,
    required this.stackTrace,
  });
}

class LocalNotificationException extends ILocalNotificationException {
  LocalNotificationException({required super.message, required super.stackTrace});
}
