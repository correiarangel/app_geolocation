import 'dart:async';
import 'dart:developer';

import 'package:geolocator/geolocator.dart';

import '../error/geo_exception.dart';

import 'dto/geo_position_params.dart';
import 'position_inteface.dart';

class GeoPositionServices extends IPosition {
  bool _doCheckout = true;
  bool get doCheckout => _doCheckout;
  double _distanceInMeters = 0;
  double get distanceInMeters => _distanceInMeters;
  Position? _position;
  Position? get position => _position;

  @override
  Future<Position?> currentPosition() async {
    Position? position;
    try {
      await chackPermisionService();

      position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
      return position;
    } on Exception catch (e, s) {
      log('GeoException-|-|-currentPosition', error: e.toString());
      throw GeoException(
        message: e.toString(),
        stackTrace: s,
      );
    }
  }

  @override
  Future<dynamic> chackPermisionService() async {
    try {
      await isGpsEnable();
      await checkPermision();
    } on GeoException catch (err) {
      log(err.toString());
      throw GeoException(
        message: err.message,
        stackTrace: err.stackTrace,
      );
    } on Exception catch (err) {
      log(err.toString());
      throw GeoException(
        message: 'Ops! GPS não possui permissão',
        stackTrace: StackTrace.current,
      );
    }
  }

  ///Verifica se a distancia em Metros
//entre 2 localizações é > que ConstDistance.parameter
  @override
  Future<bool> isDistanceGreaterThanParameter(
      {required GeoPositionParams params}) async {
    try {
      _distanceInMeters = Geolocator.distanceBetween(
        params.startLat,
        params.startLong,
        params.endLat,
        params.endLong,
      );

      //await distanceBetween(startLat, startLong, endLat, endLong);
      _doCheckout = calcDistance(
        distanceInMeters: _distanceInMeters,
        distanceCusTom: _testDistaceCustom(params.distanceCustom),
      );

      log('1 @@@@ @@@@  Distance is : $_doCheckout METROS : $distanceInMeters');
      return _doCheckout;
      // ignore: avoid_catches_without_on_clauses
    } on Exception catch (err) {
      //_doCheckout = true;
      log('Distance is ERROR : true ERRO; $err');
      throw GeoException(
        message: err.toString(),
        stackTrace: StackTrace.current,
      );
    }
  }

  bool calcDistance({
    required double distanceInMeters,
    required double distanceCusTom,
  }) {
    if (distanceInMeters >= distanceCusTom) return true;
    return false;
  }

  // se  distanceCustom = null vindo de homme se = 0 vindo de ponto
  double _testDistaceCustom(String? distanceCustom) {
    if (distanceCustom == null ||
        distanceCustom == "0" ||
        distanceCustom == "null") {
      return 100;
    }
    return double.parse(distanceCustom);
  }

  Future<double> distanceMeter({
    required double startLat,
    required double startLong,
    required double endLat,
    required double endLong,
  }) async {
    try {
      return Geolocator.distanceBetween(startLat, startLong, endLat, endLong);
    } on Exception catch (err, s) {
      log(
        'ERROR distanceBetween $err ',
        stackTrace: s,
      );
      throw GeoException(
        message: err.toString(),
        stackTrace: s,
      );
    }
  }

  @override
  Future<Position?> recoveryLastPosition() async {
    Position? position;
    try {
      position = await Geolocator.getLastKnownPosition(
        forceAndroidLocationManager: true,
      );
    } on Exception catch (e) {
      throw GeoException(
        message: e.toString(),
        stackTrace: StackTrace.current,
      );
    }

    return position;
  }

  @override
  Future<bool> isGpsEnable() async {
    bool isGps = await Geolocator.isLocationServiceEnabled();
    return isGps;
  }

  @override
  Future<LocationPermission> checkPermision() async {
    const msg = 'As permissões de localização são negadas'
        ' permanentemente, não podemos solicitar permissões.';
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.deniedForever) {
      throw GeoException(message: msg, stackTrace: StackTrace.current);
    }
    return await _requestPermission(permission);
  }

  Future<LocationPermission> _requestPermission(
      LocationPermission permission) async {
    const msg = 'ERROR: As permissões de localização foram negadas (ERRO).';
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        log(msg);
        throw GeoException(
          message: msg,
          stackTrace: StackTrace.current,
        );
      }
    }
    return permission;
  }
}
