// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:status_saver/app/app_localizations.dart';
// import 'package:status_saver/constants/app_constants.dart';

// class NotificationManager {
//   /// Variables
//   FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

//   NotificationManager() {
//     flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
//     _initNotifications();
//   }

//   getNotificationInstance() {
//     return flutterLocalNotificationsPlugin;
//   }

//   void _initNotifications() {
//     // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
//     var initializationSettingsAndroid =
//         new AndroidInitializationSettings('@mipmap/download_icon');
//     var initializationSettingsIOS = IOSInitializationSettings(
//         onDidReceiveLocalNotification: _onDidReceiveLocalNotification);

//     var initializationSettings = InitializationSettings(
//         android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

//     flutterLocalNotificationsPlugin.initialize(initializationSettings,
//         onSelectNotification: _onSelectNotification);
//   }

//   NotificationDetails _getPlatformChannelSpecfics() {
//     AppLocalizations _i18n;

//     var androidPlatformChannelSpecifics = AndroidNotificationDetails(
//         APP_PACKAGE_NAME,
//         '$APP_NAME ' + _i18n.translate('Reminder'),
//         _i18n.translate('reminder_to_download_WhatsApp_status'),
//         importance: Importance.max,
//         priority: Priority.high,
//         color: Colors.teal,
//         playSound: true,
//         ticker: '$APP_NAME ' + _i18n.translate('Reminder'));
//     var iOSPlatformChannelSpecifics = IOSNotificationDetails();
//     var platformChannelSpecifics = NotificationDetails(
//         android: androidPlatformChannelSpecifics,
//         iOS: iOSPlatformChannelSpecifics);

//     return platformChannelSpecifics;
//   }

//   Future<void> showPeriodicallyNotification(BuildContext context) async {
//     // Init i18n instance
//     final i18n = AppLocalizations.of(context);

//     await flutterLocalNotificationsPlugin.periodicallyShow(
//         0,
//         APP_NAME,
//         i18n.translate('reminder_to_download_WhatsApp_status'),
//         RepeatInterval.daily,
//         _getPlatformChannelSpecfics());
//     print('showPeriodicallyNotification() -> Scheduled');
//   }

//   Future _onSelectNotification(String payload) async {
//     print('Notification clicked');
//     return Future.value(0);
//   }

//   Future _onDidReceiveLocalNotification(
//       int id, String title, String body, String payload) async {
//     return Future.value(1);
//   }

//   void removeReminder(int notificationId) {
//     flutterLocalNotificationsPlugin.cancel(notificationId);
//   }
// }
