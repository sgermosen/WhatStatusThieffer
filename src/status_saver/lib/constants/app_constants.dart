import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:status_saver/models/media_platform.dart';

/// APP SETTINGS CONSTANTS
///
const String APP_NAME = "Social Status Saver";
const String APP_PACKAGE_NAME = "com.xamarindo.wpstatusaver";
const int APP_VERSION_NUMBER = 7;
const String APP_VERSION_NAME = "v.1.0.7";

/// LIST OF SUPPORTED PLATFORMS
///
/// Each platform declares the public folders where its media can be found.
/// All existing folders are scanned and merged, so several candidate paths can
/// be listed to stay robust across app/Android versions.
///
/// NOTE: WhatsApp exposes *viewed* statuses in a public `.Statuses` folder.
/// Instagram, Facebook and TikTok do NOT expose viewed stories publicly, so for
/// those platforms the app browses the folders where the platform saves the
/// media you download/save from within its own app.
const List<MediaPlatform> SUPPORTED_PLATFORMS = [
  MediaPlatform(
    key: "whatsapp",
    titleKey: "view_status_of_whatsApp_messenger",
    icon: FontAwesomeIcons.whatsapp,
    color: Color(0xFF25D366),
    mediaDirs: [
      "WhatsApp/Media/.Statuses",
      "Android/media/com.whatsapp/WhatsApp/Media/.Statuses",
    ],
  ),
  MediaPlatform(
    key: "whatsapp_business",
    titleKey: "view_status_of_whatsApp_business",
    icon: FontAwesomeIcons.whatsapp,
    color: Color(0xFF075E54),
    mediaDirs: [
      "WhatsApp Business/Media/.Statuses",
      "Android/media/com.whatsapp.w4b/WhatsApp Business/Media/.Statuses",
    ],
  ),
  MediaPlatform(
    key: "instagram",
    titleKey: "view_media_of_instagram",
    icon: FontAwesomeIcons.instagram,
    color: Color(0xFFE1306C),
    mediaDirs: [
      "Pictures/Instagram",
      "DCIM/Instagram",
      "Movies/Instagram",
      "Download/Instagram",
    ],
  ),
  MediaPlatform(
    key: "facebook",
    titleKey: "view_media_of_facebook",
    icon: FontAwesomeIcons.facebook,
    color: Color(0xFF1877F2),
    mediaDirs: [
      "DCIM/Facebook",
      "Pictures/Facebook",
      "Movies/Facebook",
      "Download/Facebook",
    ],
  ),
  MediaPlatform(
    key: "tiktok",
    titleKey: "view_media_of_tiktok",
    icon: FontAwesomeIcons.tiktok,
    color: Color(0xFF69C9D0),
    mediaDirs: [
      "DCIM/TikTok",
      "Movies/TikTok",
      "Pictures/TikTok",
      "Download/TikTok",
      "TikTok",
    ],
  ),
];

/// LIST OF SUPPORTED LOCALE LANGUAGES
/// Add your new supported Locale language to the array list.
///
/// E.g: Locale('en'), Locale('pt'), Locale('es'),
///
const List<Locale> SUPPORTED_LOCALES = [
  Locale('en'),
  Locale('es'),
  Locale('pt'),
];

/// User Reward Minutes
///
const int REWARDED_MINUTES = 15;

/// REMOVE ADS - GOOGLE PLAY SUBSCRIPTIONS IDS
///
const List<String> REMOVE_ADS_SUB_IDS = [
  // Production IDs
  'ads_1_week',
  'ads_1_month',
  'ads_3_months',
  'ads_6_months',
  'ads_1_year',
];

/// REMOVE WATERMARK - GOOGLE PLAY SUBSCRIPTIONS IDS
///
const List<String> REMOVE_WATERMARK_SUB_IDS = [
  // Production IDs
  'watermark_1_week',
  'watermark_1_month',
  'watermark_3_months',
  'watermark_6_months',
  'watermark_1_year',
];

/// ADMOB SETTINGS
///
/// Admob Sample App ID for testing: ca-app-pub-3940256099942544~3347511713
///
const String ADMOB_APP_ID = "ca-app-pub-8521044456540023~3652646925";
const String ADMOB_BANNER_ID = "ca-app-pub-8521044456540023/1533750040";
const String ADMOB_INTERSTITIAL_ID = "ca-app-pub-8521044456540023/5391914639";
const String ADMOB_REWARDED_VIDEO_ID = "ca-app-pub-8521044456540023/4302612443";

// FACEBOOK SETTINGS
const String FACEBOOK_USERNAME = "sgermosen24";
