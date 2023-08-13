// ignore_for_file: unnecessary_null_comparison

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:galli_map/galli_map.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  var zoomLevel;
  List<GalliMarker> markers = [];
  final GalliController controller = GalliController(
    authKey: 'f3a094e9-2917-4317-9e81-c5bf2e6286da',
    zoom: 16,
    maxZoom: 22,
    // initialPosition: LatLng(27.672905, 85.312215),
  );
  final GalliMethods galliMethods =
      GalliMethods('f3a094e9-2917-4317-9e81-c5bf2e6286da');
  final ViewerClass viewer = ViewerClass(
    viewer: Viewer(
      accessToken: 'f3a094e9-2917-4317-9e81-c5bf2e6286da',
      pinIcon: const Icon(
        Icons.circle,
        size: 48,
      ),
      animSpeed: 2,
      height: 300,
      width: 300,
    ),
    viewerPosition: const Offset(32, 32),
  );
  SearchClass? searchClass;
  @override
  void initState() {
    // log("zoom level: ${controller.map.zoom}");
    // zoomLevel = controller.map.zoom;
    searchClass = SearchClass(
      onTapAutoComplete: (autoCompleteData) async {
        markers.clear();
        setState(() {});
        var locationName = autoCompleteData.name.toString();
        var locationDistance = autoCompleteData.distance.toString();
        Position currentLocation = await galliMethods.getCurrentLocation();
        FeatureModel? searchData = await galliMethods.search(locationName,
            LatLng(currentLocation.latitude, currentLocation.longitude));
        log("${searchData!.toJson()}");

        if (searchData != null) {
          LatLng pinLocation;
          if (searchData.geometry!.type == FeatureType.point) {
            pinLocation = searchData.geometry!.coordinates![0];
          } else {
            pinLocation = searchData.geometry!.listOfCoordinates![0][0];
          }
          log(" location : ${pinLocation}");
          markers.add(GalliMarker(
              latlng: pinLocation,
              markerWidget: GestureDetector(
                onTap: () {
                  markers.clear();
                  searchClass!.updateSearchField("");

                  setState(() {});
                },
                child: const Icon(
                  Icons.flag,
                  color: Colors.red,
                  size: 32,
                ),
              )));
          setState(() {});
          galliMethods.animateMapMove(
              pinLocation, 16, this, mounted, controller.map);
        }
        log("$locationName,$locationDistance KM");
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: GalliMap(
          three60marker: Three60Marker(three60MarkerColor: Colors.purple),
          loadingWidget: const LinearProgressIndicator(),
          show360Button: false,
          controller: controller,
          search: searchClass,
          markers: markers,
          onTap: (LatLng latLng) async {
            ReverseGeocodingModel data = await galliMethods.reverse(latLng);
            log("${data.toJson()}");
            markers.clear();
            setState(() {});
            markers.add(GalliMarker(
                latlng: latLng,
                markerWidget: GestureDetector(
                  onTap: () {
                    markers.clear();
                    searchClass!.updateSearchField("");
                    setState(() {});
                  },
                  child: const Icon(
                    Icons.flag,
                    color: Colors.red,
                    size: 32,
                  ),
                )));
            var locationSelected = await galliMethods.reverse(latLng);
            searchClass!.updateSearchField(locationSelected!.address!);
            log("Zoom level :   ::: ${controller.map.zoom}");
            setState(() {});
          },
          children: [
            Positioned(
                bottom: 10,
                child: GestureDetector(
                  onTap: () async {
                    ReverseGeocodingModel data = await galliMethods
                        .reverse(LatLng(27.6704163, 85.3239504));
                    log("${data.toJson()}");
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      height: 40,
                      width: 40,
                      color: Colors.red,
                    ),
                  ),
                )),
            if (markers.isNotEmpty)
              Positioned(
                  bottom: 90,
                  right: 16,
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50)),
                    child: SizedBox(
                      height: 50,
                      width: 50,
                      child: Icon(
                        Icons.share,
                        color: Colors.orange,
                      ),
                    ),
                  ))
          ],
        ),
      ),
    );
  }
}
