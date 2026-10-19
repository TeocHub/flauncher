/*
 * Teoc Launcher — clima (Open-Meteo) y fase lunar.
 */

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';

import 'teoc_config.dart';

String weatherDescription(int code, bool isDay) {
  if (code == 0) return isDay ? "Despejado" : "Noche clara";
  if (code <= 2) return "Algo nublado";
  if (code == 3) return "Nublado";
  if (code == 45 || code == 48) return "Neblina";
  if (code >= 51 && code <= 57) return "Llovizna";
  if (code >= 61 && code <= 67) return "Lluvia";
  if (code >= 71 && code <= 77) return "Nieve";
  if (code >= 80 && code <= 82) return "Chubascos";
  if (code >= 85 && code <= 86) return "Chubascos de nieve";
  if (code >= 95) return "Tormenta";
  return "—";
}

IconData weatherIcon(int code, bool isDay) {
  if (code == 0) return isDay ? Icons.wb_sunny_outlined : Icons.nights_stay_outlined;
  if (code <= 2) return Icons.wb_cloudy_outlined;
  if (code == 3 || code == 45 || code == 48) return Icons.cloud_outlined;
  if (code >= 71 && code <= 77) return Icons.ac_unit;
  if (code >= 85 && code <= 86) return Icons.ac_unit;
  if (code >= 95) return Icons.flash_on;
  return Icons.water_drop_outlined;
}

class WeatherNow {
  final double temperature;
  final int code;
  final bool isDay;

  const WeatherNow(this.temperature, this.code, this.isDay);

  bool get isRainy => (code >= 51 && code <= 67) || (code >= 80 && code <= 82) || code >= 95;
  String get description => weatherDescription(code, isDay);
  IconData get icon => weatherIcon(code, isDay);
}

class WeatherHour {
  final DateTime time;
  final double temperature;
  final int code;
  final int rainChance;

  const WeatherHour(this.time, this.temperature, this.code, this.rainChance);

  IconData get icon => weatherIcon(code, time.hour >= 7 && time.hour < 20);
}

class WeatherDay {
  final DateTime date;
  final int code;
  final double max;
  final double min;
  final int rainChance;

  const WeatherDay(this.date, this.code, this.max, this.min, this.rainChance);

  String get description => weatherDescription(code, true);
  IconData get icon => weatherIcon(code, true);
}

class WeatherReport {
  final WeatherNow now;
  final List<WeatherHour> hours;
  final List<WeatherDay> days;
  final DateTime fetchedAt;

  const WeatherReport(this.now, this.hours, this.days, this.fetchedAt);

  WeatherDay? get today => days.isEmpty ? null : days.first;

  /// Resumen corto para la fila "Hoy": "Máx 22° · Mín 9° · 10% lluvia"
  String get todaySummary {
    final day = today;
    if (day == null) return now.description;
    return "Máx ${day.max.round()}° · Mín ${day.min.round()}°";
  }
}

WeatherReport? _lastReport;

/// Pronóstico completo (Open-Meteo, sin API key). Se reutiliza 15 minutos.
Future<WeatherReport?> fetchWeatherReport() async {
  final last = _lastReport;
  if (last != null && DateTime.now().difference(last.fetchedAt).inMinutes < 15) {
    return last;
  }

  final uri = Uri.https("api.open-meteo.com", "/v1/forecast", {
    "latitude": TeocConfig.weatherLatitude.toString(),
    "longitude": TeocConfig.weatherLongitude.toString(),
    "current": "temperature_2m,weather_code,is_day",
    "hourly": "temperature_2m,weather_code,precipitation_probability",
    "daily": "weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max",
    "forecast_days": "4",
    "timezone": "auto",
  });

  final client = HttpClient();
  client.connectionTimeout = const Duration(seconds: 8);
  try {
    final request = await client.getUrl(uri);
    final response = await request.close().timeout(const Duration(seconds: 12));
    if (response.statusCode != 200) {
      return last;
    }
    final body = await response.transform(utf8.decoder).join();
    final Map<String, dynamic> json = jsonDecode(body);

    final Map<String, dynamic> current = json["current"];
    final now = WeatherNow(
      _num(current["temperature_2m"]),
      _num(current["weather_code"]).toInt(),
      _num(current["is_day"]).toInt() == 1,
    );

    final List<WeatherHour> hours = [];
    final Map<String, dynamic>? hourly = json["hourly"];
    if (hourly != null) {
      final List times = hourly["time"] ?? [];
      final List temps = hourly["temperature_2m"] ?? [];
      final List codes = hourly["weather_code"] ?? [];
      final List rain = hourly["precipitation_probability"] ?? [];
      final from = DateTime.now().subtract(const Duration(minutes: 59));
      for (int i = 0; i < times.length && i < temps.length && i < codes.length; i++) {
        final time = DateTime.tryParse(times[i].toString());
        if (time == null || time.isBefore(from)) continue;
        hours.add(WeatherHour(time, _num(temps[i]), _num(codes[i]).toInt(), i < rain.length ? _num(rain[i]).toInt() : 0));
        if (hours.length >= 24) break;
      }
    }

    final List<WeatherDay> days = [];
    final Map<String, dynamic>? daily = json["daily"];
    if (daily != null) {
      final List dates = daily["time"] ?? [];
      final List codes = daily["weather_code"] ?? [];
      final List maxs = daily["temperature_2m_max"] ?? [];
      final List mins = daily["temperature_2m_min"] ?? [];
      final List rain = daily["precipitation_probability_max"] ?? [];
      for (int i = 0; i < dates.length && i < codes.length && i < maxs.length && i < mins.length; i++) {
        final date = DateTime.tryParse(dates[i].toString());
        if (date == null) continue;
        days.add(WeatherDay(date, _num(codes[i]).toInt(), _num(maxs[i]), _num(mins[i]), i < rain.length ? _num(rain[i]).toInt() : 0));
      }
    }

    final report = WeatherReport(now, hours, days, DateTime.now());
    _lastReport = report;
    return report;
  }
  catch (_) {
    return last;
  }
  finally {
    client.close();
  }
}

double _num(dynamic value) => value is num ? value.toDouble() : 0;

/// Solo el clima actual (lo usa el modo ambiente).
Future<WeatherNow?> fetchWeather() async => (await fetchWeatherReport())?.now;

class MoonPhase {
  final String name;
  final String symbol;

  const MoonPhase(this.name, this.symbol);

  static MoonPhase of(DateTime date) {
    // Luna nueva de referencia: 6 de enero de 2000, 18:14 UTC
    final reference = DateTime.utc(2000, 1, 6, 18, 14);
    const synodicMonth = 29.530588853;
    final days = date.toUtc().difference(reference).inMinutes / (60 * 24);
    double age = days % synodicMonth;
    if (age < 0) {
      age += synodicMonth;
    }
    final index = ((age / synodicMonth) * 8).round() % 8;

    const phases = [
      MoonPhase("Luna nueva", "🌑"),
      MoonPhase("Luna creciente", "🌒"),
      MoonPhase("Cuarto creciente", "🌓"),
      MoonPhase("Gibosa creciente", "🌔"),
      MoonPhase("Luna llena", "🌕"),
      MoonPhase("Gibosa menguante", "🌖"),
      MoonPhase("Cuarto menguante", "🌗"),
      MoonPhase("Luna menguante", "🌘"),
    ];
    return phases[max(0, min(7, index))];
  }
}
