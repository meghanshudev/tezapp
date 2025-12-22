import 'package:flutter/material.dart';
import 'package:tezchal/helpers/utils.dart';
import 'package:tezchal/pages/Account/customer_support_page.dart';
import 'package:tezchal/pages/Account/edit_profile_page.dart';
import 'package:tezchal/pages/Account/general_info_page.dart';
import 'package:tezchal/pages/Account/open_source_page.dart';
import 'package:tezchal/pages/Account/order_detail_page.dart';
import 'package:tezchal/pages/Account/order_history_page.dart';
import 'package:tezchal/pages/Account/privacy_page.dart';
import 'package:tezchal/pages/Account/suggest_page.dart';
import 'package:tezchal/pages/Account/term_condition_page.dart';
import 'package:tezchal/pages/Account/wallet_page.dart';
import 'package:tezchal/pages/Authentication/add_name_page.dart';
import 'package:tezchal/pages/Authentication/enter_otp_page.dart';
import 'package:tezchal/pages/Authentication/login_page.dart';
import 'package:tezchal/pages/Authentication/privacy_policy_login_page.dart';
import 'package:tezchal/pages/Authentication/term_condition_login_page.dart';
import 'package:tezchal/pages/Cart/add_coupon_page.dart';
import 'package:tezchal/pages/Cart/cart_page.dart';
import 'package:tezchal/pages/Cart/order_confirmed_page.dart';
import 'package:tezchal/pages/Category/category_page.dart';
import 'package:tezchal/pages/Guest/guest_category_page.dart';
import 'package:tezchal/pages/Guest/guest_product_detail_page.dart';
import 'package:tezchal/pages/Guest/guest_root_app.dart';
import 'package:tezchal/pages/Leader/leader_order_detail_page.dart';
import 'package:tezchal/pages/Leader/leader_view_detail_page.dart';
import 'package:tezchal/pages/Leader/member_request_page.dart';
import 'package:tezchal/pages/Location/choose_location_page.dart';
import 'package:tezchal/pages/Location/location_picker_page.dart';
import 'package:tezchal/pages/Product/product_detail_page.dart';
import 'package:tezchal/pages/Product/product_search_page.dart';
import 'package:tezchal/pages/Transaction/transaction_page.dart';
import 'package:tezchal/pages/UserGroup/create_user_group_page.dart';
import 'package:tezchal/pages/UserGroup/edit_user_group_page.dart';
import 'package:tezchal/pages/UserGroup/user_group_page.dart';
import 'package:tezchal/pages/UserGroup/user_group_view_page.dart';
import 'package:tezchal/pages/UserGroup/youtube_link_page.dart';
import 'package:tezchal/root_app.dart';
import 'pages/Leader/leader_all_order_page.dart';
import 'pages/Leader/memeber_profile_page.dart';
import 'pages/UserGroup/create_user_group_name_page.dart';
import 'package:flutter/material.dart';

// Import your pages

Route<dynamic> generateRoute(RouteSettings settings) {
  final Map<String, dynamic> args = (settings.arguments is Map<String, dynamic>)
      ? settings.arguments as Map<String, dynamic>
      : <String, dynamic>{};

  switch (settings.name) {
    case '/root_app':
      return MaterialPageRoute(
        builder: (context) => RootApp(data: args),
      );

    case '/guest_root_app':
      return MaterialPageRoute(
        builder: (context) => GuestRootApp(data: args),
      );

    case '/login_page':
      return MaterialPageRoute(builder: (_) => const LoginPage());

    case '/enter_otp_page':
      return MaterialPageRoute(
        builder: (_) => EnterOTPPage(data: args),
      );

    case '/add_name_page':
      return MaterialPageRoute(builder: (_) => AddNamePage());

    case '/edit_profile_page':
      return MaterialPageRoute(builder: (_) => EditProfile());

    case '/order_history_page':
      return MaterialPageRoute(builder: (_) => OrderHistoryPage());

    case '/order_detail_page':
      return MaterialPageRoute(
        builder: (_) => OrderDetailPage(id: args['id']),
      );

    case '/wallet_page':
      return MaterialPageRoute(builder: (_) => WalletPage());

    case '/cart_page':
      return MaterialPageRoute(builder: (_) => CartPage());

    case '/category_page':
      return MaterialPageRoute(
        builder: (_) => CategoryPage(
          data: args,
          isParent: args['isParent'] ?? false,
        ),
      );

    case '/product_detail_page':
      return MaterialPageRoute(
        builder: (_) => ProductDetailPage(data: args),
      );

    case '/customer_support_page':
      return MaterialPageRoute(builder: (_) => CustomerSupportPage());

    case '/suggest_page':
      return MaterialPageRoute(builder: (_) => SuggestPage());

    case '/general_info_page':
      return MaterialPageRoute(builder: (_) => GeneralInfoPage());

    case '/leader_view_detail_page':
      return MaterialPageRoute(builder: (_) => LeaderViewDetailPage());

    case '/add_coupon_page':
      return MaterialPageRoute(
        builder: (_) => AddCouponPage(schedule: args['schedule']),
      );

    case '/order_confirmed_page':
      return MaterialPageRoute(
        builder: (_) => OrderConfirmedPage(orderId: args['orderId']),
      );

    case '/member_profile_page':
      return MaterialPageRoute(
        builder: (_) => MemberProfilePage(data: args),
      );

    case '/member_request_page':
      return MaterialPageRoute(
        builder: (_) => MemberRequestPage(data: args),
      );

    case '/leader_all_order_page':
      return MaterialPageRoute(builder: (_) => LeaderAllOrderPage());

    case '/leader_order_detail_page':
      return MaterialPageRoute(
        builder: (_) => LeaderOrderDetailPage(data: args),
      );

    case '/product_search_page':
      return MaterialPageRoute(builder: (_) => ProductSearchPage());

    case '/create_user_group_page':
      return MaterialPageRoute(
        builder: (_) => CreateUserGroupPage(data: args),
      );

    case '/create_user_group_name_page':
      return MaterialPageRoute(builder: (_) => CreateUserGroupNamePage());

    case '/user_group_view_page':
      return MaterialPageRoute(builder: (_) => UserGroupViewPage());

    case '/user_group_page':
      return MaterialPageRoute(builder: (_) => UserGroupPage());

    case '/edit_user_group_page':
      return MaterialPageRoute(builder: (_) => EditUserGroupPage());

    case '/choose_location_page':
      return MaterialPageRoute(builder: (_) => ChoooseLocationPage());

    case '/location_picker_page':
      return MaterialPageRoute(builder: (_) => LocationPickerPage());

    case '/privacy_page':
      return MaterialPageRoute(builder: (_) => PrivacyPage());

    case '/term_condition_page':
      return MaterialPageRoute(builder: (_) => TermConditionPage());

    case '/transaction_page':
      return MaterialPageRoute(builder: (_) => TransactionPage());

    case '/term_condition_login_page':
      return MaterialPageRoute(builder: (_) => TermConditionLoginPage());

    case '/privacy_policy_login_page':
      return MaterialPageRoute(builder: (_) => PrivacyPolicyLoginPage());

    case '/guest_category_page':
      return MaterialPageRoute(
        builder: (_) => GuestCategoryPage(
          data: args,
          isParent: args['isParent'] ?? false,
        ),
      );

    case '/guest_product_detail_page':
      return MaterialPageRoute(
        builder: (_) => GuestProductDetailPage(data: args),
      );

    case '/open_source_page':
      return MaterialPageRoute(builder: (_) => OpenSourcePage());

    case 'youtube_link_page':
      return MaterialPageRoute(
        builder: (_) => Scaffold(
          body: Center(child: Text('YouTube link page coming soon')),
        ),
      );

    default:
      return MaterialPageRoute(
        builder: (_) => Scaffold(
          body: Center(child: Text("No Page Found")),
        ),
      );
  }
}
