// import 'package:flutter/material.dart';
// import 'package:in_app_purchase/in_app_purchase.dart';
// import 'package:status_saver/app/app_localizations.dart';
// import 'package:status_saver/widgets/my_circular_progress.dart';

// class StoreProducts extends StatefulWidget {
//   // Variables
//   final Widget icon;
//   final List<String> subscriptionIDs;

//   StoreProducts({@required this.icon, @required this.subscriptionIDs});

//   @override
//   _StoreProductsState createState() => _StoreProductsState();
// }

// class _StoreProductsState extends State<StoreProducts> {
//   // Variables
//   bool _storeIsAvailable = false;
//   //List<ProductDetails> _products;
//   AppLocalizations _i18n;

//   @override
//   void initState() {
//     super.initState();

//     // Check google play services
//     // InAppPurchaseConnection.instance
//     // InAppPurchase.instance.isAvailable().then((result) {
//     //   if (mounted)
//     //     setState(() {
//     //       _storeIsAvailable =
//     //           result; // if false the store can not be reached or accessed
//     //     });
//     // });

//     // Get product subscriptions from google play store / apple store
//     // InAppPurchaseConnection.instance
//   //   InAppPurchase.instance
//   //       .queryProductDetails(widget.subscriptionIDs.toSet())
//   //       .then((ProductDetailsResponse response) {
//   //     /// Update UI
//   //     if (mounted)
//   //       setState(() {
//   //         _products = response.productDetails
//   //             // .where((item) => item.skuDetail.type == skuty.subs)
//   //             .toList();
//   //         // Check result
//   //         if (_products.isNotEmpty) {
//   //           // Order by price ASC
//   //           _products.sort((a, b) => a.price.compareTo(b.price));
//   //         }
//   //       });
//   //   });
//   // }

//   @override
//   Widget build(BuildContext context) {
//     _i18n = AppLocalizations.of(context);
//     return _storeIsAvailable ? _showProducts() : _storeNotAvailable();
//   }

//   Widget _showProducts() {
//     if (_products == null) {
//       return Center(
//         child: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: <Widget>[
//               MyCircularProgress(),
//               SizedBox(height: 5),
//               Text(_i18n.translate("processing"),
//                   style: TextStyle(fontSize: 18), textAlign: TextAlign.center),
//               Text(_i18n.translate("please_wait"),
//                   style: TextStyle(fontSize: 18), textAlign: TextAlign.center)
//             ],
//           ),
//         ),
//       );
//     } else if (_products.isNotEmpty) {
//       return Column(
//           children: _products.map<Widget>((item) {
//         return Card(
//           margin: const EdgeInsets.only(bottom: 10),
//           child: ListTile(
//             leading: widget.icon,
//             title: Text(item.title,
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//             //subtitle: Text(item.description),
//             subtitle: Text(item.price,
//                 style: TextStyle(
//                     fontSize: 19,
//                     color: Colors.teal,
//                     fontWeight: FontWeight.bold)),
//             trailing: RaisedButton(
//                 color: Colors.teal,
//                 textColor: Colors.white,
//                 padding: const EdgeInsets.all(8),
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(20)),
//                 child: Text(_i18n.translate("SUBSCRIBE")),
//                 onPressed: () {
//                   // Purchase parameters
//                   final pParam = PurchaseParam(
//                     productDetails: item,
//                   );

//                   /// Subscribe
//                   InAppPurchase.instance
//                       .buyNonConsumable(purchaseParam: pParam);
//                 }),
//           ),
//         );
//       }).toList());
//     } else {
//       return Center(
//         child: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: <Widget>[
//               Icon(Icons.search,
//                   size: 80, color: Theme.of(context).primaryColor),
//               Text(
//                   _i18n.translate(
//                       'no_subscriptions_found_please_try_again_later'),
//                   style: TextStyle(fontSize: 18),
//                   textAlign: TextAlign.center),
//             ],
//           ),
//         ),
//       );
//     }
//   }

//   Widget _storeNotAvailable() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: <Widget>[
//           Icon(Icons.error_outline,
//               size: 80, color: Theme.of(context).primaryColor),
//           Text(
//               _i18n.translate(
//                   'sorry_subscriptions_are_not_available_now_please_try_again_later'),
//               style: TextStyle(fontSize: 18.0),
//               textAlign: TextAlign.center),
//         ],
//       ),
//     );
//   }
// }
