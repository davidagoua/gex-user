import 'package:flutter/material.dart';
import 'package:mealup/screen_animation_utils/transitions.dart';
import 'package:mealup/screens/bottom_navigation/dashboard_screen.dart';
import 'package:mealup/utils/SharedPreferenceUtil.dart';
import 'package:mealup/utils/constants.dart';
import 'package:mealup/localization/lang_constant.dart';
import 'package:mealup/localization/localization_constant.dart';
import 'package:mealup/utils/preference_utils.dart';
import 'package:mealup/model/app_setting_model.dart';
import 'package:mealup/retrofit/api_client.dart';
import 'package:mealup/retrofit/api_header.dart';
import 'package:mealup/retrofit/base_model.dart';
import 'package:mealup/retrofit/server_error.dart';
import 'intro_screen2.dart';

class IntroScreen1 extends StatefulWidget {


  @override
  State<IntroScreen1> createState() => _IntroScreen1State();
}

class _IntroScreen1State extends State<IntroScreen1> {

  @override
  Widget build(BuildContext context) {

    Future.delayed(Duration.zero, () {
      Future.delayed(Duration(seconds: 0), () {
        if (PreferenceUtils.isIntroDone("disclaimer") == false) {
          showDialog<String>(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) => AlertDialog(
              title: Text(
                "Disclaimer",
                textAlign: TextAlign.center,
              ),
              content: Text(
                "MealUp App uses location data to find nearby restaurants, for accurate food delivery, only when app is in use.",
                textAlign: TextAlign.center,
                maxLines: 4,
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () async {
                    callAppSettingData();
                    PreferenceUtils.setisIntroDone("disclaimer", true);
                    callAppSettingData();
                    Navigator.pop(context);
                  },
                  child: Text(
                    "Ok",
                  ),
                ),
              ],
            ),
          );
        }
      });
    });


    // if (SharedPreferenceUtil.getString(Constants.appPushOneSingleToken).isEmpty) {
    //   PreferenceUtils.isIntroDone("disclaimer") == true ? getOneSingleToken(SharedPreferenceUtil.getString(Constants.appSettingCustomerAppId)) : null ;
    // }

    return SafeArea(
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
            image: AssetImage('images/ic_background_image.png'),
            fit: BoxFit.cover,
          )),
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Hero(
                      tag: 'App_logo',
                      child: Image.asset(
                        'images/ic_intro_logo.png',
                        width: 140.0,
                        height: 40,
                      ),
                    ),
                  ),
                  Image.asset('images/ic_intro1.png'),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            getTranslated(context, LangConst.labelScreenIntro1Line1).toString(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: Constants.appFont,
                              color: Constants.colorBlack,
                              fontSize: 25.0,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20.0),
                            child: Text(
                              getTranslated(context, LangConst.labelScreenIntro1Line2).toString(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Constants.colorGray,
                                  fontFamily: Constants.appFont,
                                  fontSize: 16.0),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(width: 10.0, height: 0.0),
                      InkWell(
                        onTap: () {
                          PreferenceUtils.setisIntroDone("isIntroDone", true);
                          Navigator.of(context).pushAndRemoveUntil(
                              Transitions(
                                transitionType: TransitionType.fade,
                                curve: Curves.bounceInOut,
                                reverseCurve: Curves.fastLinearToSlowEaseIn,
                                widget: DashboardScreen(0),
                              ),
                              (Route<dynamic> route) => false);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Text(
                            getTranslated(context, LangConst.labelSkip).toString(),
                            style: TextStyle(
                                letterSpacing: 3.0,
                                color: Constants.colorTheme,
                                fontFamily: Constants.appFontBold,
                                fontWeight: FontWeight.bold,
                                fontSize: 13.0),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.arrow_downward,
                          color: Constants.colorTheme,
                        ),
                        onPressed: () {
                          Navigator.of(context).push(Transitions(
                              transitionType: TransitionType.slideUp,
                              curve: Curves.bounceInOut,
                              reverseCurve: Curves.fastLinearToSlowEaseIn,
                              widget: IntroScreen2()));
                        },
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

    Future<BaseModel<AppSettingModel>> callAppSettingData() async {
    AppSettingModel response;
    try {
      response = await RestClient(RetroApi().dioData()).setting();

      if (response.success!) {
        if (response.data!.currencySymbol != null) {
          SharedPreferenceUtil.putString(Constants.appSettingCurrencySymbol,
              response.data!.currencySymbol!);
        } else {
          SharedPreferenceUtil.putString(
              Constants.appSettingCurrencySymbol, '\$');
        }
        if (response.data!.currency != null) {
          SharedPreferenceUtil.putString(
              Constants.appSettingCurrency, response.data!.currency!);
        } else {
          SharedPreferenceUtil.putString(Constants.appSettingCurrency, 'USD');
        }
        if (response.data!.aboutUs != null) {
          SharedPreferenceUtil.putString(
              Constants.appSettingAboutUs, response.data!.aboutUs!);
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
          SharedPreferenceUtil.putString(
              Constants.appSettingHelp, response.data!.help!);
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
          SharedPreferenceUtil.putString(
              Constants.appAboutCompany, response.data!.companyDetails!);
        } else {
          SharedPreferenceUtil.putString(Constants.appAboutCompany, '');
        }

        if (response.data!.driverAutoRefrese != null) {
          SharedPreferenceUtil.putInt(Constants.appSettingDriverAutoRefresh,
              response.data!.driverAutoRefrese);
        } else {
          SharedPreferenceUtil.putInt(Constants.appSettingDriverAutoRefresh, 0);
        }

        if (response.data!.isPickup != null) {
          SharedPreferenceUtil.putInt(
              Constants.appSettingIsPickup, response.data!.isPickup);
        } else {
          SharedPreferenceUtil.putInt(Constants.appSettingIsPickup, 0);
        }

        if (response.data!.customerAppId != null) {
          SharedPreferenceUtil.putString(
              Constants.appSettingCustomerAppId, response.data!.customerAppId!);
        } else {
          SharedPreferenceUtil.putString(Constants.appSettingCustomerAppId, '');
        }

        SharedPreferenceUtil.putInt(Constants.appSettingBusinessAvailability,
            response.data!.businessAvailability);

        if (SharedPreferenceUtil.getInt(
                Constants.appSettingBusinessAvailability) ==
            0) {
          SharedPreferenceUtil.putString(
              Constants.appSettingBusinessMessage, response.data!.message!);
        }

        // if (SharedPreferenceUtil.getString(Constants.appPushOneSingleToken)
        //     .isEmpty) {
        //   getOeSingleToken(SharedPreferenceUtil.getString(
        //       Constants.appSettingCustomerAppId));
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
  //   if (status != null) {
  //     userId = status.userId;
  //     if (status.userId != null)
  //       SharedPreferenceUtil.putString(Constants.appPushOneSingleToken, userId!);
  //   }
  // }
}
