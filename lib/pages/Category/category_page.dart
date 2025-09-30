import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tezchal/helpers/constant.dart';
import 'package:tezchal/helpers/styles.dart';
import 'package:tezchal/helpers/theme.dart';
import 'package:tezchal/pages/Cart/cart_page.dart';
import 'package:tezchal/pages/Product/product_detail_page.dart';
import 'package:tezchal/provider/account_info_provider.dart';
import 'package:tezchal/ui_elements/category_loading.dart';
import 'package:tezchal/ui_elements/custom_appbar.dart';
import 'package:tezchal/ui_elements/product_category_item.dart';
import 'package:tezchal/ui_elements/sub_category_item.dart';
import '../../helpers/network.dart';
import '../../helpers/utils.dart';
import '../../provider/cart_provider.dart';
import '../../ui_elements/circle_category_loading.dart';

class CategoryPage extends StatefulWidget {
  CategoryPage({Key? key, required this.data, this.isParent = true})
    : super(key: key);
  final data;
  final bool isParent;

  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  List products = [];
  List subCategories = [];
  int categoryId = 0;
  int selectedSubCategoryId = 0;
  bool isLoading = false;
  bool isLoadingProduct = false;
  bool isInPage = true;
  final scollController = ScrollController();
  var allSubCategory = {
    "id": 0,
    "name": "All",
    "image": NETWORK_DEFAULT_IMAGE,
    "is_sub_category": false,
  };

  int activeItem = 0;

  var zipCode = '';
  var deliverTo = '';

  late Mixpanel mixpanel;

  @override
  void initState() {
    super.initState();
    initPage();

    deliverTo = !checkIsNullValue(userSession) ? userSession['name'] ?? "" : "";
    zipCode =
        !checkIsNullValue(userSession['zip_code'])
            ? userSession['zip_code']
            : "";
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

  initPage() async {
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

    categoryId = widget.data["category"]["id"];

    allSubCategory["image"] = widget.data["category"]["image"];
    // sub category
    if (!widget.isParent) {
      allSubCategory["name"] = widget.data["category"]["name"];
    }

    await loadSubCategories(categoryId);
    await loadProductsBySubCategory(selectedSubCategoryId);

    scollController.addListener(() async {
      if (scollController.position.pixels >
          (scollController.position.maxScrollExtent * 0.7)) {
        await loadMore();
      }
    });
  }

  bool loadingMore = false;
  int pageIndex = 1;
  bool isNoMore = false;
  Future<bool> loadMore() async {
    if (loadingMore || isNoMore) return false;
    loadingMore = true;
    pageIndex++;
    await loadProductsBySubCategory(selectedSubCategoryId);
    loadingMore = false;
    return true;
  }

  loadSubCategories(int _categoryId) async {
    if (isLoading) return;
    setState(() {
      isLoading = true;
      isLoadingProduct = true;
    });
    var params = {"page": "1", "limit": "0", "order": "rgt", "sort": "asc"};

    var response = await netGet(endPoint: "category", params: params);
    if (response["resp_code"] == "200") {
      var data = response["resp_data"]["data"];
      List tempCategories = data["list"];

      subCategories =
          tempCategories
              .where(
                (element) =>
                    element["is_sub_category"] == true &&
                    element["parent"]["id"] == _categoryId,
              )
              .toList();
      subCategories.insert(0, allSubCategory);
    } else {
      var ms = response["resp_data"]["message"];
      showToast(ms.toString(), context);
    }
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  loadProductsBySubCategory(int _subCategoryId, {bool isLoading = true}) async {
    // if (isLoadingProduct) return;

    setState(() {
      isLoadingProduct = isLoading;
    });

    var params = {
      "page": "$pageIndex",
      "limit": "10",
      "order": "name",
      "sort": "asc",
    };
    if (!widget.isParent) {
      params["sub_category_id"] = categoryId.toString();
    } else {
      params["category_id"] = categoryId.toString();
      params["sub_category_id"] = _subCategoryId.toString();
    }

    var response = await netGet(endPoint: "product", params: params);
    if (response["resp_code"] == "200") {
      var data = response["resp_data"]["data"];
      if (pageIndex == 1)
        products = data["list"];
      else
        products.addAll(data["list"]);
      isNoMore = products.length >= data["total"];
    } else {
      var ms = response["resp_data"]["message"];
      showToast(ms.toString(), context);
    }
    if (mounted) {
      setState(() {
        isLoadingProduct = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: white,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: CustomAppBar(
            subtitle:
                zipCode + " - " + context.watch<AccountInfoProvider>().name,
            subtitleIcon: Entypo.location_pin,
          ),
        ),
        bottomNavigationBar: getFooter(),
        body: getBody(),
      ),
    );
  }

  getSubCategory() {
    if (isLoading)
      return ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: 10,
        padding: EdgeInsets.only(top: 20),
        itemBuilder: (context, index) {
          return CircleCategoryLoading();
        },
      );
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(top: 25),
        child: Column(
          children: List.generate(subCategories.length, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 25),
              child: SubCategoryItem(
                activeItem: activeItem,
                index: index,
                data: subCategories[index],
                onTap: () {
                  // mix panel

                  dynamic dataPanel = {
                    "phone": userSession['phone_number'],
                    "sub_category": subCategories[index]['name'],
                  };

                  mixpanel.track(CLICK_SUB_CATEGORY, properties: dataPanel);

                  selectedSubCategoryId = subCategories[index]["id"];
                  setState(() {
                    pageIndex = 1;
                    activeItem = index;
                  });
                  loadProductsBySubCategory(selectedSubCategoryId);
                },
              ),
            );
          }),
        ),
      ),
    );
  }

  getProducts() {
    if (isLoadingProduct && pageIndex == 1)
      // return Container(
      //   child: Center(
      //     child: CustomCircularProgress(),
      //   ),
      // );
      return GridView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: 10,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 0.7,
        ),
        itemBuilder: (context, index) {
          return CategoryLoading();
        },
      );
    return (checkIsNullValue(products) || products.length == 0)
        ? Container(child: Center(child: Text("no_data").tr()))
        : GridView.builder(
            controller: scollController,
            padding: const EdgeInsets.all(10),
            itemCount: products.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.7,
            ),
            itemBuilder: (context, index) {
              var _product = products[index]["product"];
              return ProductCategoryItem(
                data: _product,
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
                      builder: (context) => ProductDetailPage(
                        data: {"product": products[index]},
                      ),
                    ),
                  );

                  setState(() {
                    isInPage = true;
                  });
                },
              );
            },
          );
  }

  Widget getBody() {
    var size = MediaQuery.of(context).size;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: size.width * 0.23,
          decoration: BoxDecoration(
            color: white,
            boxShadow: [
              BoxShadow(
                color: black.withOpacity(0.06),
                spreadRadius: 2,
                blurRadius: 5,
              ),
            ],
          ),
          child: getSubCategory(),
        ),
        Expanded(
          child: Flexible(
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: black.withOpacity(0.02),
                    spreadRadius: 2,
                    blurRadius: 5,
                  ),
                ],
              ),
              child: getProducts(),
            ),
          ),
        ),
      ],
    );
  }

  Widget getFooter() {
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
            padding: const EdgeInsets.only(
              left: 15,
              right: 15,
              top: 15,
              bottom: 20,
            ),
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
                      Navigator.of(context).pop();
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
                                    Text("cart".tr(), style: normalWhiteText),
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
                          onTap: () {},
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

  bool isAddingCart = false;
  addProductToCart(int _productId) async {
    if (isAddingCart) return;
    isAddingCart = true;
    var response = await netPatch(
      endPoint: "me/cart/product",
      params: {"product_id": _productId, "qty": 1},
    );
    if (response['resp_code'] == "200") {
      var temp = response["resp_data"]["data"];
      if (!checkIsNullValue(temp) && temp.containsKey('lines')) {
        var cart = temp;

        List cartItems = cart['lines'];
        context.read<CartProvider>().refreshCart(true);
        context.read<CartProvider>().refreshCartCount(cartItems.length);
        context.read<CartProvider>().refreshCartGrandTotal(
          double.parse(cart['total'].toString()),
        );
      }
    } else {}
    if (mounted)
      setState(() {
        isAddingCart = false;
      });
  }
}
