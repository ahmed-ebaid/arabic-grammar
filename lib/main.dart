import 'package:flutter/widgets.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'core/config/app_environment.dart';
import 'core/localization/locale_controller.dart';
import 'core/storage/storage_keys.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  final settingsBox = await Hive.openBox<dynamic>(StorageKeys.settingsBox);

  runApp(
    ArabicGrammarApp(
      environment: AppEnvironment.fromDefines(),
      localeController: LocaleController(settingsBox),
    ),
  );
}
