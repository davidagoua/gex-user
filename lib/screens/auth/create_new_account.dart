import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mealup/model/register_model.dart';
import 'package:mealup/model/send_otp_model.dart';
import 'package:mealup/retrofit/api_header.dart';
import 'package:mealup/retrofit/api_client.dart';
import 'package:mealup/retrofit/base_model.dart';
import 'package:mealup/retrofit/server_error.dart';
import 'package:mealup/screen_animation_utils/transitions.dart';
import 'package:mealup/screens/auth/login_screen.dart';
import 'package:mealup/screens/otp_screen.dart';
import 'package:mealup/utils/SharedPreferenceUtil.dart';
import 'package:mealup/utils/app_lable_widget.dart';
import 'package:mealup/utils/app_toolbar.dart';
import 'package:mealup/utils/card_password_textfield.dart';
import 'package:mealup/utils/card_textfield.dart';
import 'package:mealup/utils/constants.dart';
import 'package:mealup/utils/hero_image_app_logo.dart';
import 'package:mealup/localization/lang_constant.dart';
import 'package:mealup/localization/localization_constant.dart';

import 'package:mealup/utils/rounded_corner_app_button.dart';


class CreateNewAccount extends StatefulWidget {
  @override
  _CreateNewAccountState createState() => _CreateNewAccountState();
}

class Item {
  const Item(this.name, this.icon);

  final String name;
  final Icon icon;
}

class _CreateNewAccountState extends State<CreateNewAccount> {

  bool _passwordVisible = true;
  bool _confirmpasswordVisible = true;

  Item? selectedUser;
  List<Item> users = <Item>[
    const Item(
        'Android',
        Icon(
          Icons.android,
          color: const Color(0xFF167F67),
        )),
    const Item(
        'Flutter',
        Icon(
          Icons.flag,
          color: const Color(0xFF167F67),
        )),
    const Item(
        'ReactNative',
        Icon(
          Icons.format_indent_decrease,
          color: const Color(0xFF167F67),
        )),
    const Item(
        'iOS',
        Icon(
          Icons.mobile_screen_share,
          color: const Color(0xFF167F67),
        )),
  ];

  final _textFullName = TextEditingController();
  final _textEmail = TextEditingController();
  final _textPassword = TextEditingController();
  final _textConfPassword = TextEditingController();
  final _textContactNo = TextEditingController();
  final _formKey = new GlobalKey<FormState>();
  String? strCountryCode = '+91';

  String strLanguage = '';

  List<String> _listLanguages = [];

  int? radioIndex;

  void changeIndex(int index) {
    setState(() {
      radioIndex = index;
    });
  }

  Widget getChecked() {
    return Container(
      width: 25,
      height: 25,
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: SvgPicture.asset(
          'images/ic_check.svg',
          width: 15,
          height: 15,
        ),
      ),
      decoration: myBoxDecorationChecked(false, Constants.colorTheme),
    );
  }

  Widget getunChecked() {
    return Container(
      width: 25,
      height: 25,
      decoration: myBoxDecorationChecked(true, Constants.colorWhite),
    );
  }

  BoxDecoration myBoxDecorationChecked(bool isBorder, Color color) {
    return BoxDecoration(
      color: color,
      border: isBorder ? Border.all(width: 1.0) : null,
      borderRadius: BorderRadius.all(Radius.circular(8.0) //                 <--- border radius here
          ),
    );
  }

  @override
  void initState() {
    super.initState();
    // getLanguageList();
  }

  @override
  Widget build(BuildContext context) {

    ScreenUtil.init(context,
        designSize: Size(360, 690));

    return SafeArea(
      child: Scaffold(
        appBar: ApplicationToolbar(appbarTitle: getTranslated(context, LangConst.labelCreateNewAccount).toString()),
        backgroundColor: Color(0xFFFAFAFA),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Column(
              children: [
                SizedBox(height: 10),
                HeroImage(),
                SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                    image: AssetImage('images/ic_background_image.png'),
                    fit: BoxFit.cover,
                  )),
                  alignment: Alignment.center,
                  child: Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        AppLableWidget(
                          title: getTranslated(context, LangConst.labelFullName).toString(),
                        ),
                        CardTextFieldWidget(
                          focus: (v) {
                            FocusScope.of(context).nextFocus();
                          },
                          textInputAction: TextInputAction.next,
                          hintText: getTranslated(context, LangConst.labelEnterYourFullName).toString(),
                          textInputType: TextInputType.text,
                          textEditingController: _textFullName,
                          validator: kvalidateFullName,
                        ),
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
                        ),
                        AppLableWidget(
                          title: getTranslated(context, LangConst.labelContactNumber).toString(),
                        ),
                        Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 10, right: 10),
                              child: Row(
                                children: [
                                  Container(
                                    width: ScreenUtil().setWidth(75),
                                    decoration: BoxDecoration(
                                      borderRadius: new BorderRadius.circular(15.0),
                                      color: Constants.colorWhite,
                                      border: Border.all(
                                        color: Colors.grey,
                                        width: 0.5,
                                      ),
                                    ),
                                    height: ScreenUtil().setHeight(50),
                                    child: CountryCodePicker(
                                      padding: EdgeInsets.zero,
                                      onChanged: (c) {
                                        setState(() {
                                          strCountryCode = c.dialCode;
                                        });
                                      },
                                      // Initial selection and favorite can be one of code ('IT') OR dial_code('+39')
                                      initialSelection: 'IN',
                                      favorite: ['+91', 'IN'],
                                      hideMainText: true,
                                      alignLeft: true,
                                    ),
                                  ),
                                  SizedBox(width: 10,),
                                  Container(
                                    width: MediaQuery.of(context).size.width /1.69,
                                    child: TextFormField(
                                      textInputAction: TextInputAction.next,
                                      controller: _textContactNo,
                                      validator: kvalidateCotactNum,
                                      maxLength: 10,
                                      buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
                                      keyboardType: TextInputType.number,
                                      onFieldSubmitted: (v) {
                                        FocusScope.of(context).nextFocus();
                                      },
                                      decoration: InputDecoration(
                                        prefixIcon: Padding(padding: EdgeInsets.all(15), child: Text('$strCountryCode ')),
                                        hintStyle: TextStyle(color: Constants.colorHint),
                                        errorStyle: TextStyle(fontFamily: Constants.appFontBold, color: Colors.red),
                                        filled: true,
                                        fillColor: Constants.colorWhite,
                                        contentPadding: const EdgeInsets.only(left: 14.0, bottom: 6.0, top: 8.0,right: 14),
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
                                        hintText: '000 000 0000',

                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                        AppLableWidget(
                          title: getTranslated(context, LangConst.labelPassword).toString(),
                        ),
                        CardPasswordTextFieldWidget(
                            textEditingController: _textPassword,
                            validator: kvalidatePassword,
                            hintText: getTranslated(context, LangConst.labelEnterYourPassword).toString(),
                            isPasswordVisible: _passwordVisible),
                        AppLableWidget(
                          title: getTranslated(context, LangConst.labelConfirmPassword).toString(),
                        ),
                        CardPasswordTextFieldWidget(
                            textEditingController: _textConfPassword,
                            validator: kValidateConfPassword,
                            hintText: getTranslated(context, LangConst.labelReEnterPassword).toString(),
                            isPasswordVisible: _confirmpasswordVisible),
                        AppLableWidget(
                          title: getTranslated(context, LangConst.labelLanguage).toString(),
                        ),
                        ListView.builder(
                            physics: ClampingScrollPhysics(),
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            itemCount: _listLanguages.length,
                            itemBuilder: (BuildContext context, int index) => InkWell(
                                  onTap: () {
                                    // changeIndex(index);
                                    // String languageCode = '';
                                    // if (index == 0) {
                                    //   languageCode = 'en';
                                    // } else if (index == 1) {
                                    //   languageCode = 'es';
                                    // } else {
                                    //   languageCode = 'ar';
                                    // }
                                    // changeLanguage(context, languageCode);
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        left: ScreenUtil().setWidth(20),
                                        bottom: ScreenUtil().setHeight(10),
                                        top: ScreenUtil().setHeight(10)),
                                    child: Row(
                                      children: [
                                        radioIndex == index ? getChecked() : getunChecked(),
                                        Padding(
                                          padding: EdgeInsets.only(left: ScreenUtil().setWidth(10)),
                                          child: Text(
                                            _listLanguages[index],
                                            style: TextStyle(
                                                fontFamily: Constants.appFont,
                                                fontWeight: FontWeight.w900,
                                                fontSize: ScreenUtil().setSp(14)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )),
                        SizedBox(
                          height: ScreenUtil().setHeight(20),
                        ),
                        Padding(
                          padding: EdgeInsets.all(ScreenUtil().setWidth(10)),
                          child: RoundedCornerAppButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                // if (radioIndex == 0) {
                                //   strLanguage = 'english';
                                // } else if (radioIndex == 1) {
                                //   strLanguage = 'spanish';
                                // } else {
                                //   strLanguage = 'arabic';
                                // }
                                // print('selected Language' + strLanguage);
                                callRegisterAPI(strLanguage);
                              } else {
                                setState(() {});
                              }
                            },
                            btnLabel: getTranslated(context, LangConst.labelCreateNewAccount).toString(),
                          ),
                        ),
                        SizedBox(
                          height: ScreenUtil().setHeight(10),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                getTranslated(context, LangConst.labelAlreadyHaveAccount).toString(),
                                style: TextStyle(fontFamily: Constants.appFont,fontSize: ScreenUtil().setSp(14)),
                              ),
                              Text(
                                getTranslated(context, LangConst.labelLogin).toString(),
                                style: TextStyle(
                                    fontFamily: Constants.appFontBold,fontSize: ScreenUtil().setSp(16)),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: ScreenUtil().setHeight(30),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? kvalidatePassword(String? value) {
    Pattern pattern = r'^(?=.*?[a-z])(?=.*?[0-9]).{8,}$';
    RegExp regex = new RegExp(pattern as String);
    if (value!.length == 0) {
      return getTranslated(context, LangConst.labelPasswordRequired).toString();
    } else if (!regex.hasMatch(value))
      return getTranslated(context, LangConst.labelPasswordValidation).toString();
    else
      return null;
  }

  String? kvalidateFullName(String? value) {
    if (value!.length == 0) {
      return getTranslated(context, LangConst.labelFullNameRequired).toString();
    } else
      return null;
  }

  String? kvalidateCotactNum(String? value) {
    if (value!.length == 0) {
      return getTranslated(context, LangConst.labelContactNumberRequired).toString();
    }
    else
      return null;
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

  String? kValidateConfPassword(String? value) {
    Pattern pattern = r'^(?=.*?[a-z])(?=.*?[0-9]).{8,}$';
    RegExp regex = new RegExp(pattern as String);
    if (value!.length == 0) {
      return getTranslated(context, LangConst.labelPasswordRequired).toString();
    } else if (_textPassword.text != _textConfPassword.text)
      return getTranslated(context, LangConst.labelPasswordConfPassNotMatch).toString();
    else if (!regex.hasMatch(value))
      return getTranslated(context, LangConst.labelPasswordValidation).toString();
    else
      return null;
  }

  Future<BaseModel<RegisterModel>> callRegisterAPI(String strLanguage) async {

    RegisterModel response;
    try{
      Constants.onLoading(context);
      Map<String, String?> body = {
        'name': _textFullName.text,
        'email_id': _textEmail.text,
        'password': _textConfPassword.text,
        'phone': _textContactNo.text,
        'phone_code': strCountryCode,
        'language': strLanguage,
      };

      response = await  RestClient(RetroApi().dioData()).register(body);
      print(response.success);
      Constants.hideDialog(context);
      if (response.success!) {
        Constants.toastMessage(response.msg!);
        if (response.data!.otp != null) {
          SharedPreferenceUtil.putInt(Constants.registrationOTP, response.data!.otp);
        } else {
          SharedPreferenceUtil.putInt(Constants.registrationOTP, 0);
        }
        if (response.data!.emailId != null) {
          SharedPreferenceUtil.putString(Constants.registrationEmail, response.data!.emailId!);
        } else {
          SharedPreferenceUtil.putString(Constants.registrationEmail, '0');
        }
        if (response.data!.phone != null) {
          SharedPreferenceUtil.putString(Constants.registrationPhone, response.data!.phone!);
        } else {
          SharedPreferenceUtil.putString(Constants.registrationPhone, '0');
        }
        if (response.data!.id != null) {
          SharedPreferenceUtil.putString(Constants.registrationUserId, response.data!.id.toString());
        } else {
          SharedPreferenceUtil.putString(Constants.registrationUserId, '0');
        }

        if (response.data!.isVerified == 0) {
          callSendOTP();
        } else {
          Navigator.of(context).pushReplacement(
            Transitions(
              transitionType: TransitionType.fade,
              curve: Curves.bounceInOut,
              reverseCurve: Curves.fastLinearToSlowEaseIn,
              widget: LoginScreen(),
            ),
          );
        }
      } else {
        Constants.toastMessage(response.msg!);
      }

    }catch (error, stacktrace) {
      setState(() {
        Constants.hideDialog(context);
      });
      print("Exception occurred: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  // Future<void> getLanguageList() async {
  //   _listLanguages.clear();
  //   _listLanguages.add('English');
  //   _listLanguages.add('Spanish');
  //   _listLanguages.add('Arabic');

  //   SharedPreferences _prefs = await SharedPreferences.getInstance();
  //   String? languageCode = _prefs.getString(prefSelectedLanguageCode);

  //   setState(() {
  //     if (languageCode == 'en') {
  //       radioIndex = 0;
  //     } else if (languageCode == 'es') {
  //       radioIndex = 1;
  //     } else if (languageCode == 'ar') {
  //       radioIndex = 2;
  //     } else {
  //       radioIndex = 0;
  //     }
  //   });
  // }

  Future<BaseModel<SendOTPModel>> callSendOTP() async {
    SendOTPModel response;
    try{
      Constants.onLoading(context);
      Map<String, String> body = {
        'email_id': _textEmail.text,
        'where': 'register',
      };
      response  = await RestClient(RetroApi().dioData()).sendOtp(body);
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
    }catch (error, stacktrace) {
      setState(() {
        Constants.hideDialog(context);
      });
      print("Exception occurred: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }
}
