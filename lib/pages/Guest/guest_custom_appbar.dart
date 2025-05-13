import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:tez_mobile/helpers/styles.dart';
import 'package:tez_mobile/helpers/theme.dart';
import 'package:tez_mobile/provider/credit_provider.dart';
import 'package:provider/provider.dart';

class GuestCustomAppBar extends StatefulWidget {
  const GuestCustomAppBar(
      {Key? key,
      this.subtitle = "",
      this.subtitleIcon,
      this.onCallBack,
      this.isClick = false,
      this.onOpenSearch,
      this.onCloseSearch})
      : super(key: key);
  final String subtitle;
  final IconData? subtitleIcon;
  final bool isClick;
  final Function(dynamic)? onCallBack;
  final Function()? onOpenSearch;
  final Function()? onCloseSearch;

  @override
  State<GuestCustomAppBar> createState() => _GuestCustomAppBarState();
}

class _GuestCustomAppBarState extends State<GuestCustomAppBar> {
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
                      SizedBox(
                        width: 40,
                      ),
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
                      Container(
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
                              "₹" +
                                  context
                                      .watch<CreditProvider>()
                                      .balance
                                      .toString(),
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
