import 'package:flutter/material.dart';
import 'package:status_saver/app/ads.dart';
import 'package:status_saver/models/media_platform.dart';
import 'package:status_saver/tabs/saved_status_tab.dart';
import 'package:status_saver/tabs/videos_tab.dart';
import 'package:status_saver/widgets/my_navigation_drawer.dart';
import 'package:status_saver/tabs/photos_tab.dart';
import 'package:status_saver/app/app_localizations.dart';
import 'package:status_saver/widgets/rewarded_counter.dart';

class HomeScreen extends StatefulWidget {
  // Variables
  final MediaPlatform platform;

  HomeScreen({required this.platform});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late AppLocalizations _i18n;

  // Tabs list
  List<Tab> getTabs() {
    return <Tab>[
      Tab(
          child: Row(
        children: <Widget>[
          Icon(Icons.photo_camera),
          SizedBox(width: 3),
          Text(_i18n.translate('IMAGES')),
        ],
      )),
      Tab(
          child: Row(
        children: <Widget>[
          Icon(Icons.videocam),
          SizedBox(width: 3),
          Text(_i18n.translate('VIDEOS')),
        ],
      )),
      Tab(
          child: Row(
        children: <Widget>[
          Icon(Icons.save_alt),
          SizedBox(width: 3),
          Text(_i18n.translate('SAVED')),
        ],
      )),
    ];
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);
    return DefaultTabController(
      length: getTabs().length,
      child: Scaffold(
        drawer: Drawer(
          child: MyNavigationDrawer(),
        ),
        appBar: AppBar(
          title: Text(_i18n.translate(widget.platform.titleKey)),
          actions: [
            // Rewarded minutes counter
            RewardedMinCounter()
          ],
          bottom: TabBar(tabs: getTabs(), onTap: (int index) {}),
        ),
        body: TabBarView(physics: NeverScrollableScrollPhysics(), children: [
          /// Images tab body
          PhotosTab(app: widget.platform.key),

          /// Videos tab body
          VideosTab(app: widget.platform.key),

          /// Saved Status tab body
          SavedStatusTab(),
        ]),
        // Hidden for users who removed ads or are in a rewarded period.
        bottomNavigationBar: const BannerAdWidget(),
      ),
    );
  }
}
