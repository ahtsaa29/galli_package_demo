import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:galli_map/galli_map.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  List<GalliMarker> markers = [];
  final GalliController controller = GalliController(
    authKey: "89a40903-b75a-46b6-822b-86eebad4fa36",
    zoom: 16,
    maxZoom: 22,
    initialPosition: LatLng(27.672905, 85.312215),
  );
  final GalliMethods galliMethods =
      GalliMethods("89a40903-b75a-46b6-822b-86eebad4fa36");
  final ViewerClass viewer = ViewerClass(
    viewer: Viewer(
      accessToken: "89a40903-b75a-46b6-822b-86eebad4fa36",
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
              pinLocation, controller.map.zoom, this, mounted, controller.map);
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
          show360Button: false,
          controller: controller,
          search: searchClass,
          markers: markers,
          onTap: (LatLng latLng) async {
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
            log(latLng.toString());
            var locationSelected = await galliMethods.reverse(latLng);
            log("${locationSelected!.address}");
            searchClass!.updateSearchField(locationSelected.address!);
            setState(() {});
          },
          children: [
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
