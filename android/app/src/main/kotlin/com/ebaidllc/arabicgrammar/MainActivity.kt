package com.ebaidllc.arabicgrammar

import android.icu.util.Calendar
import android.icu.util.IslamicCalendar
import android.icu.util.TimeZone
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.ebaidllc.arabicgrammar/hijri_calendar",
        ).setMethodCallHandler { call, result ->
            if (call.method != "getDate") {
                result.notImplemented()
            } else {
                val milliseconds = call.argument<Number>("millisecondsSinceEpoch")?.toLong()
                if (milliseconds == null) {
                    result.error("invalid_argument", "A timestamp is required.", null)
                } else {
                    val calendar = IslamicCalendar(TimeZone.getDefault())
                    calendar.calculationType = IslamicCalendar.CalculationType.ISLAMIC_UMALQURA
                    calendar.timeInMillis = milliseconds
                    result.success(
                        mapOf(
                            "year" to calendar.get(Calendar.YEAR),
                            "month" to calendar.get(Calendar.MONTH) + 1,
                            "day" to calendar.get(Calendar.DAY_OF_MONTH),
                        ),
                    )
                }
            }
        }
    }
}
