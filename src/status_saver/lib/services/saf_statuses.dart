import 'dart:io';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Access to folders the app can't read directly (WhatsApp's `.Statuses` on
/// Android 11+), through the Storage Access Framework bridge in
/// `MainActivity.kt`.
///
/// The user grants access to the folder once; the permission persists across
/// restarts. Files are copied into the app cache so the rest of the app keeps
/// working with plain file paths.
class SafStatuses {
  static const MethodChannel _channel = MethodChannel('status_saver/saf');
  static int? _sdkInt;

  static Future<int> _sdk() async =>
      _sdkInt ??= await _channel.invokeMethod<int>('sdkInt') ?? 0;

  /// Android 11 (API 30) and newer require SAF for other apps' Android/media.
  static Future<bool> isRequired() async =>
      Platform.isAndroid && await _sdk() >= 30;

  static String _prefKey(String platformKey) => 'saf_tree_uri_$platformKey';

  /// The granted folder for [platformKey], or null if access is missing (never
  /// granted, or revoked by the user).
  static Future<String?> grantedUri(String platformKey) async {
    final prefs = await SharedPreferences.getInstance();
    final uri = prefs.getString(_prefKey(platformKey));
    if (uri == null) return null;
    final ok = await _channel.invokeMethod<bool>('hasAccess', {'uri': uri});
    return ok == true ? uri : null;
  }

  /// Open the system folder picker at [relativePath] (e.g.
  /// `Android/media/com.whatsapp/WhatsApp/Media/.Statuses`). Returns true if
  /// the user granted access.
  static Future<bool> requestAccess(
      String platformKey, String relativePath) async {
    final uri = await _channel
        .invokeMethod<String>('requestAccess', {'path': relativePath});
    if (uri == null) return false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey(platformKey), uri);
    return true;
  }

  /// Copy the folder's images/videos into the cache and return their paths.
  static Future<List<String>> sync(String treeUri, String platformKey) async {
    final paths = await _channel.invokeListMethod<String>(
        'sync', {'uri': treeUri, 'dir': platformKey});
    return paths ?? <String>[];
  }
}
