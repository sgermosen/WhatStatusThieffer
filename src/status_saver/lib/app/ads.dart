import 'package:firebase_admob/firebase_admob.dart';
import 'package:status_saver/constants/app_constants.dart';
import 'package:status_saver/models/app_model.dart';

class Ads {
  // Variables
  static BannerAd _bannerAd;
  static InterstitialAd _interstitialAd;

  static Future<void> initialize() async {
    FirebaseAdMob.instance.initialize(appId: ADMOB_APP_ID);
  }

  /// Setup admob info
  static final MobileAdTargetingInfo _targetingInfo = new MobileAdTargetingInfo(
    childDirected: false,
  );

  // Create Banner Ad
  static BannerAd _createBannerAd() {
    return BannerAd(
      adUnitId: ADMOB_BANNER_ID,
      size: AdSize.banner,
      targetingInfo: _targetingInfo,
      listener: (MobileAdEvent event) {
        //print("BannerAd event $event");
      },
    );
  }

  /// Create Interstitial Ad
  static InterstitialAd _createInterstitialAd() {
    return new InterstitialAd(
        adUnitId: ADMOB_INTERSTITIAL_ID,
        targetingInfo: _targetingInfo,
        listener: (MobileAdEvent event) {
          //  print('InterstitialAd MobileAdEvent: $event');
        });
  }

  // Show Banner Ad
  static void showBannerAd({bool showAds}) {
    // Get show ads value
    bool _showAds = showAds ?? AppModel().showAds;

    /// Check Active Remove-Ads Subscription
    if (_showAds && !AppModel().isRewarded) {
      if (_bannerAd == null) _bannerAd = _createBannerAd();
      _bannerAd
        ..load()
        ..show(anchorOffset: 0.0, anchorType: AnchorType.bottom);
    }
  }

  // Show Interstitial Ad
  static void showInterstitialAd() {
    /// Check Active Remove-Ads Subscription
    if (AppModel().showAds && !AppModel().isRewarded) {
      if (_interstitialAd == null) _interstitialAd = _createInterstitialAd();
      _interstitialAd
        ..load()
        ..show();
    }
  }

  // Dispose Banner Ad
  static void disposeBannerAd() async {
    await _bannerAd?.dispose();
    _bannerAd = null;
  }

  // Dispose Interstitial Ad
  static void disposeInterstitialAd() async {
    await _interstitialAd?.dispose();
    _interstitialAd = null;
  }

}
