import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'helpers/constant.dart';
import 'helpers/utils.dart';
import 'pages/Authentication/login_page.dart';
import 'provider/account_info_provider.dart';
import 'provider/cart_provider.dart';
import 'provider/credit_provider.dart';
import 'provider/has_group.dart';
import 'root_app.dart';
import 'pages/Guest/guest_root_app.dart';
import 'router.dart' as router;

// Support for Android v7 (bypass self-signed certs)
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (cert, host, port) => true;
  }
}

Future<void> main() async {
  HttpOverrides.global = MyHttpOverrides();

  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await getStorageUser();

  runApp(
    EasyLocalization(
      supportedLocales: APP_LOCALES,
      path: 'assets/langs',
      fallbackLocale: APP_LOCALES[0],
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => HasGroupProvider()),
          ChangeNotifierProvider(create: (_) => CartProvider()),
          ChangeNotifierProvider(create: (_) => CreditProvider()),
          ChangeNotifierProvider(create: (_) => AccountInfoProvider()),
        ],
        child: MyApp(homeScreen: _checkInitialScreen()),
      ),
    ),
  );
}

Widget _checkInitialScreen() {
  if (!checkIsNullValue(userSession)) {
    if (userSession['id'] == 676) {
      return GuestRootApp(data: {"activePageIndex": 0});
    }
    return RootApp(data: {"activePageIndex": 0});
  }
  return const LoginPage();
}

class MyApp extends StatelessWidget {
  final Widget homeScreen;
  const MyApp({required this.homeScreen, super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      debugShowCheckedModeBanner: ENV == "production" ? false : true,
      onGenerateRoute: router.generateRoute,
      home: homeScreen,
    );
  }
}
