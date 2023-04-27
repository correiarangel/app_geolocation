class GeoPositionParams {
  final double startLat;
  final double startLong;
  final double endLat;
  final double endLong;
  final String? distanceCustom;
  GeoPositionParams({
    required this.startLat,
    required this.startLong,
    required this.endLat,
    required this.endLong,
    required this.distanceCustom,
  });
}
