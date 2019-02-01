import 'package:flutter/material.dart';
import 'package:flutter_google_map_route/utils/gps_util.dart';
import 'package:flutter_google_map_route/map_screen.dart';
import 'package:flutter_google_map_route/model/route.dart';
import 'package:flutter_google_map_route/network/networ_util.dart';
import 'package:map_view/map_view.dart';
import 'package:map_view/polyline.dart';

class MapUtil implements GpsUtilListener {
  var staticMapProvider;
  CameraPosition cameraPosition;
  var location = new Location(0.0, 0.0);
  var zoomLevel = 18.0;
  MapView mapView;
  NetworkUtil network = new NetworkUtil();
  GpgUtils gpgUtils;
  ScreenListener _screenListener;
  List<Location> ccc;

  MapUtil(this._screenListener);

  init() {
    mapView = new MapView();
    gpgUtils = new GpgUtils(this);
    gpgUtils.init();
    staticMapProvider = new StaticMapProvider("google_map_key");
  }

  getDirectionSteps(double destinationLat, double destinationLng) {
    network
        .get("origin=" +
            location.latitude.toString() +
            "," +
            location.longitude.toString() +
            "&destination=" +
            destinationLat.toString() +
            "," +
            destinationLng.toString() +
            "&key=google_map_key")
        .then((dynamic res) {
      List<Steps> rr = res;
      print(res.toString());

      ccc = new List();
      for (final i in rr) {
        ccc.add(i.startLocation);
        ccc.add(i.endLocation);
      }

      mapView.onMapReady.listen((_) {
        mapView.setMarkers(getMarker(location.latitude,location.longitude,destinationLat,destinationLng));
        mapView.addPolyline(new Polyline("12", ccc, width: 15.0));
      });
      _screenListener.dismissLoader();
      showMap();
    }).catchError((Exception error) => _screenListener.dismissLoader());
  }

  List<Marker> getMarker(double scrLat,double scrLng,double desLat,double desLng) {
    List<Marker> markers = <Marker>[
      new Marker("1", "My Location", scrLat, scrLng, color: Colors.amber),
      new Marker("2", "Destination", desLat, desLng,
          color: Colors.red),
    ];

    return markers;
  }

  Uri getStaticMap() {
    return staticMapProvider.getStaticUri(getMyLocation(), zoomLevel.toInt(),
        height: 400, width: 900);
  }

  Location getMyLocation() {
    return location;
  }

  CameraPosition getCamera() {
    cameraPosition = new CameraPosition(getMyLocation(), zoomLevel);
    return cameraPosition;
  }

  showMap() {
    mapView.show(
        new MapOptions(
            mapViewType: MapViewType.normal,
            initialCameraPosition: getCamera(),
            showUserLocation: true,
            title: "Draw route"),
        toolbarActions: [new ToolbarAction("Close", 1)]);
    mapView.onToolbarAction.listen((id) {
      if (id == 1) {
        mapView.dismiss();
      }
    });
  }

  updateLocation(Location location) {
    this.location = location;
  }

  updateZoomLevel(double zoomLevel) {
    this.zoomLevel = zoomLevel;
  }

  @override
  onLocationChange(Map<String, double> currentLocation) {
    location =
        new Location(currentLocation["latitude"], currentLocation["longitude"]);
    _screenListener.updateScreen(location);
  }

  cameraUpdate(CameraPosition cameraPosition) {
    print("campera position changed $location");
  }

  void manageMapProperties() {
    mapView.zoomToFit(padding: 100);

    mapView.onLocationUpdated.listen((location) => updateLocation(location));

    mapView.onTouchAnnotation.listen((marker) => print("marker tapped"));

    mapView.onMapTapped.listen((location) => updateLocation(location));

    mapView.onCameraChanged
        .listen((cameraPosition) => cameraUpdate(cameraPosition));
  }
}
