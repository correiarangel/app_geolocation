import 'dart:async';
import 'package:geolocator/geolocator.dart';

import 'dto/geo_position_params.dart';

abstract class IPosition {
  Future<Position?> currentPosition();
  Future<dynamic> chackPermisionService();
  Future<Position?> recoveryLastPosition();
  Future<bool> isDistanceGreaterThanParameter(
      {required GeoPositionParams params});
  Future<bool> isGpsEnable();
  Future<LocationPermission> checkPermision();
}
