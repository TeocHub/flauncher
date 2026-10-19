/*
 * Teoc Launcher — la mascota de Digital Monster.
 * Vive discreta junto a la hora: duerme de noche, saca paraguas si llueve
 * y celebra la luna llena. Solo habla cuando la seleccionas.
 */

import 'package:flutter/material.dart';

import 'focus_box.dart';
import 'palettes.dart';
import 'pixel_sprite.dart';
import 'teoc_config.dart';
import 'teoc_theme.dart';
import 'weather.dart';

class MascotBadge extends StatefulWidget {
  final TeocPalette palette;
  final WeatherNow? weather;
  final List<String> messages;

  const MascotBadge({
    super.key,
    required this.palette,
    required this.weather,
    required this.messages,
  });

  @override
  State<MascotBadge> createState() => _MascotBadgeState();
}

class _MascotBadgeState extends State<MascotBadge> {
  int _index = 0;

  List<List<String>> _frames(DateTime now) {
    if (now.hour < 6) return MonsterSprites.sleep;
    final weather = widget.weather;
    if (weather != null && weather.isRainy) return MonsterSprites.rain;
    if (MoonPhase.of(now).name == "Luna llena") return MonsterSprites.party;
    return MonsterSprites.idle;
  }

  @override
  Widget build(BuildContext context) {
    final palette = widget.palette;
    final now = DateTime.now();
    final frames = _frames(now);
    final messages = widget.messages.isEmpty ? ["¡Hola!"] : widget.messages;
    final message = messages[_index % messages.length];

    return FocusBox(
      accent: palette.accent,
      radius: 18,
      focusScale: 1.0,
      focusedBackground: palette.surfaceHigh,
      padding: const EdgeInsets.all(6),
      onPressed: () => setState(() => _index++),
      builder: (context, focused) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            child: focused
                ? ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 260),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8, right: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            message,
                            textAlign: TextAlign.right,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: palette.text, fontSize: 12, height: 1.3),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            "${TeocConfig.mascotName.toUpperCase()} · OK: OTRA COSA",
                            style: TextStyle(
                              color: palette.muted,
                              fontFamily: TeocText.retroFont,
                              fontSize: 8,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          AnimatedPixelSprite(
            key: ValueKey(frames.first.join()),
            frames: frames,
            pixelSize: 3,
            dark: palette.light ? palette.text : const Color(0xFF0D0E12),
            mid: palette.accent,
            accent: palette.light ? Colors.white : palette.highlight,
          ),
        ],
      ),
    );
  }
}
