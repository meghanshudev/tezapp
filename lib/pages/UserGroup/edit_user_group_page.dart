import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:geocode/geocode.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:line_icons/line_icons.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tezapp/helpers/constant.dart';
import 'package:tezapp/helpers/network.dart';
import 'package:tezapp/helpers/styles.dart';
import 'package:tezapp/helpers/theme.dart';
import 'package:tezapp/helpers/utils.dart';
import 'package:tezapp/provider/has_group.dart';
import 'package:tezapp/ui_elements/custom_appbar.dart';
import 'package:tezapp/ui_elements/custom_primary_button.dart';
import 'package:tezapp/ui_elements/custom_textfield.dart';
import 'package:tezapp/ui_elements/edit_user_group_loading.dart';

import '../../ui_elements/custom_footer_buttons.dart';
import 'package:http/http.dart' as http;

class EditUserGroupPage extends StatefulWidget {
  const EditUserGroupPage({Key? key}) : super(key: key);

  @override
  State<EditUserGroupPage> createState() => _EditUserGroupPageState();
}

class _EditUserGroupPageState extends State<EditUserGroupPage> {
  List groupMember = [];

  int orderDay = 0;
  int orderTotal = 0;
  var groupData = {};
  var groupDatMember = '';

  bool isLoadingButton = false;

  TextEditingController groupNameController = TextEditingController();
  TextEditingController currentLocationController = TextEditingController();
  TextEditingController zipCodeController = TextEditingController();
  TextEditingController provinceController = TextEditingController();
  TextEditingController orderDayController = TextEditingController();

  //
  List orderDays = [
    {"id": 1, "name": "Monday"},
    {"id": 2, "name": "Tuesday"},
    {"id": 3, "name": "Wednesday"},
    {"id": 4, "name": "Thursday"},
    {"id": 5, "name": "Friday"},
    {"id": 6, "name": "Saturday"},
    {"id": 7, "name": "Sundy"},
  ];
  int orderIndex = 0;
  int orderDayIndex = 0;
  bool isLoading = false;

  double lat = 0.0;
  double lng = 0.0;

  var zipCode = '';
  var deliverTo = '';

  String groupProfile = '';
  // update profile
  File tempImage = File('');
  String profileUrl = "";
  bool isLoadingPhotoFromDevice = false;
  bool isUploadingPhoto = false;

  late Mixpanel mixpanel;

  @override
  void initState() {
    super.initState();
    getMember();
    initPage();

    deliverTo = !checkIsNullValue(userSession) ? userSession['name'] ?? "" : "";
    zipCode = !checkIsNullValue(userSession['zip_code'])
        ? userSession['zip_code']
        : "";

    initMixpanel();
  }

  Future<void> initMixpanel() async {
    mixpanel = await Mixpanel.init(MIX_PANEL, optOutTrackingDefault: false, trackAutomaticEvents: true);
  }

  initPage() {
    groupNameController.text = userSession["group"]['name'] ?? "";
    zipCodeController.text = userSession["group"]['zip_code'] ?? "";
    currentLocationController.text = userSession['group']['address'] ?? "";
  }

  getMember() async {
    setState(() {
      isLoading = true;
    });
    if (!checkIsNullValue(userSession['group'])) {
      var groupId = userSession['group']['id'];
      var response = await netGet(endPoint: "group/$groupId");
      if (response["resp_code"] == "200") {
        List members = response['resp_data']['data']['members'] ?? [];
        setState(() {
          groupMember = members;
          groupData = response['resp_data']['data'];
          orderDay = response['resp_data']['data']['order_day'];
          orderTotal = response['resp_data']['data']['total_group_orders'];
          orderDayController.text = getOrderDay(orderDay);
          orderDayIndex = orderDay;
          groupProfile =
              !checkIsNullValue(response['resp_data']['data']['image'])
                  ? response['resp_data']['data']['image'].toString()
                  : DEFAULT_GROUP_IMAGE;
        });
        if (groupMember.length == 1) {
          setState(() {
            groupDatMember =
                groupMember.length.toString() + " " + "member".tr();
          });
        } else {
          setState(() {
            groupDatMember =
                groupMember.length.toString() + " " + "members".tr();
          });
        }
      }
    }
    context.read<HasGroupProvider>().refreshGroupLeaderProfile(groupProfile);
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: white,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(120),
          child: CustomAppBar(
            subtitle: "$zipCode - $deliverTo",
            subtitleIcon: Entypo.location_pin,
          ),
        ),
        body: getBody(),
        bottomNavigationBar: getFooter(),
      ),
    );
  }

  Widget getBody() {
    var size = MediaQuery.of(context).size;
    if (isLoading) {
      // return Center(
      //     child: CustomCircularProgress(
      //   strokeWidth: 3,
      // ));
      return EditUserGroupLoading();
    }
    return SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(
        height: 5,
      ),
      Padding(
          padding: const EdgeInsets.all(15),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              "edit_group",
              style: normalBoldBlackTitle,
            ).tr(),
            SizedBox(
              height: 2,
            ),
            Text(
              userSession['group']['name'] +
                  " •  $groupDatMember  •  $orderTotal " +
                  "orders".tr(),
              style: smallMediumGreyText,
            ),
            SizedBox(
              height: 25,
            ),
            Row(
              children: [
                // Container(
                //   width: 100,
                //   height: 100,
                //   decoration: BoxDecoration(
                //       color: placeHolderColor, shape: BoxShape.circle),
                // ),
                Material(
                  borderRadius: BorderRadius.circular(50),
                  child: InkWell(
                      onTap: () {
                        onUploadProfile();
                      },
                      borderRadius: BorderRadius.circular(50),
                      child: Stack(
                        children: <Widget>[
                          displayProfile(),
                          Positioned(
                            bottom: 8,
                            left: 0,
                            right: 0,
                            child: Icon(
                              LineIcons.camera,
                              color: white,
                            ),
                          )
                        ],
                      )),
                ),
                SizedBox(
                  width: 20,
                ),
                Flexible(
                  child: Container(
                    width: size.width,
                    child: Column(
                      children: [
                        Container(
                          width: size.width,
                          child: CustomTextField(
                            controller: groupNameController,
                            hintText: "enter_group_name".tr(),
                          ),
                        ),
                        // SizedBox(
                        //   height: 15,
                        // ),
                        // Container(
                        //   width: size.width,
                        //   height: 40,
                        //   decoration: BoxDecoration(
                        //       color: whatsAppColor,
                        //       borderRadius: BorderRadius.circular(10)),
                        //   child: Padding(
                        //     padding: const EdgeInsets.only(left: 15, right: 15),
                        //     child: Row(
                        //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //       children: [
                        //         Icon(
                        //           LineIcons.whatSApp,
                        //           color: white,
                        //           size: 25,
                        //         ),
                        //         Text(
                        //           "Share on WhatsApp",
                        //           style: normalWhiteText,
                        //         ),
                        //       ],
                        //     ),
                        //   ),
                        // )
                      ],
                    ),
                  ),
                )
              ],
            ),
            SizedBox(
              height: 30,
            ),

            // Text(
            //   "address",
            //   style: meduimBlackText,
            // ).tr(),
            // SizedBox(
            //   height: 5,
            // ),
            // Text(
            //   "this_is_where_all_orders_from_all_group_members_will_be_delivered",
            //   style: smallMediumGreyText,
            // ).tr(),
            // SizedBox(
            //   height: 20,
            // ),
            // Row(
            //   children: [
            //     Flexible(
            //       child: Container(
            //         height: 50,
            //         decoration: BoxDecoration(
            //             borderRadius: BorderRadius.circular(10),
            //             border: Border.all(color: placeHolderColor)),
            //         child: Padding(
            //           padding: const EdgeInsets.only(left: 15, right: 15),
            //           child: TextField(
            //             readOnly: true,
            //             controller: zipCodeController,
            //             cursorColor: black,
            //             decoration: InputDecoration(
            //                 border: InputBorder.none,
            //                 hintText: "enter_zip_code".tr()),
            //           ),
            //         ),
            //       ),
            //     ),
            //     SizedBox(
            //       width: 20,
            //     ),
            //     // Flexible(
            //     //   flex: 2,
            //     //   child: Container(
            //     //     height: 50,
            //     //     decoration: BoxDecoration(
            //     //         borderRadius: BorderRadius.circular(10),
            //     //         border: Border.all(color: placeHolderColor)),
            //     //     child: Padding(
            //     //       padding: const EdgeInsets.only(left: 15, right: 10),
            //     //       child: Row(
            //     //         children: [
            //     //           Flexible(
            //     //             child: TextField(
            //     //               cursorColor: black,
            //     //               decoration: InputDecoration(
            //     //                   border: InputBorder.none, hintText: "Nagpur"),
            //     //             ),
            //     //           ),
            //     //           Icon(Icons.keyboard_arrow_down)
            //     //         ],
            //     //       ),
            //     //     ),
            //     //   ),
            //     // ),
            //     Flexible(
            //       flex: 2,
            //       child: Container(
            //         // width: size.width,
            //         height: 50,
            //         decoration: BoxDecoration(
            //             borderRadius: BorderRadius.circular(10),
            //             border: Border.all(color: placeHolderColor)),
            //         child: Padding(
            //           padding: const EdgeInsets.only(left: 15, right: 5),
            //           child: Row(
            //             children: [
            //               Flexible(
            //                 child: TextField(
            //                   readOnly: true,
            //                   controller: currentLocationController,
            //                   cursorColor: black,
            //                   decoration: InputDecoration(
            //                       border: InputBorder.none,
            //                       hintText: "enter_address".tr()),
            //                 ),
            //               ),
            //               SizedBox(
            //                 width: 20,
            //               ),
            //               IconButton(
            //                   onPressed: () async {
            //                     getCurrentLocation();
            //                   },
            //                   icon: Icon(
            //                     MaterialIcons.my_location,
            //                     color: primary,
            //                   ))
            //             ],
            //           ),
            //         ),
            //       ),
            //     ),
            //   ],
            // ),
            // SizedBox(
            //   height: 20,
            // ),
            // Text(
            //   "orders_every",
            //   style: meduimBlackText,
            // ).tr(),
            // SizedBox(
            //   height: 5,
            // ),
            // Text(
            //   "this_is_the_day_all_the_orders_from_your_members_are_accepted_by_tez",
            //   style: smallMediumGreyText,
            // ).tr(),
            // SizedBox(
            //   height: 20,
            // ),
            // Container(
            //   height: 50,
            //   decoration: BoxDecoration(
            //       borderRadius: BorderRadius.circular(10),
            //       border: Border.all(color: placeHolderColor)),
            //   child: Padding(
            //     padding: const EdgeInsets.only(left: 15, right: 10),
            //     child: Row(
            //       children: [
            //         Flexible(
            //           child: TextField(
            //             controller: orderDayController,
            //             onTap: () {
            //               selectDays();
            //             },
            //             readOnly: true,
            //             cursorColor: black,
            //             decoration: InputDecoration(border: InputBorder.none),
            //           ),
            //         ),
            //         Icon(Icons.keyboard_arrow_down)
            //       ],
            //     ),
            //   ),
            // ),
            GestureDetector(
              onTap: () {
                deleteGroup();
                // Navigator.of(context).pushNamed('/leader_view_detail_page');
              },
              child: CustomPrimaryButton(
                text: "delete_group".tr(),
              ),
            ),
            SizedBox(
              height: 20,
            ),
          ]))
    ]));
  }

  deleteGroup() async {
    confirmAlert(context, des: "delete_group_des".tr(), onCancel: () {
      Navigator.pop(context);
    }, onConfirm: () async {
      var groupId = userSession['group']['id'];

      var response = await netDelete(
          isUserToken: true, endPoint: "group/$groupId", params: {});

      if (mounted) {
        if (response['resp_code'] == "200") {
          // set refresh group
          context.read<HasGroupProvider>().refreshGroup(false);
          // set new session for group
          userSession['group'] = null;
          await setStorage(STORAGE_USER, userSession);

          await getStorageUser();

          showToast("you_have_left_a_group_successfully".tr(), context);

          Navigator.pop(context);
          //
          Navigator.pushNamedAndRemoveUntil(
            context,
            "/root_app",
            (route) => false,
            arguments: {"activePageIndex": 1},
          );
        } else {
          Navigator.pop(context);
          notifyAlert(context,
              desc: response['resp_data']['message'].toString(),
              btnTitle: "Ok!", onConfirm: () {
            Navigator.pop(context);
          });
        }
      }
    });
  }

  Widget displayProfile() {
    if (tempImage.path == '') {
      return Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: placeHolderColor,
            image: DecorationImage(
                image: NetworkImage(groupProfile), fit: BoxFit.cover)),
      );
    } else {
      return new ClipRRect(
        borderRadius: new BorderRadius.circular(100 / 2),
        child: Container(
          width: 100,
          height: 100,
          child: isUploadingPhoto
              ? Image.file(
                  tempImage,
                  fit: BoxFit.cover,
                  colorBlendMode: BlendMode.dstATop,
                )
              : Image.file(
                  tempImage,
                  fit: BoxFit.cover,
                ),
        ),
      );
    }
  }

  Widget getFooter() {
    return CustomFooterButtons(
      isLoading: isLoadingButton,
      proceedTitle: "save_changes".tr(),
      onTapProceed: () {
        updateGroup();
      },
      onTapBack: () {
        Navigator.of(context).pop();
      },
    );
  }

  updateGroup() async {
    if (isLoadingButton) return;
    setState(() {
      isLoadingButton = true;
    });

    var param = {
      "name": groupNameController.text,
      "address": currentLocationController.text,
      "lat": lat,
      "lng": lng,
      "zip_code": zipCodeController.text,
      "order_day": orderDayIndex,
      "image": tempImage.path == ''
          ? await networkImageToBase64(groupProfile)
          : HEADER_IMAGE_BASE64 + base64Encode(tempImage.readAsBytesSync()),
    };

    var groupId = userSession['group']['id'];

    var response = await netPut(
      isUserToken: true,
      endPoint: "group/$groupId",
      params: param,
    );

    if (mounted) {
      if (response['resp_code'] == "200") {
        // set refresh group
        context.read<HasGroupProvider>().refreshGroup(true);

        context.read<HasGroupProvider>().refreshOrderDay(orderDayIndex);

        var userGroupProfile = response['resp_data']['data']['image'];

        context
            .read<HasGroupProvider>()
            .refreshGroupLeaderProfile(userGroupProfile);

        // set new session for group
        var result = response['resp_data']['data'];
        userSession['group'] = result;

        await setStorage(STORAGE_USER, userSession);

        await getStorageUser();

        notifyAlert(context,
            desc: "you_have_updated_a_group_successfully".tr(),
            btnTitle: "Ok", onConfirm: () {
          Navigator.pop(context);
          //
        });
      } else {
        notifyAlert(context,
            desc: response['resp_data']['message'],
            btnTitle: "Ok", onConfirm: () {
          Navigator.pop(context);
        });
      }

      setState(() {
        isLoadingButton = false;
      });
    }
  }

  Future<Position> locateUser() async {
    return await determineUserLocationPosition(context);
  }

  selectDays() async {
    int tempIndex = orderDay - 1;
    await showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: 230.0,
            child: Column(
              children: <Widget>[
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.only(left: 10, right: 10),
                  height: 40,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Text("cancel",
                                style: TextStyle(color: primary, fontSize: 16))
                            .tr(),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            orderIndex = tempIndex;
                            orderDayController.text =
                                orderDays[orderIndex]['name'];
                            orderDayIndex = orderDays[orderIndex]['id'];
                          });

                          Navigator.of(context).pop();
                        },
                        child: Text("done",
                                style: TextStyle(color: primary, fontSize: 16))
                            .tr(),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: CupertinoPicker(
                    scrollController: new FixedExtentScrollController(
                      initialItem: tempIndex,
                    ),
                    itemExtent: 32.0,
                    onSelectedItemChanged: (int index) {
                      setState(() {
                        tempIndex = index;
                      });
                    },
                    children: List.generate(orderDays.length, (index) {
                      return new Center(
                        child: new Text(
                          orderDays[index]['name'],
                          style: TextStyle(color: black),
                        ),
                      );
                    }),
                  ),
                )
              ],
            ),
          );
        });
  }

  getCurrentLocation() async {
    // get current lat and lng
    var currentLocation = await determineUserLocationPosition(context);

    if (mounted) {
      setState(() {
        lat = currentLocation.latitude;
        lng = currentLocation.longitude;
      });
    }
    var result = {"lat": lat, "lng": lng};

    // mix panel
    dynamic dataPanel = {
      "phone": userSession['phone_number'],
      "location": {"lat": lat, "lng": lng}
    };

    mixpanel.track(CLICK_PERMISSION_LOCATION, properties: dataPanel);

    getNewLocation(result);
  }

  getNewLocation(result) async {
    double lat = result['lat'];
    double lng = result['lng'];

    var apiURL =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$googleKeyApi";

    var url = Uri.parse(apiURL);

    final response = await http.get(url);
    if (response.statusCode == 200) {
      var result = jsonDecode(response.body);
      List items = result['results'][0]['address_components'] ?? [];

      var postalCode = '';
      if (items.length > 0) {
        items.forEach((result) {
          if (result['types'][0] == "postal_code") {
            postalCode = result['long_name'];
          }
        });
      }
      if (checkIsNullValue(postalCode)) {
        postalCode = DEFAULT_ZIP_CODE;
      }

      var streetAddress = result['results'][0]['formatted_address'];

      setState(() {
        currentLocationController.text = streetAddress;
        zipCodeController.text = postalCode;
      });
    } else {
      setState(() {
        currentLocationController.text = "";
        zipCodeController.text = DEFAULT_ZIP_CODE;
      });
    }
  }

  // Upload Profile
  void showDemoActionSheet({context, child}) {
    showCupertinoModalPopup<String>(
      context: context,
      builder: (BuildContext context) => child,
    );
  }

  void onUploadProfile() {
    FocusScope.of(context).unfocus();

    showDemoActionSheet(
      context: context,
      child: CupertinoActionSheet(
        title: Text('select_a_group_profile').tr(),
        actions: <Widget>[
          CupertinoActionSheetAction(
              child: Text(
                'open_gallery',
                style: TextStyle(color: primary),
              ).tr(),
              onPressed: () {
                getImageFromGallery();
              }),
          CupertinoActionSheetAction(
              child: Text(
                'take_a_photo',
                style: TextStyle(color: primary),
              ).tr(),
              onPressed: () {
                getImageFromCamera();
              }),
        ],
      ),
    );
  }

  Future getImageFromGallery() async {
    setState(() {
      isLoadingPhotoFromDevice = true;
    });
    Navigator.of(context, rootNavigator: true).pop("Discard");
    final ImagePicker _picker = ImagePicker();
    // Pick an image
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    // final image = await _picker.getImage(source: ImageSource.gallery);

    if (mounted) {
      if (image != null) {
        File newFile = File(image.path);

        File afterCompress = (await getFileImage(newFile)) as File;
        setState(() {
          tempImage = afterCompress;
          isLoadingPhotoFromDevice = false;
        });
      } else {
        setState(() {
          tempImage = File('');
          isLoadingPhotoFromDevice = false;
        });
      }
    }
  }

  Future getImageFromCamera() async {
    setState(() {
      isLoadingPhotoFromDevice = true;
    });
    Navigator.of(context, rootNavigator: true).pop("Discard");
    final ImagePicker _picker = ImagePicker();
    // Pick an image
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);

    if (mounted) {
      if (image != null) {
        File newFile = File(image.path);

        File afterCompress = (await getFileImage(newFile)) as File;
        setState(() {
          tempImage = afterCompress;
          isLoadingPhotoFromDevice = false;
        });
      } else {
        setState(() {
          tempImage = File('');
          isLoadingPhotoFromDevice = false;
        });
      }
    }
  }
}
