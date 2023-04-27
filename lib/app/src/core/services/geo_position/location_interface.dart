import 'package:location/location.dart';

import 'location_gps_service.dart';

abstract class ILocation {
  Future<String> activeBackGraundPosition(bool action);
  Future<bool> isLocationGpsEnabled();
  Future<dynamic> enableGps();
  Future<LocationData> getLocation();
  Future<bool> isActiveBackGraund();
  Future<void> changeSetting();
  Future<Status> permissionStatus();
}
