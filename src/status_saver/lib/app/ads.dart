import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:status_saver/constants/app_constants.dart';
import 'package:status_saver/models/app_model.dart';

/// AdMob helper (google_mobile_ads).
///
/// Ad unit IDs come from `app_constants.dart`. For local testing replace them
/// with Google's official test IDs so you don't risk your AdMob account with
/// invalid clicks (see docs/GUIA_PUBLICACION_PLAYSTORE.md §6).
class Ads {
  static InterstitialAd _interstitial;
  static bool _initialized = false;

  /// Initialize the Mobile Ads SDK and preload an interstitial.
  /// Call once at app startup.
  static Future<void> initialize() async {
    if (_initialized) return;
    await MobileAds.instance.initialize();
    _initialized = true;
    loadInterstitial();
  }

  /// Create a banner ad. The caller is responsible for loading it (`load()`),
  /// rendering it with `AdWidget`, and disposing it.
  static BannerAd createBanner({BannerAdListener listener}) {
    return BannerAd(
      adUnitId: ADMOB_BANNER_ID,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: listener ??
          BannerAdListener(
            onAdFailedToLoad: (ad, error) => ad.dispose(),
          ),
    );
  }

  /// Preload an interstitial so it is ready to show instantly.
  static void loadInterstitial() {
    InterstitialAd.load(
      adUnitId: ADMOB_INTERSTITIAL_ID,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitial = ad,
        onAdFailedToLoad: (error) => _interstitial = null,
      ),
    );
  }

  /// Show the preloaded interstitial (unless the user removed ads / is
  /// rewarded), then preload the next one.
  static void showInterstitial() {
    if (!AppModel().showAds || AppModel().isRewarded) return;
    final InterstitialAd ad = _interstitial;
    if (ad == null) {
      // Nothing ready; make sure one is loading for next time.
      loadInterstitial();
      return;
    }
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        loadInterstitial();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        loadInterstitial();
      },
    );
    ad.show();
    _interstitial = null;
  }
}
