/*
 * Teoc Launcher — cabecera: saludo, fecha, luna, clima y accesos rápidos.
 */

import 'dart:async';

import 'package:flauncher/flauncher_channel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'pixel_sprite.dart';
import 'portal_card.dart';
import 'teoc_config.dart';
import 'teoc_theme.dart';
import 'teoc_vice.dart';
import 'weather.dart';

class TeocHeader extends StatefulWidget {
  const TeocHeader({super.key});

  @override
  State<TeocHeader> createState() => _TeocHeaderState();
}

class _TeocHeaderState extends State<TeocHeader> {
  late FLauncherChannel _channel;
  DateTime _now = DateTime.now();
  WeatherNow? _weather;
  List<Map<String, dynamic>> _inputs = [];
  Timer? _clockTimer;
  Timer? _weatherTimer;

  @override
  void initState() {
    super.initState();
    _channel = context.read<FLauncherChannel>();

    _clockTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) {
        setState(() => _now = DateTime.now());
      }
    });

    _loadWeather();
    _weatherTimer = Timer.periodic(const Duration(minutes: 30), (_) => _loadWeather());
    _loadInputs();
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    _weatherTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadWeather() async {
    final weather = await fetchWeather();
    if (mounted && weather != null) {
      setState(() => _weather = weather);
    }
  }

  Future<void> _loadInputs() async {
    try {
      final inputs = await _channel.getTvInputs();
      inputs.sort((a, b) => (_isPlayStation(b) ? 1 : 0) - (_isPlayStation(a) ? 1 : 0));
      if (mounted) {
        setState(() => _inputs = inputs.take(4).toList());
      }
    }
    catch (_) {
      // La tele no expone entradas: simplemente no se muestran.
    }
  }

  static bool _isPlayStation(Map<String, dynamic> input) {
    final label = (input["label"] ?? "").toString().toLowerCase();
    return label.contains("ps4") || label.contains("playstation") || label.contains("ps5");
  }

  String _greeting() {
    final hour = _now.hour;
    if (hour < 6) return "Buenas noches";
    if (hour < 12) return "Buenos días";
    if (hour < 20) return "Buenas tardes";
    return "Buenas noches";
  }

  String _dateLine() {
    String date;
    try {
      date = DateFormat("EEEE d 'de' MMMM", "es").format(_now);
    }
    catch (_) {
      date = DateFormat("EEEE d MMMM").format(_now);
    }
    if (date.isEmpty) {
      return date;
    }
    return date[0].toUpperCase() + date.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final moon = MoonPhase.of(_now);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${_greeting()}, ${TeocConfig.userName}",
                      style: const TextStyle(
                        color: TeocColors.cream,
                        fontSize: 30,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 0.5,
                        shadows: TeocText.softShadow,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${_dateLine()}  ·  ${moon.symbol} ${moon.name}",
                      style: const TextStyle(
                        color: TeocColors.gold,
                        fontFamily: TeocText.retroFont,
                        fontSize: 12,
                        letterSpacing: 1.2,
                        shadows: TeocText.softShadow,
                      ),
                    ),
                  ],
                ),
              ),
              if (_weather != null) _weatherBadge(_weather!),
            ],
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  ..._inputs.map((input) => Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: _inputCard(input),
                      )),
                  TeocPortalCard(
                    leading: const PixelSprite(
                      rows: [
                        "....##....",
                        "...#oo#...",
                        "...#oo#...",
                        "..######..",
                        "..#....#..",
                        "..#.##.#..",
                        "..#....#..",
                        "..######..",
                      ],
                      pixelSize: 3.5,
                      dark: TeocColors.cream,
                      mid: TeocColors.gold,
                    ),
                    title: "Teoc-Vice",
                    caption: "MIS PROYECTOS",
                    accent: TeocColors.moss,
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const TeocViceScreen()),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputCard(Map<String, dynamic> input) {
    final String id = (input["id"] ?? "").toString();
    final String label = (input["label"] ?? "Entrada").toString();
    final bool isPlayStation = _isPlayStation(input);

    return TeocPortalCard(
      leading: Icon(
        isPlayStation ? Icons.sports_esports : Icons.settings_input_hdmi,
        color: isPlayStation ? TeocColors.violet : TeocColors.cream,
        size: 26,
      ),
      title: isPlayStation ? "PlayStation 4" : label,
      caption: isPlayStation ? label.toUpperCase() : "ENTRADA HDMI",
      accent: isPlayStation ? TeocColors.violet : TeocColors.gold,
      onPressed: () => _channel.launchTvInput(id),
    );
  }

  Widget _weatherBadge(WeatherNow weather) => Padding(
        padding: const EdgeInsets.only(left: 16, bottom: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(weather.icon, color: TeocColors.moss, size: 30),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "${weather.temperature.round()}°",
                  style: const TextStyle(
                    color: TeocColors.cream,
                    fontSize: 26,
                    fontWeight: FontWeight.w300,
                    shadows: TeocText.softShadow,
                  ),
                ),
                Text(
                  "${weather.description} · ${TeocConfig.weatherCityName}".toUpperCase(),
                  style: const TextStyle(
                    color: TeocColors.muted,
                    fontFamily: TeocText.retroFont,
                    fontSize: 10,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
}
