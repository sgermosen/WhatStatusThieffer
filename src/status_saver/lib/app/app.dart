import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:status_saver/app/app_localizations.dart';
import 'package:status_saver/constants/app_constants.dart';
import 'package:status_saver/models/app_model.dart';
import 'package:status_saver/models/media_platform.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class App {
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

  /// Opacity of the watermark (0..1). Lower = more transparent/subtle.
  static const double _watermarkOpacity = 0.28;

  /// Composite a subtle watermark onto an IMAGE and write it to [outputPath].
  ///
  /// Returns true if the watermark was applied. Videos (and anything that is
  /// not a supported image) return false and should be copied as-is: on-device
  /// video re-encoding was dropped along with the discontinued flutter_ffmpeg
  /// dependency.
  Future<bool> _applyImageWatermark(
      {@required String inputPath, @required String outputPath}) async {
    final String ext = inputPath.split('.').last.toLowerCase();
    const List<String> imageExts = [
      'jpg',
      'jpeg',
      'png',
      'gif',
      'webp',
      'bmp'
    ];
    if (!imageExts.contains(ext)) return false;

    try {
      // Decode the source image.
      final img.Image base = img.decodeImage(await File(inputPath).readAsBytes());
      if (base == null) return false;

      // Decode the watermark asset.
      final ByteData wmData =
          await rootBundle.load('assets/images/status_watermark.png');
      img.Image wm = img.decodePng(wmData.buffer.asUint8List());
      if (wm == null) return false;

      // Scale the watermark to ~28% of the image width (keep aspect ratio).
      final int targetW = (base.width * 0.28).round();
      if (targetW > 0) wm = img.copyResize(wm, width: targetW);

      // Fade the watermark to make it subtle.
      wm = _fadeImage(wm, _watermarkOpacity);

      // Composite at the bottom-right corner with a 10px margin.
      int dx = base.width - wm.width - 10;
      int dy = base.height - wm.height - 10;
      if (dx < 0) dx = 0;
      if (dy < 0) dy = 0;
      img.copyInto(base, wm, dstX: dx, dstY: dy, blend: true);

      // Re-encode (keep PNG for png inputs, otherwise JPG).
      final List<int> bytes =
          ext == 'png' ? img.encodePng(base) : img.encodeJpg(base, quality: 90);
      await File(outputPath).writeAsBytes(bytes, flush: true);
      return true;
    } catch (e) {
      // On any decoding/encoding error, fall back to copying the original.
      // print('watermark error: $e');
      return false;
    }
  }

  /// Multiply the alpha channel of [src] by [opacity] (0..1) to fade it.
  img.Image _fadeImage(img.Image src, double opacity) {
    for (int y = 0; y < src.height; y++) {
      for (int x = 0; x < src.width; x++) {
        final int color = src.getPixel(x, y);
        final int alpha = img.getAlpha(color);
        src.setPixel(x, y, img.setAlpha(color, (alpha * opacity).round()));
      }
    }
    return src;
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

    /// Watermark the status (photos only) unless the user removed it / is rewarded
    if (AppModel().addWatermark && !AppModel().isRewarded) {
      final String candidate =
          "$tempDir/DOWNLOAD-ON-PLAYSTORE-${statusPath.split('/').last}";
      final bool applied = await _applyImageWatermark(
          inputPath: statusPath, outputPath: candidate);
      // Only share the watermarked copy if it was actually produced.
      if (applied) outputStatusPath = candidate;
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

  /// Get the external storage root path (e.g. `/storage/emulated/0/`).
  Future<String> _getExternalRoot() async {
    final Directory absoluteDir = await getExternalStorageDirectory();
    return absoluteDir.path
        .replaceFirst('Android/data/$APP_PACKAGE_NAME/files', '');
  }

  /// Get all existing media directories for the given platform [key].
  ///
  /// Each platform declares several candidate folders (see
  /// `SUPPORTED_PLATFORMS`); this returns only the ones that actually exist on
  /// the device so the tabs can scan and merge their contents.
  Future<List<String>> getMediaDirs(String key) async {
    final String root = await _getExternalRoot();

    // Find the platform config by key.
    MediaPlatform platform;
    for (final p in SUPPORTED_PLATFORMS) {
      if (p.key == key) {
        platform = p;
        break;
      }
    }
    if (platform == null) return <String>[];

    final List<String> dirs = [];
    for (final rel in platform.mediaDirs) {
      final String full = "$root$rel";
      if (Directory(full).existsSync()) {
        dirs.add(full);
      }
    }
    // print('getMediaDirs($key) -> $dirs');
    return dirs;
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

    /// Watermark (photos only) unless the user removed it / is rewarded.
    bool watermarked = false;
    if (AppModel().addWatermark && !AppModel().isRewarded) {
      watermarked = await _applyImageWatermark(
          inputPath: filePath, outputPath: outputStatusPath);
    }
    if (!watermarked) {
      // Videos and any non-watermarked media are copied unchanged.
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
