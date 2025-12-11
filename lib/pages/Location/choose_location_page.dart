import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:geocode/geocode.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tezchal/helpers/constant.dart';
import 'package:tezchal/helpers/styles.dart';
import 'package:tezchal/helpers/theme.dart';
import 'package:tezchal/helpers/utils.dart';
import 'package:http/http.dart' as http;
import 'package:tezchal/helpers/network.dart';
import 'package:tezchal/pages/Location/location_picker_page.dart';
import 'package:tezchal/provider/credit_provider.dart';
import 'package:tezchal/ui_elements/custom_appbar.dart';

class ChoooseLocationPage extends StatefulWidget {
  const ChoooseLocationPage({Key? key}) : super(key: key);

  @override
  State<ChoooseLocationPage> createState() => _ChoooseLocationPageState();
}

class _ChoooseLocationPageState extends State<ChoooseLocationPage> {
  bool isGetAddress = false;
  double markerLatPosition = 21.131780;
  double markerLngPosition = 79.119420;
  Completer<GoogleMapController> googleController = Completer();

  late GoogleMapController mapController;

  CameraPosition kGooglePlex = CameraPosition(
    target: LatLng(21.131780, 79.119420),
    zoom: 17.5,
  );

  String addressLocation = '';
  String zipCode = '';

  double lat = 0.0;
  double lng = 0.0;

  late Mixpanel mixpanel;

  @override
  void initState() {
    super.initState();

    getCurrentLocation();

    initMixpanel();
    log("Location: initState");
  }

  Future<void> initMixpanel() async {
    mixpanel = await Mixpanel.init(
      MIX_PANEL,
      optOutTrackingDefault: false,
      trackAutomaticEvents: true,
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    log("Location: build");
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        // resizeToAvoidBottomInset: true,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: CustomAppBar(
            subtitle: "Location",
            subtitleIcon: Entypo.location_pin,
          ),
        ),
        backgroundColor: white,
        body: getBody(),
        bottomNavigationBar: getFooter(),
        floatingActionButton: getFloatingButton(),
      ),
    );
  }

  Widget getFloatingButton() {
    return InkWell(
      onTap: () {
        getCurrentLocation();
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: black.withOpacity(0.06),
              spreadRadius: 5,
              blurRadius: 10,
            ),
          ],
        ),
        child: Center(
          child: Icon(MaterialIcons.my_location, color: black, size: 15),
        ),
      ),
    );
  }


  Widget getBody() {
    var size = MediaQuery.of(context).size;
    return Stack(
      children: [
        Container(height: size.height),
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
                  onCameraIdle: () {
                    LatLng latlng = LatLng(
                      markerLatPosition,
                      markerLngPosition,
                    );
                    var result = {
                      "lat": latlng.latitude,
                      "lng": latlng.longitude,
                    };

                    getNewLocation(result);
                  },
                  onCameraMove: (cameraPosition) {
                    LatLng latlng = cameraPosition.target;
                    setState(() {
                      markerLatPosition = latlng.latitude;
                      markerLngPosition = latlng.longitude;
                      lat = latlng.latitude;
                      lng = latlng.longitude;
                    });

                    FocusScope.of(context).unfocus();
                  },
                  onMapCreated: (GoogleMapController controller) {
                    if (!googleController.isCompleted)
                      googleController.complete(controller);
                    mapController = controller;
                    //getUserCurrentLocation(controller);
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
      height: 280,
      decoration: BoxDecoration(
        color: white,
        boxShadow: [
          BoxShadow(
            color: black.withOpacity(0.06),
            spreadRadius: 5,
            blurRadius: 10,
          ),
        ],
      ),
      padding: EdgeInsets.only(left: 20, right: 20, top: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: size.width - 30,
            height: 40,
            decoration: BoxDecoration(
              border: Border.all(color: placeHolderColor),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  child: Center(
                    child: Icon(Icons.search, size: 20, color: greyLight),
                  ),
                ),
                Flexible(
                  child: TextField(
                    readOnly: true,
                    onTap: () async {
                      log("Location: search for an address");
                      dynamic result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LocationPickerPage(),
                        ),
                      );
                      if (result != null) {
                        var lat = result['lat'];
                        var lng = result['lng'];
                        setState(() {
                          this.lat = lat;
                          this.lng = lng;
                        });
                        await moveMapPin(lat, lng);
                        await getNewLocation(result);
                      }
                    },
                    cursorColor: black,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      hintText: "search_for_an_address".tr(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          Text("is_this_your_location", style: normalBlackText).tr(),
          SizedBox(height: 20),
          Container(
            height: 60,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: white,
              boxShadow: [
                BoxShadow(
                  color: black.withOpacity(0.06),
                  spreadRadius: 5,
                  blurRadius: 10,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Row(
                children: [
                  Container(
                    width: 30,
                    child: Icon(Entypo.location_pin, size: 28, color: primary),
                  ),
                  SizedBox(width: 5),
                  Flexible(
                    child: Text(addressLocation, style: smallMediumGreyText),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 20),
          Row(
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
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: Icon(Icons.arrow_back_ios, color: black, size: 18),
                  ),
                ),
              ),
              SizedBox(width: 15),
              Flexible(
                child: InkWell(
                  onTap: () {
                    log("Location: confirm and continue");
                    _confirmLocation();
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
                          SizedBox(width: 5),
                          Icon(Icons.arrow_forward_ios, color: white, size: 18),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  // getNewLocation(result){
  //   double lat = result['lat'];
  //    double lng = result['lng'];
  //      // get gecoding
  //   GeoCode geoCode = GeoCode(apiKey: googleKeyApi);
  //   try {
  //     var result = geoCode.reverseGeocoding(
  //         latitude: lat,
  //         longitude: lng);

  //     result.then((value) async {

  //       if (mounted) {
  //         var location =
  //             value.streetAddress.toString() + " " + value.city.toString() + ", "+value.countryName.toString();
  //         setState(() {
  //           addressLocation = location;
  //         });

  //       }
  //     });
  //   } catch (e) {
  //     print(e);
  //   }
  // }
  getNewLocation(result) async {
    //  double lat = 40.714224;
    //  double lng = -73.961452;
    double lat = result['lat'];
    double lng = result['lng'];
    log("Location: getNewLocation: $lat, $lng");

    var apiURL =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$googleKeyApi";

    var url = Uri.parse(apiURL);

    final response = await http.get(url);
    if (response.statusCode == 200) {
      var result = jsonDecode(response.body);
      if (result['results'] != null && result['results'].isNotEmpty) {
        List items = result['results'][0]['address_components'] ?? [];

        var postalCode = '';
        if (items.length > 0) {
        items.forEach((result) {
          if (result['types'][0] == "postal_code") {
            postalCode = result['long_name'];
          }
        });
      }

        var location = result['results'][0]['formatted_address'];
        if (checkIsNullValue(postalCode)) {
          postalCode = DEFAULT_ZIP_CODE;
        }

        setState(() {
          addressLocation = location;
          zipCode = postalCode;
        });
      } else {
        log("ChooseLocationPage: No results found for the given coordinates.");
        setState(() {
          addressLocation = "No address found";
          zipCode = "";
        });
      }
    } else {
      log("ChooseLocationPage: Failed to fetch address from Google API.");
      setState(() {
        addressLocation = "";
        zipCode = "";
      });
    }
  }

  _confirmLocation() async {
    log("ChooseLocationPage: Confirming location and fetching fresh address...");

    // 1. Fetch fresh address from Google API, similar to root_app.dart
    var apiURL =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$googleKeyApi";
    var url = Uri.parse(apiURL);
    final response = await http.get(url);

    if (response.statusCode != 200) {
      log("ChooseLocationPage: Failed to fetch address from Google API.");
      return;
    }

    var result = jsonDecode(response.body);
    if (result['results'] == null || result['results'].isEmpty) {
      log("ChooseLocationPage: No address results found for the given coordinates.");
      return;
    }

    // 2. Parse address and zip code
    List items = result['results'][0]['address_components'] ?? [];
    var postalCode = '';
    if (items.isNotEmpty) {
      items.forEach((item) {
        if (item['types'][0] == "postal_code") {
          postalCode = item['long_name'];
        }
      });
    }

    var finalLocation = result['results'][0]['formatted_address'];
    var finalZipCode =
        checkIsNullValue(postalCode) ? DEFAULT_ZIP_CODE : postalCode;

    // 3. Call the update API
    log("ChooseLocationPage: Updating address with location: $finalLocation, zip: $finalZipCode");
    var updateResponse = await netPost(
      isUserToken: true,
      endPoint: "me/update/address",
      params: {
        "lat": lat,
        "lng": lng,
        "address": finalLocation,
        "zip_code": finalZipCode,
      },
    );

    if (mounted) {
      if (updateResponse['resp_code'] == "200") {
        log("ChooseLocationPage: Address updated successfully.");
        var data = updateResponse['resp_data']['data'];
        userSession['address'] = data['address'] ?? "";
        userSession['zip_code'] = data['zip_code'] ?? "";
        Navigator.pop(context, {'status': 'updated'});
      } else {
        log("ChooseLocationPage: Failed to update address: ${updateResponse['resp_data']}");
        var errorMessage = "something_went_wrong".tr();
        if (updateResponse['resp_data'] != null &&
            updateResponse['resp_data']['message'] != null) {
          errorMessage = updateResponse['resp_data']['message'];
        }
        final snackBar = SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }
  }

  Future<void> moveMapPin(lat, lng) async {
    final CameraPosition address = CameraPosition(
      target: LatLng(lat, lng),
      zoom: 19.151926040649414,
    );
    final GoogleMapController controller = await googleController.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(address));
  }

  getCurrentLocation() async {
    log("Location: getCurrentLocation");
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
      "location": {"lat": lat, "lng": lng},
    };

    mixpanel.track(CLICK_PERMISSION_LOCATION, properties: dataPanel);

    var result = {"lat": lat, "lng": lng};
    moveMapPin(lat, lng);
    getNewLocation(result);
  }
}
