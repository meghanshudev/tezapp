
import 'dart:convert';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tezchal/helpers/constant.dart';
import 'package:tezchal/helpers/utils.dart';
import 'package:tezchal/pages/Authentication/login_page.dart';
import 'package:tezchal/pages/Guest/guest_root_app.dart';
import 'package:tezchal/provider/account_info_provider.dart';
import 'package:tezchal/provider/cart_provider.dart';
import 'package:tezchal/provider/credit_provider.dart';
import 'package:tezchal/provider/has_group.dart';
import 'package:tezchal/root_app.dart';

import 'firebase_options.dart';

// Support for Android v7 (bypass self-signed certs)
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (cert, host, port) => true;
  }
}

void main() async {
  HttpOverrides.global = MyHttpOverrides();

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await EasyLocalization.ensureInitialized();
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();


  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HasGroupProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => CreditProvider()),
        ChangeNotifierProvider(create: (_) => AccountInfoProvider()),
      ],
      child: EasyLocalization(
        supportedLocales: APP_LOCALES,
        path: 'assets/langs',
        fallbackLocale: APP_LOCALES[0],
        child: Builder(
          builder: (context) => MaterialApp(
            navigatorKey: navigatorKey,
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            debugShowCheckedModeBanner: ENV != "production",
            home: const AppInitializer(),
          ),
        ),
      ),
    ),
  );
}



class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    await Future.delayed(const Duration(milliseconds: 100)); // small delay

    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userResult = prefs.getString(APP_PREFIX + STORAGE_USER);

    if (!checkIsNullValue(userResult)) {
      userSession = json.decode(userResult!);
      if (checkIsNullValue(userSession)) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      } else if (userSession['id'] == 676) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => GuestRootApp(data: {"activePageIndex": 0}),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => RootApp(data: {"activePageIndex": 0}),
          ),
        );
      }
    } else {
      // If no userResult found, go to login page as fallback
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
