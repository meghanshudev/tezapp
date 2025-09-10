import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:provider/provider.dart';
import 'package:tezchal/helpers/styles.dart';
import 'package:tezchal/helpers/theme.dart';
import 'package:tezchal/helpers/utils.dart';
import 'package:tezchal/provider/credit_provider.dart';

class CustomAppBarDynamic extends StatefulWidget {
  CustomAppBarDynamic({Key? key, required this.actionChild}) : super(key: key);
  final Widget actionChild;

  @override
  State<CustomAppBarDynamic> createState() => _CustomAppBarDynamicState();
}

class _CustomAppBarDynamicState extends State<CustomAppBarDynamic> {
  var zipCode = '';
  var deliverTo = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    deliverTo = !checkIsNullValue(userSession) ? userSession['name'] ?? "" : "";
    zipCode = !checkIsNullValue(userSession['zip_code'])
        ? userSession['zip_code']
        : "";
  }

  @override
  Widget build(BuildContext context) {
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
                      widget.actionChild
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
                      Expanded(
                        flex: 9,
                        child: Row(
                          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(
                              Entypo.location_pin,
                              size: 28,
                              color: primary.withOpacity(0.5),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Flexible(
                              child: Text(
                                "$zipCode - $deliverTo ",
                                maxLines: 1,
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: black.withOpacity(0.5)),
                              ),
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Expanded(
                        flex: 3,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(
                              MaterialCommunityIcons.wallet,
                              size: 25,
                              color: primary.withOpacity(0.5),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Flexible(
                              child: Text(
                                "₹ " +
                                    context
                                        .watch<CreditProvider>()
                                        .balance
                                        .toString(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: black.withOpacity(0.5)),
                              ),
                            )
                          ],
                        ),
                      ),
                      // Row(
                      //   children: [
                      //     Icon(
                      //       Entypo.location_pin,
                      //       size: 28,
                      //       color: primary.withOpacity(0.5),
                      //     ),
                      //     SizedBox(
                      //       width: 5,
                      //     ),
                      //     Text(
                      //       "deliver_to".tr() +  " $deliverTo $zipCode",
                      //       style: TextStyle(
                      //           fontSize: 15,
                      //           fontWeight: FontWeight.w500,
                      //           color: black.withOpacity(0.5)),
                      //     )
                      //   ],
                      // ),
                      // Row(
                      //   children: [
                      //     Icon(
                      //       MaterialCommunityIcons.wallet,
                      //       size: 25,
                      //       color: primary.withOpacity(0.5),
                      //     ),
                      //     SizedBox(
                      //       width: 10,
                      //     ),
                      //     Text(
                      //       "₹ "+context.watch<CreditProvider>().balance.toString(),
                      //       style: TextStyle(
                      //           fontSize: 15,
                      //           fontWeight: FontWeight.w500,
                      //           color: black.withOpacity(0.5)),
                      //     )
                      //   ],
                      // ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
