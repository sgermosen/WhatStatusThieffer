import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:status_saver/app/app.dart';

/// Kind of media resolved from a link.
enum MediaType { image, video }

/// A direct, downloadable media URL resolved from a shared link, together with
/// any HTTP headers required to actually fetch it (some CDNs reject requests
/// without a proper User-Agent / Referer).
class ResolvedMedia {
  final String url;
  final MediaType type;
  final Map<String, String> headers;

  ResolvedMedia({
    @required this.url,
    @required this.type,
    this.headers = const {},
  });
}

/// A browser-like User-Agent. Many platforms serve a stripped-down / login page
/// to non-browser clients, so we pretend to be desktop Chrome.
const String _kUserAgent =
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
    '(KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36';

Map<String, String> _browserHeaders([String referer]) {
  final h = <String, String>{
    'User-Agent': _kUserAgent,
    'Accept-Language': 'en-US,en;q=0.9',
  };
  if (referer != null) h['Referer'] = referer;
  return h;
}

/// Contract every platform-specific resolver implements.
abstract class PlatformResolver {
  /// Human key used to show the detected platform in the UI.
  String get platform;

  /// Whether this resolver knows how to handle the given [url].
  bool canHandle(String url);

  /// Resolve the direct media URL, or return null if it couldn't be found.
  Future<ResolvedMedia> resolve(String url);
}

/// Picks the right resolver for a link and falls back to Open Graph tags,
/// which a surprising amount of public content on all platforms exposes.
class LinkDownloader {
  final List<PlatformResolver> _resolvers = [
    TikTokResolver(),
    FacebookResolver(),
    InstagramResolver(),
  ];
  final _OpenGraphResolver _fallback = _OpenGraphResolver();

  /// Detect the platform name from a raw link (for the UI).
  String detectPlatform(String rawUrl) {
    final url = extractUrl(rawUrl);
    if (url == null) return null;
    for (final r in _resolvers) {
      if (r.canHandle(url)) return r.platform;
    }
    return 'link';
  }

  /// Resolve a raw shared link (which may contain surrounding text) into a
  /// direct media URL. Throws a human-readable message on failure.
  Future<ResolvedMedia> resolve(String rawUrl) async {
    final url = extractUrl(rawUrl);
    if (url == null) {
      throw 'invalid_link';
    }

    // Try the platform-specific resolver first.
    for (final r in _resolvers) {
      if (r.canHandle(url)) {
        try {
          final media = await r.resolve(url);
          if (media != null) return media;
        } catch (_) {
          // fall through to the Open Graph fallback
        }
      }
    }

    // Universal fallback: Open Graph meta tags.
    final media = await _fallback.resolve(url);
    if (media != null) return media;

    throw 'unsupported_or_private_link';
  }

  /// Download a resolved media into the app's saved-status folder so it shows
  /// up in the "Saved" tab. Returns the saved file path.
  Future<String> download(ResolvedMedia media) async {
    final App app = App();
    final String dir = await app.getSavedStatusesPath();
    if (!Directory(dir).existsSync()) {
      Directory(dir).createSync(recursive: true);
    }

    final String ext = media.type == MediaType.video ? 'mp4' : 'jpg';
    final String path =
        '$dir/Download-${DateTime.now().millisecondsSinceEpoch}.$ext';

    final headers = media.headers.isEmpty ? _browserHeaders() : media.headers;
    final resp = await http.get(Uri.parse(media.url), headers: headers);

    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      await File(path).writeAsBytes(resp.bodyBytes, flush: true);
      return path;
    }
    throw 'download_failed';
  }
}

/// Extract the first http(s) URL from a shared string (users often share
/// "look at this <url> lol").
String extractUrl(String raw) {
  if (raw == null) return null;
  final match =
      RegExp(r'https?:\/\/[^\s]+').firstMatch(raw.trim());
  return match != null ? match.group(0) : null;
}

/// Fetch a page as HTML using browser-like headers (follows redirects, which
/// resolves short links like vm.tiktok.com / fb.watch).
Future<String> _fetchHtml(String url, [String referer]) async {
  final resp = await http.get(Uri.parse(url), headers: _browserHeaders(referer));
  return resp.body;
}

/// Read a `<meta property="og:xxx" content="yyy">` value, tolerating either
/// attribute order and single/double quotes.
String _readMeta(String html, String property) {
  // property before content
  final a = RegExp(
    '<meta[^>]+(?:property|name)=["\']' +
        RegExp.escape(property) +
        '["\'][^>]+content=["\']([^"\']+)["\']',
    caseSensitive: false,
  ).firstMatch(html);
  if (a != null) return _unescape(a.group(1));

  // content before property
  final b = RegExp(
    '<meta[^>]+content=["\']([^"\']+)["\'][^>]+(?:property|name)=["\']' +
        RegExp.escape(property) +
        '["\']',
    caseSensitive: false,
  ).firstMatch(html);
  if (b != null) return _unescape(b.group(1));

  return null;
}

/// Unescape common HTML / JSON / unicode escaping found in scraped URLs.
String _unescape(String s) {
  if (s == null) return null;
  return s
      .replaceAll(r'\/', '/')
      .replaceAll('&amp;', '&')
      .replaceAllMapped(
          RegExp(r'\\u([0-9a-fA-F]{4})'),
          (m) => String.fromCharCode(int.parse(m.group(1), radix: 16)));
}

/// ---------------------------------------------------------------------------
/// TikTok
/// ---------------------------------------------------------------------------
class TikTokResolver implements PlatformResolver {
  @override
  String get platform => 'TikTok';

  @override
  bool canHandle(String url) => url.contains('tiktok.com');

  @override
  Future<ResolvedMedia> resolve(String url) async {
    final html = await _fetchHtml(url, 'https://www.tiktok.com/');

    // Newer embedded JSON blob.
    final videoUrl = _fromUniversalData(html) ?? _fromSigiState(html);
    if (videoUrl != null) {
      return ResolvedMedia(
        url: videoUrl,
        type: MediaType.video,
        headers: _browserHeaders('https://www.tiktok.com/'),
      );
    }

    // Fallback to Open Graph (cover image / player).
    final og = _readMeta(html, 'og:video') ?? _readMeta(html, 'og:image');
    if (og != null) {
      return ResolvedMedia(
        url: og,
        type: og.contains('.mp4') ? MediaType.video : MediaType.image,
        headers: _browserHeaders('https://www.tiktok.com/'),
      );
    }
    return null;
  }

  String _fromUniversalData(String html) {
    final m = RegExp(
      r'<script id="__UNIVERSAL_DATA_FOR_REHYDRATION__"[^>]*>(.+?)</script>',
      dotAll: true,
    ).firstMatch(html);
    if (m == null) return null;
    try {
      final data = jsonDecode(m.group(1));
      final item = data['__DEFAULT_SCOPE__']['webapp.video-detail']['itemInfo']
          ['itemStruct']['video'];
      return item['downloadAddr'] ?? item['playAddr'];
    } catch (_) {
      return null;
    }
  }

  String _fromSigiState(String html) {
    final m = RegExp(
      r'<script id="SIGI_STATE"[^>]*>(.+?)</script>',
      dotAll: true,
    ).firstMatch(html);
    if (m == null) return null;
    try {
      final data = jsonDecode(m.group(1));
      final Map items = data['ItemModule'];
      final first = items.values.first;
      final video = first['video'];
      return video['downloadAddr'] ?? video['playAddr'];
    } catch (_) {
      return null;
    }
  }
}

/// ---------------------------------------------------------------------------
/// Facebook (public videos / reels)
/// ---------------------------------------------------------------------------
class FacebookResolver implements PlatformResolver {
  @override
  String get platform => 'Facebook';

  @override
  bool canHandle(String url) =>
      url.contains('facebook.com') || url.contains('fb.watch');

  @override
  Future<ResolvedMedia> resolve(String url) async {
    final html = await _fetchHtml(url, 'https://www.facebook.com/');

    for (final key in const [
      'browser_native_hd_url',
      'browser_native_sd_url',
      'playable_url_quality_hd',
      'playable_url',
      'hd_src',
      'sd_src',
    ]) {
      final m = RegExp('"' + key + '":"(.*?)"').firstMatch(html);
      if (m != null && m.group(1).isNotEmpty) {
        return ResolvedMedia(
          url: _unescape(m.group(1)),
          type: MediaType.video,
          headers: _browserHeaders('https://www.facebook.com/'),
        );
      }
    }

    // Fallback to Open Graph.
    final og = _readMeta(html, 'og:video') ?? _readMeta(html, 'og:image');
    if (og != null) {
      return ResolvedMedia(
        url: og,
        type: og.contains('.mp4') ? MediaType.video : MediaType.image,
        headers: _browserHeaders('https://www.facebook.com/'),
      );
    }
    return null;
  }
}

/// ---------------------------------------------------------------------------
/// Instagram (public posts / reels only — most content needs a session)
/// ---------------------------------------------------------------------------
class InstagramResolver implements PlatformResolver {
  @override
  String get platform => 'Instagram';

  @override
  bool canHandle(String url) => url.contains('instagram.com');

  @override
  Future<ResolvedMedia> resolve(String url) async {
    final html = await _fetchHtml(url, 'https://www.instagram.com/');

    final video = _readMeta(html, 'og:video') ??
        _readMeta(html, 'og:video:secure_url');
    if (video != null) {
      return ResolvedMedia(url: video, type: MediaType.video);
    }
    final image = _readMeta(html, 'og:image');
    if (image != null) {
      return ResolvedMedia(url: image, type: MediaType.image);
    }
    return null;
  }
}

/// ---------------------------------------------------------------------------
/// Generic Open Graph fallback (works for any site exposing og:video/og:image)
/// ---------------------------------------------------------------------------
class _OpenGraphResolver {
  Future<ResolvedMedia> resolve(String url) async {
    final html = await _fetchHtml(url);
    final video = _readMeta(html, 'og:video') ??
        _readMeta(html, 'og:video:url') ??
        _readMeta(html, 'og:video:secure_url');
    if (video != null) {
      return ResolvedMedia(url: video, type: MediaType.video);
    }
    final image = _readMeta(html, 'og:image');
    if (image != null) {
      return ResolvedMedia(url: image, type: MediaType.image);
    }
    return null;
  }
}
