import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:tezapp/helpers/styles.dart';
import 'package:tezapp/helpers/theme.dart';
import 'package:tezapp/helpers/utils.dart';
import 'package:tezapp/pages/Guest/guest_custom_appbar.dart';
import 'package:tezapp/pages/Guest/guest_home_page.dart';

class GuestRootApp extends StatefulWidget {
  GuestRootApp({Key? key, this.data}) : super(key: key);
  final data;
  @override
  _GuestRootAppState createState() => _GuestRootAppState();
}

class _GuestRootAppState extends State<GuestRootApp> {
  int pageIndex = 0;

  // is in operation city
  bool isLoadingScreen = false;
  var zipCode = '';
  var deliverTo = '';
  bool isInPage = true;

  // load cart
  // check update location or not
  // bool isUpdateLocation = false;

  @override
  void initState() {
    // ignore: todo
    // TODO: implement initState
    super.initState();
    print("GUEST PAGE");

    pageIndex = !checkIsNullValue(widget.data) &&
            widget.data.containsKey("activePageIndex")
        ? widget.data["activePageIndex"]
        : pageIndex;
    initPage();
  }

  initPage() async {
    if (checkIsNullValue(userSession)) {
      await onSignOut(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    // String username = ;
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: white,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(120),
          child: GuestCustomAppBar(
            isClick: true,
            subtitle: "Guest Login",
            subtitleIcon: Entypo.location_pin,
          ),
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
        GuestHomePage(),
        Center(
          child: Text("Login to Start Shopping"),
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
              color: black.withOpacity(0.06), spreadRadius: 5, blurRadius: 10)
        ],
      ),
      child: Column(
        children: [
          // cart section
          Padding(
            padding:
                const EdgeInsets.only(left: 15, right: 15, top: 15, bottom: 20),
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
                      )
                    ],
                  ),
                  child: InkWell(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: Icon(
                        Icons.home,
                        color: black,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 15,
                ),
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
                              blurRadius: 10)
                        ]),
                    child: InkWell(
                        onTap: () async {
                          await Navigator.pushNamed(context, "/login_page");
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
                                SizedBox(
                                  width: 10,
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  color: white,
                                  size: 18,
                                )
                              ],
                            )
                          ],
                        )),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
