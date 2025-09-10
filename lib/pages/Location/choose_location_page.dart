import 'dart:async';
import 'dart:convert';

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
import 'package:tezchal/pages/Location/location_picker_page.dart';
import 'package:tezchal/provider/credit_provider.dart';
import 'package:tezchal/ui_elements/custom_search_button.dart';

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

  double lat = 0.0;
  double lng = 0.0;

  late Mixpanel mixpanel;

  @override
  void initState() {
    super.initState();

    getCurrentLocation();

    initMixpanel();
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
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        // resizeToAvoidBottomInset: true,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(120),
          child: getAppBar(),
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

  Widget getAppBar() {
    return AppBar(
      backgroundColor: primary,
      titleSpacing: 0,
      automaticallyImplyLeading: false,
      elevation: 0,
      flexibleSpace: Container(
        child: SafeArea(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                height: 80,
                decoration: BoxDecoration(color: primary),
                child: Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset("assets/images/logo-bg.png"),
                      SizedBox(width: 40),
                      Flexible(child: getSearchButton(context, () {}, () {})),
                      // Container(
                      //   width: 145,
                      //   height: 35,
                      //   padding: EdgeInsets.symmetric(horizontal: 5),
                      //   decoration: BoxDecoration(
                      //       color: white,
                      //       borderRadius: BorderRadius.circular(10)),
                      //   child: Row(
                      //     // mainAxisAlignment: MainAxisAlignment.center,
                      //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      //     children: [
                      //       Icon(
                      //         Icons.add,
                      //         size: 15,
                      //         color: greyLight,
                      //       ),
                      //       // SizedBox(
                      //       //   width: 5,
                      //       // ),
                      //       Text(
                      //         "join_a_group",
                      //         maxLines: 1,
                      //         overflow: TextOverflow.ellipsis,
                      //         style: TextStyle(
                      //             fontSize: 15,
                      //             fontWeight: FontWeight.w500,
                      //             color: greyLight),
                      //       ).tr()
                      //     ],
                      //   ),
                      // )
                    ],
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                height: 40,
                decoration: BoxDecoration(color: secondary),
                child: Padding(
                  padding: const EdgeInsets.only(left: 10, right: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "select_address",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: black.withOpacity(0.5),
                        ),
                      ).tr(),
                      Row(
                        children: [
                          Icon(
                            MaterialCommunityIcons.wallet,
                            size: 25,
                            color: primary.withOpacity(0.5),
                          ),
                          SizedBox(width: 10),
                          Text(
                            "₹ " +
                                context
                                    .watch<CreditProvider>()
                                    .balance
                                    .toString(),
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: black.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
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
                      dynamic result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LocationPickerPage(),
                        ),
                      );
                      var lat = result['lat'];
                      var lng = result['lng'];

                      await moveMapPin(lat, lng);
                      await getNewLocation(result);
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
                    Navigator.pop(context, {"lat": lat, "lng": lng});
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

    var apiURL =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$googleKeyApi";

    var url = Uri.parse(apiURL);

    final response = await http.get(url);
    if (response.statusCode == 200) {
      var result = jsonDecode(response.body);

      var streetAddress = result['results'][0]['formatted_address'];

      setState(() {
        addressLocation = streetAddress;
      });
    } else {
      setState(() {
        addressLocation = "";
      });
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
