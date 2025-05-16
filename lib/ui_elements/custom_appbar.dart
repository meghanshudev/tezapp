import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:tezapp/helpers/styles.dart';
import 'package:tezapp/helpers/theme.dart';
import 'package:tezapp/helpers/utils.dart';
import 'package:tezapp/provider/credit_provider.dart';
import 'package:provider/provider.dart';
import 'package:tezapp/ui_elements/custom_search_button.dart';

class CustomAppBar extends StatefulWidget {
  const CustomAppBar(
      {Key? key, this.subtitle = "", this.subtitleIcon, this.onCallBack,this.isClick = false, this.onOpenSearch,this.onCloseSearch})
      : super(key: key);
  final String subtitle;
  final IconData? subtitleIcon;
  final bool isClick;
  final Function(dynamic)? onCallBack;
  final Function()? onOpenSearch;
  final Function()? onCloseSearch;

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  @override
  void initState() {
    super.initState();
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
                      Text(
                        "tez",
                        style: appBarText,
                      ),
                      SizedBox(width: 40,),
                      Flexible(child: getSearchButton(context , 
                        (){ 
                          if(widget.onOpenSearch != null) { widget.onOpenSearch!(); } 
                        } , 
                        (){ 
                           if(widget.onCloseSearch != null) { widget.onCloseSearch!(); } 
                        }) 
                      )
                      // checkIsNullValue(userSession['group'])
                      //     ? Container(
                      //         width: 145,
                      //         height: 35,
                      //         padding: EdgeInsets.symmetric(horizontal: 5),
                      //         decoration: BoxDecoration(
                      //             color: white,
                      //             borderRadius: BorderRadius.circular(10)),
                      //         child: Row(
                      //           // mainAxisAlignment: MainAxisAlignment.center,
                      //           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      //           children: [
                      //             Icon(
                      //               Icons.add,
                      //               size: 15,
                      //               color: greyLight,
                      //             ),
                      //             // SizedBox(
                      //             //   width: 5,
                      //             // ),
                      //             Flexible(
                      //               child: Text(
                      //                 "join_a_group",
                      //                 maxLines: 1,
                      //                 overflow: TextOverflow.ellipsis,
                      //                 style: TextStyle(
                      //                     fontSize: 15,
                      //                     fontWeight: FontWeight.w500,
                      //                     color: greyLight),
                      //               ).tr(),
                      //             )
                      //           ],
                      //         ),
                      //       )
                      //     : Container(
                      //         // width: 145,
                      //         height: 35,
                      //         decoration: BoxDecoration(
                      //             color: white,
                      //             borderRadius: BorderRadius.circular(10)),
                      //         child: Row(
                      //           mainAxisAlignment: MainAxisAlignment.center,
                      //           children: [
                      //             Padding(
                      //               padding:
                      //                   EdgeInsets.symmetric(horizontal: 15),
                      //               child: Text(
                      //                 userSession['group']['name'],
                      //                 style: TextStyle(
                      //                     fontSize: 15,
                      //                     fontWeight: FontWeight.w500,
                      //                     color: greyLight),
                      //               ),
                      //             )
                      //           ],
                      //         ),
                      //       )
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
                      widget.isClick ? 
                      Container(
                        width: MediaQuery.of(context).size.width * 0.7,
                        child: GestureDetector(
                          onTap: () async {
                            var result = await Navigator.pushNamed(
                                context, "/choose_location_page");
                            widget.onCallBack!(result);
                          },
                          child: Row(
                            children: [
                              if (widget.subtitleIcon != null)
                                Icon(
                                  widget.subtitleIcon,
                                  size: 28,
                                  color: primary.withOpacity(0.5),
                                ),
                              SizedBox(
                                width: 5,
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.6,
                                child: Text(
                                  widget.subtitle,
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
                      ) : Container(
                        width: MediaQuery.of(context).size.width * 0.7,
                        child: Row(
                          children: [
                            if (widget.subtitleIcon != null)
                              Icon(
                                widget.subtitleIcon,
                                size: 28,
                                color: primary.withOpacity(0.5),
                              ),
                            SizedBox(
                              width: 5,
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.6,
                              child: Text(
                                widget.subtitle,
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
                      Flexible(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(
                              MaterialCommunityIcons.wallet,
                              size: 25,
                              color: primary.withOpacity(0.5),
                            ),
                           
                            Text(
                              "₹"+ context.watch<CreditProvider>().balance.toString(),
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: black.withOpacity(0.5)),
                            )
                          ],
                        ),
                      ),
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
