import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../storage/storage_keys.dart';

class LocaleController extends ChangeNotifier {
  LocaleController(Box<dynamic> settingsBox)
    : _settingsBox = settingsBox,
      _locale = _supportedLocale(
        settingsBox.get(StorageKeys.locale) as String?,
      );

  LocaleController.inMemory([this._locale = const Locale('en')])
    : _settingsBox = null;

  final Box<dynamic>? _settingsBox;
  Locale _locale;

  Locale get locale => _locale;

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) {
      return;
    }

    _locale = locale;
    await _settingsBox?.put(StorageKeys.locale, locale.languageCode);
    notifyListeners();
  }

  static Locale _supportedLocale(String? languageCode) {
    return languageCode == 'ar' ? const Locale('ar') : const Locale('en');
  }
}
