import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:location/location.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

import '../../repositories/geo_repository.dart';
import '../../services/geo_position/geo_position_service.dart';
import '../../services/geo_position/location_gps_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final repository = GeoRepository(
    location: LocationGpsService(
      Location.instance,
    ),
    geoService: GeoPositionServices(),
  );

  double latitude = 0;
  double longetude = 0;
  String statusGps = 'Desconhecido';
  String? statusPemission;
  bool statusPemissionProgress = false;
  bool positionProgress = false;
  bool statusGpsProgress = false;
  bool enableGpsProgress = false;
  ScreenshotController screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget linearProgress = const Padding(
      padding: EdgeInsets.all(16),
      child: LinearProgressIndicator(color: Colors.white),
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Screenshot(
              controller: screenshotController,
              child: Card(
                shadowColor: Colors.grey.shade800,
                borderOnForeground: true,
                elevation: 0.9,
                color: Colors.purple,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 16.0),
                      statusPemissionProgress
                          ? linearProgress
                          : Visibility(
                              visible: statusPemission == null ? false : true,
                              child: Text(
                                'Permissão atual: $statusPemission',
                                style: const TextStyle(
                                  fontSize: 24.0,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                      const SizedBox(height: 16.0),
                      statusGpsProgress
                          ? linearProgress
                          : Visibility(
                              visible:
                                  statusGps == 'Desconhecido' ? false : true,
                              child: Text(
                                'Status GPS: $statusGps',
                                style: const TextStyle(
                                  fontSize: 24.0,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                      const SizedBox(height: 16.0),
                      positionProgress
                          ? linearProgress
                          : Visibility(
                              visible: latitude + longetude == 0 ? false : true,
                              child: Column(
                                children: [
                                  const Text(
                                    'Localização atual ',
                                    style: TextStyle(
                                      fontSize: 24.0,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  Text(
                                    'Latitude: $latitude \n Longetude: $longetude ',
                                    style: const TextStyle(
                                      fontSize: 16.0,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 16.0),
                                ],
                              ),
                            ),
                      ElevatedButton.icon(
                        onPressed: () async {
                          await share(screenshotController);
                        },
                        label: const Text('Compartilhar informações'),
                        icon: const Icon(Icons.share),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton.icon(
              onPressed: () async {
                setState(() => statusGpsProgress = true);
                final isEnable =
                    await repository.location.isLocationGpsEnabled();
                if (isEnable) setState(() => statusGps = 'ESTA ATIVO ');
                if (!isEnable) setState(() => statusGps = 'DESATIVADO');
                setState(() => statusGpsProgress = false);
              },
              label: const Text('Status atual do GPS'),
              icon: const Icon(Icons.gpp_maybe),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                setState(() => statusPemissionProgress = true);
                final permission = await repository.location.permissionStatus();
                final status = convertStatus(permission);
                setState(() {
                  statusPemission = status;
                  statusPemissionProgress = false;
                });
              },
              label: const Text('Checar Permiçãoes'),
              icon: const Icon(Icons.launch),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                await _getPosition();
              },
              label: const Text('Localização Atual'),
              icon: const Icon(Icons.pin_drop),
            ),
            enableGpsProgress
                ? const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: LinearProgressIndicator(),
                  )
                : ElevatedButton.icon(
                    onPressed: () async {
                      setState(() => enableGpsProgress = true);
                      final result =
                          await repository.geoService.chackPermisionService();
                      log('$result');
                      setState(() => enableGpsProgress = false);
                    },
                    label: const Text('Ativar GPS'),
                    icon: const Icon(Icons.gps_fixed_sharp),
                  ),
            ElevatedButton.icon(
              onPressed: () async {
                if (latitude == 0 || longetude == 0) await _getPosition();
                if (context.mounted) {
                  await _openMapsSheet(
                    title: 'Localização atual',
                    ctx: context,
                    latitude: latitude,
                    longetude: longetude,
                  );
                }
              },
              label: const Text('Visulizar localização atual no Maps'),
              icon: const Icon(Icons.map),
            ),
          ],
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Future<void> _getPosition() async {
    setState(() => positionProgress = true);
    final position = await repository.getPositionCalls();
    setState(() {
      latitude = position.latitude;
      longetude = position.longitude;
      positionProgress = false;
    });
  }

  Future<void> share(ScreenshotController screenshot) async {
    if (!kIsWeb) {
      await screenshot
          .capture(delay: const Duration(milliseconds: 10))
          .then((image) async {
        if (image != null) {
          final directory = await getApplicationDocumentsDirectory();
          final imagePath = await File('${directory.path}/image.png').create();
          await imagePath.writeAsBytes(image);

          await Share.shareFiles([imagePath.path]);
        }
      });
    }
  }
  Coords convert({
  required double latitude,
  required double longetude,
}) {
  log('convert /// LAT $latitude /// LOG: $longetude');
  return Coords(latitude, longetude);
}

Future<dynamic> _openMapsSheet({
  required String title,
  required ctx,
  required double latitude,
  required double longetude,
}) async {
  try {
    final coords = convert(latitude: latitude, longetude: longetude);
    final availableMaps = await MapLauncher.installedMaps;

    showModalBottomSheet(
      context: ctx,
      builder: (BuildContext context) {
        return SafeArea(
          child: SingleChildScrollView(
            child: Wrap(
              children: <Widget>[
                for (var map in availableMaps)
                  ListTile(
                    onTap: () => map.showMarker(
                      coords: coords,
                      title: title,
                    ),
                    title: Text('Nome do Mapa: ${map.mapName}'),
                    leading: SvgPicture.asset(
                      map.icon,
                      height: 30.0,
                      width: 30.0,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  } catch (e) {
    log(e.toString());
  }
}

String convertStatus(Status status) {
  switch (status) {
    case Status.denied:
      return 'Negada';
    case Status.deniedForever:
      return 'Negada para sempre';
    case Status.granted:
      return 'Consedida';
    case Status.grantedLimited:
      return 'Consedida com limitação';
  }
}

}