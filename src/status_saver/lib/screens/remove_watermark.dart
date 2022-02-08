import 'package:flutter/material.dart';
import 'package:status_saver/app/app_localizations.dart';
import 'package:status_saver/constants/app_constants.dart';
import 'package:status_saver/widgets/store_products.dart';

class RemoveWatermarkScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(i18n.translate('remove_watermark_subscriptions')),
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
                child: Text(
                    i18n.translate(
                        'save_your_status_10x_faster_without_the_watermark'),
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.center),
              ),
            ),
            Divider(),
            // List of subscriptions
            // StoreProducts(
            //   subscriptionIDs: REMOVE_WATERMARK_SUB_IDS,
            //   icon: CircleAvatar(
            //     backgroundColor: Colors.teal,
            //     child: Icon(Icons.copyright_rounded, color: Colors.white),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
