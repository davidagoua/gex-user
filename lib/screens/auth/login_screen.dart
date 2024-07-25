import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mealup/model/app_setting_model.dart';
import 'package:mealup/model/login_model.dart';
import 'package:mealup/model/send_otp_model.dart';
import 'package:mealup/retrofit/api_client.dart';
import 'package:mealup/retrofit/api_header.dart';
import 'package:mealup/retrofit/base_model.dart';
import 'package:mealup/retrofit/server_error.dart';
import 'package:mealup/screen_animation_utils/transitions.dart';
import 'package:mealup/screens/auth/change_password.dart';
import 'package:mealup/screens/auth/create_new_account.dart';
import 'package:mealup/screens/bottom_navigation/dashboard_screen.dart';
import 'package:mealup/utils/SharedPreferenceUtil.dart';
import 'package:mealup/utils/app_lable_widget.dart';
import 'package:mealup/utils/card_password_textfield.dart';
import 'package:mealup/utils/card_textfield.dart';
import 'package:mealup/utils/constants.dart';
import 'package:mealup/utils/hero_image_app_logo.dart';
import 'package:mealup/localization/lang_constant.dart';
import 'package:mealup/localization/localization_constant.dart';
import 'package:mealup/utils/rounded_corner_app_button.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import '../otp_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isRememberMe = false;
  bool _passwordVisible = true;

  final _textEmail = TextEditingController();
  final _textPassword = TextEditingController();
  final _formKey = new GlobalKey<FormState>();
  bool credentialsReadOnly = false;
  String provider = 'LOCAL';

  @override
  void initState() {
    super.initState();

    /// TODO Setup: You can set default email and password for testing purpose, so you don't have to type every time.
    /// NOTE: Make sure to comment this code before release.

    // _textEmail.text = 'democustomer@saasmonks.in';
    // _textPassword.text = '123456';

    if (SharedPreferenceUtil.getString(Constants.appPushOneSingleToken).isEmpty) {
      getOneSingleToken(SharedPreferenceUtil.getString(Constants.appSettingCustomerAppId));
    }
    callAppSettingData();
  }

  @override
  void dispose() {
    _textEmail.dispose();
    _textPassword.dispose();
    super.dispose();
  }

  Future<BaseModel<AppSettingModel>> callAppSettingData() async {
    AppSettingModel response;
    try {
      response = await RestClient(RetroApi().dioData()).setting();
      print(response.success);
      print('businessAvailability' + response.data!.businessAvailability.toString());

      if (response.success!) {
        if (response.data!.currencySymbol != null) {
          SharedPreferenceUtil.putString(Constants.appSettingCurrencySymbol, response.data!.currencySymbol!);
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
        if (response.data!.aboutUs != null) {
          SharedPreferenceUtil.putString(Constants.appSettingAboutUs, response.data!.aboutUs!);
        } else {
          SharedPreferenceUtil.putString(Constants.appSettingAboutUs, '');
        }

        if (response.data!.termsAndCondition != null) {
          SharedPreferenceUtil.putString(Constants.appSettingTerm, response.data!.termsAndCondition!);
        } else {
          SharedPreferenceUtil.putString(Constants.appSettingTerm, '');
        }

        if (response.data!.help != null) {
          SharedPreferenceUtil.putString(Constants.appSettingHelp, response.data!.help!);
        } else {
          SharedPreferenceUtil.putString(Constants.appSettingHelp, '');
        }

        if (response.data!.privacyPolicy != null) {
          SharedPreferenceUtil.putString(Constants.appSettingPrivacyPolicy, response.data!.privacyPolicy!);
        } else {
          SharedPreferenceUtil.putString(Constants.appSettingPrivacyPolicy, '');
        }

        if (response.data!.companyDetails != null) {
          SharedPreferenceUtil.putString(Constants.appAboutCompany, response.data!.companyDetails!);
        } else {
          SharedPreferenceUtil.putString(Constants.appAboutCompany, '');
        }
        if (response.data!.driverAutoRefrese != null) {
          SharedPreferenceUtil.putInt(Constants.appSettingDriverAutoRefresh, response.data!.driverAutoRefrese);
        } else {
          SharedPreferenceUtil.putInt(Constants.appSettingDriverAutoRefresh, 0);
        }

        if (response.data!.isPickup != null) {
          SharedPreferenceUtil.putInt(Constants.appSettingIsPickup, response.data!.isPickup);
        } else {
          SharedPreferenceUtil.putInt(Constants.appSettingIsPickup, 0);
        }

        if (response.data!.customerAppId != null) {
          SharedPreferenceUtil.putString(Constants.appSettingCustomerAppId, response.data!.customerAppId!);
        } else {
          SharedPreferenceUtil.putString(Constants.appSettingCustomerAppId, '');
        }

        if (response.data!.androidCustomerVersion != null) {
          SharedPreferenceUtil.putString(
              Constants.appSettingAndroidCustomerVersion, response.data!.androidCustomerVersion!);
        } else {
          SharedPreferenceUtil.putString(Constants.appSettingAndroidCustomerVersion, '');
        }

        SharedPreferenceUtil.putInt(Constants.appSettingBusinessAvailability, response.data!.businessAvailability);

        if (SharedPreferenceUtil.getInt(Constants.appSettingBusinessAvailability) == 0) {
          SharedPreferenceUtil.putString(Constants.appSettingBusinessMessage, response.data!.message!);
        }

        if (SharedPreferenceUtil.getString(Constants.appPushOneSingleToken).isEmpty) {
          getOneSingleToken(SharedPreferenceUtil.getString(Constants.appSettingCustomerAppId));
        }
      } else {
        Constants.toastMessage('Error while get app setting data.');
      }
    } catch (error, stacktrace) {
      print("Exception occurred: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                child: Image.asset(
                  'images/ic_login_page.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Scaffold(
              primary: true,
              backgroundColor: Colors.transparent,
              body: Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                    image: AssetImage('images/ic_background_image.png'),
                    fit: BoxFit.cover,
                  )),
                  child: Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.disabled,
                    child: ListView.builder(
                      itemCount: 1,
                      shrinkWrap: false,
                      itemBuilder: (BuildContext context, int index) {
                        return Column(
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.of(context).push(Transitions(
                                    transitionType: TransitionType.slideUp,
                                    curve: Curves.bounceInOut,
                                    reverseCurve: Curves.fastLinearToSlowEaseIn,
                                    widget: DashboardScreen(0)));
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(right: 10, left: 10, top: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      getTranslated(context, LangConst.labelSkipNow).toString(),
                                      style: TextStyle(
                                        color: Colors.black,
                                        decoration: TextDecoration.underline,
                                        decorationColor: Colors.black,
                                        decorationThickness: 2,
                                        fontSize: ScreenUtil().setSp(16),
                                        fontFamily: Constants.appFont,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            HeroImage(),
                            SizedBox(height: 20),
                            Container(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 20, right: 20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    AppLableWidget(
                                      title: getTranslated(context, LangConst.labelEmail).toString(),
                                    ),
                                    CardTextFieldWidget(
                                      focus: (v) {
                                        FocusScope.of(context).nextFocus();
                                      },
                                      textInputAction: TextInputAction.next,
                                      hintText: getTranslated(context, LangConst.labelEnterYourEmailID).toString(),
                                      textInputType: TextInputType.emailAddress,
                                      textEditingController: _textEmail,
                                      validator: kvalidateEmail,
                                      readOnly: credentialsReadOnly,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        AppLableWidget(
                                          title: getTranslated(context, LangConst.labelPassword).toString(),
                                        ),
                                      ],
                                    ),
                                    CardPasswordTextFieldWidget(
                                      textEditingController: _textPassword,
                                      // validator: kvalidatePassword,
                                      hintText: getTranslated(context, LangConst.labelEnterYourPassword).toString(),
                                      readOnly: credentialsReadOnly,
                                      isPasswordVisible: _passwordVisible,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(10.0),
                                          alignment: Alignment.centerRight,
                                          child: GestureDetector(
                                            onTap: () {
                                              Navigator.of(context).push(Transitions(
                                                  transitionType: TransitionType.fade,
                                                  curve: Curves.bounceInOut,
                                                  reverseCurve: Curves.fastLinearToSlowEaseIn,
                                                  widget: ChangePassword()));
                                            },
                                            child: Text(
                                              getTranslated(context, LangConst.labelForgotPassword).toString(),
                                              style: TextStyle(
                                                fontFamily: Constants.appFontBold,
                                                fontSize: ScreenUtil().setSp(16),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(left: 20.0, right: 20, top: 10, bottom: 10),
                                      child: RoundedCornerAppButton(
                                        onPressed: () {
                                          if (_formKey.currentState!.validate()) {
                                            Constants.checkNetwork().whenComplete(() => callUserLogin());
                                          } else {
                                            setState(() {});
                                          }
                                        },
                                        btnLabel: getTranslated(context, LangConst.labelLogin).toString(),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10.0,
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).push(Transitions(
                                            transitionType: TransitionType.slideUp,
                                            curve: Curves.bounceInOut,
                                            reverseCurve: Curves.fastLinearToSlowEaseIn,
                                            widget: CreateNewAccount()));
                                      },
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            getTranslated(context, LangConst.labelDonthaveAcc).toString(),
                                            style: TextStyle(
                                              fontFamily: Constants.appFont,
                                              fontSize: ScreenUtil().setSp(14),
                                            ),
                                          ),
                                          Text(
                                            getTranslated(context, LangConst.labelCreateNow).toString(),
                                            style: TextStyle(
                                              fontFamily: Constants.appFontBold,
                                              fontSize: ScreenUtil().setSp(16),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? kvalidateEmail(String? value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern as String);
    if (value!.length == 0) {
      return getTranslated(context, LangConst.labelEmailRequired).toString();
    } else if (!regex.hasMatch(value))
      return getTranslated(context, LangConst.labelEnterValidEmail).toString();
    else
      return null;
  }

  // String? kvalidatePassword(String? value) {
  //   Pattern pattern = r'^(?=.*?[a-z])(?=.*?[0-9]).{8,}$';
  //   RegExp regex = new RegExp(pattern as String);
  //   if (value!.length == 0) {
  //     return getTranslated(context, LangConst.labelPasswordRequired;
  //   } else if (!regex.hasMatch(value))
  //     return getTranslated(context, LangConst.labelPasswordValidation;
  //   else
  //     return null;
  // }

  getOneSingleToken(String appId) async {
    //  ! UPDATE ONESIGNAL CODE
    //Remove this method to stop OneSignal Debugging
    OneSignal.Debug.setLogLevel(OSLogLevel.verbose);

    OneSignal.initialize(appId);

    // The promptForPushNotificationsWithUserResponse function will show the iOS or Android push notification prompt. We recommend removing the following code and instead using an In-App Message to prompt for notification permission
    OneSignal.Notifications.requestPermission(true);

    OneSignal.Notifications.addPermissionObserver((state) {
      print("Has permission " + state.toString());
    });

    // OneSignal.shared.consentGranted(true);
    // await OneSignal.shared.setAppId(appId);
    // OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);
    // await OneSignal.shared.promptUserForPushNotificationPermission(fallbackToSettings: true);
    // OneSignal.shared.promptLocationPermission();
    // await OneSignal.shared.getDeviceState().then(
    //     (value) => SharedPreferenceUtil.putString(Constants.appPushOneSingleToken, value!.userId!));
    // print("pushtoken1:${SharedPreferenceUtil.getString(Constants.appPushOneSingleToken)}");
  }

  Future<BaseModel<LoginModel>> callUserLogin() async {
    LoginModel response;
    try {
      Constants.onLoading(context);

      Map<String, String> body = {
        'email_id': _textEmail.text,
        'password': _textPassword.text,
        'provider': provider,
        'device_token': SharedPreferenceUtil.getString(Constants.appPushOneSingleToken),
      };

      response = await RestClient(RetroApi().dioData()).userLogin(body);
      Constants.hideDialog(context);
      print(response.success);
      if (response.success!) {
        if (response.data!.isVerified == 1) {
          Constants.toastMessage(getTranslated(context, LangConst.labelLoginSuccessfully).toString());
          response.data!.otp == null
              ? SharedPreferenceUtil.putInt(Constants.loginOTP, 0)
              : SharedPreferenceUtil.putInt(Constants.loginOTP, response.data!.otp);
          SharedPreferenceUtil.putString(Constants.loginEmail, response.data!.emailId!);
          SharedPreferenceUtil.putString(Constants.loginPhone, response.data!.phone!);
          if (response.data!.phoneCode != null) {
            SharedPreferenceUtil.putString(Constants.loginPhoneCode, response.data!.phoneCode!);
          } else {
            SharedPreferenceUtil.putString(Constants.loginPhoneCode, '+91');
          }
          SharedPreferenceUtil.putString(Constants.loginUserId, response.data!.id.toString());
          SharedPreferenceUtil.putString(Constants.headerToken, response.data!.token!);
          SharedPreferenceUtil.putString(Constants.loginUserImage, response.data!.image!);
          SharedPreferenceUtil.putString(Constants.loginUserName, response.data!.name!);

          response.data!.ifscCode == null
              ? SharedPreferenceUtil.putString(Constants.bankIFSC, '')
              : SharedPreferenceUtil.putString(Constants.bankIFSC, response.data!.ifscCode!);
          response.data!.micrCode == null
              ? SharedPreferenceUtil.putString(Constants.bankMICR, '')
              : SharedPreferenceUtil.putString(Constants.bankMICR, response.data!.micrCode!);
          response.data!.accountName == null
              ? SharedPreferenceUtil.putString(Constants.bankACCName, '')
              : SharedPreferenceUtil.putString(Constants.bankACCName, response.data!.accountName!);
          response.data!.accountNumber == null
              ? SharedPreferenceUtil.putString(Constants.bankACCNumber, '')
              : SharedPreferenceUtil.putString(Constants.bankACCNumber, response.data!.accountNumber!);

          SharedPreferenceUtil.putBool(Constants.isLoggedIn, true);

          // String languageCode = '';
          // if (response.data!.language == 'english') {
          //   languageCode = 'en';
          // } else if (response.data!.language == 'arabic') {
          //   languageCode = 'ar';
          // } else {
          //   languageCode = 'en';
          // }

          // changeLanguage(context, languageCode);

          Navigator.of(context).pushReplacement(
            Transitions(
              transitionType: TransitionType.slideUp,
              curve: Curves.bounceInOut,
              reverseCurve: Curves.fastLinearToSlowEaseIn,
              widget: DashboardScreen(0),
            ),
          );
        } else {
          SharedPreferenceUtil.putString(Constants.registrationUserId, response.data?.id.toString() ?? "04");
          callSendOTP();
        }
      } else {
        Constants.toastMessage(getTranslated(context, LangConst.labelEmailPasswordWrong).toString());
      }
    } catch (error, stacktrace) {
      Constants.hideDialog(context);
      print("Exception occurred: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<SendOTPModel>> callSendOTP() async {
    SendOTPModel response;
    try {
      Constants.onLoading(context);
      Map<String, String> body = {
        'email_id': _textEmail.text,
        'where': 'register',
      };
      response = await RestClient(RetroApi().dioData()).sendOtp(body);
      Constants.hideDialog(context);
      print(response.success);
      if (response.success!) {
        SharedPreferenceUtil.putString(Constants.loginUserId, response.data!.id.toString());
        Navigator.of(context).push(
          Transitions(
            transitionType: TransitionType.fade,
            curve: Curves.bounceInOut,
            reverseCurve: Curves.fastLinearToSlowEaseIn,
            widget: OTPScreen(
              isFromRegistration: true,
              emailForOTP: _textEmail.text,
            ),
          ),
        );
      } else {
        Constants.toastMessage(response.msg.toString());
      }
    } catch (error, stacktrace) {
      setState(() {
        Constants.hideDialog(context);
      });
      print("Exception occurred: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }
}
