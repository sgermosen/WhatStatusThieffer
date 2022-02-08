import 'package:flutter/material.dart';
import 'package:status_saver/app/ads.dart';
import 'package:status_saver/app/app.dart';
import 'package:status_saver/constants/app_constants.dart';
import 'package:status_saver/notifications/NotificationManager.dart';
import 'package:status_saver/screens/home_screen.dart';
import 'package:status_saver/app/app_localizations.dart';

class StartScreen extends StatefulWidget {
  @override
  _StartScreenState createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  // Variables
  //final NotificationManager _notificationManager = new NotificationManager();
  final App _app = new App();

  void _initializations() async {
    // Init Admob app
    //  await Ads.initialize();

    // Schedule notification reminder
    //  Future.delayed(Duration.zero, () {
    //  _notificationManager.showPeriodicallyNotification(context);
    //   });
  }

  @override
  void initState() {
    super.initState();

    /// Inawaititializations
    _initializations();
  }

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(APP_NAME),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          color: Colors.grey.withAlpha(70),
          child: Column(
            children: <Widget>[
              /// App logo
              _app.getAppLogo(width: 130, height: 130),
              SizedBox(height: 20),
              Text(
                i18n.translate('select_app_to_view_status'),
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 15),

              /// Open WhatsApp Messenger
              GestureDetector(
                child: Card(
                  child: ListTile(
                    leading: Image.asset(
                        "assets/images/whatsapp_messenger_icon.png"),
                    title: Text(
                      i18n.translate('view_status_of_whatsApp_messenger'),
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.teal,
                          fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(i18n.translate('click_here_to_open')),
                  ),
                ),
                onTap: () async {
                  // Open WhatsApp Business Messenger
                  _goToHomeScreen("WhatsApp");
                },
              ),
              SizedBox(height: 15),

              /// Open WhatsApp Business
              GestureDetector(
                child: Card(
                  child: ListTile(
                    leading:
                        Image.asset("assets/images/whatsapp_business_icon.png"),
                    title: Text(
                      i18n.translate('view_status_of_whatsApp_business'),
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.teal,
                          fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(i18n.translate('click_here_to_open')),
                  ),
                ),
                onTap: () {
                  // Open WhatsApp Business Status
                  _goToHomeScreen("WhatsApp Business");
                },
              ),
              SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  void _goToHomeScreen(String app) async {
    /// Check permission to access storage dir
    await _app.checkStoragePermission(onGranted: () {
      // Go to home screen
      Future(() {
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => HomeScreen(app: app)));
      });
    });
  }
}
