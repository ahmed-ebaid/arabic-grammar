import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/localization/locale_controller.dart';
import '../../l10n/app_localizations.dart';

class LanguageButton extends StatelessWidget {
  const LanguageButton({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return IconButton(
      tooltip: l10n.language,
      icon: const Icon(Icons.language),
      onPressed: () => _showLanguagePicker(context),
    );
  }

  Future<void> _showLanguagePicker(BuildContext context) async {
    final localeController = context.read<LocaleController>();
    final l10n = AppLocalizations.of(context);

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(
                  l10n.language,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              RadioGroup<String>(
                groupValue: localeController.locale.languageCode,
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }
                  localeController.setLocale(Locale(value));
                  Navigator.of(context).pop();
                },
                child: Column(
                  children: [
                    RadioListTile<String>(
                      value: 'en',
                      title: Text(l10n.english),
                    ),
                    RadioListTile<String>(
                      value: 'ar',
                      title: Text(l10n.arabic),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}
