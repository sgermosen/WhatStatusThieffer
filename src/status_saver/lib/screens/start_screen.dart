import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:status_saver/app/app.dart';
import 'package:status_saver/constants/app_constants.dart';
import 'package:status_saver/models/media_platform.dart';
import 'package:status_saver/screens/home_screen.dart';
import 'package:status_saver/app/app_localizations.dart';

class StartScreen extends StatefulWidget {
  @override
  _StartScreenState createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  // Variables
  final App _app = new App();

  void _initializations() async {
    // Init Admob app
    //  await Ads.initialize();
  }

  @override
  void initState() {
    super.initState();

    /// Initializations
    _initializations();
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
