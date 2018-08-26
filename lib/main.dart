import 'package:flutter/material.dart';
import 'package:flutter_google_map_route/map_screen.dart';
import 'package:map_view/map_view.dart';

void main() {
  MapView.setApiKey("AIzaSyDrHKl8IxB4cGXIoELXQOzzZwiH1xtsRf4");
  runApp(new MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: new ThemeData(
      primaryColor: const Color(0xFF02BB9F),
      primaryColorDark: const Color(0xFF167F67),
      accentColor: const Color(0xFF167F67),
    ),
    home: new MapScreen(),
  ));
}
