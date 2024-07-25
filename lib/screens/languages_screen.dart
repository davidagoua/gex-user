import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mealup/localization/language_class.dart';
import 'package:mealup/main.dart';
import 'package:mealup/utils/SharedPreferenceUtil.dart';
import 'package:mealup/utils/app_toolbar.dart';
import 'package:mealup/utils/constants.dart';
import 'package:mealup/localization/lang_constant.dart';
import 'package:mealup/localization/localization_constant.dart';


class LanguagesScreen extends StatefulWidget {
  @override
  _LanguagesScreenState createState() => _LanguagesScreenState();
}

class _LanguagesScreenState extends State<LanguagesScreen> {

  int radioindex = 0;

  void changeIndex(int index) {
    setState(() {
      radioindex = index;
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
      borderRadius: BorderRadius.all(Radius.circular(8.0)),
    );
  }

  @override
  void initState() {
    super.initState();
    // getLanguageList();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: Size(360, 690));

    return SafeArea(
      child: Scaffold(
        appBar: ApplicationToolbar(
          appbarTitle: getTranslated(context, LangConst.labelLanguage).toString(),
        ),
        body: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
            image: AssetImage('images/ic_background_image.png'),
            fit: BoxFit.cover,
          )),
          child: ListView.builder(
              physics: ClampingScrollPhysics(),
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              itemCount: Language.languageList().length,
              itemBuilder: (BuildContext context, int index) => InkWell(
                    onTap: () async {
                      changeIndex(index);
                      Locale local = await setLocale(Language.languageList()[index].languageCode);
                      setState(() {
                        MyApp.setLocale(context, local);
                        SharedPreferenceUtil.putString(Constants.currentLanguageCode,Language.languageList()[index].languageCode);
                        Navigator.of(context).pop();
                      });
                    },
                    child: Padding(
                      padding: EdgeInsets.only(
                          left: ScreenUtil().setWidth(20),
                          bottom: ScreenUtil().setHeight(10),
                          top: ScreenUtil().setHeight(20)),
                      child: Row(
                        children: [
                          SharedPreferenceUtil.getString(Constants.currentLanguageCode) == 'N/A'
                                  && index == 0 || SharedPreferenceUtil.getString(Constants.currentLanguageCode) == Language.languageList()[index].languageCode
                          ? getChecked() 
                          : getunChecked(),
                          Padding(
                            padding: EdgeInsets.only(
                                left: ScreenUtil().setWidth(10)),
                            child: Text(
                              Language.languageList()[index].name,
                              style: TextStyle(
                                  fontFamily: Constants.appFont,
                                  fontWeight: FontWeight.w900,
                                  fontSize: ScreenUtil().setSp(14),),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )),
        ),
      ),
    );
  }
}


