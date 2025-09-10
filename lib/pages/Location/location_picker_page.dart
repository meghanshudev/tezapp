import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:keyboard_avoider/keyboard_avoider.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tezchal/helpers/constant.dart';
import 'package:tezchal/helpers/styles.dart';
import 'package:tezchal/helpers/theme.dart';
import 'package:tezchal/helpers/utils.dart';
import 'package:tezchal/provider/credit_provider.dart';
import 'package:tezchal/ui_elements/custom_search_button.dart';

class LocationPickerPage extends StatefulWidget {
  const LocationPickerPage({Key? key}) : super(key: key);

  @override
  State<LocationPickerPage> createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage> {
  bool isGetAddress = false;
  bool isLoading = false;
  double markerLatPosition = 21.131780;
  double markerLngPosition = 79.119420;
  final Completer<GoogleMapController> googleController = Completer();

  final TextEditingController addressController = TextEditingController();
  late GoogleMapController mapController;

  CameraPosition kGooglePlex = const CameraPosition(
    target: LatLng(21.131780, 79.119420),
    zoom: 17.5,
  );

  String addressLocation = '';
  String errorMessage = '';

  List predictions = [];
  // GoogleMapsPlaces? googlePlace;

  double lat = 0.0, lng = 0.0;

  late Mixpanel mixpanel;

  @override
  void initState() {
    super.initState();
    
    try {
      // googlePlace = GoogleMapsPlaces(apiKey: googleKeyApi);
      getCurrentLocation();
      initMixpanel();
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to initialize location services';
      });
    }
  }

  Future<void> initMixpanel() async {
    mixpanel = await Mixpanel.init(MIX_PANEL, optOutTrackingDefault: false, trackAutomaticEvents: true);
  }

  Future<void> autoCompleteSearch(String value) async {
    if (value.isEmpty) {
      setState(() {
        // predictions = [];
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      // var result = await googlePlace?.autocomplete.get(value);
      // if (result != null && result.predictions != null && mounted) {
      //   setState(() {
      //     predictions = result.predictions!;
      //     isLoading = false;
      //   });
      // }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = 'Failed to fetch location suggestions';
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    addressController.dispose();
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
    return KeyboardAvoider(
      child: Stack(
        children: [
          if (errorMessage.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              color: Colors.red[100],
              child: Text(
                errorMessage,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
          SizedBox(
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
                if (!googleController.isCompleted) {
                  googleController.complete(controller);
                }
                mapController = controller;
              },
            ),
          ),
          const Align(
            alignment: Alignment.center,
            child: Padding(
              padding: EdgeInsets.only(bottom: 20),
              child: Icon(Entypo.location_pin, size: 50, color: primary),
            ),
          ),
          if (isLoading)
            const Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.only(top: 100),
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
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
        padding: const EdgeInsets.only(top: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: GooglePlaceAutoCompleteTextField(googleAPIKey: googleKeyApi, textEditingController: addressController,)),
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
                    SizedBox(
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
                      controller: addressController,
                      onChanged: (value) {
                        // if (value.isNotEmpty) {
                        //   autoCompleteSearch(value);
                        // } else {
                        //   if (predictions.isNotEmpty && mounted) {
                        //     setState(() {
                        //       predictions = [];
                        //     });
                        //   }
                        // }
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
            const SizedBox(height: 10),
            Container(
              width: size.width,
              height: 320,
              decoration: const BoxDecoration(),
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
                              const SizedBox(width: 10),
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
                            // try {
                            //   setState(() => isLoading = true);
                            //   var result = await googlePlace?.details
                            //       .get(predictions[index].placeId ?? '');
                            //   var latitude = result?.result?.geometry?.location?.lat;
                            //   var longitude = result?.result?.geometry?.location?.lng;
                              
                            //   if (latitude != null && longitude != null) {
                            //     setState(() {
                            //       lat = latitude;
                            //       lng = longitude;
                            //     });
                            //     Navigator.pop(context, {"lat": lat, "lng": lng});
                            //   } else {
                            //     setState(() {
                            //       errorMessage = 'Failed to get location details';
                            //     });
                            //   }
                            // } catch (e) {
                            //   setState(() {
                            //     errorMessage = 'Failed to process location';
                            //   });
                            // } finally {
                            //   if (mounted) {
                            //     setState(() => isLoading = false);
                            //   }
                            // }
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
                                  Icon(Entypo.location_pin,
                                      size: 25, color: black),
                                  const SizedBox(width: 10),
                                  Flexible(
                                      child: Text(
                                    predictions[index].description ?? '',
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
            const SizedBox(height: 20),
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
                      onTap: () => Navigator.pop(context),
                      child: const Padding(
                        padding: EdgeInsets.only(left: 5),
                        child: Icon(
                          Icons.arrow_back_ios,
                          color: black,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
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
                            const SizedBox(width: 5),
                            const Icon(
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

  Future<void> moveMapPin(double lat, double lng) async {
    final CameraPosition address =
        CameraPosition(target: LatLng(lat, lng), zoom: 19.151926040649414);
    final GoogleMapController controller = await googleController.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(address));
  }

  Future<void> getCurrentLocation() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final currentLocation = await determineUserLocationPosition(context);

      if (mounted) {
        setState(() {
          lat = currentLocation.latitude;
          lng = currentLocation.longitude;
          isLoading = false;
        });

        final dataPanel = {
          "phone": userSession['phone_number'],
          "location": {"lat": lat, "lng": lng}
        };

        await mixpanel.track(CLICK_PERMISSION_LOCATION, properties: dataPanel);
        await moveMapPin(lat, lng);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = 'Failed to get current location';
          isLoading = false;
        });
      }
    }
  }
}