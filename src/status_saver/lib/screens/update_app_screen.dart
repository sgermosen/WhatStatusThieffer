// import 'package:flutter/material.dart';
// import 'package:status_saver/app/app.dart';


// class UpdateAppScreen extends StatefulWidget {
//   @override
//   _UpdateAppScreenState createState() => _UpdateAppScreenState();
// }

// class _UpdateAppScreenState extends State<UpdateAppScreen> {

//   // Variables
//   final App _app = new App();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Update aplication"),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(25),
//         child: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: <Widget>[
//               /// App icon
//               _app.getAppLogo(),
//               SizedBox(height: 5),
//               /// App name
//               Text(_app.appName,
//                 style: TextStyle(
//                   fontSize: 25, fontWeight: FontWeight.bold,
//                 ),textAlign: TextAlign.center,
//               ),
//               SizedBox(height: 20),
//               Text("Hello, a new version of ${_app.appName} has been launched on Google Play Store.",
//                 style: TextStyle(fontSize: 20, color: Theme.of(context).primaryColor,
//                     fontWeight: FontWeight.bold), textAlign: TextAlign.center),
//               SizedBox(height: 10),
//               Text("Please install it now and enjoy the new features.",
//                 style: TextStyle(fontSize: 18), textAlign: TextAlign.center),
//               SizedBox(height: 5),
//               GestureDetector(
//                 child: Image.asset("assets/images/google_play_badge.png",
//                     width: 250, height: 97),
//                 onTap: () {
//                   /// Go to play store
//                   _app.goToPlayStore();
//                 },
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
