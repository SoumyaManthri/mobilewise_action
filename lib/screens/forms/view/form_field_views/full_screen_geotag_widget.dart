import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../shared/model/framework_form.dart';
import '../../../../shared/model/geotag_arguments.dart';
import '../../../../utils/app_state.dart';
import '../../../../utils/common_constants.dart' as constants;
import '../../../../utils/hex_color.dart';

class FullScreenGeotagWidget extends StatefulWidget {
  const FullScreenGeotagWidget(
      {Key? key,
      required this.latitude,
      required this.longitude,
      required this.field})
      : super(key: key);

  final double latitude;
  final double longitude;
  final FrameworkFormField field;

  @override
  State<FullScreenGeotagWidget> createState() => _FullScreenGeotagWidgetState();
}

class _FullScreenGeotagWidgetState extends State<FullScreenGeotagWidget> {
  MapController mapController = MapController();
  late double lat;
  late double lng;
  List<Marker> mapMarkers = [];

  @override
  void initState() {
    super.initState();
    lat = widget.latitude;
    lng = widget.longitude;
  }

  @override
  Widget build(BuildContext context) {
    Marker droppedMarker = Marker(
      point: LatLng(lat, lng),
      child: const Icon(
        Icons.location_on_rounded,
        color: Colors.red,
        size: constants.markerIconDimension,
      ),
    );
    if (mapMarkers.isEmpty) {
      mapMarkers.add(droppedMarker);
    }
    return Scaffold(
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            FlutterMap(
              options: MapOptions(
                  center: LatLng(lat, lng),
                  zoom: 13,
                  maxZoom: 19,
                  interactiveFlags:
                      InteractiveFlag.pinchZoom | InteractiveFlag.drag,
                  onLongPress: (tapPosition, latLng) {
                    /// Drop new map marker
                    setState(() {
                      lat = latLng.latitude;
                      lng = latLng.longitude;
                      droppedMarker = Marker(
                        point: LatLng(lat, lng),
                        child: const Icon(
                          Icons.location_on_rounded,
                          color: Colors.red,
                          size: constants.markerIconDimension,
                        ),
                      );
                      mapMarkers.clear();
                      mapMarkers.add(droppedMarker);
                    });
                  }),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: ['a', 'b', 'c'],
                ),
                MarkerLayer(
                  markers: mapMarkers,
                ),
              ],
              mapController: mapController,
            ),
            Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    alignment: Alignment.topLeft,
                    child: InkWell(
                      onTap: () {
                        /// onBackPressed
                        Navigator.pop(context);
                      },
                      child: const Padding(
                        padding: EdgeInsets.fromLTRB(
                          constants.mediumPadding,
                          constants.largePadding * 1.5,
                          0.0,
                          0.0,
                        ),
                        child: Icon(
                          Icons.close,
                          size: constants.markerIconDimension,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                      0.0, 0.0, 0.0, constants.mediumPadding),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: constants.formButtonBarHeight,
                    child: Padding(
                      padding: const EdgeInsets.all(constants.mediumPadding),
                      child: SizedBox(
                        height: constants.buttonHeight,
                        child: ElevatedButton(
                          onPressed: () {
                            /// onBackPressed
                            AppState.instance.addToFormTempMap(
                                widget.field.key, '$lat,$lng');
                            Navigator.pop(context, GeotagArguments(lat, lng));
                          },
                          style: constants.buttonStyle(
                              backgroundColor: HexColor(
                                  AppState.instance.themeModel.primaryColor)),
                          child: Text(
                            constants.confirmLocation,
                            style: constants.buttonTextStyle,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
