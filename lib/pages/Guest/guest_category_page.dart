import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:tezchal/helpers/constant.dart';
import 'package:tezchal/helpers/styles.dart';
import 'package:tezchal/helpers/theme.dart';
import 'package:tezchal/pages/Authentication/login_page.dart';
import 'package:tezchal/pages/Guest/guest_product_detail_page.dart';
import 'package:tezchal/ui_elements/category_loading.dart';
import 'package:tezchal/pages/guest/guest_custom_appbar.dart';
import 'package:tezchal/pages/Guest/guest_product_category_item.dart';
import 'package:tezchal/ui_elements/sub_category_item.dart';
import '../../helpers/network.dart';
import '../../helpers/utils.dart';
import '../../ui_elements/circle_category_loading.dart';

class GuestCategoryPage extends StatefulWidget {
  GuestCategoryPage({Key? key, required this.data, this.isParent = true})
    : super(key: key);
  final data;
  final bool isParent;

  @override
  _GuestCategoryPageState createState() => _GuestCategoryPageState();
}

class _GuestCategoryPageState extends State<GuestCategoryPage> {
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

  @override
  void initState() {
    super.initState();
    initPage();

    deliverTo = !checkIsNullValue(userSession) ? userSession['name'] ?? "" : "";
    zipCode =
        !checkIsNullValue(userSession['zip_code'])
            ? userSession['zip_code']
            : "";
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
          preferredSize: Size.fromHeight(120),
          child: GuestCustomAppBar(
            onOpenSearch: () {
              setState(() {
                isInPage = false;
              });
            },
            onCloseSearch: () {
              setState(() {
                isInPage = true;
              });
            },
            subtitle: "Guest Login",
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
      return ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: 10,
        padding: EdgeInsets.only(top: 20, left: 10),
        itemBuilder: (context, index) {
          return CategoryLoading();
        },
      );
    return (checkIsNullValue(products) || products.length == 0)
        ? Container(child: Center(child: Text("no_data").tr()))
        : SingleChildScrollView(
          controller: scollController,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20, left: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: List.generate(products.length, (index) {
                    var _product = products[index]["product"];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20, right: 10),
                      child: GuestProductCategoryItem(
                        data: _product,
                        onTap: () async {
                          setState(() {
                            isInPage = false;
                          });
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => GuestProductDetailPage(
                                    data: {"product": products[index]},
                                  ),
                            ),
                          );
                          setState(() {
                            isInPage = true;
                          });
                        },
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
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
        Flexible(
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
                      child: Icon(Icons.arrow_back_ios, color: black, size: 20),
                    ),
                  ),
                ),
                SizedBox(width: 15),
                Flexible(
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: primary,
                      boxShadow: [
                        BoxShadow(
                          color: black.withOpacity(0.06),
                          spreadRadius: 5,
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: InkWell(
                      onTap: () async {
                        await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Text(
                                "Login to Start Shopping",
                                style: meduimWhiteText,
                              ),
                              SizedBox(width: 10),
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
