import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:mealup/localization/localization_constant.dart';

class LanguageLocalization {
  final Locale locale;

  LanguageLocalization(this.locale);

  static LanguageLocalization? of(BuildContext context) {
    return Localizations.of<LanguageLocalization>(
        context, LanguageLocalization);
  }

  late Map<String, String> _localizationValue;

  Future load() async {
    String jsonStringValue = await rootBundle.loadString(
        'lib/localization/languages/${locale.languageCode.toString()}.json');

    Map<String, dynamic> mappedJson = json.decode(jsonStringValue);

    _localizationValue = mappedJson.map((key, value) => MapEntry(key, value));
  }

  String? getTranslateValue(String key) {
    return _localizationValue[key];
  }

  static const LocalizationsDelegate<LanguageLocalization> delegate =
      _LanguageLocalizationDelegate();
}

class _LanguageLocalizationDelegate
    extends LocalizationsDelegate<LanguageLocalization> {
  const _LanguageLocalizationDelegate();

  @override
  bool isSupported(Locale locale) {
    return [
      ENGLISH,
      ARABIC,
      SPANISH,
      FRENCH,
//*   Uncomment Below Code And Replace With Your Language Name If You are adding new language :      
//    YOUR_LANGUAGE_NAME,      
    ].contains(locale.languageCode);
  }

  @override
  Future<LanguageLocalization> load(Locale locale) async {
    LanguageLocalization localization = new LanguageLocalization(locale);
    await localization.load();
    return localization;
  }

  @override
  bool shouldReload(_LanguageLocalizationDelegate old) => false;
}
