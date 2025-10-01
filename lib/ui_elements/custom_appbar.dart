import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:tezchal/helpers/styles.dart';
import 'package:tezchal/helpers/theme.dart';
import 'package:tezchal/helpers/utils.dart';
import 'package:tezchal/pages/Location/choose_location_page.dart';
import 'package:tezchal/provider/credit_provider.dart';
import 'package:provider/provider.dart';
import 'package:tezchal/ui_elements/custom_search_button.dart';

class CustomAppBar extends StatefulWidget {
  const CustomAppBar({
    Key? key,
    this.subtitle = "",
    this.title,
    this.subtitleIcon,
    this.onCallBack,
    this.isClick = false,
    this.isWidget = false,
  }) : super(key: key);
  final String subtitle;
  final String? title;
  final IconData? subtitleIcon;
  final bool isClick;
  final bool isWidget;
  final Function(dynamic)? onCallBack;

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
      flexibleSpace: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (!widget.isWidget)
                    widget.isClick
                        ? Container(
                            width: MediaQuery.of(context).size.width * 0.4,
                            child: GestureDetector(
                              onTap: () async {
                                var result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChoooseLocationPage(),
                                  ),
                                );
                                widget.onCallBack!(result);
                              },
                              child: Row(
                                children: [
                                  if (widget.subtitleIcon != null)
                                    Icon(
                                      widget.subtitleIcon,
                                      size: 28,
                                      color: white,
                                    ),
                                  SizedBox(width: 5),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.3,
                                    child: Text(
                                      widget.subtitle,
                                      maxLines: 1,
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w500,
                                        color: white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : Container(
                            width: MediaQuery.of(context).size.width * 0.4,
                            child: Row(
                              children: [
                                if (widget.subtitleIcon != null)
                                  Icon(widget.subtitleIcon,
                                      size: 28, color: white),
                                SizedBox(width: 5),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width *
                                      0.3,
                                  child: Text(
                                    widget.subtitle,
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w500,
                                      color: white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                  if (!widget.isWidget)
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(
                            MaterialCommunityIcons.wallet,
                            size: 25,
                            color: white,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            "₹" +
                                context
                                    .watch<CreditProvider>()
                                    .balance
                                    .toString(),
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: white,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            if (widget.isWidget)
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (widget.title != null)
                      Text(
                        widget.title!,
                        style: normalBoldWhiteTitle,
                      ),
                  ],
                ),
              ),
            if (widget.isWidget)
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.subtitle,
                      style: smallMediumWhiteText,
                    ),
                  ],
                ),
              )
          ],
        ),
      ),
    );
  }
}
