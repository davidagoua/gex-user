import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:mealup/localization/lang_localizations.dart';
import 'package:mealup/localization/localization_constant.dart';
import 'package:mealup/model/cartmodel.dart';
import 'package:mealup/screens/splash_screen.dart';
import 'package:mealup/utils/SharedPreferenceUtil.dart';
import 'package:mealup/utils/constants.dart';
import 'package:mealup/utils/preference_utils.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:scoped_model/scoped_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // System Navigation Bar white color

  await SharedPreferenceUtil.getInstance();
  await PreferenceUtils.init();
  HttpOverrides.global = MyHttpOverrides();
  Stripe.publishableKey = PreferenceUtils.getString(Constants.appStripePublishKey).isNotEmpty
      ? PreferenceUtils.getString(Constants.appStripePublishKey)
      : 'N/A';
  Stripe.merchantIdentifier = 'merchant.flutter.stripe.test';
  Stripe.urlScheme = 'flutterstripe';
  await Stripe.instance.applySettings();
  runApp(MyApp(
    model: CartModel(),
  ));
}

class MyApp extends StatefulWidget {
  final CartModel model;

  const MyApp({Key? key, required this.model}) : super(key: key);

  static void setLocale(BuildContext context, Locale newLocale) {
    var state = context.findAncestorStateOfType<_MyAppState>()!;
    state.setLocale(newLocale);
  }

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  void didChangeDependencies() async {
    getLocale().then((locale) {
      setState(() {
        _locale = locale;
      });
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshConfiguration(
      footerTriggerDistance: 15,
      dragSpeedRatio: 0.91,
      headerBuilder: () => MaterialClassicHeader(),
      footerBuilder: () => ClassicFooter(),
      enableLoadingWhenNoData: true,
      enableRefreshVibrate: false,
      enableLoadMoreVibrate: false,
      child: ScopedModel<CartModel>(
        model: widget.model,
        child: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
            systemNavigationBarColor: Theme.of(context).brightness == Brightness.light ? Colors.white : Colors.black,
            systemNavigationBarIconBrightness: Brightness.dark,
          ),
          child: MaterialApp(
            locale: _locale,
            supportedLocales: [
              Locale(ENGLISH, 'US'),
              Locale(SPANISH, 'ES'),
              Locale(ARABIC, 'AE'),
              //*         Uncomment Below Code If you are adding new language
              //          Locale(YOUR_LANGUAGE, 'LANGUAGE_CODE'),
            ],
            localizationsDelegates: [
              LanguageLocalization.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            localeResolutionCallback: (deviceLocal, supportedLocales) {
              for (var local in supportedLocales) {
                if (local.languageCode == deviceLocal!.languageCode && local.countryCode == deviceLocal.countryCode) {
                  return deviceLocal;
                }
              }
              return supportedLocales.first;
            },
            theme: ThemeData(
              brightness: Brightness.light,
              primaryColor: Constants.colorBackground,
              useMaterial3: false,
            ),
            home: SplashScreen(
              model: widget.model,
            ),
            debugShowCheckedModeBanner: false,
          ),
        ),
      ),
    );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)..badCertificateCallback = (X509Certificate cert, host, port) => true;
  }
}
