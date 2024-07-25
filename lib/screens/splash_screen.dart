import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mealup/model/app_setting_model.dart';
import 'package:mealup/model/cartmodel.dart';
import 'package:mealup/retrofit/api_client.dart';
import 'package:mealup/retrofit/api_header.dart';
import 'package:mealup/retrofit/base_model.dart';
import 'package:mealup/retrofit/server_error.dart';
import 'package:mealup/utils/SharedPreferenceUtil.dart';
import 'package:mealup/utils/constants.dart';
import 'package:mealup/utils/database_helper.dart';
import 'package:mealup/utils/preference_utils.dart';
import 'bottom_navigation/dashboard_screen.dart';
import 'intro/intro_screen1.dart';

final dbHelper = DatabaseHelper.instance;

class SplashScreen extends StatefulWidget {
  final CartModel? model;

  const SplashScreen({Key? key, this.model}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    PreferenceUtils.isIntroDone("disclaimer") == true
        ? callAppSettingData()
        : null;
    super.initState();
    _queryFirst(context, widget.model);

    // PreferenceUtils.isIntroDone("disclaimer") == true
    //     ? Constants.checkNetwork().whenComplete(() => callAppSettingData())
    //     : null;
    changeRoute();
  }

  Future changeRoute() async {
    await Future.delayed(Duration(milliseconds: 3000), () {
      Navigator.pushReplacement(
        this.context,
        MaterialPageRoute(
          builder: (BuildContext context) =>
              PreferenceUtils.isIntroDone("isIntroDone")
                  ? DashboardScreen(0)
                  : IntroScreen1(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    print('ok =======3');
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('images/ic_background_image.png'),
              fit: BoxFit.cover,
            )),
        alignment: Alignment.center,
        child: Hero(
          tag: 'App_logo',
          child: Image.asset('images/ic_intro_logo.png'),
        ),
      ),
        backgroundColor: Constants.colorBackground,
    );
  }

  Future<BaseModel<AppSettingModel>> callAppSettingData() async {
    AppSettingModel response;
    try {
      response = await RestClient(RetroApi().dioData()).setting();

      if (response.success!) {
        if (response.data!.currencySymbol != null) {
          SharedPreferenceUtil.putString(
              Constants.appSettingCurrencySymbol, response.data!.currencySymbol!);
        } else {
          SharedPreferenceUtil.putString(Constants.appSettingCurrencySymbol, '\$');
        }
        if (response.data!.currency != null) {
          SharedPreferenceUtil.putString(Constants.appSettingCurrency, response.data!.currency!);
        } else {
          SharedPreferenceUtil.putString(Constants.appSettingCurrency, 'USD');
        }
        if (response.data!.aboutUs != null) {
          SharedPreferenceUtil.putString(Constants.appSettingAboutUs, response.data!.aboutUs!);
        } else {
          SharedPreferenceUtil.putString(Constants.appSettingAboutUs, '');
        }

        if (response.data!.termsAndCondition != null) {
          SharedPreferenceUtil.putString(
              Constants.appSettingTerm, response.data!.termsAndCondition!);
        } else {
          SharedPreferenceUtil.putString(Constants.appSettingTerm, '');
        }

        if (response.data!.help != null) {
          SharedPreferenceUtil.putString(Constants.appSettingHelp, response.data!.help!);
        } else {
          SharedPreferenceUtil.putString(Constants.appSettingHelp, '');
        }

        if (response.data!.privacyPolicy != null) {
          SharedPreferenceUtil.putString(
              Constants.appSettingPrivacyPolicy, response.data!.privacyPolicy!);
        } else {
          SharedPreferenceUtil.putString(Constants.appSettingPrivacyPolicy, '');
        }

        if (response.data!.companyDetails != null) {
          SharedPreferenceUtil.putString(Constants.appAboutCompany, response.data!.companyDetails!);
        } else {
          SharedPreferenceUtil.putString(Constants.appAboutCompany, '');
        }

        if (response.data!.driverAutoRefrese != null) {
          SharedPreferenceUtil.putInt(
              Constants.appSettingDriverAutoRefresh, response.data!.driverAutoRefrese);
        } else {
          SharedPreferenceUtil.putInt(Constants.appSettingDriverAutoRefresh, 0);
        }

        if (response.data!.isPickup != null) {
          SharedPreferenceUtil.putInt(Constants.appSettingIsPickup, response.data!.isPickup);
        } else {
          SharedPreferenceUtil.putInt(Constants.appSettingIsPickup, 0);
        }

        if (response.data!.customerAppId != null) {
          SharedPreferenceUtil.putString(
              Constants.appSettingCustomerAppId, response.data!.customerAppId!);
        } else {
          SharedPreferenceUtil.putString(Constants.appSettingCustomerAppId, '');
        }

        SharedPreferenceUtil.putInt(Constants.appSettingBusinessAvailability, response.data!.businessAvailability);

        if (SharedPreferenceUtil.getInt(Constants.appSettingBusinessAvailability) == 0) {
          SharedPreferenceUtil.putString(Constants.appSettingBusinessMessage, response.data!.message!);
        }

        // if (SharedPreferenceUtil
        //     .getString(Constants.appPushOneSingleToken)
        //     .isEmpty) {
        //   getOneSingleToken(SharedPreferenceUtil.getString(Constants.appSettingCustomerAppId));
        // }
      } else {
        Constants.toastMessage('Error while get app setting data.');
      }
      print('ok =======4');
    } catch (error, stacktrace) {
      print("Exception occurred: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  // getOneSingleToken(String appId) async {
  //   String? userId = '';
  //   OneSignal.shared.consentGranted(true);
  //   await OneSignal.shared.setAppId(appId);
  //   OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);
  //   await OneSignal.shared.promptUserForPushNotificationPermission(fallbackToSettings: true);
  //   OneSignal.shared.promptLocationPermission();
  //   var status = await (OneSignal.shared.getDeviceState());
  //   userId = status!.userId;

  //   if (SharedPreferenceUtil
  //       .getString(Constants.appPushOneSingleToken)
  //       .isEmpty) {
  //   } else {
  //     SharedPreferenceUtil.putString(Constants.appPushOneSingleToken, userId!);
  //   }
  // }
}

void _queryFirst(BuildContext context, CartModel? model) async {
  final allRows = await dbHelper.queryAllRows();
  allRows.forEach((row) => print(row));
  for (int i = 0; i < allRows.length; i++) {
    model!.addProduct(Product(
      id: allRows[i]['pro_id'],
      restaurantsName: allRows[i]['restName'],
      title: allRows[i]['pro_name'],
      imgUrl: allRows[i]['pro_image'],
      price: double.parse(allRows[i]['pro_price']),
      qty: allRows[i]['pro_qty'],
      restaurantsId: allRows[i]['restId'],
      restaurantImage: allRows[i]['restImage'],
      foodCustomization: allRows[i]['pro_customization'],
      isRepeatCustomization: allRows[i]['isRepeatCustomization'],
      tempPrice: double.parse(allRows[i]['itemTempPrice'].toString()),
      itemQty: allRows[i]['itemQty'],
      isCustomization: allRows[i]['isCustomization'],
      proType: allRows[i]['type'],
    ));
  }
}