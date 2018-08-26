library flutter_google_places_autocomplete.src;

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_webservice/places.dart';

class GooglePlacesAutocompleteWidget extends StatefulWidget {

  final String apiKey;
  final String hint;
  final Location location;
  final num offset;
  final num radius;
  final String language;
  final List<String> types;
  final List<Component> components;
  final bool strictbounds;
  final ValueChanged<PlacesAutocompleteResponse> onError;

  GooglePlacesAutocompleteWidget(
      {@required this.apiKey,
      this.hint = "Search",
      this.offset,
      this.location,
      this.radius,
      this.language,
      this.types,
      this.components,
      this.strictbounds,
      this.onError,
      Key key})
      : super(key: key);

  @override
  State<GooglePlacesAutocompleteWidget> createState() {
    return new _GooglePlacesAutocompleteOverlayState();
  }

  static GooglePlacesAutocompleteState of(BuildContext context) => context
      .ancestorStateOfType(const TypeMatcher<GooglePlacesAutocompleteState>());
}

class _GooglePlacesAutocompleteOverlayState
    extends GooglePlacesAutocompleteState {
  @override
  Widget build(BuildContext context) {
    final header = new Column(children: <Widget>[
      new Material(

          child: new Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new IconButton(
                color: Colors.black45,
                icon: new Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              new Expanded(
                  child: new Padding(
                child: _textField(),
                padding: const EdgeInsets.only(right: 8.0),
              )),
            ],
          )),
      new Divider(
          //height: 1.0,
          )
    ]);

    var body;

    if (query.text.isEmpty ||
        response == null ||
        response.predictions.isEmpty) {
      body = new Material(
        color: Colors.white,
        borderRadius: new BorderRadius.only(
            bottomLeft: new Radius.circular(2.0),
            bottomRight: new Radius.circular(2.0)),
      );
    } else {
      body = new SingleChildScrollView(
          child: new Material(
              borderRadius: new BorderRadius.only(
                  bottomLeft: new Radius.circular(2.0),
                  bottomRight: new Radius.circular(2.0)),
              color: Colors.white,
              child: new ListBody(
                  children: response.predictions
                      .map((p) => new PredictionTile(
                          prediction: p, onTap: Navigator.of(context).pop))
                      .toList())));
    }

    final container = new Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 30.0),
        child: new Stack(children: <Widget>[
          header,
          new Padding(padding: new EdgeInsets.only(top: 48.0), child: body),
        ]));

    if (Platform.isIOS) {
      return new Padding(
          padding: new EdgeInsets.only(top: 8.0), child: container);
    }
    return container;
  }

  Widget _textField() => new TextField(
        controller: query,
        autofocus: true,
        decoration: new InputDecoration(
            hintText: widget.hint,
            hintStyle: new TextStyle(color: Colors.black54, fontSize: 16.0),
            border: null),
        onChanged: search,
      );
}

class GooglePlacesAutocompleteResult extends StatefulWidget {
  final ValueChanged<Prediction> onTap;

  GooglePlacesAutocompleteResult({this.onTap});

  @override
  _GooglePlacesAutocompleteResult createState() =>
      new _GooglePlacesAutocompleteResult();
}

class _GooglePlacesAutocompleteResult
    extends State<GooglePlacesAutocompleteResult> {
  @override
  Widget build(BuildContext context) {
    final state = GooglePlacesAutocompleteWidget.of(context);
    assert(state != null);

    if (state.query.text.isEmpty ||
        state.response == null ||
        state.response.predictions.isEmpty) {
      final children = <Widget>[];

      return new Stack(children: children);
    }
    return new PredictionsListView(
        predictions: state.response.predictions, onTap: widget.onTap);
  }
}

class PredictionsListView extends StatelessWidget {
  final List<Prediction> predictions;
  final ValueChanged<Prediction> onTap;

  PredictionsListView({@required this.predictions, this.onTap});

  @override
  Widget build(BuildContext context) {
    return new ListView(
        children: predictions
            .map((Prediction p) =>
                new PredictionTile(prediction: p, onTap: onTap))
            .toList());
  }
}

class PredictionTile extends StatelessWidget {
  final Prediction prediction;
  final ValueChanged<Prediction> onTap;

  PredictionTile({@required this.prediction, this.onTap});

  @override
  Widget build(BuildContext context) {
    return new ListTile(
      leading: new Icon(Icons.location_on),
      title: new Text(prediction.description),
      onTap: () {
        if (onTap != null) {
          onTap(prediction);
        }
      },
    );
  }
}

Future<Prediction> showGooglePlacesAutocomplete(
    {@required BuildContext context,
    @required String apiKey,
    String hint = "Search",
    num offset,
    Location location,
    num radius,
    String language,
    List<String> types,
    List<Component> components,
    bool strictbounds,
    ValueChanged<PlacesAutocompleteResponse> onError}) {
  final builder = (BuildContext ctx) => new GooglePlacesAutocompleteWidget(
        apiKey: apiKey,
        language: language,
        components: components,
        types: types,
        location: location,
        radius: radius,
        strictbounds: strictbounds,
        offset: offset,
        hint: hint,
        onError: onError,
      );

  return showDialog(context: context, builder: builder);
}

abstract class GooglePlacesAutocompleteState
    extends State<GooglePlacesAutocompleteWidget> {
  TextEditingController query;
  PlacesAutocompleteResponse response;
  GoogleMapsPlaces _places;
  bool searching;

  @override
  void initState() {
    super.initState();
    query = new TextEditingController(text: "");
    _places = new GoogleMapsPlaces(widget.apiKey);
    searching = false;
  }

  Future<Null> doSearch(String value) async {
    if (mounted && value.isNotEmpty) {
      setState(() {
        searching = true;
      });

      final res = await _places.autocomplete(value,
          offset: widget.offset,
          location: widget.location,
          radius: widget.radius,
          language: widget.language,
          types: widget.types,
          components: widget.components,
          strictbounds: widget.strictbounds);

      if (res.errorMessage?.isNotEmpty == true ||
          res.status == "REQUEST_DENIED") {
        onResponseError(res);
      } else {
        onResponse(res);
      }
    } else {
      onResponse(null);
    }
  }

  Timer _timer;

  Future<Null> search(String value) async {
    _timer?.cancel();
    _timer = new Timer(const Duration(milliseconds: 300), () {
      _timer.cancel();
      doSearch(value);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _places.dispose();
    super.dispose();
  }

  @mustCallSuper
  void onResponseError(PlacesAutocompleteResponse res) {
    if (mounted) {
      if (widget.onError != null) {
        widget.onError(res);
      }
      setState(() {
        response = null;
        searching = false;
      });
    }
  }

  @mustCallSuper
  void onResponse(PlacesAutocompleteResponse res) {
    if (mounted) {
      setState(() {
        response = res;
        searching = false;
      });
    }
  }
}
