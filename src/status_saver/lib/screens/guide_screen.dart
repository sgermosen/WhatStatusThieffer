import 'package:flutter/material.dart';
import 'package:status_saver/app/ads.dart';
import 'package:status_saver/app/app_localizations.dart';

class GuideScreen extends StatefulWidget {
  @override
  _GuideScreenState createState() => _GuideScreenState();
}

class _GuideScreenState extends State<GuideScreen> {
  // Variables
  final _guideStyle = TextStyle(fontSize: 18.0);

  @override
  void initState() {
    //Ads.showInterstitialAd();
    super.initState();
  }

  @override
  void dispose() {
    //Ads.disposeInterstitialAd();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(i18n.translate('how_to_use_the_application')),
      ),
      body: SingleChildScrollView(
        padding:
            const EdgeInsets.only(top: 15, left: 10, right: 10, bottom: 65),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Header
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    Icons.help_outline,
                    size: 100,
                    color: Colors.teal,
                  ),
                  Text(i18n.translate('how_does_statusapp_work'),
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ))
                ],
              ),
            ),
            SizedBox(height: 20),
            // Number 1 - required to do
            _guideNumber('1*', i18n.translate('view_your_whatsapp_status')),
            // Instructions
            Text(i18n.translate('first_open_your_whatsapp'),
                style: _guideStyle),
            Divider(thickness: 1),
            Center(child: Image.asset('assets/images/status_guide.jpg')),
            Divider(thickness: 1),
            //Number 2 - required to do
            _guideNumber('2*', i18n.translate('save_whatsapp_status')),
            Text(i18n.translate('go_back_to_the_statusapp'),
                style: _guideStyle),
            Divider(thickness: 1),
            // Number 3
            _guideNumber('3', i18n.translate('saved_status')),
            Text(i18n.translate('to_view_all_the_statuses_saved'),
                style: _guideStyle),
            Divider(thickness: 1),
            // The END
            Center(
              child: Text(
                '*** ${i18n.translate('END')} ***',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _guideNumber(String number, String title) {
    final style = TextStyle(
        fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal);
    return Row(
      children: <Widget>[
        Text('( $number )', style: style),
        SizedBox(width: 5),
        Text(title, style: style)
      ],
    );
  }
}
