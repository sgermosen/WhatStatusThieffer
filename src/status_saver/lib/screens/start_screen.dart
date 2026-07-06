import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:status_saver/app/app.dart';
import 'package:status_saver/constants/app_constants.dart';
import 'package:status_saver/models/media_platform.dart';
import 'package:status_saver/screens/download_link_screen.dart';
import 'package:status_saver/screens/home_screen.dart';
import 'package:status_saver/app/app_localizations.dart';
import 'package:status_saver/services/link_downloader.dart';

class StartScreen extends StatefulWidget {
  @override
  _StartScreenState createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  // Variables
  final App _app = new App();

  /// Subscription to links shared into the app while it is running.
  StreamSubscription _intentSub;

  void _initializations() async {
    // Init Admob app
    //  await Ads.initialize();
  }

  @override
  void initState() {
    super.initState();

    /// Initializations
    _initializations();

    /// Listen for links shared into the app
    _initShareIntent();
  }

  @override
  void dispose() {
    if (_intentSub != null) _intentSub.cancel();
    super.dispose();
  }

  /// Handle links shared into the app from the system share sheet.
  void _initShareIntent() {
    // App already running and a link is shared into it.
    _intentSub = ReceiveSharingIntent.getTextStream().listen(
      (String value) => _openSharedLink(value),
      onError: (dynamic err) {
        // Ignore share-intent errors.
      },
    );

    // App launched from a shared link (cold start).
    ReceiveSharingIntent.getInitialText().then((String value) {
      _openSharedLink(value);
      // Avoid re-processing the same intent on rebuilds.
      ReceiveSharingIntent.reset();
    });
  }

  /// Open the download screen prefilled with the shared link (if it is one).
  void _openSharedLink(String value) {
    if (value == null) return;
    if (extractUrl(value) == null) return;
    Future(() {
      if (!mounted) return;
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => DownloadLinkScreen(initialUrl: value)));
    });
  }

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);

    // Build the header widgets followed by one card per supported platform.
    final List<Widget> children = <Widget>[
      /// App logo
      _app.getAppLogo(width: 130, height: 130),
      SizedBox(height: 20),
      Text(
        i18n.translate('select_app_to_view_status'),
        style: TextStyle(fontSize: 18),
        textAlign: TextAlign.center,
      ),
      SizedBox(height: 15),
    ];

    for (final platform in SUPPORTED_PLATFORMS) {
      children.add(_buildPlatformCard(platform));
    }

    // Download-from-link entry point.
    children.add(_buildDownloadLinkCard(i18n));
    children.add(SizedBox(height: 50));

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
            children: children,
          ),
        ),
      ),
    );
  }

  /// Build a selectable card for a given [platform].
  Widget _buildPlatformCard(MediaPlatform platform) {
    final i18n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: GestureDetector(
        child: Card(
          child: ListTile(
            leading: FaIcon(platform.icon, color: platform.color, size: 38),
            title: Text(
              i18n.translate(platform.titleKey),
              style: TextStyle(
                  fontSize: 20,
                  color: Colors.teal,
                  fontWeight: FontWeight.bold),
            ),
            subtitle: Text(i18n.translate('click_here_to_open')),
          ),
        ),
        onTap: () => _goToHomeScreen(platform),
      ),
    );
  }

  /// Card that opens the "Download from link" screen.
  Widget _buildDownloadLinkCard(AppLocalizations i18n) {
    return Padding(
      padding: const EdgeInsets.only(top: 5, bottom: 15),
      child: GestureDetector(
        child: Card(
          color: Colors.teal,
          child: ListTile(
            leading: Icon(Icons.link, color: Colors.white, size: 38),
            title: Text(
              i18n.translate('download_from_link'),
              style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              i18n.translate('paste_a_link_to_download'),
              style: TextStyle(color: Colors.white70),
            ),
          ),
        ),
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => DownloadLinkScreen()));
        },
      ),
    );
  }

  void _goToHomeScreen(MediaPlatform platform) async {
    /// Check permission to access storage dir
    await _app.checkStoragePermission(onGranted: () {
      // Go to home screen
      Future(() {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => HomeScreen(platform: platform)));
      });
    });
  }
}
