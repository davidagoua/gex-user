import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mealup/localization/lang_localizations.dart';
import 'package:mealup/utils/SharedPreferenceUtil.dart';
import 'package:mealup/utils/constants.dart';

String? getTranslated(BuildContext context, String key) {
  return LanguageLocalization.of(context)!.getTranslateValue(key);
}

const String ENGLISH = "en";
const String ARABIC = "ar";
const String SPANISH = "es";
const String FRENCH = "fr";

//* TO ADD NEW LANGUAGE
//* For Example To add new language to your application, add new line, like this:
//* const String LANGUAGE_NAME = "LANGUAGE_CODE";

Future<Locale> setLocale(String languageCode) async {
  SharedPreferenceUtil.putString(Constants.currentLanguageCode, languageCode);
  return _locale(languageCode);
}

Locale _locale(String languageCode) {
  Locale _temp;
  switch (languageCode) {
    case ENGLISH:
      _temp = Locale(languageCode, 'US');
      break;
    case ARABIC:
      _temp = Locale(languageCode, 'AE');
      break;
    case SPANISH:
      _temp = Locale(languageCode, 'ES');
      break;
    case SPANISH:
      _temp = Locale(languageCode, 'FR');
      break;
      
//*  Uncomment Below Code If You Have Added New Language, And Replace
//*  LANGUGE_NAME and LANGUAGE_CODE With YOUR LANGUAGE_NAME and LANGUAGE_CODE
//    case LANGUAGE_NAME:
//      temp = Locale(languageCode, 'LANGUAGE_CODE');
//      break;


    default:
      _temp = Locale(FRENCH, 'FR');
  }
  return _temp;
}

Future<Locale> getLocale() async {
  String? languageCode = SharedPreferenceUtil.getString(Constants.currentLanguageCode);
  return _locale(languageCode);
}

