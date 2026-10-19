/*
 * Teoc Launcher — clima (Open-Meteo) y fase lunar.
 */

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';

import 'teoc_config.dart';

class WeatherNow {
  final double temperature;
  final int code;
  final bool isDay;

  const WeatherNow(this.temperature, this.code, this.isDay);

  String get description {
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

  IconData get icon {
    if (code == 0) return isDay ? Icons.wb_sunny_outlined : Icons.nights_stay_outlined;
    if (code <= 2) return Icons.wb_cloudy_outlined;
    if (code == 3 || code == 45 || code == 48) return Icons.cloud_outlined;
    if (code >= 71 && code <= 77) return Icons.ac_unit;
    if (code >= 85 && code <= 86) return Icons.ac_unit;
    if (code >= 95) return Icons.flash_on;
    return Icons.water_drop_outlined;
  }
}

Future<WeatherNow?> fetchWeather() async {
  final uri = Uri.https("api.open-meteo.com", "/v1/forecast", {
    "latitude": TeocConfig.weatherLatitude.toString(),
    "longitude": TeocConfig.weatherLongitude.toString(),
    "current": "temperature_2m,weather_code,is_day",
    "timezone": "auto",
  });

  final client = HttpClient();
  client.connectionTimeout = const Duration(seconds: 8);
  try {
    final request = await client.getUrl(uri);
    final response = await request.close().timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) {
      return null;
    }
    final body = await response.transform(utf8.decoder).join();
    final Map<String, dynamic> json = jsonDecode(body);
    final Map<String, dynamic> current = json["current"];
    return WeatherNow(
      (current["temperature_2m"] as num).toDouble(),
      (current["weather_code"] as num).toInt(),
      (current["is_day"] as num).toInt() == 1,
    );
  }
  catch (_) {
    return null;
  }
  finally {
    client.close();
  }
}

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
