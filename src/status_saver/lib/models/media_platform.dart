import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Represents a social media platform whose media (WhatsApp statuses,
/// stories, reels or downloaded videos) this app can browse and save.
///
/// The app is data-driven: to add support for a new platform you only need to
/// add a new [MediaPlatform] entry to `SUPPORTED_PLATFORMS` in
/// `constants/app_constants.dart`. No screen or tab code needs to change.
class MediaPlatform {
  /// Unique key used internally and passed between screens/tabs.
  final String key;

  /// i18n translation key for the display name shown to the user.
  final String titleKey;

  /// Icon shown in the platform picker card.
  final FaIconData icon;

  /// Brand color for the icon.
  final Color color;

  /// Relative directory paths (from the external storage root, e.g.
  /// `/storage/emulated/0/`) that may contain this platform's media.
  ///
  /// Every directory that exists is scanned and the results are merged, so it
  /// is safe to list several candidate locations (they change between app
  /// versions and Android versions).
  final List<String> mediaDirs;

  /// Folder (relative to the storage root) that Android 11+ only lets us read
  /// through the system folder picker (Storage Access Framework). Null for
  /// platforms whose media lives in normal, readable media folders.
  final String? safPath;

  const MediaPlatform({
    required this.key,
    required this.titleKey,
    required this.icon,
    required this.color,
    required this.mediaDirs,
    this.safPath,
  });
}
