import 'dart:async';
import 'package:flutter/services.dart';
import 'package:location/location.dart';

class GpgUtils {
  GpsUtilListener listener;
  Map<String, double> _startLocation;
  Map<String, double> _currentLocation;

  StreamSubscription<Map<String, double>> _locationSubscription;

  Location _location = new Location();
  bool _permission = false;
  String error;

  bool currentWidget = true;

  GpgUtils(this.listener);

  void init() {
    initPlatformState();

    _locationSubscription =
        _location.onLocationChanged().listen((Map<String,double> result) {

          _currentLocation = result;
          listener.onLocationChange(_currentLocation);
        });

  }


  // Platform messages are asynchronous, so we initialize in an async method.
  initPlatformState() async {
    Map<String, double> location;
    // Platform messages may fail, so we use a try/catch PlatformException.

    try {
      _permission = await _location.hasPermission();
      location = await _location.getLocation();


      error = null;
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        error = 'Permission denied';
      } else if (e.code == 'PERMISSION_DENIED_NEVER_ASK') {
        error = 'Permission denied - please ask the user to enable it from the app settings';
      }

      location = null;
    }

    _startLocation = location;
    listener.onLocationChange(_startLocation);
  }

}

abstract class GpsUtilListener {
  onLocationChange(Map<String, double> location);
}
