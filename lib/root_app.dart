import 'dart:convert';
import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:geocode/geocode.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:tezchal/helpers/constant.dart';
import 'package:tezchal/helpers/styles.dart';
import 'package:tezchal/helpers/theme.dart';
import 'package:tezchal/pages/Account/account_page.dart';
import 'package:tezchal/pages/Account/order_history_page.dart';
import 'package:tezchal/pages/Cart/cart_page.dart';
import 'package:tezchal/pages/Home/home_page.dart';
import 'package:tezchal/pages/Location/location_picker_page.dart';
import 'package:tezchal/provider/account_info_provider.dart';
import 'package:tezchal/provider/cart_provider.dart';
import 'package:tezchal/ui_elements/custom_appbar.dart';
import 'package:tezchal/ui_elements/custom_circular_progress.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:tezchal/ui_elements/custom_search_button.dart';

import 'helpers/network.dart';
import 'helpers/utils.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class RootApp extends StatefulWidget {
  RootApp({Key? key, this.data}) : super(key: key);
  final data;
  @override
  _RootAppState createState() => _RootAppState();
}

class _RootAppState extends State<RootApp> {
  int pageIndex = 0;

  // is in operation city
  bool isInOperationCity = true;
  bool isLoadingScreen = false;
  var address = '';
  var zipCode = '';
  var deliverTo = '';

  // load cart
  bool hasCartItem = false;
  bool isLoadingCart = false;
  var cart;

  // check update location or not
  // bool isUpdateLocation = false;

  late Mixpanel mixpanel;
  bool _isLoading = true;

  @override
  void initState() {
    // ignore: todo
    // TODO: implement initState
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    print("ROOT PAGE");

    pageIndex =
        !checkIsNullValue(widget.data) &&
                widget.data.containsKey("activePageIndex")
            ? widget.data["activePageIndex"]
            : pageIndex;

    final AppsFlyerOptions appsFlyerOptions = AppsFlyerOptions(
      afDevKey: "NZc7Uh8aPcGiBZFoghEWSR",
      appId: "1625884539",
      showDebug: true,
      timeToWaitForATTUserAuthorization: 50,
    );

    AppsflyerSdk appsflyerSdk = AppsflyerSdk(appsFlyerOptions);

    appsflyerSdk.initSdk(
      registerConversionDataCallback: true,
      registerOnAppOpenAttributionCallback: true,
      registerOnDeepLinkingCallback: true,
    );

    checkInOperationCity();

    await initMixpanel();
    await initPage();
    getProfileData(context);
    deliverTo =
        !checkIsNullValue(userSession) ? userSession['name'] ?? "" ?? "" : "";
    zipCode =
        !checkIsNullValue(userSession['zip_code'])
            ? userSession['zip_code'] ?? ""
            : "";
    address =
        !checkIsNullValue(userSession['address'])
            ? userSession['address'] ?? ""
            : "";

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> initMixpanel() async {
    mixpanel = await Mixpanel.init(
      MIX_PANEL,
      optOutTrackingDefault: false,
      trackAutomaticEvents: true,
    );
  }

  void onOpenSearch() {
    setState(() {
      HOME_PAGE_LEAVE = false;
    });
  }

  void onCloseSearch() {
    setState(() {
      HOME_PAGE_LEAVE = true;
    });
  }

  checkInOperationCity({lat = 0.0, lng = 0.0}) async {
    log("RootApp: Checking if in operation city...");
    setState(() {
      isLoadingScreen = true;
    });

    // If a new location is provided, get the address and update.
    if (lat != 0.0 || lng != 0.0) {
      log("RootApp: New location provided. Getting address...");
      await getCurrentLocation(lat: lat, lng: lng);
    } else {
      // Otherwise, check the current profile.
      log("RootApp: No new location. Checking profile...");
      var response = await netGet(isUserToken: true, endPoint: "me/profile");

      if (response['resp_code'] == "200") {
        var data = response['resp_data']['data'];
        bool inCity = data['is_in_operation_city'];
        if (mounted) {
          log("RootApp: Profile received. In city: $inCity");
          setState(() {
            isInOperationCity = inCity;
            address = data['address'] ?? "";
            zipCode = data['zip_code'] ?? "";
            userSession['address'] = address;
            userSession['zip_code'] = zipCode;
            isLoadingScreen = false;
          });
        }
        if (!inCity) {
          log("RootApp: Not in an operation city. Getting current location...");
          await getCurrentLocation();
        }
      } else {
        log("RootApp: Failed to get profile. Assuming not in city.");
        if (mounted) {
          setState(() {
            isInOperationCity = false;
            isLoadingScreen = false;
          });
        }
      }
    }
  }

  getCurrentLocation({lat = 0.0, lng = 0.0}) async {
    // get current lat and lng
    var currentLocation = await determineUserLocationPosition(context);
    // change to rest api geocoding

    var newLat = lat != 0.0 ? lat : currentLocation.latitude;
    var newLng = lng != 0.0 ? lng : currentLocation.longitude;

    // mix panel
    dynamic dataPanel = {
      "phone": userSession['phone_number'],
      "location": {"lat": newLat, "lng": newLng},
  };

    mixpanel.track(CLICK_PERMISSION_LOCATION, properties: dataPanel);

    var apiURL =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=$newLat,$newLng&key=$googleKeyApi";

    var url = Uri.parse(apiURL);

    final response = await http.get(url);
    if (response.statusCode == 200) {
      var result = jsonDecode(response.body);
      List items = result['results'][0]['address_components'] ?? [];

      // print(items);
      var postalCode = '';
      if (items.length > 0) {
        items.forEach((result) {
          if (result['types'][0] == "postal_code") {
            postalCode = result['long_name'];
          }
        });
      }

      var location = result['results'][0]['formatted_address'];
      var lat = newLat;
      var lng = newLng;
      if (checkIsNullValue(postalCode)) {
        postalCode = DEFAULT_ZIP_CODE;
      }
      var zipCode = postalCode;

      await updateUserAddress(location, lat, lng, zipCode);
    }
  }

  updateUserAddress(location, lat, lng, zipCode) async {
    log("RootApp: Updating user address...");
    var response = await netPost(
      isUserToken: true,
      endPoint: "me/update/address",
      params: {
        "lat": lat,
        "lng": lng,
        "address": location,
        "zip_code": zipCode,
      },
    );

    if (mounted) {
      if (response['resp_code'] == "200") {
        log("RootApp: User address updated successfully.");
        var data = response['resp_data']['data'];
        setState(() {
          isInOperationCity = data['is_in_operation_city'];
          address = data['address'] ?? "";
          zipCode = data['zip_code'] ?? "";
          userSession['address'] = address;
          userSession['zip_code'] = zipCode;
          isLoadingScreen = false;
        });
      } else {
        log("RootApp: Failed to update user address: ${response['resp_data']}");
        setState(() {
          isInOperationCity = false;
          isLoadingScreen = false;
        });
      }
    }
  }

  _refreshProfile() async {
    log("RootApp: Refreshing profile...");
    setState(() {
      isLoadingScreen = true;
    });
    var response = await netGet(isUserToken: true, endPoint: "me/profile");

    if (mounted) {
      if (response['resp_code'] == "200") {
        var data = response['resp_data']['data'];
        log("RootApp: Profile refreshed successfully.");
        setState(() {
          isInOperationCity = data['is_in_operation_city'];
          address = data['address'] ?? "";
          zipCode = data['zip_code'] ?? "";
          userSession['address'] = address;
          userSession['zip_code'] = zipCode;
          isLoadingScreen = false;
        });
      } else {
        log("RootApp: Failed to refresh profile: ${response['resp_data']}");
        setState(() {
          isInOperationCity = false;
          isLoadingScreen = false;
        });
      }
    }
  }

  initPage() async {
    await loadCart();
    if (checkIsNullValue(userSession)) {
      await onSignOut(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: white,
        body: Center(child: CustomCircularProgress()),
      );
    }
    // String username = ;
    List topItems = [
      {"icon": Feather.home, "label": "home".tr(), "page": 0},
      {"icon": Feather.list, "label": "order_history".tr(), "page": 1},
      {"icon": Feather.user, "label": "account".tr(), "page": 2},
      {"icon": Feather.shopping_cart, "label": "cart".tr(), "page": 3},
    ];
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: white,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child:
              pageIndex == 0
                  ? CustomAppBar(
                    isClick: true,
                    onCallBack: (result) async {
                      log("CallBack result from location page: $result");
                      if (result != null && result['status'] == 'updated') {
                        await _refreshProfile();
                      }
                    },
                    subtitle: address + " - " + zipCode,
                    subtitleIcon: Entypo.location_pin,
                  )
                  : CustomAppBar(subtitle: topItems[pageIndex]['label']),
        ),
        bottomNavigationBar: getFooter(),
        body: getBody(),
      ),
    );
  }

  Widget getBody() {
    return IndexedStack(
      index: pageIndex,
      children: [
        HomePage(),
        OrderHistoryPage(),
        AccountPage(),
        CartPage(onCartEmptied: loadCart), // Pass loadCart as callback
      ],
    );
  }

  Widget getFooter() {
    List bottomItems = [
      {"icon": Feather.home, "label": "home".tr(), "page": 0},
      {"icon": Feather.list, "label": "order".tr(), "page": 1},
      {"icon": Feather.user, "label": "account".tr(), "page": 2},
      {"icon": Feather.shopping_cart, "label": "cart".tr(), "page": 3},
    ];
    if (isLoadingScreen) {
      return Center(child: CustomCircularProgress());
    } else {
      return isInOperationCity
          ? Container(
            width: double.infinity,
            height: 90,
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: greyLight70, width: 1.5)),
            ),
            child: Padding(
              padding: const EdgeInsets.only(
                left: 40,
                right: 40,
                top: 15,
                bottom: 20,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(bottomItems.length, (index) {
                  return InkWell(
                    onTap: () async {
                      setState(() {
                        pageIndex = bottomItems[index]['page'] as int;
                      });
                      if (pageIndex == 3) {
                        // If navigating to the CartPage, explicitly refresh its data
                        // This assumes CartPage has a mechanism to refresh when its dependencies change or it's rebuilt.
                        // The previous change in CartPage.dart to use didChangeDependencies should handle this.
                        print("CartPage - refreshing cart data");
                        await loadCart(); // Call loadCart from RootApp to refresh the cart provider
                      }
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          bottomItems[index]['icon'] as IconData?,
                          color:
                              pageIndex == bottomItems[index]['page']
                                  ? primary
                                  : black,
                        ),
                        SizedBox(height: 5),
                        Text(
                          bottomItems[index]['label'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                pageIndex == bottomItems[index]['page']
                                    ? primary
                                    : black,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          )
          : comingLocation();
    }
  }

  Widget comingLocation() {
    var size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.only(top: 185, left: 20, right: 20),
      child: Column(
        children: [
          Container(
            height: 125,
            width: double.infinity,
            decoration: BoxDecoration(
              // color: placeHolderColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                "assets/images/not_found.png",
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(height: 15),
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

                      log("CallBack result from location picker page: $result");
                      if (result != null &&
                          result['lat'] != null &&
                          result['lng'] != null) {
                        var lat = result['lat'];
                        var lng = result['lng'];
                        checkInOperationCity(lat: lat, lng: lng);
                      }
                    },
                    cursorColor: black,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      hintText: "choose_another_location".tr(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 15),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: placeHolderColor),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.only(
                top: 20,
                bottom: 30,
                left: 20,
                right: 20,
              ),
              child: Column(
                children: [
                  Text(
                    "we_don't_deliver_to_your_location_yet",
                    style: meduimBoldBlackText,
                  ).tr(),
                  SizedBox(height: 5),
                  Text("but_we_will_soon", style: meduimBoldBlackText).tr(),
                  SizedBox(height: 20),
                  // Text(
                  //   "Wait for a while. Our team is working",
                  //   style: meduimNormalBlackText,
                  // ),
                  // SizedBox(
                  //   height: 5,
                  // ),
                  // Text(
                  //   "tirelessly to bring Tez in your localcity.",
                  //   style: meduimNormalBlackText,
                  // ),
                  Text(
                    "wait_for_a_while_our_team_is_working_tirelessly_to_bring_tez_in_your_locality",
                    textAlign: TextAlign.center,
                    style: meduimNormalBlackText.copyWith(height: 1.5),
                  ).tr(),
                  SizedBox(height: 20),
                  Text(
                    "follow_us_for_updates",
                    style: meduimBoldBlackText,
                  ).tr(),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () {
                          launchSocialLink(INSTAGRAM);
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          child: SvgPicture.asset(
                            "assets/icons/instagram_icon.svg",
                          ),
                        ),
                      ),
                      SizedBox(width: 20),
                      InkWell(
                        onTap: () {
                          launchSocialLink(FACEBOOK);
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          child: SvgPicture.asset(
                            "assets/icons/facebook_icon.svg",
                          ),
                        ),
                      ),
                      SizedBox(width: 20),
                      InkWell(
                        onTap: () {
                          launchSocialLink(LINKEDIN);
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          child: SvgPicture.asset(
                            "assets/icons/linkedin_icon.svg",
                          ),
                        ),
                      ),
                      SizedBox(width: 20),
                      InkWell(
                        onTap: () {
                          launchSocialLink(TWITTER);
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          child: SvgPicture.asset(
                            "assets/icons/twitter_icon.svg",
                          ),
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
    );
  }

  loadCart() async {
    if (isLoadingCart) return;
    isLoadingCart = true;
    var response = await netGet(isUserToken: true, endPoint: "me/cart");
    print("CartPage - refreshing cart data ${response}");
    if (response['resp_code'] == "200") {
      var temp = response["resp_data"]["data"];
      if (!checkIsNullValue(temp) && temp.containsKey('lines')) {
        cart = temp;
        hasCartItem = !checkIsNullValue(cart);

        List cartItems = cart['lines'];
        // Update CartProvider with full cart data
        context.read<CartProvider>().refreshCartData(cart);
        context.read<CartProvider>().refreshCart(true);
        context.read<CartProvider>().refreshCartCount(cartItems.length);
        context.read<CartProvider>().refreshCartGrandTotal(
          double.parse(cart['total'].toString()),
        );
      } else {
        // Handle case where data is null or 'lines' is missing (empty cart)
        cart = null;
        context.read<CartProvider>().refreshCartData(null); // Clear cart data
        context.read<CartProvider>().refreshCart(false);
        context.read<CartProvider>().refreshCartCount(0);
        context.read<CartProvider>().refreshCartGrandTotal(0.0);
      }
    } else {
      // Handle non-200 responses or other errors by clearing the cart
      cart = null;
      context.read<CartProvider>().refreshCartData(null); // Clear cart data
      context.read<CartProvider>().refreshCart(false);
      context.read<CartProvider>().refreshCartCount(0);
      context.read<CartProvider>().refreshCartGrandTotal(0.0);
    }
    if (mounted)
      setState(() {
        isLoadingCart = false;
      });
  }
}
