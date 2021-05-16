import 'package:flutter/material.dart';
import 'package:status_saver/app/app.dart';
import 'package:status_saver/app/app_localizations.dart';
import 'package:status_saver/constants/app_constants.dart';

class AboutScreen extends StatefulWidget {
  @override
  _AboutScreenState createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  // Variables
  final App _app = new App();

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(i18n.translate('about_us')),
      ),
      body: SingleChildScrollView(
        padding:
            const EdgeInsets.only(top: 25, left: 25, right: 25, bottom: 65),
        child: Center(
          child: Column(
            children: <Widget>[
              /// App icon
              _app.getAppLogo(),
              SizedBox(height: 10),

              /// App name
              Text(
                APP_NAME,
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 5),

              /// App slogan
              Text(i18n.translate('app_short_description'),
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 18,
                  )),
              SizedBox(height: 15),

              /// App full description
              Text(i18n.translate('app_full_description'),
                  style: TextStyle(
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center),
              SizedBox(height: 10),

              /// App version number
              Text(APP_VERSION_NAME,
                  style: TextStyle(fontSize: 20, color: Colors.grey),
                  textAlign: TextAlign.center),

              /// Share app button
              SizedBox(height: 10),
              FlatButton.icon(
                color: Colors.teal,
                textColor: Colors.white,
                icon: Icon(Icons.share),
                label: Text(i18n.translate('share_app'),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    )),
                onPressed: () {
                  /// Share app
                  _app.shareApp(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
