import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mealup/model/common_res.dart';
import 'package:mealup/retrofit/api_header.dart';
import 'package:mealup/retrofit/api_client.dart';
import 'package:mealup/retrofit/base_model.dart';
import 'package:mealup/retrofit/server_error.dart';
import 'package:mealup/screen_animation_utils/transitions.dart';
import 'package:mealup/screens/auth/login_screen.dart';
import 'package:mealup/utils/SharedPreferenceUtil.dart';
import 'package:mealup/utils/app_lable_widget.dart';
import 'package:mealup/utils/app_toolbar.dart';
import 'package:mealup/utils/card_password_textfield.dart';
import 'package:mealup/utils/constants.dart';
import 'package:mealup/utils/hero_image_app_logo.dart';
import 'package:mealup/localization/lang_constant.dart';
import 'package:mealup/localization/localization_constant.dart';
import 'package:mealup/utils/rounded_corner_app_button.dart';


class ChangePassword1 extends StatefulWidget {
  @override
  _ChangePassword1State createState() => _ChangePassword1State();
}

class _ChangePassword1State extends State<ChangePassword1> {
  bool _passwordVisible = true;
  bool _confirmPasswordVisible = true;

  final _textPassword = TextEditingController();
  final _textConfPassword = TextEditingController();
  final _formKey = new GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {


    // dynamic screenWidth = MediaQuery.of(context).size.width;
    // dynamic screenHeight = MediaQuery.of(context).size.height;

    ScreenUtil.init(context,
        designSize: Size(360, 690),);

    return SafeArea(
      child: Scaffold(
        appBar: ApplicationToolbar(
            appbarTitle: getTranslated(context, LangConst.labelChangePassword).toString()),
        backgroundColor: Color(0xFFFAFAFA),
        body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints viewportConstraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints:
                    BoxConstraints(minHeight: viewportConstraints.maxHeight),
                child: Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                    image: AssetImage('images/ic_background_image.png'),
                    fit: BoxFit.cover,
                  )),
                  child: Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.always,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        HeroImage(),
                        Padding(
                          padding: EdgeInsets.all(ScreenUtil().setWidth(40)),
                          child: Image.asset(
                            'images/ic_lock.png',
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                              ScreenUtil().setWidth(40),
                              0.0,
                              ScreenUtil().setWidth(40),
                              ScreenUtil().setHeight(40)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              AppLableWidget(
                                title: getTranslated(context, LangConst.labelNewPassword).toString(),
                              ),
                              CardPasswordTextFieldWidget(
                                  textEditingController: _textPassword,
                                  validator: kvalidatePassword,
                                  hintText: getTranslated(context, LangConst.labelEnterNewPassword).toString(),
                                  isPasswordVisible: _passwordVisible,
                              ),
                              AppLableWidget(
                                title:
                                    getTranslated(context, LangConst.labelConfirmPassword).toString(),
                              ),
                              CardPasswordTextFieldWidget(
                                  textEditingController: _textConfPassword,
                                  validator: kValidateConfPassword,
                                  hintText: getTranslated(context, LangConst.labelReEnterNewPassword).toString(),
                                  isPasswordVisible: _confirmPasswordVisible),
                              SizedBox(
                                height: ScreenUtil().setHeight(20),
                              ),
                              RoundedCornerAppButton(
                                btnLabel:
                                    getTranslated(context, LangConst.labelChangePassword).toString(),
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    Constants.checkNetwork().whenComplete(
                                        () => callChangePasswordForgot());
                                  } else {
                                    setState(() {
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
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

  Future<BaseModel<CommenRes>> callChangePasswordForgot() async {
    CommenRes response;
    try{
      Constants.onLoading(context);
    Map<String, String> body = {
      'user_id': SharedPreferenceUtil.getString(Constants.loginUserId),
      'password': _textPassword.text,
      'password_confirmation': _textConfPassword.text,
    };
      response  = await  RestClient(RetroApi().dioData()).changeForgot(body);
      Constants.hideDialog(context);
      print(response.success);
      if (response.success!) {
        Constants.toastMessage(response.data!);
        Navigator.of(context).pushAndRemoveUntil(
            Transitions(
              transitionType: TransitionType.fade,
              curve: Curves.bounceInOut,
              reverseCurve: Curves.fastLinearToSlowEaseIn,
              widget: LoginScreen(),
            ),
                (Route<dynamic> route) => false);
      } else {
        Constants.toastMessage('Error while change password.');
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
