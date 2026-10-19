/*
 * Teoc Launcher — contenido editable desde GitHub (teoc/contenido.json):
 * recordatorios, calendario gamer y eventos. Se guarda una copia local
 * para que funcione aunque no haya internet.
 */

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'teoc_config.dart';

class Reminder {
  final String text;
  /// "todos" o el id de un perfil ("teoc", "skynook").
  final String forProfile;
  /// Días de la semana (1 = lunes ... 7 = domingo). Vacío = todos los días.
  final List<int> weekdays;
  final DateTime? date;

  const Reminder(this.text, this.forProfile, this.weekdays, this.date);

  bool appliesTo(String profileId, DateTime now) {
    if (forProfile != "todos" && forProfile != profileId) {
      return false;
    }
    final day = date;
    if (day != null) {
      return day.year == now.year && day.month == now.month && day.day == now.day;
    }
    return weekdays.isEmpty || weekdays.contains(now.weekday);
  }
}

class CalendarEntry {
  final String title;
  final DateTime date;
  final String detail;
  /// "juego" o "evento"
  final String kind;

  const CalendarEntry(this.title, this.date, this.detail, this.kind);

  int daysLeft(DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    return target.difference(today).inDays;
  }
}

class RemoteContentService extends ChangeNotifier {
  static const _cacheKey = "teoc_remote_content";

  final SharedPreferences _prefs;
  List<Reminder> _reminders = [];
  List<CalendarEntry> _calendar = [];
  Timer? _timer;

  List<Reminder> get reminders => _reminders;
  List<CalendarEntry> get calendar => _calendar;

  RemoteContentService(this._prefs) {
    final cached = _prefs.getString(_cacheKey);
    if (cached != null) {
      _apply(cached);
    }
    refresh();
    _timer = Timer.periodic(const Duration(hours: 1), (_) => refresh());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  List<Reminder> remindersFor(String profileId) {
    final now = DateTime.now();
    return _reminders.where((reminder) => reminder.appliesTo(profileId, now)).toList();
  }

  List<CalendarEntry> upcoming({int limit = 6}) {
    final now = DateTime.now();
    final list = _calendar.where((entry) => entry.daysLeft(now) >= 0).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    return list.take(limit).toList();
  }

  Future<void> refresh() async {
    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 8);
    try {
      // El parámetro evita que el CDN entregue una versión vieja
      final uri = Uri.parse("${TeocConfig.remoteContentUrl}?t=${DateTime.now().millisecondsSinceEpoch ~/ 600000}");
      final request = await client.getUrl(uri);
      final response = await request.close().timeout(const Duration(seconds: 12));
      if (response.statusCode != 200) {
        return;
      }
      final body = await response.transform(utf8.decoder).join();
      if (_apply(body)) {
        await _prefs.setString(_cacheKey, body);
      }
    }
    catch (_) {
      // Sin internet: se mantiene la copia guardada
    }
    finally {
      client.close();
    }
  }

  bool _apply(String body) {
    try {
      final Map<String, dynamic> json = jsonDecode(body);

      final List<Reminder> reminders = [];
      for (final raw in (json["recordatorios"] as List? ?? [])) {
        if (raw is! Map) continue;
        final text = (raw["texto"] ?? "").toString();
        if (text.isEmpty) continue;
        final List<int> weekdays = [];
        for (final day in (raw["dias"] as List? ?? [])) {
          final value = _weekday(day.toString());
          if (value != null) weekdays.add(value);
        }
        reminders.add(Reminder(
          text,
          (raw["para"] ?? "todos").toString().toLowerCase(),
          weekdays,
          DateTime.tryParse((raw["fecha"] ?? "").toString()),
        ));
      }

      final List<CalendarEntry> calendar = [];
      void addEntries(List? list, String kind) {
        for (final raw in (list ?? [])) {
          if (raw is! Map) continue;
          final date = DateTime.tryParse((raw["fecha"] ?? "").toString());
          final title = (raw["titulo"] ?? "").toString();
          if (date == null || title.isEmpty) continue;
          calendar.add(CalendarEntry(title, date, (raw["detalle"] ?? raw["plataformas"] ?? "").toString(), kind));
        }
      }
      addEntries(json["lanzamientos"] as List?, "juego");
      addEntries(json["eventos"] as List?, "evento");

      _reminders = reminders;
      _calendar = calendar;
      notifyListeners();
      return true;
    }
    catch (_) {
      return false;
    }
  }

  static int? _weekday(String name) {
    const days = {
      "lunes": 1, "martes": 2, "miercoles": 3, "miércoles": 3, "jueves": 4,
      "viernes": 5, "sabado": 6, "sábado": 6, "domingo": 7,
    };
    return days[name.toLowerCase().trim()];
  }
}
