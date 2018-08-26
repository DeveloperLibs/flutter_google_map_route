import 'package:flutter/material.dart';
import 'package:flutter_google_map_route/progress_hud.dart';
import 'package:flutter_google_map_route/utils/google_place_util.dart';
import 'package:flutter_google_map_route/utils/map_util.dart';
import 'package:map_view/map_view.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => new _MapScreenState();
}

class _MapScreenState extends State<MapScreen>
    implements ScreenListener, GooglePlacesListener {
  MapUtil mapUtil;
  String locationAddress = "Search destination";
  String myLocation = "";
  GooglePlaces googlePlaces;
  bool _isLoading = false;
  double _destinationLat;
  double _destinationLng;

  @override
  void initState() {
    super.initState();
    mapUtil = new MapUtil(this);
    mapUtil.init();
    googlePlaces = new GooglePlaces(this);
  }

  @override
  Widget build(BuildContext context) {
    var screenWidget = new Column(
      children: <Widget>[
        new GestureDetector(
          onTap: () {
            googlePlaces.findPlace(context);
          },
          child: new Container(
            alignment: FractionalOffset.center,
            margin: EdgeInsets.all(10.0),
            padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
            decoration: new BoxDecoration(
              color: const Color.fromRGBO(255, 255, 255, 1.0),
              border: Border.all(color: const Color(0x33A6A6A6)),
              borderRadius: new BorderRadius.all(const Radius.circular(6.0)),
            ),
            child: new Row(
              children: <Widget>[
                new Icon(Icons.search),
                new Flexible(
                  child: new Container(
                    padding: new EdgeInsets.only(right: 13.0),
                    child: new Text(
                      locationAddress,
                      overflow: TextOverflow.ellipsis,
                      style: new TextStyle(color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        new Container(
          height: 230.0,
          child: new Stack(
            children: <Widget>[
              new Center(
                child: Container(
                  child: new Text(
                    "Google Map Box",
                    textAlign: TextAlign.center,
                  ),
                  padding: const EdgeInsets.all(20.0),
                ),
              ),
              new GestureDetector(
                onTap: () => mapUtil.showMap(),
                child: new Center(
                  child: new Image.network(mapUtil.getStaticMap().toString()),
                ),
              ),
            ],
          ),
        ),
        new Container(
          margin: new EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
          padding: new EdgeInsets.only(top: 10.0),
          child: new Text(
            myLocation,
            style: new TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        new GestureDetector(
          onTap: () => getMapRoute(),
          child: new Container(
            margin: EdgeInsets.fromLTRB(30.0, 30.0, 30.0, 0.0),
            padding: EdgeInsets.all(15.0),
            alignment: FractionalOffset.center,
            decoration: new BoxDecoration(
              color: const Color(0xFFFFD900),
              borderRadius: new BorderRadius.all(const Radius.circular(6.0)),
            ),
            child: Text(
              "Draw Route",
              style: new TextStyle(
                  color: const Color(0xFF28324E),
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );

    return new Scaffold(
      backgroundColor: const Color(0xFFA6AFAA),
      appBar: AppBar(
        title: new Text(
          "Google maps route",
          textAlign: TextAlign.center,
          style: new TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: ProgressHUD(
        child: new SingleChildScrollView(
          child: screenWidget,
        ),
        inAsyncCall: _isLoading,
        opacity: 0.0,
      ),
    );
  }

  Widget getTextField(
      String inputBoxName, TextEditingController inputBoxController) {
    var loginBtn = new Padding(
      padding: const EdgeInsets.all(5.0),
      child: new TextFormField(
        controller: inputBoxController,
        decoration: new InputDecoration(
          hintText: inputBoxName,
        ),
      ),
    );

    return loginBtn;
  }

  Widget getButton(String buttonLabel, EdgeInsets margin) {
    var staticMapBtn = new Container(
      margin: margin,
      padding: EdgeInsets.all(8.0),
      alignment: FractionalOffset.center,
      decoration: new BoxDecoration(
        color: const Color(0xFF167F67),
        border: Border.all(color: const Color(0xFF28324E)),
        borderRadius: new BorderRadius.all(const Radius.circular(6.0)),
      ),
      child: new Text(
        buttonLabel,
        style: new TextStyle(
          color: const Color(0xFFFFFFFF),
          fontSize: 20.0,
          fontWeight: FontWeight.w300,
          letterSpacing: 0.3,
        ),
      ),
    );
    return staticMapBtn;
  }

  updateStaticMap() {
    setState(() {});
  }

  @override
  updateScreen(Location location) {
    myLocation = "You are at: " +
        location.latitude.toString() +
        ", " +
        location.longitude.toString();
    googlePlaces.updateLocation(location.latitude, location.longitude);
    setState(() {});
  }

  @override
  selectedLocation(double lat, double lng, String address) {
    setState(() {
      _destinationLat = lat;
      _destinationLng = lng;
      locationAddress = address;
    });
  }

  getMapRoute() {
    setState(() {
      _isLoading = true;
    });
    mapUtil.getDirectionSteps(_destinationLat, _destinationLng);
  }

  @override
  dismissLoader() {
    setState(() {
      _isLoading = false;
    });
  }
}

abstract class ScreenListener {
  updateScreen(Location location);
  dismissLoader();
}
