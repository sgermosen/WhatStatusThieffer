import 'package:flutter_test/flutter_test.dart';
import 'package:status_saver/services/link_downloader.dart';

void main() {
  group('extractUrl', () {
    test('finds the URL inside shared text', () {
      expect(
          extractUrl('mira esto https://vm.tiktok.com/ZMabc123/ jaja'),
          'https://vm.tiktok.com/ZMabc123/');
    });
    test('returns null without a URL', () {
      expect(extractUrl('hola'), isNull);
      expect(extractUrl(null), isNull);
    });
  });

  group('detectPlatform', () {
    final d = LinkDownloader();
    test('recognises each supported platform', () {
      expect(d.detectPlatform('https://www.tiktok.com/@a/video/1'), 'TikTok');
      expect(d.detectPlatform('https://fb.watch/abc/'), 'Facebook');
      expect(d.detectPlatform('https://www.instagram.com/reel/xyz/'),
          'Instagram');
    });
    test('falls back to a generic link', () {
      expect(d.detectPlatform('https://example.com/video'), 'link');
    });
    test('returns null for text without a link', () {
      expect(d.detectPlatform('no link here'), isNull);
    });
  });
}
