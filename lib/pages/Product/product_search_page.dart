import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tezchal/helpers/network.dart';
import 'package:tezchal/helpers/styles.dart';
import 'package:tezchal/helpers/theme.dart';
import 'package:tezchal/helpers/utils.dart';
import 'package:tezchal/models/product.dart';
import 'package:tezchal/pages/Cart/cart_page.dart';
import 'package:tezchal/pages/Product/product_detail_page.dart';
import 'package:tezchal/provider/account_info_provider.dart';
import 'package:tezchal/provider/cart_provider.dart';
import 'package:tezchal/provider/credit_provider.dart';
import 'package:tezchal/ui_elements/custom_appbar.dart';
import 'package:tezchal/ui_elements/loading_widget.dart';
import 'package:tezchal/ui_elements/product_search_loading.dart';
import 'package:tezchal/ui_elements/custom_search_button.dart';
import '../../helpers/constant.dart';
import '../../models/category.dart';
import '../../ui_elements/content_placeholder.dart';
import '../../ui_elements/product_item_network.dart';

class ProductSearchPage extends StatefulWidget {
  const ProductSearchPage({Key? key}) : super(key: key);

  @override
  State<ProductSearchPage> createState() => _ProductSearchPageState();
}

class _ProductSearchPageState extends State<ProductSearchPage> {
  final TextEditingController searchController = TextEditingController();
  bool hasCartItem = false;
  bool isLoading = false;
  List<Product> list = [];
  List<Category> categories = [];
  List products = [];
  bool isInPage = true;

  // List<Category> addCategory = [
  //   Category(
  //     id: "0",
  //     name: "All",
  //     image: NETWORK_DEFAULT_IMAGE,
  //     isSubCategory: false,
  //   ),
  // ];

  late Mixpanel mixpanel;

  @override
  void initState() {
    super.initState();
    initailize();
    // fechCategoryPopular();
    initMixpanel();
  }

  initailize() {
    eventBus.on().listen((event) async {
      if (!isInPage) {
        List temp = products;
        setState(() {
          products = [];
        });
        await Future.delayed(Duration(milliseconds: 100));
        setState(() {
          products = temp;
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

  // Future fechCategoryPopular() async {
  //   setState(() { isLoading = true; });
  //   Map<dynamic, dynamic> data = await CategoryRepository().index(
  //     params: {
  //       "page": "1",
  //       "limit": "10",
  //       "order": "order_count",
  //       "sort": "desc",
  //     }
  //   );
  //   List<Category> items = data["list"] as List<Category>;
  //   // items.insert(0, addCategory[0]);
  //   setState(() {
  //     categories = items;
  //     isLoading = false;
  //   });

  // }

  // onSearch(String searchText) async {
  //   if(mounted) {
  //     setState(() { isLoading = true; });

  //     Map<dynamic, dynamic> data = await SearchRepository().search(
  //       params: {
  //         "page" : "1",
  //         "row" : "10",
  //         "search" : searchText,
  //       }
  //     );
  //     List<Product> items = data["list"] as List<Product>;
  //     setState(() {
  //       list = items;
  //       isLoading = false;
  //     });
  //   }
  // }

  onSearch(String searchText) async {
    setState(() {
      isLoading = true;
    });
    var response = await netGet(
      isUserToken: true,
      endPoint: "product",
      params: {"page": "1", "order": "name", "search": searchText},
    );

    if (response['resp_code'] == "200") {
      if (mounted) {
        setState(() {
          isLoading = false;
          products = response['resp_data']['data']['list'];
        });
      }
    } else {
      setState(() {
        isLoading = false;
        products = [];
      });
    }
  }

  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: white,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(80),
          child: CustomAppBar(
            isClick: true,
            // onCallBack: (result) async {
            //   await getCurrentLocation(
            //       lat: result['lat'], lng: result['lng']);
            //   await checkInOperationCity(
            //     lat: result['lat'],
            //     lng: result['lng'],
            //   );
            // },
            // subtitle: zipCode +
            //     " - " +
            //     context.watch<AccountInfoProvider>().name,
            subtitleIcon: Entypo.location_pin,
          ),
        ),
        // appBar: PreferredSize(
        //   preferredSize: Size.fromHeight(60),
        //   child: getAppBar(),
        // ),
        bottomNavigationBar: getFooter(),
        body: getBody(),
      ),
    );
  }

  Widget getBody() {
    var size = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: Column(
        // crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 5),
          Container(
            width: double.infinity,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: greyLight, width: 1.5),
            ),
            margin: EdgeInsets.all(10),
            child: Row(
              children: [
                Container(
                  width: 50,
                  child: Center(
                    child: Icon(Icons.search, size: 30, color: greyLight),
                  ),
                ),
                Flexible(
                  child: TextField(
                    controller: searchController,
                    onSubmitted: (val) => onSearch(val),
                    onChanged: (val) => onSearch(val),
                    onEditingComplete: () => onSearch(searchController.text),
                    cursorColor: black,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "search_for_products".tr(),
                    ),
                  ),
                ),
                SizedBox(width: 20),
              ],
            ),
          ),
          SizedBox(height: 5),
          isLoading ? ProductSearchLoading() : getProductSection(size),
          SizedBox(height: 40),
        ],
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
          child: Container(
            width: double.infinity,
            height: 80,
            decoration: BoxDecoration(color: primary),
            child: Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        "search",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                          color: white,
                        ),
                      ).tr(),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(
                        MaterialCommunityIcons.wallet,
                        size: 25,
                        color: white,
                      ),
                      SizedBox(width: 10),
                      Text(
                        "₹ " +
                            context.watch<CreditProvider>().balance.toString(),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget getProductSection(size) {
    return Column(
      children: [
        products.length == 1
            ? Container(
              padding: EdgeInsets.only(left: 15),
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: () async {
                  dynamic dataPanel = {
                    "phone": userSession['phone_number'],
                    "product": products[0]['product']['name'],
                  };

                  mixpanel.track(CLICK_PRODUCT, properties: dataPanel);
                  setState(() {
                    isInPage = false;
                  });
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) =>
                              ProductDetailPage(data: {"product": products[0]}),
                    ),
                  );

                  setState(() {
                    isInPage = true;
                  });
                },
                child: ProductItemNetwork(
                  product: products[0]['product'],
                  width: (size.width - 60) / 2,
                  discountLabel:
                      convertDouble(products[0]['percent_off']).toInt(),
                  kgLabel:
                      products[0]['product']["attributes"].length == 0
                          ? ""
                          : products[0]['product']["attributes"][0]["value"],
                  image: products[0]['image'],
                  name: products[0]['name'],
                  priceStrike: CURRENCY + "${products[0]["unit_price"]}",
                  price: CURRENCY + "${products[0]["sale_price"]}",
                ),
              ),
            )
            : Wrap(
              spacing: 20,
              runSpacing: 20,
              crossAxisAlignment: WrapCrossAlignment.start,
              children: List.generate(products.length, (index) {
                return GestureDetector(
                  onTap: () async {
                    dynamic dataPanel = {
                      "phone": userSession['phone_number'],
                      "product": products[index]['product']['name'],
                    };

                    mixpanel.track(CLICK_PRODUCT, properties: dataPanel);
                    setState(() {
                      isInPage = false;
                    });
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => ProductDetailPage(
                              data: {"product": products[index]},
                            ),
                      ),
                    );
                    setState(() {
                      isInPage = true;
                    });
                  },
                  child: ProductItemNetwork(
                    product: products[index]['product'],
                    width: (size.width - 60) / 2,
                    discountLabel:
                        convertDouble(products[index]['percent_off']).toInt(),
                    kgLabel:
                        products[index]['product']["attributes"].length == 0
                            ? ""
                            : products[index]['product']["attributes"][0]["value"],
                    image: products[index]['image'],
                    name: products[index]['product']['name'],
                    priceStrike:
                        CURRENCY + products[index]['unit_price'].toString(),
                    price: CURRENCY + products[index]['sale_price'].toString(),
                  ),
                );
              }),
            ),
      ],
    );
  }

  Widget getFooter() {
    var size = MediaQuery.of(context).size;
    return Container(
      width: double.infinity,
      height: 90,
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
      child: Column(
        children: [
          // cart section
          Padding(
            padding: const EdgeInsets.only(left: 15, right: 15, top: 15),
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
                context.watch<CartProvider>().isHasCart
                    ? Flexible(
                      child: InkWell(
                        onTap: () async {
                          dynamic dataPanel = {
                            "phone": userSession['phone_number'],
                            "cart_screen": "cart_screen",
                          };

                          mixpanel.track(CART_SCREEN, properties: dataPanel);
                          setState(() {
                            isInPage = false;
                          });
                          await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => CartPage()),
                          );
                          setState(() {
                            isInPage = true;
                          });
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  getCartInfo(context),
                                  style: normalWhiteText,
                                ),
                                Row(
                                  children: [
                                    Text("cart", style: normalWhiteText).tr(),
                                    SizedBox(width: 5),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      color: white,
                                      size: 18,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                    : Flexible(
                      child: Container(
                        width: double.infinity,
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
                          onTap: () => Navigator.pop(context),
                          child: Center(
                            child:
                                Text(
                                  "cart_empty_start_shopping",
                                  style: normalGreyText,
                                ).tr(),
                          ),
                        ),
                      ),
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
