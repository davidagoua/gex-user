import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mealup/screen_animation_utils/transitions.dart';
import 'package:mealup/screens/about_app_screen.dart';
import 'package:mealup/screens/about_company_screen.dart';
import 'package:mealup/screens/auth/change_password_user.dart';
import 'package:mealup/screens/faqs_screen.dart';
import 'package:mealup/screens/feedback_and_support_screen.dart';
import 'package:mealup/screens/languages_screen.dart';
import 'package:mealup/screens/privacy_policy_screen.dart';
import 'package:mealup/screens/terms_of_use_screen.dart';
import 'package:mealup/utils/SharedPreferenceUtil.dart';
import 'package:mealup/utils/app_toolbar.dart';
import 'package:mealup/utils/constants.dart';
import 'package:mealup/localization/lang_constant.dart';
import 'package:mealup/localization/localization_constant.dart';
import 'edit_personal_information.dart';
import 'manage_your_location.dart';

class SettingScreen extends StatefulWidget {
  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {

  @override
  Widget build(BuildContext context) {

    return SafeArea(
      child: Scaffold(
        appBar: ApplicationToolbar(
          appbarTitle: getTranslated(context, LangConst.screenSetting).toString(),
        ),
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        SizedBox(
                          height: 10,
                        ),
                        SettingMenuWidget(
                            onClick: () {
                              Navigator.of(context).push(Transitions(
                                  transitionType: TransitionType.fade,
                                  curve: Curves.bounceInOut,
                                  reverseCurve: Curves.fastLinearToSlowEaseIn,
                                  widget: EditProfileInformation()));
                            },
                            strMenuName:
                                getTranslated(context, LangConst.labelEditPersonalInfo).toString()),
                        SettingMenuWidget(
                            onClick: () {
                              Navigator.of(context).push(Transitions(
                                  transitionType: TransitionType.fade,
                                  curve: Curves.bounceInOut,
                                  reverseCurve: Curves.fastLinearToSlowEaseIn,
                                  widget: ManageYourLocation()));
                            },
                            strMenuName:
                                getTranslated(context, LangConst.labelManageYourLocation).toString()),
                        SettingMenuWidget(
                            onClick: () {
                              Navigator.of(context).push(Transitions(
                                  transitionType: TransitionType.fade,
                                  curve: Curves.bounceInOut,
                                  reverseCurve: Curves.fastLinearToSlowEaseIn,
                                  widget: ChangePasswordUser()));
                            },
                            strMenuName:
                                getTranslated(context, LangConst.labelChangePassword).toString()),
                        SettingMenuWidget(
                            onClick: () {
                              Navigator.of(context).push(Transitions(
                                  transitionType: TransitionType.fade,
                                  curve: Curves.bounceInOut,
                                  reverseCurve: Curves.fastLinearToSlowEaseIn,
                                  widget: LanguagesScreen()));
                            },
                            strMenuName: getTranslated(context, LangConst.labelLanguage).toString()),
                        SettingMenuWidget(
                            onClick: () {
                              Navigator.of(context).push(Transitions(
                                  transitionType: TransitionType.fade,
                                  curve: Curves.bounceInOut,
                                  reverseCurve: Curves.fastLinearToSlowEaseIn,
                                  widget: AboutApp()));
                            },
                            strMenuName: getTranslated(context, LangConst.labelAboutApp).toString()),
                        SettingMenuWidget(
                            onClick: () {
                              Navigator.of(context).push(Transitions(
                                  transitionType: TransitionType.fade,
                                  curve: Curves.bounceInOut,
                                  reverseCurve: Curves.fastLinearToSlowEaseIn,
                                  widget: AboutCompanyScreen()));
                            },
                            strMenuName:
                                getTranslated(context, LangConst.labelAboutCompany).toString()),
                        SettingMenuWidget(
                            onClick: () {
                              Navigator.of(context).push(Transitions(
                                  transitionType: TransitionType.fade,
                                  curve: Curves.bounceInOut,
                                  reverseCurve: Curves.fastLinearToSlowEaseIn,
                                  widget: PrivacyPolicyScreen()));
                            },
                            strMenuName:
                                getTranslated(context, LangConst.labelPrivacyPolicy).toString()),
                        SettingMenuWidget(
                            onClick: () {
                              Navigator.of(context).push(Transitions(
                                  transitionType: TransitionType.fade,
                                  curve: Curves.bounceInOut,
                                  reverseCurve: Curves.fastLinearToSlowEaseIn,
                                  widget: TermsOfUseScreen()));
                            },
                            strMenuName: getTranslated(context, LangConst.labelTermOfUse).toString()),
                        SettingMenuWidget(
                            onClick: () {
                              Navigator.of(context).push(Transitions(
                                  transitionType: TransitionType.fade,
                                  curve: Curves.bounceInOut,
                                  reverseCurve: Curves.fastLinearToSlowEaseIn,
                                  widget: FeedbackAndSupportScreen()));
                            },
                            strMenuName:
                                getTranslated(context, LangConst.labelFeedbacknSup).toString()),
                        SettingMenuWidget(
                            onClick: () {
                              Navigator.of(context).push(Transitions(
                                  transitionType: TransitionType.fade,
                                  curve: Curves.bounceInOut,
                                  reverseCurve: Curves.fastLinearToSlowEaseIn,
                                  widget: FAQsScreen()));
                            },
                            strMenuName:
                            getTranslated(context, LangConst.labelFAQs).toString()),
                        Padding(
                          padding: const EdgeInsets.only(top: 30, bottom: 50),
                          child: Text(
                            getTranslated(context, LangConst.labelMealupAppVersion).toString() +
                                SharedPreferenceUtil.getString(Constants.appSettingAndroidCustomerVersion),
                            style: TextStyle(
                                color: Constants.colorGray,
                                fontSize: ScreenUtil().setSp(12),
                                fontFamily: Constants.appFont),
                            textAlign: TextAlign.center,
                          ),
                        )
                      ],
                    ),
                  )),
            );
          },
        ),
      ),
    );
  }

}

// ignore: must_be_immutable
class SettingMenuWidget extends StatelessWidget {
  Function onClick;
  String? strImagePath, strMenuName;

  SettingMenuWidget({required this.onClick, required this.strMenuName});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onClick as void Function()?,
      child: Container(
        height: 60,
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                margin: EdgeInsets.only(top: 10),
                child: Text(
                  strMenuName!,
                  style:
                      TextStyle(fontSize: 16, fontFamily: Constants.appFont),
                ),
              ),
              Container(
                alignment: Alignment.center,
                child: Divider(
                  thickness: 1,
                  color: Color(0xffcccccc),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
