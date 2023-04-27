abstract class IGeoException implements Exception {
  final String message;
  final StackTrace stackTrace;

  IGeoException({
    required this.message,
    required this.stackTrace,
  });
}

class GeoException extends IGeoException {
  GeoException({required super.message, required super.stackTrace});
}
