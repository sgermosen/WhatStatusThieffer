import 'dart:async';

import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:status_saver/constants/app_constants.dart';
import 'package:status_saver/models/app_model.dart';

/// Handles Google Play subscriptions (remove ads / remove watermark).
///
/// See docs/GUIA_PUBLICACION_PLAYSTORE.md §5 for how to create the matching
/// products in the Play Console (the IDs must match the constants exactly) and
/// why purchases only work once the app is uploaded to a track and the tester
/// account is added as a license tester.
class Purchases {
  // Singleton
  static final Purchases _instance = Purchases._internal();
  factory Purchases() => _instance;
  Purchases._internal();

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>> _sub;

  /// All subscription IDs the app offers.
  Set<String> get productIds =>
      REMOVE_ADS_SUB_IDS.toSet()..addAll(REMOVE_WATERMARK_SUB_IDS);

  /// Start listening for purchase updates and restore past purchases.
  /// Call once at app startup.
  void init() {
    if (_sub != null) return;
    _sub = _iap.purchaseStream.listen(
      _onPurchaseUpdate,
      onDone: () => _sub.cancel(),
      onError: (dynamic error) {
        // Ignore purchase stream errors.
      },
    );
    // Restore previously bought subscriptions to reflect them in the UI.
    restore();
  }

  void dispose() {
    if (_sub != null) _sub.cancel();
    _sub = null;
  }

  /// Whether the store (Play Billing) is reachable.
  Future<bool> isAvailable() => _iap.isAvailable();

  /// Load the product details to render them in the store screen.
  Future<List<ProductDetails>> loadProducts() async {
    final ProductDetailsResponse resp =
        await _iap.queryProductDetails(productIds);
    final List<ProductDetails> products = resp.productDetails;
    // Order by price ascending.
    products.sort((a, b) => a.rawPrice.compareTo(b.rawPrice));
    return products;
  }

  /// Start the purchase flow for a subscription.
  void buy(ProductDetails product) {
    final PurchaseParam param = PurchaseParam(productDetails: product);
    _iap.buyNonConsumable(purchaseParam: param);
  }

  /// Restore past purchases.
  Future<void> restore() => _iap.restorePurchases();

  void _onPurchaseUpdate(List<PurchaseDetails> purchases) {
    for (final PurchaseDetails p in purchases) {
      if (p.status == PurchaseStatus.purchased ||
          p.status == PurchaseStatus.restored) {
        _deliverProduct(p.productID);
      }
      // Always finish pending purchases so Play stops re-delivering them.
      if (p.pendingCompletePurchase) {
        _iap.completePurchase(p);
      }
    }
  }

  /// Unlock the feature bought by the given product ID.
  void _deliverProduct(String productId) {
    if (productId.startsWith('ads')) {
      AppModel().disableShowAds();
    } else if (productId.startsWith('watermark')) {
      AppModel().disableWatermark();
    }
  }
}
