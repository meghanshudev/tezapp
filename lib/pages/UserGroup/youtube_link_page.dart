import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tez_mobile/helpers/styles.dart';
import 'package:tez_mobile/helpers/theme.dart';
import 'package:tez_mobile/ui_elements/custom_footer.dart';
import 'package:webview_flutter/webview_flutter.dart';

class YoutubeLinkPage extends StatefulWidget {
  final String link;
  final String title;
  const YoutubeLinkPage({ Key? key,required this.link,required this.title }) : super(key: key);

  @override
  _YoutubeLinkPageState createState() => _YoutubeLinkPageState();
}

class _YoutubeLinkPageState extends State<YoutubeLinkPage> {
  @override
   void initState() {
     super.initState();
     // Enable virtual display.
     if (Platform.isAndroid) WebView.platform = AndroidWebView();
   }
   
  @override
   Widget build(BuildContext context) {
     return Scaffold(
      //  appBar: AppBar(),
       body: WebView(
         javascriptMode: JavascriptMode.unrestricted,
         initialUrl: widget.link,
       ),
        bottomNavigationBar: getFooter(),
     );
   }
   Widget getFooter() {
    var size = MediaQuery.of(context).size;
    return Container(
      width: double.infinity,
      height: 90,
      decoration: BoxDecoration(color: white, boxShadow: [
        BoxShadow(
            color: black.withOpacity(0.06), spreadRadius: 5, blurRadius: 10)
      ]),
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
                            blurRadius: 10)
                      ]),
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: Icon(
                        Icons.arrow_back_ios,
                        color: black,
                        size: 18,
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
                          color: white,
                          boxShadow: [
                            BoxShadow(
                                color: black.withOpacity(0.06),
                                spreadRadius: 5,
                                blurRadius: 10)
                          ]),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 5, right: 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              widget.title,
                              style: normalBlackText,
                            ),
                          ],
                        ),
                      ),
                    ))
              ],
            ),
          )
        ],
      ),
    );
  }
}