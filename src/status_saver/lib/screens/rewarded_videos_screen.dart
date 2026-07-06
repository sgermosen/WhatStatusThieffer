import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:status_saver/app/app_localizations.dart';
import 'package:status_saver/constants/app_constants.dart';
import 'package:status_saver/main.dart';
import 'package:status_saver/models/app_model.dart';
import 'package:status_saver/screens/start_screen.dart';
import 'package:status_saver/widgets/rewarded_counter.dart';

/// Lets the user watch a rewarded ad to unlock a few minutes without ads and
/// without the watermark (see AppModel.isRewarded / rewardedTimer).
class RewardedVideosScreen extends StatefulWidget {
  @override
  _RewardedVideosScreenState createState() => _RewardedVideosScreenState();
}

class _RewardedVideosScreenState extends State<RewardedVideosScreen> {
  RewardedAd _rewardedAd;
  bool _isLoaded = false;
  bool _isLoading = false;

  /// Go back to the start screen when the rewarded time ends.
  void _goToStartScreen() {
    Future(() {
      navigatorKey.currentState.pushAndRemoveUntil(
          new MaterialPageRoute(builder: (context) => StartScreen()),
          (Route r) => false);
    });
  }

  /// Load a rewarded ad.
  void _loadVideoAd(AppLocalizations i18n) {
    setState(() => _isLoading = true);
    RewardedAd.load(
      adUnitId: ADMOB_REWARDED_VIDEO_ID,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          Fluttertoast.showToast(
              backgroundColor: Colors.red,
              msg: i18n.translate('video_loaded'));
          if (mounted)
            setState(() {
              _isLoaded = true;
              _isLoading = false;
            });
        },
        onAdFailedToLoad: (error) {
          _rewardedAd = null;
          if (mounted)
            setState(() {
              _isLoaded = false;
              _isLoading = false;
            });
        },
      ),
    );
  }

  /// Show the loaded rewarded ad and deliver the reward.
  void _showVideoAd() {
    final RewardedAd ad = _rewardedAd;
    if (ad == null) return;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) => ad.dispose(),
      onAdFailedToShowFullScreenContent: (ad, error) => ad.dispose(),
    );
    ad.show(onUserEarnedReward: (ad, reward) {
      // Grant the reward minutes and start the countdown.
      AppModel().updateRewarded(true, REWARDED_MINUTES);
      AppModel().rewardedTimer(onEndTimer: _goToStartScreen);
    });
    _rewardedAd = null;
    if (mounted) setState(() => _isLoaded = false);
  }

  @override
  void dispose() {
    if (_rewardedAd != null) _rewardedAd.dispose();
    super.dispose();
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
                    onPressed: (_isLoaded || _isLoading)
                        ? null
                        : () => _loadVideoAd(i18n),
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
