import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:status_saver/constants/app_constants.dart';

/// Every key the code translates must exist in every language file, otherwise
/// the UI shows the raw key.
void main() {
  Map<String, dynamic> load(String lang) =>
      json.decode(File('assets/lang/$lang.json').readAsStringSync());

  final usedKeys = <String>{};
  final pattern = RegExp(r'''translate\(\s*['"]([A-Za-z0-9_]+)['"]''');
  for (final f in Directory('lib').listSync(recursive: true)) {
    if (f is File && f.path.endsWith('.dart')) {
      usedKeys.addAll(
          pattern.allMatches(f.readAsStringSync()).map((m) => m.group(1)!));
    }
  }
  usedKeys.addAll(SUPPORTED_PLATFORMS.map((p) => p.titleKey));

  for (final locale in SUPPORTED_LOCALES) {
    final lang = locale.languageCode;
    test('$lang.json has every key used in the code', () {
      final strings = load(lang);
      final missing = usedKeys.where((k) => !strings.containsKey(k)).toList()
        ..sort();
      expect(missing, isEmpty, reason: 'Missing in $lang.json');
    });
  }
}
