import 'package:geolocator/geolocator.dart';

abstract class IGeoRepository {
  Future<bool> testDistancePosition({
    required String lattudeEnd,
    required String longetudeEnd,
    required String? distanceCustom,
  });

  Future<Position> getPositionCalls();
  String testLatitudeEnd({
    required String latEnd,
    required double latitudeCurrenty,
  });

  String testLogetudeEnd({
    required String lngEnd,
    required double longetudeCurrenty,
  });

  Future<bool> isGpsEnable();

  Future<bool> itIs100MetersFromLimit({
    required double latitudeEnd,
    required double longetudEnd,
    required String distanceCustom,
  });

  Future<bool> itIs100MetersFromLimitFiveParams({
    required double latitudeEnd,
    required double longetudeEnd,
    required double latitudeCurrenty,
    required double longetudeCurrenty,
    required String? distanceCustom,
  });

  Future<Map<String, dynamic>> getLoacation();
}
