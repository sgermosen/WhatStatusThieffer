import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:status_saver/app/app_localizations.dart';
import 'package:status_saver/models/app_model.dart';
import 'package:status_saver/services/purchases.dart';
import 'package:status_saver/widgets/my_circular_progress.dart';

/// Lists the Google Play subscriptions for [subscriptionIDs] with a subscribe
/// button for each one.
class StoreProducts extends StatefulWidget {
  final Widget icon;
  final List<String> subscriptionIDs;

  const StoreProducts(
      {super.key, required this.icon, required this.subscriptionIDs});

  @override
  State<StoreProducts> createState() => _StoreProductsState();
}

class _StoreProductsState extends State<StoreProducts> {
  bool? _storeIsAvailable;
  List<ProductDetails>? _products;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final available = await Purchases.isAvailable();
    final products = available
        ? await Purchases.loadProducts(widget.subscriptionIDs)
        : <ProductDetails>[];
    if (!mounted) return;
    setState(() {
      _storeIsAvailable = available;
      _products = products;
    });
  }

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);
    final products = _products;

    if (_storeIsAvailable == null) {
      return _message(
        MyCircularProgress(),
        '${i18n.translate("processing")}\n${i18n.translate("please_wait")}',
      );
    }
    if (_storeIsAvailable == false) {
      return _message(
        Icon(Icons.error_outline,
            size: 80, color: Theme.of(context).primaryColor),
        i18n.translate(
            'sorry_subscriptions_are_not_available_now_please_try_again_later'),
      );
    }

    return ScopedModelDescendant<AppModel>(
      builder: (context, child, model) {
        if (!model.showAds) {
          return _message(
            const Icon(Icons.check_circle, size: 80, color: Colors.teal),
            i18n.translate('you_already_removed_ads'),
          );
        }
        if (products == null || products.isEmpty) {
          return _message(
            Icon(Icons.search, size: 80, color: Theme.of(context).primaryColor),
            i18n.translate('no_subscriptions_found_please_try_again_later'),
          );
        }
        return Column(
          children: products.map<Widget>((item) {
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: widget.icon,
                title: Text(item.title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                subtitle: Text(item.price,
                    style: const TextStyle(
                        fontSize: 19,
                        color: Colors.teal,
                        fontWeight: FontWeight.bold)),
                trailing: FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: Colors.teal),
                  onPressed: () => Purchases.buy(item),
                  child: Text(i18n.translate("SUBSCRIBE")),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _message(Widget icon, String text) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            icon,
            const SizedBox(height: 5),
            Text(text,
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
