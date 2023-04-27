import 'dart:developer';

import 'package:geolocator/geolocator.dart';

import '../services/error/geo_exception.dart';
import '../services/geo_position/dto/geo_position_params.dart';
import '../services/geo_position/location_interface.dart';
import '../services/geo_position/position_inteface.dart';
import 'interface/geo_repository_interface.dart';

const String errorPositionNull = 'ERROR:GeoRepository Position NULL';

class GeoRepository extends IGeoRepository {
  final IPosition geoService;
  final ILocation location;
  GeoRepository({
    required this.location,
    required this.geoService,
  });

  @override
  Future<bool> testDistancePosition({
    required String lattudeEnd,
    required String longetudeEnd,
    required String? distanceCustom,
  }) async {
    bool doCheckout = true;

    try {
      final Position position = await getPositionCalls();
      // ignore: unnecessary_null_comparison
      if (position != null) {
        String latEnd = testLatitudeEnd(
          latEnd: lattudeEnd,
          latitudeCurrenty: position.latitude,
        );
        String lngEnd = testLogetudeEnd(
          lngEnd: longetudeEnd,
          longetudeCurrenty: position.longitude,
        );
        //Verifica se a distancia entre 2 localização é > ConstDistance.parameter
        doCheckout = await geoService.isDistanceGreaterThanParameter(
            params: GeoPositionParams(
          startLat: position.latitude,
          startLong: position.longitude,
          endLat: double.parse(latEnd),
          endLong: double.parse(lngEnd),
          distanceCustom: distanceCustom ?? '',
        ));
        //action
        return doCheckout;
      } else {
        return true;
      }
    } on GeoException catch (e, s) {
      log('GeoLocationDirectCalls', error: e.toString(), stackTrace: s);
      throw GeoException(
        message: e.toString(),
        stackTrace: s,
      );
    }
  }

  @override
  Future<Position> getPositionCalls() async {
    Position? position;
    try {
      position = await geoService.currentPosition();
      position ??= await _testResultPosition(position);
      return position;
    } on Exception catch (e, s) {
      log(errorPositionNull, error: e.toString(), stackTrace: s);
      return await _retornException();
    }
  }

  Future<Position> _retornException() async {
    Position? position;

    try {
      position ??= await _filllLocation();
      if (position == null) {
        throw GeoException(
            message: errorPositionNull, stackTrace: StackTrace.current);
      }
      return position;
    } on Exception catch (e, s) {
      throw GeoException(message: e.toString(), stackTrace: s);
    }
  }

  Future<Position> _testResultPosition(Position? position) async {
    try {
      position ??= await _filllLocation();
      if (position == null) {
        throw GeoException(
            message: errorPositionNull, stackTrace: StackTrace.current);
      }
      return position;
    } on Exception catch (e, s) {
      throw GeoException(message: e.toString(), stackTrace: s);
    }
  }

  @override
  String testLatitudeEnd({
    required String latEnd,
    required double latitudeCurrenty,
  }) {
    if (latEnd.isEmpty ||
        latEnd == 'null' ||
        latEnd == '0.0' ||
        latEnd == '0') {
      return '$latitudeCurrenty';
    }
    return latEnd;
  }

  @override
  String testLogetudeEnd({
    required String lngEnd,
    required double longetudeCurrenty,
  }) {
    if (lngEnd.isEmpty ||
        lngEnd == 'null' ||
        lngEnd == '0.0' ||
        lngEnd == '0') {
      return '$longetudeCurrenty';
    }
    return lngEnd;
  }

  @override
  Future<bool> isGpsEnable() async {
    return await geoService.isGpsEnable();
  }

  @override
  Future<bool> itIs100MetersFromLimit({
    required double latitudeEnd,
    required double longetudEnd,
    required String distanceCustom,
  }) async {
    try {
      Position? position = await getPositionCalls();
      String latEnd = testLatitudeEnd(
        latEnd: latitudeEnd.toString(),
        latitudeCurrenty: position.latitude,
      );
      String lngEnd = testLogetudeEnd(
        lngEnd: longetudEnd.toString(),
        longetudeCurrenty: position.longitude,
      );
      final result = await geoService.isDistanceGreaterThanParameter(
          params: GeoPositionParams(
        startLat: position.latitude,
        startLong: position.longitude,
        endLat: double.parse(latEnd),
        endLong: double.parse(lngEnd),
        distanceCustom: distanceCustom.toString(),
      ));
      return result;
    } on GeoException catch (err) {
      throw GeoException(
        message: err.message,
        stackTrace: StackTrace.current,
      );
    }
  }

  @override
  Future<bool> itIs100MetersFromLimitFiveParams({
    required double latitudeEnd,
    required double longetudeEnd,
    required double latitudeCurrenty,
    required double longetudeCurrenty,
    required String? distanceCustom,
  }) async {
    try {
      String latEnd = testLatitudeEnd(
        latEnd: '$latitudeEnd',
        latitudeCurrenty: latitudeCurrenty,
      );
      String lngEnd = testLogetudeEnd(
        lngEnd: '$longetudeEnd',
        longetudeCurrenty: longetudeCurrenty,
      );
      final result = await geoService.isDistanceGreaterThanParameter(
          params: GeoPositionParams(
        startLat: latitudeCurrenty,
        startLong: longetudeCurrenty,
        endLat: double.parse(latEnd),
        endLong: double.parse(lngEnd),
        distanceCustom: distanceCustom,
      ));
      return result;
    } on GeoException catch (err) {
      log('??? ERROR - ${err.message} stackTrace: ${StackTrace.current}');
      throw GeoException(message: err.message, stackTrace: StackTrace.current);
    }
  }

  @override
  Future<Map<String, dynamic>> getLoacation() async {
    Map<String, dynamic> mapPosition = {};
    try {
      final locationData = await location.getLocation();
      mapPosition = {
        'latitude': locationData.latitude,
        'longetude': locationData.longitude
      };
    } on Exception catch (error, s) {
      throw GeoException(
          message: 'Lime 205/ Georepositor: $error', stackTrace: s);
    }
    return mapPosition;
  }

  Future<Position?> _filllLocation() async {
    try {
      final loacalDataMap = await getLoacation();
      if (loacalDataMap.isEmpty) return null;
      log('GET POSITION IN LOCATION @@@@@@@@@@@');
      return mapToPosition(loacalDataMap);
    } on Exception catch (err, s) {
      log('ERROR :_filllLocation', error: err.toString(), stackTrace: s);
      throw GeoException(message: err.toString(), stackTrace: s);
    }
  }

  Position mapToPosition(Map<String, dynamic> positionMap) {
    return Position(
      longitude: positionMap['longitude'] ?? 0,
      latitude: positionMap['latitude'] ?? 0,
      timestamp: DateTime.now(),
      accuracy: 0,
      altitude: 0,
      heading: 0,
      speed: 0,
      speedAccuracy: 0,
    );
  }
}
