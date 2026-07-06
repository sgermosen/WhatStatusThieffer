import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:status_saver/app/ads.dart';
import 'package:status_saver/constants/app_constants.dart';
import 'package:status_saver/models/app_model.dart';
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

  HomeScreen({@required this.platform});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// Variables
  AppLocalizations _i18n;

  /// Bottom banner ad
  BannerAd _bannerAd;
  bool _bannerLoaded = false;

  /// Check User Active Subsscriptions to Update App UI
  Future<bool> _checkUserActiveSubscriptions() async {
    // Local variables
    bool _showAds = true;

    //   // Query past subscriptions
    //   InAppPurchase.instance
    // //  InAppPurchaseConnection.instance
    //       ///.queryPastPurchases()
    //       //.then((QueryPurchaseDetailsResponse pastPurchases) {
    //     // Chek past purchases result
    //     if (pastPurchases.pastPurchases.isNotEmpty) {
    //       for (var purchase in pastPurchases.pastPurchases) {
    //         debugPrint('User Active Subs sku: ${purchase.productID}');

    //         /// Check Subscription ID to Update App UI
    //         if (purchase.productID.startsWith('ads')) {
    //           // Disable showing Ads
    //           AppModel().disableShowAds();
    //           _showAds = false;
    //         } else if (purchase.productID.startsWith('watermark')) {
    //           // Disable watermarking status
    //           AppModel().disableWatermark();
    //         }
    //       }
    //     }
    //     // else {
    //     //  debugPrint('No Active subscriptions for current User');
    //     // }
    //   });
    return _showAds;
  }

  /// Handle in-app purchases Upates
//   void _handlePurchaseUpdates() {
//     // listen purchase updates

//  //   _inAppPurchaseStream = InAppPurchase.instance.purchaseStream
//         //InAppPurchaseConnection
//         // .instance.purchaseUpdatedStream
//        // .listen((purchases) async {
//       // Loop incoming purchases
//       for (var purchase in purchases) {
//         // Control purchase status
//         switch (purchase.status) {
//           case PurchaseStatus.pending:
//             // Handle this case.
//             break;
//           case PurchaseStatus.purchased:

//             /// **** Deliver Subscription to User **** ///
//             ///
//             /// Check Subscription ID to Update App UI
//             if (purchase.productID.startsWith('ads')) {
//               // Disable showing Ads
//               AppModel().disableShowAds();
//             } else if (purchase.productID.startsWith('watermark')) {
//               // Disable watermarking status
//               AppModel().disableWatermark();
//             }

//             debugPrint('Subscription ID -> ${purchase.productID}');

//             if (purchase.pendingCompletePurchase) {
//               /// Complete pending purchase
//               InAppPurchase.instance.completePurchase(purchase);
//               //  InAppPurchaseConnection.instance.completePurchase(purchase);
//               debugPrint('Success pending purchase completed!');
//             }
//             break;
//           case PurchaseStatus.error:
//             // Handle this case.
//             debugPrint('purchase error-> ${purchase.error.message}');
//             break;
//         }
//       }
//     });
//   }

  @override
  void initState() {
    super.initState();
    _checkUserActiveSubscriptions().then((showAds) {
      // Load the banner ad only if the user has not removed ads.
      if (showAds && AppModel().showAds && !AppModel().isRewarded) {
        _loadBanner();
      }
    });
  }

  /// Load the bottom banner ad.
  void _loadBanner() {
    _bannerAd = Ads.createBanner(
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) setState(() => _bannerLoaded = true);
        },
        onAdFailedToLoad: (ad, error) => ad.dispose(),
      ),
    );
    _bannerAd.load();
  }

  @override
  void dispose() {
    if (_bannerAd != null) _bannerAd.dispose();
    super.dispose();
  }

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
        body: Column(
          children: <Widget>[
            Expanded(
              child: TabBarView(
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    /// Images tab body
                    PhotosTab(app: widget.platform.key),

                    /// Videos tab body
                    VideosTab(app: widget.platform.key),

                    /// Saved Status tab body
                    SavedStatusTab(),
                  ]),
            ),

            /// Bottom banner ad
            _buildBanner(),
          ],
        ),
      ),
    );
  }

  /// Bottom banner (empty space until the ad has loaded).
  Widget _buildBanner() {
    if (_bannerAd == null || !_bannerLoaded) {
      return SizedBox(width: 0, height: 0);
    }
    return Container(
      alignment: Alignment.center,
      width: _bannerAd.size.width.toDouble(),
      height: _bannerAd.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd),
    );
  }
}
