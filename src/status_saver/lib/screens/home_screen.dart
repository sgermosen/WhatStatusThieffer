import 'dart:async';

import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:status_saver/app/ads.dart';
import 'package:status_saver/constants/app_constants.dart';
import 'package:status_saver/models/app_model.dart';
import 'package:status_saver/tabs/saved_status_tab.dart';
import 'package:status_saver/tabs/videos_tab.dart';
import 'package:status_saver/widgets/my_navigation_drawer.dart';
import 'package:status_saver/tabs/photos_tab.dart';
import 'package:status_saver/app/app_localizations.dart';
import 'package:status_saver/widgets/rewarded_counter.dart';

class HomeScreen extends StatefulWidget {
  // Variables
  final String app;

  HomeScreen({@required this.app});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// Variables
  // in_app_purchase stream
  StreamSubscription<List<PurchaseDetails>> _inAppPurchaseStream;
  AppLocalizations _i18n;

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
  void _handlePurchaseUpdates() {
    // listen purchase updates

    _inAppPurchaseStream = InAppPurchase.instance.purchaseStream
        //InAppPurchaseConnection
        // .instance.purchaseUpdatedStream
        .listen((purchases) async {
      // Loop incoming purchases
      for (var purchase in purchases) {
        // Control purchase status
        switch (purchase.status) {
          case PurchaseStatus.pending:
            // Handle this case.
            break;
          case PurchaseStatus.purchased:

            /// **** Deliver Subscription to User **** ///
            ///
            /// Check Subscription ID to Update App UI
            if (purchase.productID.startsWith('ads')) {
              // Disable showing Ads
              AppModel().disableShowAds();
            } else if (purchase.productID.startsWith('watermark')) {
              // Disable watermarking status
              AppModel().disableWatermark();
            }

            debugPrint('Subscription ID -> ${purchase.productID}');

            if (purchase.pendingCompletePurchase) {
              /// Complete pending purchase
              InAppPurchase.instance.completePurchase(purchase);
              //  InAppPurchaseConnection.instance.completePurchase(purchase);
              debugPrint('Success pending purchase completed!');
            }
            break;
          case PurchaseStatus.error:
            // Handle this case.
            debugPrint('purchase error-> ${purchase.error.message}');
            break;
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _checkUserActiveSubscriptions().then((showAds) {
      // Check to show Banner Ad
      Ads.showBannerAd(showAds: showAds);
    });
    // Listeners update
    _handlePurchaseUpdates();
  }

  @override
  void dispose() {
    super.dispose();
    Ads.disposeBannerAd();
    _inAppPurchaseStream.cancel();
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
          title: Text(APP_NAME),
          actions: [
            // Rewarded minutes counter
            RewardedMinCounter()
          ],
          bottom: TabBar(tabs: getTabs(), onTap: (int index) {}),
        ),
        body: TabBarView(physics: NeverScrollableScrollPhysics(), children: [
          /// Images tab body
          PhotosTab(app: widget.app),

          /// Videos tab body
          VideosTab(app: widget.app),

          /// Saved Status tab body
          SavedStatusTab(),
        ]),
      ),
    );
  }
}
