import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:keyboard_avoider/keyboard_avoider.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tezapp/helpers/constant.dart';
import 'package:tezapp/helpers/styles.dart';
import 'package:tezapp/helpers/theme.dart';

import 'package:tezapp/helpers/utils.dart';
import 'package:tezapp/provider/credit_provider.dart';
import 'package:tezapp/ui_elements/custom_search_button.dart';

class LocationPickerPage extends StatefulWidget {
  const LocationPickerPage({Key? key}) : super(key: key);

  @override
  State<LocationPickerPage> createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage> {
  bool isGetAddress = false;
  double markerLatPosition = 21.131780;
  double markerLngPosition = 79.119420;
  Completer<GoogleMapController> googleController = Completer();

  TextEditingController addressController = new TextEditingController();
  late GoogleMapController mapController;

  CameraPosition kGooglePlex = CameraPosition(
    target: LatLng(21.131780, 79.119420),
    zoom: 17.5,
  );

  String addressLocation = '';

  List<AutocompletePrediction> predictions = [];
  GooglePlace? googlePlace;

  double lat = 0.0, lng = 0.0;

  late Mixpanel mixpanel;

  @override
  void initState() {
    super.initState();

    getCurrentLocation();
    // init google place
    googlePlace = GooglePlace(googleKeyApi);

    initMixpanel();
  }

  Future<void> initMixpanel() async {
    mixpanel = await Mixpanel.init(MIX_PANEL, optOutTrackingDefault: false, trackAutomaticEvents: true);
  }

  void autoCompleteSearch(String value) async {
    var result = await googlePlace?.autocomplete.get(value);
    if (result != null && result.predictions != null && mounted) {
      setState(() {
        predictions = result.predictions!;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: white,
        body: getBody(),
        bottomNavigationBar: getFooter(),
      ),
    );
  }

  Widget getBody() {
    var size = MediaQuery.of(context).size;
    return Stack(
      children: [
        Container(
          height: size.height,
        ),
        Container(
          height: size.height,
          child: Stack(
            children: [
              Container(
                height: size.height,
                child: GoogleMap(
                  zoomControlsEnabled: false,
                  mapType: MapType.normal,
                  myLocationButtonEnabled: false,
                  initialCameraPosition: kGooglePlex,
                  onCameraMoveStarted: () {
                    setState(() {
                      isGetAddress = false;
                    });
                  },
                  onCameraMove: (cameraPosition) {
                    LatLng latlng = cameraPosition.target;
                    setState(() {
                      markerLatPosition = latlng.latitude;
                      markerLngPosition = latlng.longitude;
                    });
                    FocusScope.of(context).unfocus();
                  },
                  onMapCreated: (GoogleMapController controller) {
                    if (!googleController.isCompleted)
                      googleController.complete(controller);
                    mapController = controller;
                  },
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Container(
                  height: 120.0,
                  width: 120.0,
                  alignment: Alignment.center,
                  child: Container(
                    padding: EdgeInsets.only(bottom: 20),
                    child: Icon(Entypo.location_pin, size: 50, color: primary),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget getFooter() {
    var size = MediaQuery.of(context).size;
    return Container(
        width: MediaQuery.of(context).size.width,
        height: 500,
        decoration: BoxDecoration(color: white, boxShadow: [
          BoxShadow(
              color: black.withOpacity(0.06), spreadRadius: 5, blurRadius: 10)
        ]),
        padding: EdgeInsets.only(top: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Container(
                width: size.width - 30,
                height: 40,
                decoration: BoxDecoration(
                    border: Border.all(color: placeHolderColor),
                    borderRadius: BorderRadius.circular(10)),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      child: Center(
                          child: Icon(
                        Icons.search,
                        size: 20,
                        color: greyLight,
                      )),
                    ),
                    Flexible(
                        child: TextField(
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          autoCompleteSearch(value);
                        } else {
                          if (predictions.length > 0 && mounted) {
                            setState(() {
                              predictions = [];
                            });
                          }
                        }
                      },
                      cursorColor: black,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          hintText: "search_for_an_address".tr()),
                    )),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            // list of location
            Container(
              width: size.width,
              height: 320,
              decoration: BoxDecoration(
                  // color: primary
                  ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    InkWell(
                      onTap: () {
                        getCurrentLocation();
                        Navigator.pop(context, {"lat": lat, "lng": lng});
                      },
                      child: Container(
                        height: 60,
                        width: size.width,
                        decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(color: placeHolderColor))),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20, right: 20),
                          child: Row(
                            children: [
                              Icon(MaterialIcons.my_location,
                                  size: 25, color: primary),
                              SizedBox(
                                width: 10,
                              ),
                              Flexible(
                                  child: Text(
                                "use_my_current_location",
                                style: meduimGreyText,
                              ).tr())
                            ],
                          ),
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(predictions.length, (index) {
                        return InkWell(
                          onTap: () async {
                            var result = await this
                                .googlePlace
                                ?.details
                                .get(predictions[index].placeId.toString());
                            var latitude =
                                result?.result?.geometry?.location?.lat;
                            var longtitude =
                                result?.result?.geometry?.location?.lng;
                            setState(() {
                              lat = latitude!;
                              lng = longtitude!;
                            });

                            Navigator.pop(context, {"lat": lat, "lng": lng});
                          },
                          child: Container(
                            height: 60,
                            width: size.width,
                            decoration: BoxDecoration(
                                border: Border(
                                    bottom:
                                        BorderSide(color: placeHolderColor))),
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 20, right: 20),
                              child: Row(
                                children: [
                                  Icon(Entypo.location_pin,
                                      size: 25, color: black),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Flexible(
                                      child: Text(
                                    predictions[index].description.toString(),
                                    style: meduimGreyText,
                                  ))
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: white,
                        boxShadow: [
                          BoxShadow(
                              color: black.withOpacity(0.06),
                              spreadRadius: 5,
                              blurRadius: 10)
                        ]),
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context, {"lat": lat, "lng": lng});
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(left: 5),
                        child: Icon(
                          Icons.arrow_back_ios,
                          color: black,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  Flexible(
                      child: InkWell(
                    onTap: () {
                      Navigator.pop(context, {"lat": lat, "lng": lng});
                    },
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: primary,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 15, right: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              "confirm_&_continue",
                              style: normalWhiteText,
                            ).tr(),
                            SizedBox(
                              width: 5,
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: white,
                              size: 18,
                            )
                          ],
                        ),
                      ),
                    ),
                  ))
                ],
              ),
            )
          ],
        ));
  }

  Future<void> moveMapPin(lat, lng) async {
    final CameraPosition address =
        CameraPosition(target: LatLng(lat, lng), zoom: 19.151926040649414);
    final GoogleMapController controller = await googleController.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(address));
  }

  getCurrentLocation() async {
    // get current lat and lng
    var currentLocation = await determineUserLocationPosition(context);

    if (mounted) {
      setState(() {
        lat = currentLocation.latitude;
        lng = currentLocation.longitude;
      });
    }

    // mix panel
    dynamic dataPanel = {
      "phone": userSession['phone_number'],
      "location": {"lat": lat, "lng": lng}
    };

    mixpanel.track(CLICK_PERMISSION_LOCATION, properties: dataPanel);

    moveMapPin(lat, lng);
  }
}
