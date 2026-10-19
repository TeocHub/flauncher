/*
 * Teoc Launcher — la mascota de Digital Monster, viva en la pantalla de inicio.
 * Duerme de noche, saca paraguas si llueve y celebra la luna llena.
 * Al apretarla cuenta otra cosa.
 */

import 'package:flutter/material.dart';

import 'focus_box.dart';
import 'pixel_sprite.dart';
import 'teoc_config.dart';
import 'teoc_theme.dart';
import 'weather.dart';

class MascotPanel extends StatefulWidget {
  final Color accent;
  final WeatherNow? weather;
  final String tip;
  final int remindersCount;
  final String? nextRelease;

  const MascotPanel({
    super.key,
    required this.accent,
    required this.weather,
    required this.tip,
    required this.remindersCount,
    this.nextRelease,
  });

  @override
  State<MascotPanel> createState() => _MascotPanelState();
}

class _MascotPanelState extends State<MascotPanel> {
  int _messageIndex = 0;

  List<List<String>> _frames(DateTime now) {
    final weather = widget.weather;
    final moon = MoonPhase.of(now);
    if (now.hour >= 0 && now.hour < 6) {
      return MonsterSprites.sleep;
    }
    if (weather != null && weather.isRainy) {
      return MonsterSprites.rain;
    }
    if (moon.name == "Luna llena") {
      return MonsterSprites.party;
    }
    return MonsterSprites.idle;
  }

  List<String> _messages(DateTime now) {
    final weather = widget.weather;
    final moon = MoonPhase.of(now);
    final List<String> messages = [widget.tip];

    if (now.hour < 6) {
      messages.insert(0, "Zzz... ya es tarde, ¿un capítulo más y a dormir?");
    }
    if (weather != null) {
      if (weather.isRainy) {
        messages.add("Está lloviendo: día perfecto para mantita y juego.");
      }
      else if (weather.temperature >= 28) {
        messages.add("Hace ${weather.temperature.round()}°: ¡hidrátate!");
      }
      else if (weather.temperature <= 8) {
        messages.add("Hace ${weather.temperature.round()}°: abrígate bien.");
      }
      else {
        messages.add("Afuera: ${weather.description.toLowerCase()}, ${weather.temperature.round()}°.");
      }
    }
    messages.add("Hoy hay ${moon.name.toLowerCase()} ${moon.symbol}");
    if (widget.remindersCount > 0) {
      messages.add(widget.remindersCount == 1
          ? "Tienes 1 recordatorio para hoy."
          : "Tienes ${widget.remindersCount} recordatorios para hoy.");
    }
    final release = widget.nextRelease;
    if (release != null) {
      messages.add(release);
    }
    return messages;
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final messages = _messages(now);
    final message = messages[_messageIndex % messages.length];

    return FocusBox(
      accent: widget.accent,
      radius: 18,
      background: TeocColors.surface.withOpacity(0.72),
      focusedBackground: TeocColors.surfaceHigh.withOpacity(0.9),
      padding: const EdgeInsets.all(12),
      onPressed: () => setState(() => _messageIndex++),
      builder: (context, focused) => Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 64,
            height: 64,
            child: Center(
              child: AnimatedPixelSprite(
                key: ValueKey(_frames(now).first.join()),
                frames: _frames(now),
                pixelSize: 4.4,
                dark: TeocColors.night,
                mid: widget.accent,
                accent: TeocColors.cream,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  TeocConfig.mascotName.toUpperCase(),
                  style: TextStyle(
                    color: widget.accent,
                    fontFamily: TeocText.retroFont,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 4),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Text(
                    message,
                    key: ValueKey(message),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: TeocColors.cream, fontSize: 12, height: 1.3),
                  ),
                ),
                if (focused)
                  const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Text(
                      "OK: otra cosa",
                      style: TextStyle(
                        color: TeocColors.muted,
                        fontFamily: TeocText.retroFont,
                        fontSize: 9,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
