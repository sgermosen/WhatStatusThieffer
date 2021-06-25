import 'dart:io';
import 'dart:typed_data';

//import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:status_saver/app/app_localizations.dart';
import 'package:status_saver/constants/app_constants.dart';
import 'package:status_saver/models/app_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class App {
  final FlutterFFmpeg _flutterFFmpeg = new FlutterFFmpeg();
  final String _savedStatusDirKey = 'saved_status_dir';
  final String _autoPlayVideoKey = 'auto_play_video';
  final String _darkThemeKey = 'dark_theme';

  // GETTERS

  /// Get Saved Status Directory
  Future<String> getSavedStatusDir() async {
    final _prefs = await SharedPreferences.getInstance();
    final result = _prefs.getString(_savedStatusDirKey);
    return result ?? APP_NAME;
  }

  /// Get Auto Play Video
  Future<bool> getAutoPlayVideo() async {
    final _prefs = await SharedPreferences.getInstance();
    final result = _prefs.getBool(_autoPlayVideoKey);
    return result ?? true;
  }

  /// Get Dark Theme
  Future<bool> getDarkTheme() async {
    final _prefs = await SharedPreferences.getInstance();
    final result = _prefs.getBool(_darkThemeKey);
    return result ?? false;
  }

  // SETTERS

  /// Set Saved Status Directory
  Future<void> setSavedStatusDir(String newDir) async {
    final _prefs = await SharedPreferences.getInstance();
    await _prefs.setString(_savedStatusDirKey, newDir);
  }

  /// Set Auto Play Video
  Future<void> setAutoPlayVideo(bool newValue) async {
    final _prefs = await SharedPreferences.getInstance();
    await _prefs.setBool(_autoPlayVideoKey, newValue);
  }

  /// Get Dark Theme
  Future<void> setDarkTheme(bool newValue) async {
    final _prefs = await SharedPreferences.getInstance();
    await _prefs.setBool(_darkThemeKey, newValue);
  }

  //Todo: Here is an error with the output, because this need to be deleted when the conversion it's done
  /// Copy Asset to Temporary Directory
  /// to be used for watermark
  Future<String> _copyAssetToTempDir(String assetName, String fileName) async {
    // Load asset from app assets
    final ByteData assetByteData = await rootBundle.load(assetName);

    // Get byteList from asset
    final List<int> byteList = assetByteData.buffer
        .asUint8List(assetByteData.offsetInBytes, assetByteData.lengthInBytes);

    // Get Temporary Directory
    final Directory tempDir = await getTemporaryDirectory();

    // Returns the absolute file path from temp dir

    return (await File('${tempDir.path}/$fileName')
            .writeAsBytes(byteList, mode: FileMode.writeOnly, flush: true))
        .path;
  }

  /// Add Watermark logo to Video/Image Status
  /// Returns the output status directory path
  Future<void> addWatermark(
      {@required String inputSatusPath,
      @required String outputStatusPath}) async {
    // Get Watermark logo
    final String watermarkPath = await _copyAssetToTempDir(
        'assets/images/status_watermark.png', 'status_watermark.png');

    // Add Watermark
    await _flutterFFmpeg
        .execute(
            "-i \"$inputSatusPath\" -i $watermarkPath -filter_complex 'overlay=x=W-w-10:y=H-h-10' -y \"$outputStatusPath\" ")
        .then((rc) => print("FFmpeg process exited with rc $rc"));
  }

  //Todo: Really I think than this is an stupid functionality if the watermark it's active
  /// Share not saved Status and add Watermark
  Future<void> shareNotSavedStatus(
      String statusPath, BuildContext context) async {
    // Get temporary directory to store the watermarked status to be shared
    final String tempDir = (await getTemporaryDirectory()).path;

    // Status path
    String outputStatusPath = statusPath;

    // Show processing dialog
    processingDialog(context);

    /// Check Active Remove-Ads Subscription to Watermark the Status
    ///
    if (AppModel().addWatermark && !AppModel().isRewarded) {
      // Remane the status
      outputStatusPath =
          "$tempDir/DOWNLOAD-ON-PLAYSTORE-${statusPath.split('/').last}";
      // Add watermark
      await addWatermark(
          inputSatusPath: statusPath, outputStatusPath: outputStatusPath);
    }

    // Close pr dialog
    Navigator.of(context).pop();

    // Share the watermarked status
    Share.shareFiles([outputStatusPath]);
    //print(outputStatusPath);
  }

  /// Return App Logo
  Widget getAppLogo({double width, double height}) {
    return Image.asset('assets/images/app_logo.png',
        width: width ?? 120, height: height ?? 120);
  }

  // /// Setup admob info
  // static final MobileAdTargetingInfo targetInfo = new MobileAdTargetingInfo(
  //   childDirected: false,
  // );

  /// Get thumbnail from video

  Future<String> getVideoThumbnail(videoPathUrl) async {
    // Generates thumbnail from video
    final thumbnailPath = await VideoThumbnail.thumbnailFile(
      video: videoPathUrl,
      imageFormat: ImageFormat.JPEG,
      maxWidth:
          250, // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
      quality: 75,
    );

    return thumbnailPath;
  }

  /// Share app
  Future<void> shareApp(BuildContext context) async {
    // Init i18n instance
    final i18n = AppLocalizations.of(context);

    Share.share('${i18n.translate('share_app_message')} '
        'https://play.google.com/store/apps/details?id=$APP_PACKAGE_NAME\n'
        '${i18n.translate('install_it_now')}');
  }

  /// Go to play store app page
  Future goToPlayStore() async {
    final String url =
        "https://play.google.com/store/apps/details?id=$APP_PACKAGE_NAME";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw "Could not launch $url";
    }
  }

  /// Open facebook page in app/browser
  Future<void> openFacebook() async {
    final facebookUrl = 'https://facebook.com/$FACEBOOK_USERNAME';
    try {
      await launch(facebookUrl);
    } catch (error) {
      throw 'Could not launch $error';
    }
  }

  /// Open privacy policy page
  Future<void> openPrivacyPage() async {
    const url =
        'http://www.sgermosen.com/2020/08/privacy-policy-for-xamarindo.html';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  /// Check storage permission
  Future<void> checkStoragePermission(
      {@required VoidCallback onGranted}) async {
    final permission = await Permission.storage.request();

    //  print(permission);

    // Check result
    if (permission.isGranted) {
      print('permission.isGranted: true');
      onGranted();
    } else if (permission.isPermanentlyDenied) {
      print('permission.isPermanentlyDenied: true -> openAppSettings');
      openAppSettings();
    }
  }

  //Todo: The objective of this feature was than you can share directly from
  //whatsapp without need to use my app, but for some reason whatsapp dont like that, so, I guess than this is a stupid feature
  /// Get WhatsApp Statuses path
  Future<String> getStatusesPath(String app) async {
    final Directory absoluteDir = await getExternalStorageDirectory();
    final String externalDirPath = absoluteDir.path
        .replaceFirst('Android/data/$APP_PACKAGE_NAME/files', '');
    final statusesPath = "$externalDirPath/$app/Media/.Statuses";
    // print('getStatusesPath() -> $statusesPath');
    return statusesPath;
  }

  /// Get Saved Statuses path
  Future<String> getSavedStatusesPath() async {
    final Directory absoluteDir = await getExternalStorageDirectory();
    final String externalDirPath = absoluteDir.path
        .replaceFirst('Android/data/$APP_PACKAGE_NAME/files', '');
    // Get Saved Status User Directory
    final String userDir = await getSavedStatusDir();

    final statusesPath = "$externalDirPath/$userDir";
    //  print('getSavedStatusesPath() -> $statusesPath');
    return statusesPath;
  }

  /// Save File in Gallery
  Future<void> saveFileInGallery(BuildContext context,
      {@required String filePath}) async {
    // Init i18n instance
    final i18n = AppLocalizations.of(context);

    // show loading dialog
    processingDialog(context);

    /// Get absolute external app directory
    final Directory absoluteDir = await getExternalStorageDirectory();
    final String dirPath = absoluteDir.path
        .replaceFirst('Android/data/$APP_PACKAGE_NAME/files', '');

    /// Get Saved Status User Directory
    final String userDir = await getSavedStatusDir();

    String statusDir = dirPath + '$userDir';
    final String fileExt = filePath.split('.').last;

    // Check directory
    if (!Directory(statusDir).existsSync()) {
      // Create Status dir
      Directory(statusDir).createSync();
      //  print('$appName dir created!');
    }
    //else {
    //  print('$appName dir exists!');
    //}

    /// Create the Status new file name
    /// TODO: you can make whatever strategy you want to make names for the file
    final String outputStatusPath =
        "$statusDir/Status-${DateTime.now().millisecondsSinceEpoch.toString()}.$fileExt";

    /// Check User Active Remove-Watermark Subscription
    if (AppModel().addWatermark && !AppModel().isRewarded) {
      /***  Add watermark to Status ***/
      await addWatermark(
          inputSatusPath: filePath, outputStatusPath: outputStatusPath);
    } else {
      // Copy status to new dir without watermark
      File(filePath).copySync(outputStatusPath);
    }

    // Close dialog
    Navigator.of(context).pop();

    // Show message
    showDialogInfo(
      context: context,
      message: i18n
          .translate('status_saved_successfully_please_click_on_AD_to_help_us'),
    );
  }

  /// Show processing dialog
  void processingDialog(BuildContext context) {
    final i18n = AppLocalizations.of(context);
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
                content: Row(
              children: <Widget>[
                CircularProgressIndicator(),
                SizedBox(width: 15),
                Text(
                    "${i18n.translate('processing')}\n${i18n.translate('please_wait')}",
                    style: TextStyle(fontSize: 18))
              ],
            )));
  }

  /// Dialog to show information
  void showDialogInfo({
    @required BuildContext context,
    @required String message,
    Color color,
  }) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(Icons.check_circle,
                      size: 65, color: color ?? Colors.teal),
                  SizedBox(width: 15),
                  Text(message,
                      style: TextStyle(fontSize: 18),
                      textAlign: TextAlign.center)
                ],
              ),
              actions: <Widget>[
                FlatButton(
                  color: Colors.teal,
                  textColor: Colors.white,
                  child: Text('OK'),
                  onPressed: () => Navigator.of(context).pop(),
                )
              ],
            ));
  }
}
