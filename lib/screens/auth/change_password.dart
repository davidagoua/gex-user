import 'package:flutter/material.dart';
import 'package:mealup/model/send_otp_model.dart';
import 'package:mealup/retrofit/api_header.dart';
import 'package:mealup/retrofit/api_client.dart';
import 'package:mealup/retrofit/base_model.dart';
import 'package:mealup/retrofit/server_error.dart';
import 'package:mealup/screen_animation_utils/transitions.dart';
import 'package:mealup/screens/otp_screen.dart';
import 'package:mealup/utils/SharedPreferenceUtil.dart';
import 'package:mealup/utils/app_lable_widget.dart';
import 'package:mealup/utils/app_toolbar.dart';
import 'package:mealup/utils/card_textfield.dart';
import 'package:mealup/utils/constants.dart';
import 'package:mealup/utils/hero_image_app_logo.dart';
import 'package:mealup/localization/lang_constant.dart';
import 'package:mealup/localization/localization_constant.dart';
import 'package:mealup/utils/rounded_corner_app_button.dart';


class ChangePassword extends StatefulWidget {
  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {

  final _textEmail = TextEditingController();
  final _formKey = new GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {


    return SafeArea(
      child: Scaffold(
        appBar: ApplicationToolbar(
            appbarTitle: getTranslated(context, LangConst.labelForgotPassword1).toString()),
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
                          padding: const EdgeInsets.all(40.0),
                          child: Image.asset(
                            'images/ic_email.png',
                          ),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
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
                                textInputAction: TextInputAction.done,
                                hintText:
                                    getTranslated(context, LangConst.labelEnterYourEmailID).toString(),
                                textInputType: TextInputType.emailAddress,
                                textEditingController: _textEmail,
                                validator: kvalidateEmail,
                              ),
                              SizedBox(
                                height: 30.0,
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 20,right: 20),
                                child: RoundedCornerAppButton(
                                  btnLabel:
                                      getTranslated(context, LangConst.labelSubmitThis).toString(),
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      callSendOTP();
                                    } else {
                                      setState(() {
                                      });
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(25.0),
                          child: Text(
                            getTranslated(context, LangConst.labelChangePasswordBottomline).toString(),
                            style: TextStyle(
                              color: Constants.colorGray,
                              fontSize: 10.0,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        )
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

  Future<BaseModel<SendOTPModel>> callSendOTP() async {
    SendOTPModel response;
    try{
      Constants.onLoading(context);
      Map<String, String> body = {
        'email_id': _textEmail.text,
        'where': 'forgot_password',
      };
      response  = await RestClient(RetroApi().dioData()).sendOtp(body);
      Constants.hideDialog(context);
      print(response.success);
      if (response.success!) {
        Constants.toastMessage('OTP Sent');
        SharedPreferenceUtil.putString(Constants.loginUserId, response.data!.id.toString());
        Navigator.of(context).push(
          Transitions(
            transitionType: TransitionType.fade,
            curve: Curves.bounceInOut,
            reverseCurve: Curves.fastLinearToSlowEaseIn,
            widget: OTPScreen(
              isFromRegistration: false,
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
