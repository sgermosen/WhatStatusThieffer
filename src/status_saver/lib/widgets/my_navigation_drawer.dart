import 'package:flutter/material.dart';
import 'package:status_saver/app/ads.dart';
import 'package:status_saver/app/app.dart';
import 'package:status_saver/constants/app_constants.dart';
import 'package:status_saver/models/app_model.dart';
import 'package:status_saver/screens/about_us_screen.dart';
import 'package:status_saver/screens/app_settings_screen.dart';
import 'package:status_saver/screens/guide_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:status_saver/screens/remove_ads_screen.dart';
import 'package:status_saver/screens/remove_watermark.dart';
import 'package:status_saver/app/app_localizations.dart';
import 'package:status_saver/screens/rewarded_videos_screen.dart';

class MyNavigationDrawer extends StatelessWidget {
  // Variables
  final _menutextcolor = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w500,
  );

  final App _app = new App();

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);
    return ListView(
      padding: EdgeInsets.all(0),
      children: <Widget>[
        /// DrawerHeader
        _drawerHeader(context),

        /// *** New features *** ///
        ListTile(
          leading: Icon(Icons.block),
          title: Text(
            i18n.translate('remove_ads'),
          ),
          trailing: Icon(Icons.arrow_forward),
          onTap: () {
            // Go to Remove Ads screen
            Navigator.push(context,
                new MaterialPageRoute(builder: (context) => RemoveAdsScreen()));
          },
        ),

        ListTile(
          leading: Icon(Icons.copyright),
          title:
              Text(i18n.translate('remove_watermark'), style: _menutextcolor),
          trailing: Icon(Icons.arrow_forward),
          onTap: () {
            // Go to Remove Watermark screen
            Navigator.push(
                context,
                new MaterialPageRoute(
                    builder: (context) => RemoveWatermarkScreen()));
          },
        ),

        ListTile(
          leading: Icon(Icons.settings),
          title: Text(i18n.translate('app_settings'), style: _menutextcolor),
          trailing: Icon(Icons.arrow_forward),
          onTap: () {
            // Go to app settings screen
            Navigator.push(
                context,
                new MaterialPageRoute(
                    builder: (context) => AppSettingsScreen()));
          },
        ),

        ListTile(
          leading: Icon(Icons.play_circle_fill, color: Colors.red),
          title: Text(i18n.translate('rewarded_videos'), style: _menutextcolor),
          trailing: Icon(Icons.arrow_forward),
          onTap: () async {
            // Go to Rewarded Videos screen
            await Navigator.of(context)
                .push(new MaterialPageRoute(
                    builder: (context) => RewardedVideosScreen()))
                .then((_) {
              // Check to hide Banner Ads
              if (AppModel().isRewarded) {
                Ads.disposeBannerAd();
              }
            });
          },
        ),

        /// *** End new features
        ///
        Divider(thickness: 1),
        ListTile(
          leading: Icon(Icons.help_outline),
          title: Text(i18n.translate('how_it_works'), style: _menutextcolor),
          onTap: () {
            // Go to guide page
            Navigator.push(context,
                new MaterialPageRoute(builder: (context) => GuideScreen()));
          },
        ),
        ListTile(
          leading: Icon(Icons.info),
          title: Text(i18n.translate('about_us'), style: _menutextcolor),
          onTap: () {
            // Go to privacy policy
            Navigator.push(context,
                new MaterialPageRoute(builder: (context) => AboutScreen()));
          },
        ),
        ListTile(
          leading: Icon(Icons.share),
          title: Text(i18n.translate('share_with_your_friends'),
              style: _menutextcolor),
          onTap: () {
            /// Share app
            _app.shareApp(context);
          },
        ),
        ListTile(
          leading: Icon(FontAwesomeIcons.facebook, color: Colors.blue),
          title: Text(i18n.translate('like_our_page'), style: _menutextcolor),
          subtitle: Text(
            '@$FACEBOOK_USERNAME',
            style: TextStyle(fontSize: 16),
          ),
          onTap: () {
            /// Share app
            _app.openFacebook();
          },
        ),
        ListTile(
          leading: Icon(Icons.rate_review),
          title:
              Text(i18n.translate('rate_on_play_store'), style: _menutextcolor),
          onTap: () async {
            /// Go to play store
            _app.goToPlayStore();
          },
        ),
        ListTile(
          leading: Icon(Icons.security),
          title: Text(i18n.translate('privacy_policy'), style: _menutextcolor),
          onTap: () async {
            // Go to privacy policy page
            _app.openPrivacyPage();
          },
        ),
        Container(height: 65),
      ],
    );
  }

  /// DrawerHeader
  Widget _drawerHeader(BuildContext context) {
    final i18n = AppLocalizations.of(context);
    return SafeArea(
      child: Container(
        color: Colors.teal,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Center(child: _app.getAppLogo(width: 80, height: 80)),
            SizedBox(height: 5),
            Text(APP_NAME,
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold)),
            SizedBox(height: 5),
            Text(
              i18n.translate('app_short_description'),
              style: TextStyle(fontSize: 18, color: Colors.white70),
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
  }
}
