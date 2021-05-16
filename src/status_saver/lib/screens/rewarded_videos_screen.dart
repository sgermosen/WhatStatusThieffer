import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:status_saver/app/app_localizations.dart';
import 'package:status_saver/constants/app_constants.dart';
import 'package:status_saver/main.dart';
import 'package:status_saver/models/app_model.dart';
import 'package:status_saver/screens/start_screen.dart';
import 'package:status_saver/widgets/rewarded_counter.dart';

class RewardedVideosScreen extends StatefulWidget {
  @override
  _RewardedVideosScreenState createState() => _RewardedVideosScreenState();
}

class _RewardedVideosScreenState extends State<RewardedVideosScreen> {
  // variables
  final _rewardedInstance = RewardedVideoAd.instance;
  bool _isLoaded = false;

  // Go to start screen
  void _goToStartScreen() async {
    Future(() {
      navigatorKey.currentState
          .pushAndRemoveUntil(new MaterialPageRoute(
            builder: (context) => StartScreen()), (Route r) => false);
    });
  }

  void _loadVideoAd(AppLocalizations i18n) async {
    await _rewardedInstance.load(adUnitId: ADMOB_REWARDED_VIDEO_ID);
    // Show message
    Fluttertoast.showToast(
        backgroundColor: Colors.red, msg: i18n.translate('video_loaded'));
    // Update UI
    setState(() => _isLoaded = true);
  }

  void _showVideoAd() async {
    await _rewardedInstance
        .show()
        .catchError((e) => print("error in showing ad: ${e.toString()}"));
  }

  void _deliverUserReward() {
    _rewardedInstance.listener =
        (RewardedVideoAdEvent event, {String rewardType, int rewardAmount}) {
      if (event == RewardedVideoAdEvent.rewarded) {
        //print('rewardType: $rewardType, rewardAmount: $rewardAmount');
        // Update UI
        AppModel().updateRewarded(true, REWARDED_MINUTES);
        // Start count down
        AppModel().rewardedTimer(onEndTimer: () {
          // Go to start screen when end reward timer
          _goToStartScreen();
        });
        // Update UI
        setState(() => _isLoaded = false);
      }
    };
  }

  @override
  void initState() {
    super.initState();
    _deliverUserReward();
  }

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(i18n.translate('rewarded_videos')),
        actions: [
          // Rewarded minutes counter
          RewardedMinCounter()
        ],
      ),
      backgroundColor: Colors.grey[400],
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(8, 10, 8, 8),
        child: Column(
          children: [
            // Header message
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text(
                        i18n.translate(
                            'watch_the_video_ads_and_get_a_few_minutes_to_use_our_app_without_ads_and_watermark_processing'),
                        style: TextStyle(fontSize: 18),
                        textAlign: TextAlign.center),
                    Divider(thickness: 1),
                    Text(
                        i18n
                            .translate(
                                'get_minutes_per_video_and_feel_the_power_of_our_app')
                            .replaceFirst(
                                '{rewarded_min}', REWARDED_MINUTES.toString()),
                        style: TextStyle(fontSize: 18),
                        textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
            Divider(),
            // Rewarded videos ads
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Load the video
                FlatButton.icon(
                    textColor: Colors.white,
                    color: Colors.teal,
                    onPressed: _isLoaded ? null : () => _loadVideoAd(i18n),
                    icon: Icon(Icons.refresh),
                    label: Text(i18n.translate('load_video'))),

                // Watch the video
                FlatButton.icon(
                    textColor: Colors.white,
                    color: Colors.red,
                    onPressed: _isLoaded ? () => _showVideoAd() : null,
                    icon: Icon(Icons.play_arrow),
                    label: Text(i18n.translate('watch_video'))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
