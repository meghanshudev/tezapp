import 'package:flutter/material.dart';
import 'package:tez_mobile/helpers/utils.dart';
import 'package:tez_mobile/pages/Account/customer_support_page.dart';
import 'package:tez_mobile/pages/Account/edit_profile_page.dart';
import 'package:tez_mobile/pages/Account/general_info_page.dart';
import 'package:tez_mobile/pages/Account/open_source_page.dart';
import 'package:tez_mobile/pages/Account/order_detail_page.dart';
import 'package:tez_mobile/pages/Account/order_history_page.dart';
import 'package:tez_mobile/pages/Account/privacy_page.dart';
import 'package:tez_mobile/pages/Authentication/privacy_policy_login_page.dart';
import 'package:tez_mobile/pages/Account/suggest_page.dart';
import 'package:tez_mobile/pages/Authentication/term_condition_login_page.dart';
import 'package:tez_mobile/pages/Account/term_condition_page.dart';
import 'package:tez_mobile/pages/Account/wallet_page.dart';
import 'package:tez_mobile/pages/Authentication/add_name_page.dart';
import 'package:tez_mobile/pages/Authentication/enter_otp_page.dart';
import 'package:tez_mobile/pages/Authentication/login_page.dart';
import 'package:tez_mobile/pages/Cart/add_coupon_page.dart';
import 'package:tez_mobile/pages/Cart/cart_page.dart';
import 'package:tez_mobile/pages/Cart/order_confirmed_page.dart';
import 'package:tez_mobile/pages/Category/category_page.dart';
import 'package:tez_mobile/pages/Leader/leader_order_detail_page.dart';
import 'package:tez_mobile/pages/Leader/leader_view_detail_page.dart';
import 'package:tez_mobile/pages/Leader/member_request_page.dart';
import 'package:tez_mobile/pages/Location/choose_location_page.dart';
import 'package:tez_mobile/pages/Location/location_picker_page.dart';
import 'package:tez_mobile/pages/Product/product_detail_page.dart';
import 'package:tez_mobile/pages/Product/product_search_page.dart';
import 'package:tez_mobile/pages/Transaction/transaction_page.dart';
import 'package:tez_mobile/pages/UserGroup/create_user_group_page.dart';
import 'package:tez_mobile/pages/UserGroup/edit_user_group_page.dart';
import 'package:tez_mobile/pages/UserGroup/user_group_view_page.dart';
import 'package:tez_mobile/pages/UserGroup/youtube_link_page.dart';
import 'package:tez_mobile/root_app.dart';
import 'package:tez_mobile/pages/Guest/guest_root_app.dart';
import 'package:tez_mobile/pages/Guest/guest_category_page.dart';
import 'package:tez_mobile/pages/Guest/guest_product_detail_page.dart';
import 'package:tez_mobile/pages/Guest/guest_category_page.dart';
import 'package:tez_mobile/pages/UserGroup/user_group_page.dart';

import 'pages/Leader/leader_all_order_page.dart';
import 'pages/Leader/memeber_profile_page.dart';
import 'pages/UserGroup/create_user_group_name_page.dart';

Route<dynamic> generateRoute(RouteSettings setting) {
  final Map<String, dynamic> args = checkIsNullValue(setting.arguments)
      ? new Map<String, dynamic>()
      : setting.arguments as Map<String, dynamic>;
  switch (setting.name) {
    case "/root_app":
      return MaterialPageRoute(
        builder: (context) => RootApp(
          data: args,
        ),
      );
    case "/login_page":
      return MaterialPageRoute(builder: (context) => LoginPage());
    case "/enter_otp_page":
      return MaterialPageRoute(
        builder: (context) =>
            EnterOTPPage(data: args["data"] as Map<String, dynamic>),
      );
    case "/add_name_page":
      return MaterialPageRoute(builder: (context) => AddNamePage());
    case "/edit_profile_page":
      return MaterialPageRoute(builder: (context) => EditProfile());
    case "/order_history_page":
      return MaterialPageRoute(builder: (context) => OrderHistoryPage());
    case "/order_detail_page":
      return MaterialPageRoute(
          builder: (context) => OrderDetailPage(id: args['id']));
    case "/wallet_page":
      return MaterialPageRoute(builder: (context) => WalletPage());
    case "/category_page":
      return MaterialPageRoute(
        builder: (context) =>
            CategoryPage(data: args, isParent: args['isParent']),
      );
    case "/product_detail_page":
      return MaterialPageRoute(
        builder: (context) => ProductDetailPage(data: args),
      );
    case "/cart_page":
      return MaterialPageRoute(builder: (context) => CartPage());
    case "/customer_support_page":
      return MaterialPageRoute(builder: (context) => CustomerSupportPage());
    case "/suggest_page":
      return MaterialPageRoute(builder: (context) => SuggestPage());
    case "/general_info_page":
      return MaterialPageRoute(builder: (context) => GeneralInfoPage());
    case "/leader_view_detail_page":
      return MaterialPageRoute(
          settings: RouteSettings(name: "/leader_view_detail_page"),
          builder: (context) => LeaderViewDetailPage());
    case "/add_coupon_page":
      return MaterialPageRoute(
          builder: (context) => AddCouponPage(
                schedule: args['schedule'],
              ));
    case "/order_confirmed_page":
      return MaterialPageRoute(
          builder: (context) => OrderConfirmedPage(
                data: args,
              ));
    case "/member_profile_page":
      return MaterialPageRoute(
          builder: (context) => MemberProfilePage(
                data: args,
              ));
    case "/member_request_page":
      return MaterialPageRoute(
          builder: (context) => MemberRequestPage(
                data: args,
              ));
    case "/leader_all_order_page":
      return MaterialPageRoute(builder: (context) => LeaderAllOrderPage());
    case "/leader_order_detail_page":
      return MaterialPageRoute(
          builder: (context) => LeaderOrderDetailPage(
                data: args,
              ));
    case "/product_search_page":
      return MaterialPageRoute(builder: (context) => ProductSearchPage());
    case "/create_user_group_page":
      return MaterialPageRoute(
        builder: (context) => CreateUserGroupPage(
          data: args,
        ),
      );
    case "/create_user_group_name_page":
      return MaterialPageRoute(builder: (context) => CreateUserGroupNamePage());
    case "/user_group_view_page":
      return MaterialPageRoute(
        builder: (context) => UserGroupViewPage(),
      );
    case "/user_group_page":
      return MaterialPageRoute(
        builder: (context) => UserGroupPage(),
      );
    case "/edit_user_group_page":
      return MaterialPageRoute(builder: (context) => EditUserGroupPage());
    case "/choose_location_page":
      return MaterialPageRoute(builder: (context) => ChoooseLocationPage());
    case "/location_picker_page":
      return MaterialPageRoute(builder: (context) => LocationPickerPage());
    case "/privacy_page":
      return MaterialPageRoute(builder: (context) => PrivacyPage());
    case "/transaction_page":
      return MaterialPageRoute(builder: (context) => TransactionPage());
    case "/term_condition_page":
      return MaterialPageRoute(builder: (context) => TermConditionPage());
    case "youtube_link_page":
      return MaterialPageRoute(
        builder: (context) => YoutubeLinkPage(
          link: args['link'],
          title: args['title'],
        ),
      );
    case "/open_source_page":
      return MaterialPageRoute(builder: (context) => OpenSourcePage());
    case "/term_condition_login_page":
      return MaterialPageRoute(builder: (context) => TermConditionLoginPage());
    case "/privacy_policy_login_page":
      return MaterialPageRoute(builder: (context) => PrivacyPolicyLoginPage());
    case "/guest_category_page":
      return MaterialPageRoute(
          builder: (context) =>
              GuestCategoryPage(data: args, isParent: args['isParent']));
    case "/guest_root_app":
      return MaterialPageRoute(
        builder: (context) => GuestRootApp(
          data: args,
        ),
      );
    case "/guest_product_detail_page":
      return MaterialPageRoute(
        builder: (context) => GuestProductDetailPage(data: args),
      );
    default:
      return MaterialPageRoute(
        builder: (context) => Scaffold(
          body: Text("No Page"),
        ),
      );
  }
}
