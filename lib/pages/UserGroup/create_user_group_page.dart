import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:geocode/geocode.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:tez_mobile/helpers/constant.dart';
import 'package:tez_mobile/helpers/network.dart';
import 'dart:async';
import 'package:tez_mobile/helpers/styles.dart';
import 'package:tez_mobile/helpers/theme.dart';
import 'package:tez_mobile/helpers/utils.dart';
import 'package:tez_mobile/ui_elements/custom_appbar.dart';

import '../../ui_elements/custom_footer_buttons.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:provider/provider.dart';
import 'package:tez_mobile/provider/has_group.dart';
import 'package:http/http.dart' as http;

class CreateUserGroupPage extends StatefulWidget {
  CreateUserGroupPage({Key? key, required this.data}) : super(key: key);
  final data;

  @override
  State<CreateUserGroupPage> createState() => _CreateUserGroupPageState();
}

class _CreateUserGroupPageState extends State<CreateUserGroupPage> {
  bool isJoinGroup = false;
  bool isLoadingButton = false;

  TextEditingController yourAddressController = TextEditingController();

  // google map
  bool isGetAddress = false;
  double markerLatPosition = 21.131780;
  double markerLngPosition = 79.119420;
  Completer<GoogleMapController> googleController = Completer();

  // TextEditingController addressController = new TextEditingController();
  late GoogleMapController mapController;

  CameraPosition kGooglePlex = CameraPosition(
    target: LatLng(21.131780, 79.119420),
    zoom: 17.5,
  );

  String addressLocation = '';
  String zipCode = '';
  var deliverTo = '';
  var zipCodeLabel = '';
  double lat = 0.0;
  double lng = 0.0;

  late Mixpanel mixpanel;

  @override
  void initState() {
    super.initState();
    setState(() {
      isJoinGroup = widget.data['join'];
    });

    setState(() {
      zipCodeLabel = !checkIsNullValue(userSession['zip_code'])
          ? userSession['zip_code']
          : "";
      deliverTo = !checkIsNullValue(userSession) ? userSession['name'] : "";
    });

    initMixpanel();
  }

  Future<void> initMixpanel() async {
    mixpanel = await Mixpanel.init(MIX_PANEL, optOutTrackingDefault: false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: white,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(120),
          child: CustomAppBar(
            subtitle: "$zipCodeLabel - $deliverTo",
            subtitleIcon: Entypo.location_pin,
          ),
        ),
        bottomNavigationBar: getFooter(),
        body: getBody(),
      ),
    );
  }

  Widget getFooter() {
    return CustomFooterButtons(
      isLoading: isLoadingButton,
      proceedTitle: "create_your_tez_group".tr(),
      titlePadding: EdgeInsets.zero,
      titleCenter: true,
      onTapProceed: () {
        createGroup();
      },
      onTapBack: () {
        Navigator.of(context).pop();
      },
    );
  }

  Widget getBody() {
    var size = MediaQuery.of(context).size;
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(15),
          child: Container(
            height: size.height,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                isJoinGroup
                    ? Text(
                        addressLocation,
                        style: normalBoldBlackTitle,
                        maxLines: 2,
                      )
                    : Text(
                        "create_your_tez_group".tr(),
                        style: normalBoldBlackTitle,
                      ),
                SizedBox(
                  height: 2,
                ),
                isJoinGroup
                    ? Text(
                        "enter_the_address_where_all_orders_will_be_delivered"
                            .tr(),
                        style: smallMediumGreyText,
                      )
                    : Text(
                        "5%_commission".tr(),
                        style: smallMediumGreyText,
                      ),
                SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 100, left: 15, right: 15),
          child: Container(
            height: size.height,
            child: Stack(
              children: [
                Container(
                  height: 250,
                  decoration: BoxDecoration(
                      border: Border.all(color: primary, width: 1.5)),
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
                      LatLng latlng =
                          LatLng(markerLatPosition, markerLngPosition);
                      var result = {
                        "lat": latlng.latitude,
                        "lng": latlng.longitude
                      };
                      getNewLocation(result);
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
                      //getUserCurrentLocation(controller);
                    },
                  ),
                ),
                Positioned(
                  left: 120,
                  top: 70,
                  child: Container(
                    height: 120.0,
                    width: 120.0,
                    alignment: Alignment.center,
                    child: Container(
                      padding: EdgeInsets.only(bottom: 20),
                      child:
                          Icon(Entypo.location_pin, size: 50, color: primary),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 15, right: 15, top: 370),
          child: Container(
            width: size.width,
            height: 50,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: placeHolderColor)),
            child: Padding(
              padding: const EdgeInsets.only(left: 15, right: 5),
              child: Row(
                children: [
                  Flexible(
                    child: TextField(
                      controller: yourAddressController,
                      cursorColor: black,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "your_address".tr()),
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  IconButton(
                      onPressed: () {
                        getCurrentLocation();
                      },
                      icon: Icon(
                        MaterialIcons.my_location,
                        color: primary,
                      ))
                ],
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget getBodyBK() {
    var size = MediaQuery.of(context).size;
    return SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(
        height: 5,
      ),
      Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Create your Tez Group",
              style: normalBoldBlackTitle,
            ),
            SizedBox(
              height: 2,
            ),
            Text(
              "5% commission  •  FREE Groceries  •  FREE Gifts",
              style: smallMediumGreyText,
            ),
            SizedBox(
              height: 20,
            ),
            isJoinGroup
                ? Container(
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
                              LatLng latlng =
                                  LatLng(markerLatPosition, markerLngPosition);
                              var result = {
                                "lat": latlng.latitude,
                                "lng": latlng.longitude
                              };
                              getNewLocation(result);
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
                              child: Icon(Entypo.location_pin,
                                  size: 50, color: primary),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : Container(
                    height: 150,
                    width: size.width,
                    decoration: BoxDecoration(
                        color: placeHolderColor,
                        borderRadius: BorderRadius.circular(10)),
                  ),
            SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    ]));
  }

  createGroup() async {
    if (isLoadingButton) return;
    setState(() {
      isLoadingButton = true;
    });

    var currentLocation = await locateUser();

    var param = {
      "name": widget.data['name'],
      "address": addressLocation,
      "lat": currentLocation.latitude.toString(),
      "lng": currentLocation.longitude.toString(),
      "zip_code": zipCode.toString()
    };

    var response = await netPost(
      isUserToken: true,
      endPoint: "group",
      params: param,
    );

    if (mounted) {
      if (response['resp_code'] == "200") {
        dynamic dataPanel = {
          "phone": userSession['phone_number'],
          "group_id": response['resp_data']['data']['group_code']
        };

        mixpanel.track(CLICK_CREATE_GROUP, properties: dataPanel);

        // set refresh group
        context.read<HasGroupProvider>().refreshGroup(true);

        // set new session for group
        var result = response['resp_data']['data'];
        userSession['group'] = result;
        await setStorage(STORAGE_USER, userSession);

        await getStorageUser();

        notifyAlert(context,
            desc: "you_have_created_a_group_successfully".tr(),
            btnTitle: "Ok", onConfirm: () {
          Navigator.pop(context);
          //
          Navigator.pushNamedAndRemoveUntil(
            context,
            "/root_app",
            (route) => false,
            arguments: {"activePageIndex": 1},
          );
        });
      } else {
        notifyAlert(context,
            desc: response['resp_data']['message'].toString(),
            btnTitle: "Ok", onConfirm: () {
          Navigator.pop(context);
        });
      }

      setState(() {
        isLoadingButton = false;
      });
    }
  }

  Future<Position> locateUser() async {
    return await determineUserLocationPosition(context);
  }

  getNewLocation(result) async {
    double lat = result['lat'];
    double lng = result['lng'];

    var apiURL =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$googleKeyApi";

    var url = Uri.parse(apiURL);

    final response = await http.get(url);
    if (response.statusCode == 200) {
      var result = jsonDecode(response.body);
      List items = result['results'][0]['address_components'] ?? [];

      var postalCode = '';
      if (items.length > 0) {
        items.forEach((result) {
          if (result['types'][0] == "postal_code") {
            postalCode = result['long_name'];
          }
        });
      }
      if (checkIsNullValue(postalCode)) {
        postalCode = DEFAULT_ZIP_CODE;
      }

      var streetAddress = result['results'][0]['formatted_address'];

      setState(() {
        addressLocation = streetAddress;
        yourAddressController.text = addressLocation;
        zipCode = postalCode;
        zipCodeLabel = " - " + zipCode;
      });
    } else {
      setState(() {
        addressLocation = "";
        yourAddressController.text = addressLocation;
        zipCode = "";
        zipCodeLabel = "";
      });
    }
  }

  Future<void> moveMapPin(lat, lng) async {
    final CameraPosition address =
        CameraPosition(target: LatLng(lat, lng), zoom: 19.151926040649414);
    final GoogleMapController controller = await googleController.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(address));
  }

  getCurrentLocation() async {
    var currentLocation = await locateUser();

    if (mounted)
      setState(() {
        lat = currentLocation.latitude;
        lng = currentLocation.longitude;
      });
    var result = {"lat": lat, "lng": lng};
    moveMapPin(lat, lng);
    getNewLocation(result);
  }
}
