import 'package:flutter/cupertino.dart';

import '../helpers/theme.dart';
import 'content_placeholder.dart';

class ProductDetailLoading extends StatelessWidget {
  const ProductDetailLoading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ContentPlaceholder(
            height: 200,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ContentPlaceholder(
                  height: 20,
                  width: 200,
                  spacing: EdgeInsets.only(bottom: 0),
                ),
                ContentPlaceholder(
                  height: 10,
                  width: 80,
                ),
                Row(
                  children: [
                    Expanded(
                        flex: 2,
                        child: ContentPlaceholder(
                          height: 40,
                        )),
                    SizedBox(
                      width: 50,
                    ),
                    Expanded(
                        child: ContentPlaceholder(
                      height: 40,
                    )),
                  ],
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(3, (index) {
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Container(
                    width: 200,
                    padding: const EdgeInsets.all(10),
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              ContentPlaceholder(
                                  height: 10,
                                  spacing: EdgeInsets.only(bottom: 5, top: 10)),
                              ContentPlaceholder(
                                  height: 10,
                                  spacing: EdgeInsets.only(bottom: 0)),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 30,
                        ),
                        Expanded(
                            child: ContentPlaceholder(
                                height: 40,
                                spacing: EdgeInsets.only(bottom: 0, top: 10)))
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          ContentPlaceholder(
            height: 20,
            width: 200,
            spacing: EdgeInsets.only(left: 20),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(5, (index) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Container(
                    width: 160,
                    padding: const EdgeInsets.only(bottom: 5),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: white,
                        boxShadow: [
                          BoxShadow(
                              color: black.withOpacity(0.06),
                              spreadRadius: 5,
                              blurRadius: 10)
                        ]),
                    child: Column(
                      children: [
                        ContentPlaceholder(
                          height: 115,
                          spacing: EdgeInsets.zero,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ContentPlaceholder(
                                height: 10,
                                spacing: EdgeInsets.zero,
                              ),
                              ContentPlaceholder(
                                height: 10,
                                width: 50,
                                spacing: EdgeInsets.only(bottom: 5),
                              ),
                              Row(
                                children: [
                                  Expanded(
                                      child: Column(
                                    children: [
                                      ContentPlaceholder(
                                        height: 10,
                                        spacing: EdgeInsets.only(bottom: 0),
                                      ),
                                      ContentPlaceholder(
                                        height: 10,
                                        spacing: EdgeInsets.only(bottom: 0),
                                      ),
                                    ],
                                  )),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Expanded(
                                      flex: 2,
                                      child: ContentPlaceholder(
                                        height: 40,
                                        spacing: EdgeInsets.only(bottom: 0),
                                      )),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
