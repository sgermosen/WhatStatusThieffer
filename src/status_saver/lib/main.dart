import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
// import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:status_saver/app/app.dart';
import 'package:status_saver/app/app_localizations.dart';
import 'package:status_saver/constants/app_constants.dart';
import 'package:status_saver/models/app_model.dart';
import 'package:status_saver/screens/start_screen.dart';
//import 'package:in_app_purchase_android/in_app_purchase_android.dart';

void main() async {
  // For play billing library 2.0 on Android, it is mandatory to call
  // [enablePendingPurchases](https://developer.android.com/reference/com/android/billingclient/api/BillingClient.Builder.html#enablependingpurchases)
  // as part of initializing the app.
  // InAppPurchaseConnection.enablePendingPurchases();
  if (defaultTargetPlatform == TargetPlatform.android) {
    //InAppPurchaseAndroidPlatformAddition.enablePendingPurchases();
  }
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

// Global navigator
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class _MyAppState extends State<MyApp> {
  // Variables
  final App _app = new App();

  @override
  void initState() {
    super.initState();
    // Get app theme
    _app.getDarkTheme().then((value) {
      print('isDarkThemeEnabled: $value');
      // Update UI
      AppModel().updateAppTheme(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<AppModel>(
      model: AppModel(),
      child:
          ScopedModelDescendant<AppModel>(builder: (context, child, appModel) {
        return MaterialApp(
          navigatorKey: navigatorKey,
          title: APP_NAME,
          theme: ThemeData(
              primarySwatch: Colors.teal,
              brightness: appModel.isDarkThemeEnabled
                  ? Brightness.dark
                  : Brightness.light),
          debugShowCheckedModeBanner: false,
          home: StartScreen(),

          /// Setup translations
          localizationsDelegates: [
            // AppLocalizations is where the lang translations is loaded
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: SUPPORTED_LOCALES,
          // Returns a locale which will be used by the app
          localeResolutionCallback: (locale, supportedLocales) {
            // Check if the current device locale is supported
            for (var supportedLocale in supportedLocales) {
              if (supportedLocale.languageCode == locale.languageCode) {
                return supportedLocale;
              }
            }
            // If the locale of the device is not supported, use the first one
            // from the list (English, in this case).
            return supportedLocales.first;
          },

          /// End translations setup
        );
      }),
    );
  }
}
