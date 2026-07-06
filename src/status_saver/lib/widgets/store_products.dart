import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:status_saver/app/app_localizations.dart';
import 'package:status_saver/services/purchases.dart';
import 'package:status_saver/widgets/my_circular_progress.dart';

/// Shows the available Google Play subscriptions and lets the user subscribe.
class StoreProducts extends StatefulWidget {
  // Variables
  final Widget icon;

  /// Only products whose ID starts with this prefix are shown (e.g. 'ads' or
  /// 'watermark'), so the same widget serves both the remove-ads and
  /// remove-watermark screens.
  final String filterPrefix;

  StoreProducts({@required this.icon, this.filterPrefix});

  @override
  _StoreProductsState createState() => _StoreProductsState();
}

class _StoreProductsState extends State<StoreProducts> {
  // Variables
  final Purchases _purchases = new Purchases();
  bool _storeIsAvailable = false;
  bool _loading = true;
  List<ProductDetails> _products;
  AppLocalizations _i18n;

  @override
  void initState() {
    super.initState();
    _loadStore();
  }

  Future<void> _loadStore() async {
    // Check Google Play billing availability.
    final bool available = await _purchases.isAvailable();
    if (!mounted) return;
    if (!available) {
      setState(() {
        _storeIsAvailable = false;
        _loading = false;
      });
      return;
    }

    // Load products.
    final List<ProductDetails> products = await _purchases.loadProducts();
    if (!mounted) return;
    setState(() {
      _storeIsAvailable = true;
      _products = widget.filterPrefix == null
          ? products
          : products
              .where((p) => p.id.startsWith(widget.filterPrefix))
              .toList();
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);
    if (_loading) return _loadingView();
    return _storeIsAvailable ? _showProducts() : _storeNotAvailable();
  }

  Widget _loadingView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            MyCircularProgress(),
            SizedBox(height: 5),
            Text(_i18n.translate("processing"),
                style: TextStyle(fontSize: 18), textAlign: TextAlign.center),
            Text(_i18n.translate("please_wait"),
                style: TextStyle(fontSize: 18), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _showProducts() {
    if (_products == null || _products.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.search,
                  size: 80, color: Theme.of(context).primaryColor),
              Text(
                  _i18n.translate(
                      'no_subscriptions_found_please_try_again_later'),
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }

    return Column(
        children: _products.map<Widget>((item) {
      return Card(
        margin: const EdgeInsets.only(bottom: 10),
        child: ListTile(
          leading: widget.icon,
          title: Text(item.title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          subtitle: Text(item.price,
              style: TextStyle(
                  fontSize: 19,
                  color: Colors.teal,
                  fontWeight: FontWeight.bold)),
          trailing: RaisedButton(
              color: Colors.teal,
              textColor: Colors.white,
              padding: const EdgeInsets.all(8),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: Text(_i18n.translate("SUBSCRIBE")),
              onPressed: () => _purchases.buy(item)),
        ),
      );
    }).toList());
  }

  Widget _storeNotAvailable() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.error_outline,
              size: 80, color: Theme.of(context).primaryColor),
          Text(
              _i18n.translate(
                  'sorry_subscriptions_are_not_available_now_please_try_again_later'),
              style: TextStyle(fontSize: 18.0),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
