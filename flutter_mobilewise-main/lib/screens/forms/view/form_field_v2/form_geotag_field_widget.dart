import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../screens/forms/view/form_field_views/full_screen_geotag_widget.dart';
import '../../../../screens/forms/view_model/form_view_model.dart';
import '../../../../shared/model/framework_form.dart';
import '../../../../shared/model/geotag_arguments.dart';
import '../../../../utils/app_state.dart';
import '../../../../utils/common_constants.dart' as constants;
import '../../../../utils/common_constants.dart';
import '../../../../utils/hex_color.dart';
import '../../../../utils/util.dart';

class FormGeotagFieldWidget extends StatefulWidget {
  const FormGeotagFieldWidget({
    Key? key,
    required this.field,
    required this.viewModel,
  }) : super(key: key);

  final FrameworkFormField field;
  final FormViewModel viewModel;

  @override
  State<FormGeotagFieldWidget> createState() => _FormGeotagFieldWidgetState();
}

class _FormGeotagFieldWidgetState extends State<FormGeotagFieldWidget> {
  MapController mapController = MapController();
  double lat = -1;
  double lng = -1;
  List<Marker> mapMarkers = [];
  LatLng mapCenter = const LatLng(0, 0);

  @override
  Widget build(BuildContext context) {
    if (widget.field.isEditable &&
        AppState.instance.formTempMap.containsKey(widget.field.key)) {
      /// Dropped location exists in the formTempMap (user has dropped it already)
      String value = AppState.instance.formTempMap[widget.field.key];
      List<String> latLng = value.split(',');
      lat = double.parse(latLng[0]);
      lng = double.parse(latLng[1]);
    } else if (widget.viewModel.clickedSubmissionValuesMap
        .containsKey(widget.field.key)) {
      /// Dropped location exists in the formDataListSubmissionMap
      String value =
          widget.viewModel.clickedSubmissionValuesMap[widget.field.key];
      List<String> latLng = value.split(',');
      lat = double.parse(latLng[0]);
      lng = double.parse(latLng[1]);
    } else if (AppState.instance.currentUserLocation!.latitude != null &&
        AppState.instance.currentUserLocation!.longitude != null) {
      /// Pick current user location and add to tempMap
      lat = AppState.instance.currentUserLocation!.latitude!.toDouble();
      lng = AppState.instance.currentUserLocation!.longitude!.toDouble();
      AppState.instance.formTempMap[widget.field.key] = '$lat,$lng';
    }
    if (lat != -1 && lng != -1 && mapMarkers.isEmpty) {
      mapMarkers.add(Marker(
        point: LatLng(lat, lng),
        child: const Icon(
          Icons.location_on_rounded,
          color: Colors.red,
          size: constants.markerIconDimension,
        ),
      ));
      mapCenter = LatLng(lat, lng);
    }
    return _view();
  }

  _view() {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          0.00,
          Util.instance.getTopMargin(widget.field.style),
          0.00,
          constants.mediumPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: widget.field.label,
              style: widget.field.style != null
                  ? constants.applyStyleV2(
                      bold: widget.field.style!.bold,
                      underline: widget.field.style!.underline,
                      italics: widget.field.style!.italics,
                      color: widget.field.style!.color,
                      size: widget.field.style!.size)
                  : constants.applyStyleV2(),
              children: <TextSpan>[
                // Red * to show if the field is mandatory
                TextSpan(
                  text: widget.field.isMandatory && widget.field.isEditable
                      ? ' *'
                      : '',
                  style: constants.normalRedTextStyle,
                ),
              ],
            ),
          ),
          const SizedBox(
            height: constants.smallPadding,
          ),
          lat != -1 && lng != -1
              ? Container(
                  decoration: borderOutlined(),
                  width: MediaQuery.of(context).size.width,
                  height: constants.cameraPlaceholderImageHeight,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(
                      Radius.circular(5.0),
                    ),
                    child: FlutterMap(
                      options: MapOptions(
                        initialCenter: mapCenter,
                        initialZoom: 13,
                        maxZoom: 19,
                        // interactionOptions: InteractionOptions.none,
                        onTap: (tapPosition, latLng) async {
                          if (widget.field.isEditable) {
                            /// Open the full screen geotagging widget
                            GeotagArguments ga = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => FullScreenGeotagWidget(
                                        latitude: lat,
                                        longitude: lng,
                                        field: widget.field,
                                      )),
                            );
                            lat = ga.latitude;
                            lng = ga.longitude;
                            mapMarkers.clear();
                            mapMarkers.add(Marker(
                              point: LatLng(lat, lng),
                              child: const Icon(
                                Icons.location_on_rounded,
                                color: Colors.red,
                                size: constants.markerIconDimension,
                              ),
                            ));
                            mapCenter = LatLng(lat, lng);
                            setState(() {});
                          }
                        },
                      ),
                      mapController: mapController,
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                          subdomains: const ['a', 'b', 'c'],
                        ),
                        MarkerLayer(
                          markers: mapMarkers,
                        ),
                      ],
                    ),
                  ))
              : const SizedBox(),
        ],
      ),
    );
  }

  Decoration borderOutlined() {
    return BoxDecoration(
      color: Colors.black,
      shape: BoxShape.rectangle,
      borderRadius: const BorderRadius.all(Radius.circular(5)),
      border: Border.all(),
    );
  }
}
