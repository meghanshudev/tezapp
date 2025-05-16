import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:tezapp/helpers/constant.dart';
import 'package:tezapp/helpers/styles.dart';
import 'package:tezapp/helpers/theme.dart';
import 'package:tezapp/helpers/utils.dart';
import 'package:tezapp/ui_elements/category_item.dart';
import 'package:tezapp/ui_elements/custom_circular_progress.dart';
import 'package:tezapp/ui_elements/loading_widget.dart';
import 'package:tezapp/ui_elements/product_item_network.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../helpers/network.dart';
import '../../ui_elements/slider_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List ads = [];
  List categories = [];
  List allCategories = [];

  RefreshController refreshController = RefreshController();

  bool isLoading = false;
  bool isPulling = false;

  int page = 1;
  int total = 0;
  List categoryFeatures = [];

  bool isAdsLoading = false;

  late Mixpanel mixpanel;

  @override
  void initState() {
    super.initState();
    initPage();

    initMixpanel();
    initailize();
  }

  initailize() {
    eventBus.on().listen((event) async {
      if (!HOME_PAGE_LEAVE) {
        List temp = categoryFeatures;
        setState(() {
          categoryFeatures = [];
        });
        await Future.delayed(Duration(milliseconds: 100));
        setState(() {
          categoryFeatures = temp;
        });
      }
    });
  }

  Future<void> initMixpanel() async {
    mixpanel = await Mixpanel.init(
      MIX_PANEL,
      optOutTrackingDefault: false,
      trackAutomaticEvents: true,
    );
  }

  initPage() async {
    await fetchAds();
    await loadCategories();
    await loadFeatureCategories();

    // Push notification opened handler (new API)
    OneSignal.Notifications.addClickListener((event) async {
      final resultNotification = event.notification.additionalData ?? {};

      if (!checkIsNullValue(resultNotification['id'])) {
        HOME_PAGE_LEAVE = false;
        await Navigator.pushNamed(
          context,
          "/order_detail_page",
          arguments: {"id": resultNotification['id'].toString()},
        );
        HOME_PAGE_LEAVE = true;
      } else {
        HOME_PAGE_LEAVE = false;
        await Navigator.pushNamed(context, "/order_history_page");
        HOME_PAGE_LEAVE = true;
      }
    });

    // Register device for push notifications
    await getDeviceToken();
  }

  Future<void> getDeviceToken() async {
    // Set log level for debugging (optional)
    OneSignal.Debug.setLogLevel(OSLogLevel.verbose);

    // Initialize OneSignal with your App ID
    OneSignal.initialize(ONE_SIGNAL_ID);

    // Grant consent (if required)
    // OneSignal.consentGranted(true);


    // Request push notification permission from the user
    final accepted = await OneSignal.Notifications.requestPermission(true);
    print("Accepted permission: $accepted");

    // Opt-in to push subscription (optional, but recommended)
    OneSignal.User.pushSubscription.optIn();

    // Send custom tags (e.g. user ID)
    try {
      await OneSignal.User.addTagWithKey("id", userSession['id'].toString());
      print("User tag sent successfully");
    } catch (e) {
      print("Failed to send tag: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: white, body: getBody());
  }

  fetchAds() async {
    setState(() {
      isAdsLoading = true;
    });

    var params = {"limit": "0", "order": "rgt", "sort": "asc"};

    var response = await netGet(endPoint: "advertisement", params: params);
    if (response["resp_code"] == "200") {
      var data = response["resp_data"]["data"];
      List adsItems = data['list'] ?? [];
      if (mounted) {
        setState(() {
          ads = adsItems;
        });
      }
    } else {
      setState(() {
        ads = [];
      });
    }
    setState(() {
      isAdsLoading = false;
    });
  }

  loadCategories() async {
    var params = {"page": "1", "limit": "0", "order": "rgt", "sort": "asc"};

    var response = await netGet(endPoint: "category", params: params);
    if (response["resp_code"] == "200") {
      var data = response["resp_data"]["data"];
      List tempCategories = data["list"];
      if (mounted) {
        setState(() {
          categories =
              tempCategories
                  .where((element) => element["is_sub_category"] == false)
                  .toList();
        });
      }
    }
  }

  loadFeatureCategories() async {
    if (isLoading) return;
    setState(() {
      isLoading = true;
    });
    var params = {
      "page": page.toString(),
      "limit": "5",
      "order": "feature_order",
      "sort": "asc",
      "feature": "1",
    };
    //  var params = {"page": "1", "limit": "0", "order": "rgt", "sort": "asc"};
    //  var params = {"page": "1", "limit": "5", "order": "rgt", "sort": "asc"};
    var response = await netGet(endPoint: "category", params: params);
    if (response["resp_code"] == "200") {
      var data = response["resp_data"]["data"];
      List tempCategories = data["list"];
      int cnt = int.parse(data["total"].toString());
      if (mounted) {
        setState(() {});

        for (var item in tempCategories) {
          List products = await loadProductFeature(
            item['id'].toString(),
            item['is_sub_category'],
          );

          item["products"] = products;
        }

        setState(() {
          if (page == 1)
            categoryFeatures = tempCategories;
          else
            categoryFeatures.addAll(tempCategories);

          total = cnt;
          isLoading = false;
          isPulling = false;
          page++;
        });
      }
    }
    return true;
  }

  loadProductFeature(categoryId, isSubCategory) async {
    var params = {"page": "1", "limit": "10", "order": "name", "sort": "asc"};
    if (isSubCategory) {
      params["sub_category_id"] = categoryId;
    } else {
      params["category_id"] = categoryId;
    }

    var response = await netGet(endPoint: "product", params: params);
    if (response["resp_code"] == "200") {
      var data = response["resp_data"]["data"];
      List products = data['list'] ?? [];
      return products;
    } else {
      return [];
    }
  }

  getCategories() {
    return Padding(
      padding: EdgeInsets.fromLTRB(15, 0, 15, 15),
      child: Column(
        children: [
          Text("jbffggfhsgfh"),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.only(left: 5),
            child: Wrap(
              spacing: 20,
              runSpacing: 20,
              children: List.generate(categories.length, (index) {
                return GestureDetector(
                  onTap: () async {
                    dynamic dataPanel = {
                      "phone": userSession['phone_number'],
                      "category": categories[index]['name'],
                    };

                    mixpanel.track(CLICK_CATEGORY, properties: dataPanel);

                    setState(() {
                      HOME_PAGE_LEAVE = false;
                    });
                    await Navigator.pushNamed(
                      context,
                      "/category_page",
                      arguments: {
                        "category": categories[index],
                        "allCategories": categories,
                        "isParent": true,
                      },
                    );
                    setState(() {
                      HOME_PAGE_LEAVE = true;
                    });
                  },
                  child: CategoryItem(data: categories[index]),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  onOrderOnWhatsapp() async {
    String text = "I want to order my Kirana from Tez.";
    if (Platform.isIOS) {
      if (await canLaunch(WHATSAPP_IOS_URL + WHATSAPP)) {
        await launch(WHATSAPP_IOS_URL + WHATSAPP + "&text=${Uri.parse(text)}");
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: new Text("whatsapp_not_installed".tr())),
        );
      }
    } else {
      if (await canLaunch(WHATSAPP_ANDROID_URL + WHATSAPP)) {
        await launch(WHATSAPP_ANDROID_URL + WHATSAPP + "&text=" + text);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: new Text("whatsapp_not_installed".tr())),
        );
      }
    }
    // mix panel
    dynamic dataPanel = {
      "phone": userSession['phone_number'],
      "order_kirana_whatsapp": "order_kirana_whatsapp",
    };

    mixpanel.track(CLICK_ORDER_KIRANA_ON_WHATSAPP, properties: dataPanel);
  }

  Widget getBody() {
    return NotificationListener(
      onNotification: (ScrollNotification scrollInfo) {
        if (scrollInfo.metrics.pixels >= (scrollInfo.metrics.maxScrollExtent)) {
          if (!isLoading && (categoryFeatures.length < total)) {
            loadMore();
            return true;
          }
        }
        return false;
      },
      child: SmartRefresher(
        enablePullDown: true,
        controller: refreshController,
        onRefresh: onRefresh,
        onLoading: onLoading,
        header: WaterDropHeader(),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [getList()],
          ),
        ),
      ),
    );
  }

  Future<void> loadMore() async {
    await loadFeatureCategories();
  }

  void onLoading() async {
    refreshController.loadComplete();
  }

  void onRefresh() async {
    setState(() {
      page = 1;
      isPulling = true;
    });
    await fetchAds();
    // 0 feature as false
    // 1 feature as true
    await loadCategories();
    loadFeatureCategories().then((isSuccess) {
      if (isSuccess) {
        refreshController.refreshCompleted();
      } else {
        refreshController.refreshFailed();
      }
    });
  }

  Widget getList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 15),
        Padding(
          padding: const EdgeInsets.only(right: 20, left: 20),
          child: GestureDetector(
            onTap: () => onOrderOnWhatsapp(),
            child: Container(
              height: 50,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: whatsAppColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Icon(LineIcons.whatSApp, color: white, size: 25),
                  SizedBox(width: 5),
                  Text("order_kirana_on_whatsapp", style: normalWhiteText).tr(),
                  SizedBox(width: 5),
                  Icon(LineIcons.camera, color: white, size: 25),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: 15),
        Padding(
          padding: const EdgeInsets.only(left: 15, right: 15),
          child: SliderWidget(items: ads),
        ),
        getCategories(),
        SizedBox(height: 5),
        Divider(thickness: 0.8),
        SizedBox(height: 10),
        (isLoading && page == 1 && !isPulling)
            ? SizedBox(
              height: 150,
              child: Center(child: CustomCircularProgress()),
            )
            : Column(
              children: List.generate(categoryFeatures.length, (index) {
                List products = categoryFeatures[index]['products'];

                return products.length > 0
                    ? Padding(
                      padding: const EdgeInsets.only(bottom: 25),
                      child: getProductByCagories(
                        index,
                        categoryFeatures[index]['name'] ?? "",
                        categoryFeatures[index]['description'] ?? "",
                        categoryFeatures[index]['products'] ?? [],
                      ),
                    )
                    : Container();
              }),
            ),
        SizedBox(height: 20),
        (isLoading && page > 1) ? LoadingData() : Container(),
        SizedBox(height: 40),
      ],
    );
  }

  // Widget getBody() {
  //   return SingleChildScrollView(
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [

  //       ],
  //     ),
  //   );
  // }

  Widget getProductByCagories(index, title, subTitle, List products) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 15, left: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      subTitle,
                      style: TextStyle(fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () async {
                  await Navigator.pushNamed(
                    context,
                    "/category_page",
                    arguments: {
                      "category": categoryFeatures[index],
                      "allCategories": categoryFeatures,
                      "isParent": !categoryFeatures[index]["is_sub_category"],
                    },
                  );
                  setState(() {
                    HOME_PAGE_LEAVE = true;
                  });
                  dynamic dataPanel = {
                    "phone": userSession['phone_number'],
                    "category": categories[index],
                  };
                  mixpanel.track(CLICK_CATEGORY, properties: dataPanel);
                  setState(() {
                    HOME_PAGE_LEAVE = false;
                  });
                },
                child: Row(
                  children: [
                    Text("see_more", style: TextStyle(fontSize: 16)).tr(),
                    SizedBox(width: 3),
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Icon(
                        Icons.arrow_forward_ios,
                        color: black,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SingleChildScrollView(
          padding: EdgeInsets.only(left: 15),
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(products.length, (index) {
              var product = products[index]['product'];
              return Padding(
                padding: const EdgeInsets.only(right: 20, top: 20, bottom: 20),
                child: GestureDetector(
                  onTap: () async {
                    dynamic dataPanel = {
                      "phone": userSession['phone_number'],
                      "product": products[index]['product']['name'],
                    };

                    mixpanel.track(CLICK_PRODUCT, properties: dataPanel);
                    setState(() {
                      HOME_PAGE_LEAVE = false;
                    });
                    await Navigator.pushNamed(
                      context,
                      "/product_detail_page",
                      arguments: {"product": products[index]},
                    );
                    setState(() {
                      HOME_PAGE_LEAVE = true;
                    });
                  },
                  child: ProductItemNetwork(
                    product: product,
                    discountLabel:
                        convertDouble(product['percent_off']).toInt(),
                    kgLabel:
                        product["attributes"].length == 0
                            ? ""
                            : product["attributes"][0]["value"],
                    image: product['image'],
                    name: product['name'],
                    priceStrike: CURRENCY + "${product["unit_price"]}",
                    price: CURRENCY + "${product["sale_price"]}",
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
