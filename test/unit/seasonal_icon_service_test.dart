import 'package:arabic_grammar/core/services/hijri_calendar_service.dart';
import 'package:arabic_grammar/core/services/seasonal_icon_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('maps Ramadan, Eid al-Fitr, and Eid al-Adha windows', () {
    expect(
      SeasonalIconService.iconFor(const HijriDate(1447, 9, 1)),
      SeasonalIcon.ramadan,
    );
    expect(
      SeasonalIconService.iconFor(const HijriDate(1447, 10, 2)),
      SeasonalIcon.eidAlFitr,
    );
    expect(
      SeasonalIconService.iconFor(const HijriDate(1447, 10, 4)),
      SeasonalIcon.standard,
    );
    expect(
      SeasonalIconService.iconFor(const HijriDate(1447, 12, 10)),
      SeasonalIcon.eidAlAdha,
    );
    expect(
      SeasonalIconService.iconFor(const HijriDate(1447, 12, 14)),
      SeasonalIcon.standard,
    );
  });

  test('applies alternate icon via MethodChannel on iOS', () async {
    String? currentIcon;
    final appliedIcons = <String?>[];
    const iconChannel = MethodChannel(SeasonalIconService.channelName);
    const hijriChannel = MethodChannel(HijriCalendarService.channelName);

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(iconChannel, (call) async {
          switch (call.method) {
            case 'supportsAlternateIcons':
              return true;
            case 'getIconName':
              return currentIcon;
            case 'setIconName':
              final args = call.arguments as Map<dynamic, dynamic>;
              currentIcon = args['name'] as String?;
              appliedIcons.add(currentIcon);
              return null;
          }
          return null;
        });

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(hijriChannel, (call) async {
          return <String, int>{'year': 1447, 'month': 9, 'day': 10};
        });

    addTearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(iconChannel, null);
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(hijriChannel, null);
    });

    final service = SeasonalIconService(platformSupported: true);
    expect(await service.applyForDate(), isTrue);
    expect(currentIcon, 'AppIcon-Ramadan');
    expect(await service.applyForDate(), isFalse);
    expect(appliedIcons, ['AppIcon-Ramadan']);
  });
}
