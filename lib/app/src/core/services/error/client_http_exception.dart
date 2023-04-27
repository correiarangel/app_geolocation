abstract class IClientHttpException implements Exception {
  final String message;
  final StackTrace stackTrace;

  IClientHttpException({
    required this.message,
    required this.stackTrace,
  });
}

class ClientHttpException extends IClientHttpException {
  ClientHttpException({required super.message, required super.stackTrace});
}
