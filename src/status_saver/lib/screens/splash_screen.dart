// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:status_saver/app/app.dart';
// import 'package:status_saver/screens/start_screen.dart';
// import 'package:status_saver/screens/update_app_screen.dart';

// class SplashScreen extends StatefulWidget {
//   @override
//   _SplashScreenState createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {
//   // Variables
//   final App _app = new App();

//   /// ********* Version Control Function ********** ///
//   /// Get app current version from Cloud Firestore,
//   /// that is the same with Google Play Store app version
//   Future<int> _checkPlayStoreVersion() async {
//     final DocumentSnapshot appInfo =
//         await Firestore.instance.collection('app').document('settings').get();
//     return appInfo['app_version'];
//   }

//   @override
//   void initState() {
//     super.initState();

//     _checkPlayStoreVersion().then((serverVersion) async {
//       // print('serverVersion: $serverVersion');

//       /// Compare with current user app version
//       if (serverVersion > _app.appVersionNumber) {
//         /// Go to update screen
//         Future(() {
//           Navigator.pushReplacement(context,
//               MaterialPageRoute(builder: (context) => UpdateAppScreen()));
//         });
//         // print("Go to update screen");

//       } else {
//         /// Check permission to access storage dir
//         await _app.checkStoragePermission(onGranted: () {
//           _goToStartScreen();
//         });
//       }
//     }).catchError((error) {
//       //  print('_getServerVersion() -> error: $error');
//     });
//   }

//   Future<void> _goToStartScreen() async {
//     /// Go to home screen
//     Future(() {
//       Navigator.pushReplacement(
//           context, MaterialPageRoute(builder: (context) => StartScreen()));
//     });
//     // print("Go to home screen");
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Container(
//           color: Theme.of(context).primaryColor,
//           child: Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: <Widget>[
//                 /// App icon
//                 _app.getAppLogo(),
//                 SizedBox(height: 10),

//                 /// App name
//                 Text(
//                   _app.appName,
//                   style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 23,
//                       fontWeight: FontWeight.bold),
//                 ),
//                 SizedBox(height: 5),
//                 // slogan
//                 Text(
//                   _app.appShortDescription,
//                   style: TextStyle(
//                     color: Colors.white70,
//                     fontSize: 18,
//                   ),
//                 ),
//                 SizedBox(height: 50),
//                 Center(
//                     child: CircularProgressIndicator(
//                         valueColor:
//                             AlwaysStoppedAnimation<Color>(Colors.white)))
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
