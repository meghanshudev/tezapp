import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:tezapp/helpers/utils.dart';
import '../helpers/theme.dart';

class ActiveDot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 3, right: 3),
      height: 10,
      width: 10,
      decoration: BoxDecoration(
        color: primary,
        borderRadius: BorderRadius.circular(50),
      ),
    );
  }
}

class InactiveDot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 3, right: 3),
      height: 10,
      width: 10,
      decoration: BoxDecoration(
        color: white.withOpacity(.5),
        borderRadius: BorderRadius.circular(50),
      ),
    );
  }
}

class SliderWidget extends StatefulWidget {
  final List items;
  const SliderWidget({required this.items, Key? key}) : super(key: key);

  @override
  _SliderWidgetState createState() => _SliderWidgetState();
}

class _SliderWidgetState extends State<SliderWidget> {
  int activeIndex = 0;

  setActiveDot(index) {
    setState(() {
      activeIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Stack(
      alignment: Alignment.topCenter,
      children: <Widget>[
        Container(
          child: CarouselSlider(
            options: CarouselOptions(
              autoPlayInterval: Duration(seconds: 5),
              autoPlay: true,
              height: getHeight(size.width-40,"1280:421"),
              autoPlayCurve: Curves.fastLinearToSlowEaseIn,
              autoPlayAnimationDuration: Duration(seconds: 2),
              viewportFraction: 1,
              onPageChanged: (index, reason) {
                setActiveDot(index);
              },
            ),
            items: List.generate(
              this.widget.items.length,
              (index) {
                return Padding(
                  padding: const EdgeInsets.only(left: 5,right: 5),
                  child: Container(
                    decoration: BoxDecoration(
                      color: white,
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                        image: NetworkImage(this.widget.items[index]['image']),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        Positioned(
          bottom: 5,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.items.length,
              (idx) {
                return activeIndex == idx ? ActiveDot() : InactiveDot();
              },
            ),
          ),
        ),
      ],
    );
  }
}
