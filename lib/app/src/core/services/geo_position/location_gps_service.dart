import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:location/location.dart';
import '../error/geo_exception.dart';

import 'location_interface.dart';

class LocationGpsService implements ILocation {
  final Location location;

  LocationGpsService(this.location);

  @override
  Future<bool> isLocationGpsEnabled() async {
    return await location.serviceEnabled();
  }

  @override
  Future<LocationData> getLocation() async {
    try {
      await changeSetting();
      final isGpsEnabled = await isLocationGpsEnabled();
      if (!isGpsEnabled) enableGps();
      return await location.getLocation().timeout(const Duration(seconds: 5));
    } on Exception catch (e, s) {
      throw GeoException(message: e.toString(), stackTrace: s);
    }
  }

  @override
  Future<dynamic> enableGps() async {
    PermissionStatus? permissionStatus;

    try {
      bool isServiceEnabled = await isLocationGpsEnabled();

      if (!isServiceEnabled) {
        isServiceEnabled = await location.requestService();
        if (!isServiceEnabled) {
          return;
        }
      }
      permissionStatus = await location.hasPermission();
      if (permissionStatus == PermissionStatus.denied) {
        permissionStatus = await location.requestPermission();
        if (permissionStatus != PermissionStatus.denied) {
          return;
        }
      }
    } on PlatformException catch (err, s) {
      log('ERROR: ${err.message} - ', stackTrace: s);
      throw PlatformException(
          message: err.message, stacktrace: s.toString(), code: err.code);
    } on Exception catch (err, s) {
      log('ERROR: $err - ', error: err, stackTrace: s);
      throw GeoException(message: err.toString(), stackTrace: s);
    }
  }

  @override
  Future<String> activeBackGraundPosition(bool enable) async {
    try {
      bool isEnable = await location.enableBackgroundMode(enable: enable);
      log(" SEGUNDO PLANO /////-///// $isEnable");
      return '$isEnable';
    } on Exception catch (err, s) {
      return _testException(err, s);
    }
  }

  @override
  Future<bool> isActiveBackGraund() async =>
      await location.isBackgroundModeEnabled();

  @override
  Future<Status> permissionStatus() async {
    final permissionStatus = await location.hasPermission();
    switch (permissionStatus) {
      case PermissionStatus.denied:
        return Status.denied;
      case PermissionStatus.granted:
        return Status.granted;
      case PermissionStatus.grantedLimited:
        return Status.grantedLimited;
      case PermissionStatus.deniedForever:
        return Status.deniedForever;
    }
  }

  @override
  Future<void> changeSetting() async {
    await location.changeSettings(
      accuracy: LocationAccuracy.low,
      distanceFilter: 10,
      interval: 1000,
    );
  }

  String _testException(Exception err, StackTrace stackTrace) {
   
    log('ERROR AO ATIVAR SEGUNDO PLANO  -- ',
        error: err, stackTrace: stackTrace);

    final error = err.toString();
    if (error.contains(deniedResponse)) return deniedResponse;

    throw GeoException(message: err.toString(), stackTrace: stackTrace);
  }
}
const String deniedResponse = 'PERMISSION_DENIED';
enum Status {
  /// A permissão para usar serviços de localização foi concedida para alta precisão.
  granted,

  /// A permissão foi concedida, mas para baixa precisão. Válido apenas para iOS 14+.
  grantedLimited,

  /// A permissão para usar os serviços de localização foi negada pelo usuário. Poderia
  /// foram negados para sempre no iOS.
  denied,

  /// A permissão para usar os serviços de localização foi negada para sempre pelo
  /// do utilizador. Nenhuma caixa de diálogo será exibida na solicitação de permissão.
  deniedForever
}
