import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mealup/localization/lang_constant.dart';
import 'package:mealup/localization/localization_constant.dart';

class Constants {
  /// TODO Setup: Enter your base url here, Make sure you have added a "/" at the end of the URL
  /// Make sure wether you are using http or https
  /// Make sure wether you need /public/ in the base URL or not
  /// After changing here, also change in the [api_client.g.dart] file
  /// if that file doesn't exist, run the following command in the project terminal
  /// flutter pub run build_runner build --delete-conflicting-outputs
  /// Please don't remove "/api/".
  static const String baseURL = "http://zone0.cloud:800//api/";

  /// TODO Setup: Enter you Google Map Keys Below
  static final String androidKey = 'Enter_Your_Google_Map_Key';
  static final String iosKey = 'Enter_Your_Google_Map_Key_For_iOS';

  static const String currentLanguageCode = "";

  static Color colorBlack = Color(0xFF090E21);
  static Color colorGray = Color(0xFF999999);
  static Color colorLike = Color(0xFFff6060);
  static Color colorLikeLight = Color(0xFFe2bcbc);
  static Color colorTheme = Color(0xFF06C168);
  static Color colorOrderPending = Color(0xFFF4AE36);
  static Color colorOrderPickup = Color(0xFFd1286b);
  static Color colorBackground = Color(0xFFFAFAFA);
  static Color colorRate = Color(0xFFffc107);
  static Color colorBlue = Color(0xFF1492e6);
  static Color colorHint = Color(0xFFb9b9b9);
  static Color colorWhite = Color(0xFFFFFFFF);

  static String appFont = 'Proxima';
  static String appFontBold = 'ProximaBold';

  static String isDisclaimer = 'isDisclaimer';

  static String registrationOTP = 'regOTP';
  static String registrationEmail = 'regEmail';
  static String registrationPhone = 'regPhone';
  static String registrationUserId = 'userId';

  static String bankIFSC = 'bank_IFSC';
  static String bankMICR = 'bank_MICR';
  static String bankACCName = 'bank_ACC_Name';
  static String bankACCNumber = 'bank_ACC_Number';

  static String loginOTP = 'loginOTP';
  static String loginEmail = 'loginEmail';
  static String loginPhone = 'loginPhone';
  static String loginPhoneCode = 'loginPhoneCode';
  static String loginUserId = 'loggeduserId';
  static String loginUserImage = 'loggedImage';
  static String loginUserName = 'loggedName';

  static String headerToken = 'headerToken';
  static String isLoggedIn = 'isLoggedIn';
  static String stripePaymentToken = 'stripePaymentToken';

  static String selectedAddress = 'selectedAddress';
  static String selectedAddressId = 'selectedAddressId';
  static String recentSearch = 'recentSearch';

  static String appSettingCurrency = 'appSettingCurrency';
  static String appSettingCurrencySymbol = 'appSettingCurrencySymbol';
  static String appSettingPrivacyPolicy = 'appSettingPrivacyPolicy';
  static String appSettingTerm = 'appSettingTerm';
  static String appAboutCompany = 'appAboutCompany';
  static String appSettingHelp = 'appSettingHelp';
  static String appSettingAboutUs = 'appSettingAboutUs';
  static String appSettingDriverAutoRefresh = 'appSettingDriverAutoRefresh';
  static String appSettingBusinessAvailability = 'appSettingBusiness_availability';
  static String appSettingBusinessMessage = 'appSettingBusiness_message';
  static String appSettingCustomerAppId = 'appSettingCustomerAppId';
  static String appSettingAndroidCustomerVersion = 'appSetting_android_customer_version';
  static String appSettingIsPickup = 'appSetting_isPickup';
  static String appPushOneSingleToken = 'push_oneSingleToken';

  static String previousLat = 'previousLat';
  static String previousLng = 'previousLng';

  // payment Setting
  static String appPaymentWallet = 'appPaymentWallet';
  static String appPaymentCOD = 'appPaymentCOD';
  static String appPaymentStripe = 'appPaymentStripe';
  static String appPaymentRozerPay = 'appPaymentRozerPay';
  static String appPaymentPaypal = 'appPaymentPaypal';
  static String appStripePublishKey = 'appStripePublishKey';
  static String appStripeSecretKey = 'appStripeSecretKey';
  static String appPaypalProduction = 'appPaypalProducation';
  static String appPaypalClientId = 'appPaypal_client_id';
  static String appPaypalSecretKey = 'appPaypal_secret_key';
  static String appPaypalSendBox = 'appPaypalSendbox';
  static String appRozerpayPublishKey = 'appRozerpayPublishKey';

  static Future<bool> checkNetwork() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      return true;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      return true;
    } else {
      Constants.toastMessage("Pas de connection internet");
      return false;
    }
  }

  static var kAppLabelWidget =
      TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0, fontFamily: Constants.appFontBold);

  static var kTextFieldInputDecoration = InputDecoration(
    hintStyle: TextStyle(color: Constants.colorHint),
    errorStyle: TextStyle(fontFamily: Constants.appFontBold, color: Colors.red),
    filled: true,
    fillColor: Constants.colorWhite,
    contentPadding: const EdgeInsets.only(left: 14.0, bottom: 6.0, top: 8.0, right: 14),
    errorMaxLines: 2,
    border: new OutlineInputBorder(
      borderRadius: new BorderRadius.circular(15.0),
      borderSide: BorderSide(width: 0.5, color: Colors.grey),
    ),
    enabledBorder: new OutlineInputBorder(
      borderRadius: new BorderRadius.circular(15.0),
      borderSide: BorderSide(width: 0.5, color: Colors.grey),
    ),
    disabledBorder: new OutlineInputBorder(
      borderRadius: new BorderRadius.circular(15.0),
      borderSide: BorderSide(width: 0.5, color: Colors.grey),
    ),
    focusedBorder: new OutlineInputBorder(
      borderRadius: new BorderRadius.circular(15.0),
      borderSide: BorderSide(width: 0.5, color: Colors.grey),
    ),
    errorBorder: new OutlineInputBorder(
      borderRadius: new BorderRadius.circular(15.0),
      borderSide: BorderSide(width: 0.5, color: Colors.red),
    ),
    focusedErrorBorder: new OutlineInputBorder(
      borderRadius: new BorderRadius.circular(15.0),
      borderSide: BorderSide(width: 1, color: Colors.red),
    ),
  );

  static toastMessage(String msg) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black54,
        textColor: Constants.colorWhite,
        fontSize: 16.0);
  }

  static onLoading(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            padding: EdgeInsets.all(20),
            child: new Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                new CircularProgressIndicator(),
                SizedBox(width: 20),
                new Text(getTranslated(context, LangConst.labelPleaseWait).toString()),
              ],
            ),
          ),
        );
      },
    );
  }

  static hideDialog(BuildContext context) {
    Navigator.pop(context);
  }
}
