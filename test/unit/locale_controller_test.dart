import 'dart:io';

import 'package:arabic_grammar/core/localization/locale_controller.dart';
import 'package:arabic_grammar/core/storage/storage_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() {
  test(
    'defaults to Arabic and restores the selected English language',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'locale_settings_',
      );
      Hive.init(directory.path);
      final box = await Hive.openBox<dynamic>('locale_settings');
      addTearDown(() async {
        await box.close();
        await directory.delete(recursive: true);
      });
      final controller = LocaleController(box);
      expect(controller.locale, const Locale('ar'));
      await controller.setLocale(const Locale('en'));
      expect(box.get(StorageKeys.locale), 'en');
      expect(LocaleController(box).locale, const Locale('en'));
      await controller.setLocale(const Locale('ar'));
      expect(LocaleController(box).locale, const Locale('ar'));
    },
  );
}
