/*
 * Teoc Launcher — "¿Quién está viendo?"
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'focus_box.dart';
import 'pixel_sprite.dart';
import 'profiles.dart';
import 'teoc_config.dart';
import 'teoc_theme.dart';
import 'weather.dart';

class ProfilePicker extends StatelessWidget {
  const ProfilePicker({super.key});

  @override
  Widget build(BuildContext context) {
    final service = context.watch<ProfileService>();
    final profiles = service.profiles;
    final lastId = service.current.id;
    final moon = MoonPhase.of(DateTime.now());

    return Scaffold(
      backgroundColor: TeocColors.night,
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.3),
            radius: 1.2,
            colors: [Color(0xFF1E1830), TeocColors.night],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "${moon.symbol}  ${TeocConfig.companyName.toUpperCase()}",
                style: const TextStyle(
                  color: TeocColors.gold,
                  fontFamily: TeocText.retroFont,
                  fontSize: 12,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "¿Quién está viendo?",
                style: TextStyle(
                  color: TeocColors.cream,
                  fontSize: 34,
                  fontWeight: FontWeight.w300,
                ),
              ),
              const SizedBox(height: 36),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final profile in profiles)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _ProfileCard(
                        profile: profile,
                        autofocus: profile.id == lastId,
                        onPressed: () => service.select(profile),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final TeocProfile profile;
  final bool autofocus;
  final VoidCallback onPressed;

  const _ProfileCard({required this.profile, required this.autofocus, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FocusBox(
      autofocus: autofocus,
      accent: profile.accent,
      radius: 24,
      focusScale: 1.1,
      background: TeocColors.surface.withOpacity(0.7),
      focusedBackground: profile.accentSoft,
      onPressed: onPressed,
      builder: (context, focused) => SizedBox(
        width: 170,
        height: 200,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ProfileAvatar(profile: profile, pixelSize: 8),
            const SizedBox(height: 18),
            Text(
              profile.name,
              style: TextStyle(
                color: focused ? TeocColors.cream : TeocColors.muted,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileAvatar extends StatelessWidget {
  final TeocProfile profile;
  final double pixelSize;

  const ProfileAvatar({super.key, required this.profile, required this.pixelSize});

  @override
  Widget build(BuildContext context) => PixelSprite(
        rows: profile.avatar,
        pixelSize: pixelSize,
        dark: TeocColors.night,
        mid: profile.accent,
        accent: TeocColors.cream,
      );
}
