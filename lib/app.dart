import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'core/config/app_environment.dart';
import 'core/localization/locale_controller.dart';
import 'core/models/content_models.dart';
import 'core/progress/lesson_progress_controller.dart';
import 'core/theme/app_theme.dart';
import 'core/user/user_data_controller.dart';
import 'l10n/app_localizations.dart';
import 'root_scaffold.dart';

class ArabicGrammarApp extends StatelessWidget {
  ArabicGrammarApp({
    required this.environment,
    required this.localeController,
    required this.lessonProgressController,
    UserDataController? userDataController,
    this.contentCatalog,
    super.key,
  }) : userDataController = userDataController ?? UserDataController.inMemory();

  final AppEnvironment environment;
  final LocaleController localeController;
  final LessonProgressController lessonProgressController;
  final UserDataController userDataController;
  final ContentCatalog? contentCatalog;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: localeController),
        ChangeNotifierProvider.value(value: userDataController),
      ],
      child: Consumer2<LocaleController, UserDataController>(
        builder: (context, locale, userData, child) {
          return MaterialApp(
            onGenerateTitle: (context) => AppLocalizations.of(context).appName,
            debugShowCheckedModeBanner: !environment.isProduction,
            locale: locale.locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: ThemeMode.system,
            builder: (context, child) {
              final mediaQuery = MediaQuery.of(context);
              return MediaQuery(
                data: mediaQuery.copyWith(
                  textScaler: TextScaler.linear(userData.textScale),
                ),
                child: child!,
              );
            },
            home: RootScaffold(
              contentCatalog: contentCatalog,
              lessonProgressController: lessonProgressController,
              userDataController: userDataController,
            ),
          );
        },
      ),
    );
  }
}
