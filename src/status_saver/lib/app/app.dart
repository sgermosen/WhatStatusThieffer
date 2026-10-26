import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:status_saver/app/app_localizations.dart';
import 'package:status_saver/constants/app_constants.dart';
import 'package:status_saver/models/media_platform.dart';
import 'package:status_saver/services/saf_statuses.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fc_native_video_thumbnail/fc_native_video_thumbnail.dart';

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

  /// Share a status that has not been saved yet.
  /// (The watermark feature was disabled and its ffmpeg dependency removed.)
  Future<void> shareNotSavedStatus(
      String statusPath, BuildContext context) async {
    await SharePlus.instance.share(ShareParams(files: [XFile(statusPath)]));
  }

  /// Return App Logo
  Widget getAppLogo({double? width, double? height}) {
    return Image.asset('assets/images/app_logo.png',
        width: width ?? 120, height: height ?? 120);
  }

  // /// Setup admob info
  // static final MobileAdTargetingInfo targetInfo = new MobileAdTargetingInfo(
  //   childDirected: false,
  // );

  /// Get thumbnail from video

  Future<String?> getVideoThumbnail(String videoPath) async {
    // Cache thumbnails by video name so each one is generated only once.
    final Directory cache = await getTemporaryDirectory();
    final String name = videoPath.split('/').last;
    final File thumb = File('${cache.path}/thumbs/$name.jpg');
    if (thumb.existsSync()) return thumb.path;
    thumb.parent.createSync(recursive: true);
    try {
      final created = await FcNativeVideoThumbnail().saveThumbnailToFile(
        srcFile: videoPath,
        destFile: thumb.path,
        width: 250,
        height: 400,
        format: 'jpeg',
        quality: 75,
      );
      return created ? thumb.path : null;
    } catch (e) {
      debugPrint('Thumbnail failed for $videoPath: $e');
      return null;
    }
  }

  /// Share app
  Future<void> shareApp(BuildContext context) async {
    // Init i18n instance
    final i18n = AppLocalizations.of(context);

    await SharePlus.instance.share(ShareParams(
        text: '${i18n.translate('share_app_message')} '
            'https://play.google.com/store/apps/details?id=$APP_PACKAGE_NAME\n'
            '${i18n.translate('install_it_now')}'));
  }

  /// Go to play store app page
  Future<void> goToPlayStore() => _openUrl(
      "https://play.google.com/store/apps/details?id=$APP_PACKAGE_NAME");

  /// Open facebook page in app/browser
  Future<void> openFacebook() =>
      _openUrl('https://facebook.com/$FACEBOOK_USERNAME');

  /// Open privacy policy page
  Future<void> openPrivacyPage() => _openUrl(
      'http://www.sgermosen.com/2020/08/privacy-policy-for-xamarindo.html');

  /// Open a URL in the browser / matching app.
  Future<void> _openUrl(String url) async {
    if (!await launchUrl(Uri.parse(url),
        mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }

  /// Check storage permission
  ///
  /// Android 13+ (API 33) has no generic storage permission: media access is
  /// granted per type (photos / videos). Older versions use `storage`. We ask
  /// for both sets and continue if either is granted.
  Future<void> checkStoragePermission(
      {required VoidCallback onGranted}) async {
    final statuses = await [
      Permission.storage,
      Permission.photos,
      Permission.videos,
    ].request();

    final granted =
        statuses.values.any((s) => s.isGranted || s.isLimited);
    if (granted) {
      onGranted();
    } else if (statuses.values.every((s) => s.isPermanentlyDenied)) {
      openAppSettings();
    }
  }

  /// Get the external storage root path (e.g. `/storage/emulated/0/`).
  Future<String> _getExternalRoot() async {
    final Directory? absoluteDir = await getExternalStorageDirectory();
    if (absoluteDir == null) return '/storage/emulated/0/';
    return absoluteDir.path
        .replaceFirst('Android/data/$APP_PACKAGE_NAME/files', '');
  }

  /// Load the media files (absolute paths) of the platform [key].
  ///
  /// On Android 11+ WhatsApp statuses are read through the folder the user
  /// granted with the system picker; if access is missing the result has
  /// [MediaLoadResult.needsFolderAccess] set.
  Future<MediaLoadResult> loadMediaFiles(String key) async {
    final platform = platformByKey(key);
    if (platform == null) return MediaLoadResult(const []);

    final safPath = platform.safPath;
    if (safPath != null && await SafStatuses.isRequired()) {
      final uri = await SafStatuses.grantedUri(key);
      if (uri == null) {
        return MediaLoadResult(const [], needsFolderAccess: true);
      }
      return MediaLoadResult(await SafStatuses.sync(uri, key));
    }

    final List<String> files = [];
    for (final dir in await getMediaDirs(key)) {
      try {
        files.addAll(Directory(dir).listSync().map((item) => item.path));
      } catch (e) {
        // Ignore directories we can't read.
      }
    }
    return MediaLoadResult(files);
  }

  /// Ask the user (system folder picker) for access to the platform's
  /// statuses folder. Returns true when granted.
  Future<bool> requestFolderAccess(String key) async {
    final safPath = platformByKey(key)?.safPath;
    if (safPath == null) return false;
    return SafStatuses.requestAccess(key, safPath);
  }

  MediaPlatform? platformByKey(String key) {
    for (final p in SUPPORTED_PLATFORMS) {
      if (p.key == key) return p;
    }
    return null;
  }

  /// Get all existing media directories for the given platform [key].
  ///
  /// Each platform declares several candidate folders (see
  /// `SUPPORTED_PLATFORMS`); this returns only the ones that actually exist on
  /// the device so the tabs can scan and merge their contents.
  Future<List<String>> getMediaDirs(String key) async {
    final String root = await _getExternalRoot();

    final platform = platformByKey(key);
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

  /// Get Saved Statuses path.
  ///
  /// Saved files go to `Pictures/<folder>` in shared storage: since Android 11
  /// apps can no longer create folders at the storage root, but they can
  /// create their own files inside the standard media folders.
  Future<String> getSavedStatusesPath() async {
    final String root = await _getExternalRoot();
    final String userDir = await getSavedStatusDir();
    return "${root}Pictures/$userDir";
  }

  /// Save File in Gallery
  Future<void> saveFileInGallery(BuildContext context,
      {required String filePath}) async {
    // Init i18n instance
    final i18n = AppLocalizations.of(context);

    // show loading dialog
    processingDialog(context);

    final String statusDir = await getSavedStatusesPath();
    final String fileExt = filePath.split('.').last;

    // Check directory
    if (!Directory(statusDir).existsSync()) {
      Directory(statusDir).createSync(recursive: true);
    }

    /// Create the Status new file name
    /// TODO: you can make whatever strategy you want to make names for the file
    final String outputStatusPath =
        "$statusDir/Status-${DateTime.now().millisecondsSinceEpoch.toString()}.$fileExt";

    // Copy status to the saved-status directory
    File(filePath).copySync(outputStatusPath);

    if (!context.mounted) return;
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
    required BuildContext context,
    required String message,
    Color? color,
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
                FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: Colors.teal),
                  child: const Text('OK'),
                  onPressed: () => Navigator.of(context).pop(),
                )
              ],
            ));
  }
}

/// Media files of a platform, or a flag saying the user must first grant
/// folder access (Android 11+ WhatsApp statuses).
class MediaLoadResult {
  final List<String> files;
  final bool needsFolderAccess;

  const MediaLoadResult(this.files, {this.needsFolderAccess = false});
}
