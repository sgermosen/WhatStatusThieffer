import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:status_saver/constants/app_constants.dart';

class AppLocalizations {
  final Locale locale;

  // Constructor
  AppLocalizations(this.locale);

  // Helper method to keep the code in widgets concise
  // Localizations are accessed using an InheritedWidget "of syntax"
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  // Localized strings map
  Map<String, String> _localizedStrings;

  // Load the json language file from the "lang folder"
  Future<bool> load() async {
    final String jsonLang =
        await rootBundle.loadString('assets/lang/${locale.languageCode}.json');
    // Decode string result
    final Map<String, dynamic> langMap = json.decode(jsonLang);
    _localizedStrings =
        langMap.map((key, value) => MapEntry(key, value.toString()));

    return true;
  }

  // Translate method - will be called from every widget which needs a localized text
  String translate(String key) {
    return _localizedStrings[key];
  }

  // Static member to have a simple access to the delegate from the MaterialApp
  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();
}

// LocalizationsDelegate is a factory for a set of localized resources
// In this case, the localized strings will be gotten in an AppLocalizations

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  // This delegate will never change (it doesn't even have fields)
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return SUPPORTED_LOCALES.contains(locale);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    // Init AppLocalizations class where the json loading actually runs
    final AppLocalizations localizations = new AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(LocalizationsDelegate<AppLocalizations> old) => false;
}
