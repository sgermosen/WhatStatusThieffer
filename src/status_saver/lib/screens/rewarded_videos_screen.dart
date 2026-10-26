import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:status_saver/app/ads.dart';
import 'package:status_saver/app/app_localizations.dart';
import 'package:status_saver/constants/app_constants.dart';
import 'package:status_saver/models/app_model.dart';
import 'package:status_saver/widgets/rewarded_counter.dart';

/// Watch a rewarded video to use the app without ads for [REWARDED_MINUTES].
class RewardedVideosScreen extends StatefulWidget {
  const RewardedVideosScreen({super.key});

  @override
  State<RewardedVideosScreen> createState() => _RewardedVideosScreenState();
}

class _RewardedVideosScreenState extends State<RewardedVideosScreen> {
  RewardedAd? _rewardedAd;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadVideoAd();
  }

  void _loadVideoAd() {
    setState(() => _loading = true);
    RewardedAd.load(
      adUnitId: Ads.rewardedId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          setState(() {
            _rewardedAd = ad;
            _loading = false;
          });
        },
        onAdFailedToLoad: (error) {
          debugPrint('Rewarded ad failed to load: $error');
          if (mounted) setState(() => _loading = false);
        },
      ),
    );
  }

  void _showVideoAd() {
    final ad = _rewardedAd;
    if (ad == null) return;
    setState(() => _rewardedAd = null);
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) => ad.dispose(),
      onAdFailedToShowFullScreenContent: (ad, error) => ad.dispose(),
    );
    ad.show(onUserEarnedReward: (_, __) {
      AppModel().updateRewarded(true, REWARDED_MINUTES);
      AppModel().rewardedTimer(onEndTimer: () {});
    });
  }

  @override
  void dispose() {
    _rewardedAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(i18n.translate('rewarded_videos')),
        actions: [RewardedMinCounter()],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(8, 10, 8, 8),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text(
                        i18n.translate(
                            'watch_the_video_ads_and_get_a_few_minutes_to_use_our_app_without_ads_and_watermark_processing'),
                        style: const TextStyle(fontSize: 18),
                        textAlign: TextAlign.center),
                    const Divider(thickness: 1),
                    Text(
                        i18n
                            .translate(
                                'get_minutes_per_video_and_feel_the_power_of_our_app')
                            .replaceFirst(
                                '{rewarded_min}', REWARDED_MINUTES.toString()),
                        style: const TextStyle(fontSize: 18),
                        textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                FilledButton.icon(
                  style: FilledButton.styleFrom(backgroundColor: Colors.teal),
                  onPressed: (_loading || _rewardedAd != null)
                      ? null
                      : _loadVideoAd,
                  icon: const Icon(Icons.refresh),
                  label: Text(i18n.translate('load_video')),
                ),
                FilledButton.icon(
                  style: FilledButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: _rewardedAd != null ? _showVideoAd : null,
                  icon: const Icon(Icons.play_arrow),
                  label: Text(i18n.translate('watch_video')),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
