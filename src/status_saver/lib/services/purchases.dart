import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:status_saver/constants/app_constants.dart';
import 'package:status_saver/models/app_model.dart';

/// Google Play subscriptions ("remove ads").
///
/// The product IDs in [REMOVE_ADS_SUB_IDS] must exist (and be active) in
/// Play Console → Monetize → Subscriptions, and purchases only work in a build
/// installed from a Play testing track. See docs/GUIA_PUBLICACION_PLAYSTORE.md.
class Purchases {
  static final InAppPurchase _iap = InAppPurchase.instance;
  static StreamSubscription<List<PurchaseDetails>>? _sub;

  /// Start listening for purchases and apply any active subscription.
  /// Call once at startup.
  static Future<void> initialize() async {
    if (_sub != null) return;
    _sub = _iap.purchaseStream.listen(
      _handlePurchases,
      onError: (Object e) => debugPrint('Purchase stream error: $e'),
    );
    if (!await _iap.isAvailable()) return;
    await _checkActiveSubscriptions();
  }

  /// Query Play for the subscriptions the user currently owns. Expired
  /// subscriptions are not returned, so ads come back when they lapse.
  static Future<void> _checkActiveSubscriptions() async {
    try {
      final android =
          _iap.getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();
      final response = await android.queryPastPurchases();
      for (final purchase in response.pastPurchases) {
        _deliver(purchase);
      }
    } catch (e) {
      debugPrint('Could not query past purchases: $e');
    }
  }

  static bool _isRemoveAds(String productId) =>
      REMOVE_ADS_SUB_IDS.contains(productId);

  static void _deliver(PurchaseDetails purchase) {
    if (_isRemoveAds(purchase.productID)) {
      AppModel().disableShowAds();
    }
  }

  static Future<void> _handlePurchases(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      switch (purchase.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          _deliver(purchase);
          break;
        case PurchaseStatus.error:
          debugPrint('Purchase error: ${purchase.error?.message}');
          break;
        case PurchaseStatus.pending:
        case PurchaseStatus.canceled:
          break;
      }
      // Purchases must be acknowledged or Google refunds them after 3 days.
      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
    }
  }

  static Future<bool> isAvailable() => _iap.isAvailable();

  /// Load the store listing for the given product IDs, cheapest first.
  static Future<List<ProductDetails>> loadProducts(List<String> ids) async {
    final response = await _iap.queryProductDetails(ids.toSet());
    if (response.notFoundIDs.isNotEmpty) {
      debugPrint('Products not found in Play Console: ${response.notFoundIDs}');
    }
    final products = response.productDetails.toList()
      ..sort((a, b) => a.rawPrice.compareTo(b.rawPrice));
    return products;
  }

  /// Start the Play purchase flow. Subscriptions are bought as
  /// non-consumables.
  static Future<void> buy(ProductDetails product) async {
    await _iap.buyNonConsumable(
        purchaseParam: PurchaseParam(productDetails: product));
  }
}
