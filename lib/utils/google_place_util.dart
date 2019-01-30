import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_map_route/flutter_google_places_autocomplete.dart';
import 'package:google_maps_webservice/places.dart';

class GooglePlaces {
  final homeScaffoldKey = new GlobalKey<ScaffoldState>();
  final searchScaffoldKey = new GlobalKey<ScaffoldState>();
  GoogleMapsPlaces _places =
      new GoogleMapsPlaces("AIzaSyCyMTdg3zrs6lKPhz9hE3XDmkJQ1m6QpYc");
  Location location;
  GooglePlacesListener _mapScreenState;

  GooglePlaces(this._mapScreenState);

  Future findPlace(BuildContext context) async {
    Prediction p = await showGooglePlacesAutocomplete(
      context: context,
      location: location,
      apiKey: "AIzaSyCyMTdg3zrs6lKPhz9hE3XDmkJQ1m6QpYc",
      onError: (res) {
        homeScaffoldKey.currentState
            .showSnackBar(new SnackBar(content: new Text(res.errorMessage)));
      },
    );

    displayPrediction(p, homeScaffoldKey.currentState);
  }

  Future<Null> displayPrediction(Prediction p, ScaffoldState scaffold) async {
    if (p != null) {
      // get detail (lat/lng)
      PlacesDetailsResponse detail =
          await _places.getDetailsByPlaceId(p.placeId);
      final lat = detail.result.geometry.location.lat;
      final lng = detail.result.geometry.location.lng;
      _mapScreenState.selectedLocation(
          lat, lng, detail.result.formattedAddress);
    }
  }

  void updateLocation(double lat, double long) {
    location = new Location(lat, long);
  }
}

abstract class GooglePlacesListener {
  selectedLocation(double lat, double long, String address);
}
