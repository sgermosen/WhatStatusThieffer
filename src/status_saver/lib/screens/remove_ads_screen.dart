import 'package:flutter/material.dart';
import 'package:status_saver/constants/app_constants.dart';
import 'package:status_saver/widgets/store_products.dart';
import 'package:status_saver/app/app_localizations.dart';


class RemoveAdsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(i18n.translate('remove_ads_subscriptions')),
      ),
      backgroundColor: Colors.grey[400],
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(8, 10, 8, 8),
        child: Column(
          children: [
             // Header message
             Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(i18n.translate('get_a_better_experience_with_our_app_without_Ads_showing'),
                style: TextStyle(fontSize: 18), textAlign: TextAlign.center),
              ), 
             ),
             Divider(),
            // List of subscriptions
            StoreProducts(
              subscriptionIDs: REMOVE_ADS_SUB_IDS,
              icon: CircleAvatar(
                backgroundColor: Colors.red,
                child: Icon(Icons.block, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
