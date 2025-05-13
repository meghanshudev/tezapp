import 'dart:ui';

import 'package:event_bus/event_bus.dart';

const ENV = 'production';

const API_URL = (ENV == "production")
    ? "https://api.teznow.com/api/v1/"
    : "https://tez-api.sopheamen.com/api/v1/";

const ONE_SIGNAL_ID = (ENV == "production")
    ? "7c2c4ea1-0c6d-4365-85cd-028ae88dfe85"
    : "643ee9e2-2e0d-41aa-bf38-3ed4ed3ededa";

const iconPath = "assets/icons/";
const imagePath = "assets/images/";

const String APP_PREFIX = "Tez";
const String STORAGE_USER = "user_object";
const String LANGUAGE = "LANGUAGE";
const APP_LOCALES = [Locale('en', 'US'), Locale('hi', 'IN')];
const String APP_VERSION = "v1.0";
const String BUNDLE_VERSION = "v101";
const String APP_EMAIL = "support@teznow.com";
const String WHATSAPP = "918669904755";
const String PREFIX_PHONE = "+91";
const String COUNTRY_CODE = "";

const String CURRENCY = "₹";
const String PHONE_FORMAT = '0##-#######';

const String LOCAL_DEFAULT_IMAGE = "assets/images/default.jpg";
const String NETWORK_DEFAULT_IMAGE =
    "https://roboliristorante.com/wp-content/uploads/2021/10/default.jpg";
const String DEFAULT_GROUP_IMAGE =
    "https://tez-production.s3.ap-south-1.amazonaws.com/groups/2022/5/2cb9a7919e01c5a1c22a824a0481e735.png";

const googleKeyApi = "AIzaSyB7D57hhnF6sJw6V3wnU2YH3WSwcqV_DEc";

const String WHATSAPP_ANDROID_URL = "whatsapp://send?phone=";
const String WHATSAPP_IOS_URL = "whatsapp://send?phone=";
const String EARN_WITH_TEZ = "https://go.teznow.com/earn";
const String HOW_IT_WORKS = "https://go.teznow.com/how-it-works";
const String HEADER_IMAGE_BASE64 = 'data:image/png;base64,';
const String DEFAULT_ZIP_CODE = "12000";

const String CREDENTIAL_KEY = "6PMJC2eXhJgSdxqo3wOBYcdfvP5pCjy5";
const String CREDENTIAL_IV = "6dFQ0vczyBuDhIR2";

// social media
const String INSTAGRAM = "https://instagram.com/TezSocial";
const String FACEBOOK = "https://facebook.com/TezNow";
const String LINKEDIN = "https://linkedin.com/company/TezNow";
const String TWITTER = "https://twitter.com/TezSocial";

const String PLAY_STORE_LINK = "https://teznow.com/app";

const String MIX_PANEL = "8177459d630e7f03524abaad3b345e7a";

const String LOGIN_PHONE_NUMBER = "LOGIN_PHONE_NUMBER";
const String ENTER_OTP = "ENTER_OTP";
const String ADD_NAME = "ADD_NAME";
const String CLICK_CATEGORY = "CLICK_CATEGORY";
const String CLICK_SUB_CATEGORY = "CLICK_SUB_CATEGORY";
const String CLICK_PRODUCT = "CLICK_PRODUCT";
const String REMOVE_PRODUCT_FROM_CART = "REMOVE_PRODUCT_FROM_CART";
const String CART_SCREEN = "CART_SCREEN";
const String CLICK_EMPTY_CART = "CLICK_EMPTY_CART";
const String CLICK_ORDER_CONFIRM = "CLICK_ORDER_CONFIRM";
const String CLICK_CREATE_GROUP = "CLICK_CREATE_GROUP";
const String CLICK_JOIN_GROUP = "CLICK_JOIN_GROUP";
const String CLICK_ORDER_KIRANA_ON_WHATSAPP = "CLICK_ORDER_KIRANA_ON_WHATSAPP";
const String CLICK_SHARE_GROUP_ON_WHATSAPP = "CLICK_SHARE_GROUP_ON_WHATSAPP";
const String CLICK_SHARE_ORDER_WHATSAPP = "CLICK_SHARE_ORDER_WHATSAPP";
const String CLICK_HOW_TO_EARN_TEZ_GROUPS = "CLICK_HOW_TO_EARN_TEZ_GROUPS";
const String CLICK_PERMISSION_LOCATION = "CLICK_PERMISSION_LOCATION";
const String CLICK_INCREASE_OR_DECREASE_PRODUCT_QTY =
    "CLICK_INCREASE_OR_DECREASE_PRODUCT_QTY";
const String CLICK_ADD_TO_CART = "CLICK_ADD_TO_CART";

EventBus eventBus = EventBus();

bool HOME_PAGE_LEAVE = true;
