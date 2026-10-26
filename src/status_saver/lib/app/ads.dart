import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:status_saver/constants/app_constants.dart';
import 'package:status_saver/models/app_model.dart';

/// AdMob integration (banner, interstitial, rewarded).
///
/// Debug builds always use Google's official test ad units, so testing never
/// serves real ads (clicking your own real ads can get the AdMob account
/// banned). Release builds use the IDs from `app_constants.dart`.
class Ads {
  static const _testBanner = 'ca-app-pub-3940256099942544/6300978111';
  static const _testInterstitial = 'ca-app-pub-3940256099942544/1033173712';
  static const _testRewarded = 'ca-app-pub-3940256099942544/5224354917';

  static String get bannerId => kReleaseMode ? ADMOB_BANNER_ID : _testBanner;
  static String get interstitialId =>
      kReleaseMode ? ADMOB_INTERSTITIAL_ID : _testInterstitial;
  static String get rewardedId =>
      kReleaseMode ? ADMOB_REWARDED_VIDEO_ID : _testRewarded;

  /// Minimum time between two interstitials, so saving several statuses in a
  /// row doesn't show an ad every time.
  static const _interstitialCooldown = Duration(minutes: 2);

  static InterstitialAd? _interstitial;
  static DateTime? _lastInterstitial;
  static bool _initialized = false;

  /// Ads are hidden for users who bought "remove ads" and during a rewarded
  /// ad-free period.
  static bool get enabled => AppModel().showAds && !AppModel().isRewarded;

  /// Ask for GDPR/UMP consent where required, then start the Mobile Ads SDK.
  /// Safe to call more than once.
  static Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    ConsentInformation.instance.requestConsentInfoUpdate(
      ConsentRequestParameters(),
      () => ConsentForm.loadAndShowConsentFormIfRequired((_) => _startSdk()),
      (_) => _startSdk(),
    );
  }

  static Future<void> _startSdk() async {
    if (!await ConsentInformation.instance.canRequestAds()) return;
    await MobileAds.instance.initialize();
    loadInterstitial();
  }

  /// Preload an interstitial so it is ready when needed.
  static void loadInterstitial() {
    if (!enabled || _interstitial != null) return;
    InterstitialAd.load(
      adUnitId: interstitialId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitial = ad,
        onAdFailedToLoad: (error) =>
            debugPrint('Interstitial failed to load: $error'),
      ),
    );
  }

  /// Show the preloaded interstitial (respecting the cooldown) and preload the
  /// next one.
  static void showInterstitial() {
    final ad = _interstitial;
    final last = _lastInterstitial;
    if (!enabled || ad == null) return;
    if (last != null && DateTime.now().difference(last) < _interstitialCooldown) {
      return;
    }
    _interstitial = null;
    _lastInterstitial = DateTime.now();
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
  }
}

/// Adaptive banner that hides itself when ads are disabled.
class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _banner;
  bool _loaded = false;
  bool _requested = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_requested && Ads.enabled) {
      _requested = true;
      _load(MediaQuery.of(context).size.width.truncate());
    }
  }

  Future<void> _load(int width) async {
    final size =
        await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(width);
    if (!mounted || size == null) return;
    final banner = BannerAd(
      adUnitId: Ads.bannerId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _loaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          debugPrint('Banner failed to load: $error');
        },
      ),
    );
    _banner = banner;
    banner.load();
  }

  @override
  void dispose() {
    _banner?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<AppModel>(
      builder: (context, child, model) {
        final banner = _banner;
        if (!_loaded || banner == null || !Ads.enabled) {
          return const SizedBox.shrink();
        }
        return SafeArea(
          top: false,
          child: SizedBox(
            width: banner.size.width.toDouble(),
            height: banner.size.height.toDouble(),
            child: AdWidget(ad: banner),
          ),
        );
      },
    );
  }
}
