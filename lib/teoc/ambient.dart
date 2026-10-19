/*
 * Teoc Launcher — modo ambiente: aparece tras unos minutos sin usar el control.
 * Paisaje que cambia cada hora, reloj grande, clima, carta del día,
 * recordatorios y el próximo lanzamiento. Cualquier botón lo cierra.
 */

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'daily.dart';
import 'pixel_sprite.dart';
import 'profiles.dart';
import 'remote_content.dart';
import 'teoc_theme.dart';
import 'weather.dart';

class AmbientScreen extends StatefulWidget {
  const AmbientScreen({super.key});

  @override
  State<AmbientScreen> createState() => _AmbientScreenState();
}

class _AmbientScreenState extends State<AmbientScreen> {
  DateTime _now = DateTime.now();
  WeatherNow? _weather;
  Timer? _timer;
  bool _zoomed = false;
  bool _closing = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (mounted) {
        setState(() => _now = DateTime.now());
      }
    });
    fetchWeather().then((weather) {
      if (mounted && weather != null) {
        setState(() => _weather = weather);
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() => _zoomed = true);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _close() {
    if (_closing) {
      return;
    }
    _closing = true;
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileService>().current;
    final content = context.watch<RemoteContentService>();
    final reminders = content.remindersFor(profile.id);
    final upcoming = content.upcoming(limit: 1);
    final card = TarotCard.ofDay(profile.id, _now);
    final moon = MoonPhase.of(_now);
    final weather = _weather;

    String date;
    try {
      date = DateFormat("EEEE d 'de' MMMM", "es").format(_now);
    }
    catch (_) {
      date = DateFormat("EEEE d MMMM").format(_now);
    }
    if (date.isNotEmpty) {
      date = date[0].toUpperCase() + date.substring(1);
    }

    // Una imagen distinta cada hora (picsum.photos, sin API key)
    final seed = "teoc-${_now.year}${_now.month}${_now.day}${_now.hour}";
    final imageUrl = "https://picsum.photos/seed/$seed/1280/720";

    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          _close();
        }
        return KeyEventResult.handled;
      },
      child: GestureDetector(
        onTap: _close,
        child: Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            fit: StackFit.expand,
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0.6, -0.6),
                    radius: 1.4,
                    colors: [profile.accentSoft, TeocColors.night],
                  ),
                ),
              ),
              AnimatedScale(
                scale: _zoomed ? 1.08 : 1.0,
                duration: const Duration(seconds: 90),
                curve: Curves.linear,
                child: Image.network(
                  imageUrl,
                  key: ValueKey(imageUrl),
                  fit: BoxFit.cover,
                  gaplessPlayback: true,
                  frameBuilder: (context, child, frame, wasSync) => AnimatedOpacity(
                    opacity: frame == null ? 0 : 1,
                    duration: const Duration(seconds: 2),
                    child: child,
                  ),
                  errorBuilder: (context, error, stack) => const SizedBox.shrink(),
                ),
              ),
              // Velo oscuro para que el texto se lea siempre
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x99000000), Color(0x22000000), Color(0xAA000000)],
                    stops: [0, 0.45, 1],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(48, 36, 48, 32),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _reminders(reminders, profile.accent)),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              DateFormat("HH:mm").format(_now),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 72,
                                fontWeight: FontWeight.w200,
                                height: 1,
                                shadows: TeocText.softShadow,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              date,
                              style: const TextStyle(color: Colors.white, fontSize: 16, shadows: TeocText.softShadow),
                            ),
                            if (weather != null) ...[
                              const SizedBox(height: 4),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(weather.icon, color: Colors.white, size: 18),
                                  const SizedBox(width: 6),
                                  Text(
                                    "${weather.temperature.round()}°  ${weather.description}",
                                    style: const TextStyle(color: Colors.white, fontSize: 15, shadows: TeocText.softShadow),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _info("CARTA DEL DÍA · ${profile.name.toUpperCase()}", "${card.symbol}  ${card.name}"),
                        const SizedBox(width: 40),
                        _info("LUNA", "${moon.symbol}  ${moon.name}"),
                        if (upcoming.isNotEmpty) ...[
                          const SizedBox(width: 40),
                          _info(
                            _releaseLabel(upcoming.first.daysLeft(_now)),
                            upcoming.first.title,
                          ),
                        ],
                        const Spacer(),
                        AnimatedPixelSprite(
                          frames: _now.hour < 6 ? MonsterSprites.sleep : MonsterSprites.idle,
                          pixelSize: 4,
                          dark: Colors.black,
                          mid: profile.accent,
                          accent: Colors.white,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _releaseLabel(int days) {
    if (days <= 0) return "SALE HOY";
    if (days == 1) return "SALE MAÑANA";
    return "EN $days DÍAS";
  }

  Widget _reminders(List<Reminder> reminders, Color accent) {
    if (reminders.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "HOY",
          style: TextStyle(
            color: Colors.white,
            fontFamily: TeocText.retroFont,
            fontSize: 12,
            letterSpacing: 2,
            shadows: TeocText.softShadow,
          ),
        ),
        const SizedBox(height: 8),
        for (final reminder in reminders.take(5))
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                Container(width: 8, height: 8, decoration: BoxDecoration(color: accent, shape: BoxShape.circle)),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    reminder.text,
                    style: const TextStyle(color: Colors.white, fontSize: 15, shadows: TeocText.softShadow),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _info(String label, String value) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontFamily: TeocText.retroFont,
              fontSize: 10,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w300, shadows: TeocText.softShadow),
          ),
        ],
      );
}
