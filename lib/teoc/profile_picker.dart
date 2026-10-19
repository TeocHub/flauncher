/*
 * Teoc Launcher — "¿Quién está viendo?" y personalización de perfiles.
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'focus_box.dart';
import 'palettes.dart';
import 'pixel_sprite.dart';
import 'profiles.dart';
import 'teoc_config.dart';
import 'teoc_theme.dart';

class ProfileAvatar extends StatelessWidget {
  final TeocAvatar avatar;
  final TeocPalette palette;
  final double pixelSize;

  const ProfileAvatar({super.key, required this.avatar, required this.palette, required this.pixelSize});

  @override
  Widget build(BuildContext context) => PixelSprite(
        rows: avatar.rows,
        pixelSize: pixelSize,
        dark: palette.light ? palette.text : const Color(0xFF0D0E12),
        mid: palette.accent,
        accent: palette.light ? palette.text.withOpacity(0.55) : palette.highlight,
      );
}

class ProfilePicker extends StatelessWidget {
  const ProfilePicker({super.key});

  @override
  Widget build(BuildContext context) {
    final service = context.watch<ProfileService>();
    final lastId = service.current.id;

    return Scaffold(
      backgroundColor: TeocColors.night,
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.3),
            radius: 1.2,
            colors: [Color(0xFF1C1A26), TeocColors.night],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                TeocConfig.companyName.toUpperCase(),
                style: const TextStyle(
                  color: TeocColors.muted,
                  fontFamily: TeocText.retroFont,
                  fontSize: 11,
                  letterSpacing: 5,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "¿Quién está viendo?",
                style: TextStyle(color: TeocColors.cream, fontSize: 34, fontWeight: FontWeight.w300),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final profile in service.profiles)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      child: Column(
                        children: [
                          _ProfileCard(
                            profile: profile,
                            palette: service.paletteOf(profile),
                            avatar: service.avatarOf(profile),
                            autofocus: profile.id == lastId,
                            onPressed: () => service.select(profile),
                          ),
                          const SizedBox(height: 14),
                          FocusBox(
                            accent: service.paletteOf(profile).accent,
                            radius: 20,
                            focusScale: 1.05,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => ProfileEditor(profile: profile)),
                            ),
                            builder: (context, focused) => Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.edit_outlined, size: 14, color: focused ? TeocColors.cream : TeocColors.muted),
                                const SizedBox(width: 6),
                                Text(
                                  "Personalizar",
                                  style: TextStyle(color: focused ? TeocColors.cream : TeocColors.muted, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ],
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
  final TeocPalette palette;
  final TeocAvatar avatar;
  final bool autofocus;
  final VoidCallback onPressed;

  const _ProfileCard({
    required this.profile,
    required this.palette,
    required this.avatar,
    required this.autofocus,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FocusBox(
      autofocus: autofocus,
      accent: palette.accent,
      radius: 26,
      focusScale: 1.1,
      onPressed: onPressed,
      builder: (context, focused) => Container(
        width: 170,
        height: 196,
        decoration: BoxDecoration(gradient: palette.gradient),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ProfileAvatar(avatar: avatar, palette: palette, pixelSize: 8),
            const SizedBox(height: 18),
            Text(
              profile.name,
              style: TextStyle(color: palette.text, fontSize: 20, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

/// Elegir ícono y colores de un perfil, con vista previa en vivo.
class ProfileEditor extends StatelessWidget {
  final TeocProfile profile;

  const ProfileEditor({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final service = context.watch<ProfileService>();
    final palette = service.paletteOf(profile);
    final avatar = service.avatarOf(profile);

    return Scaffold(
      backgroundColor: palette.background.last,
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        decoration: BoxDecoration(gradient: palette.gradient),
        padding: const EdgeInsets.fromLTRB(48, 36, 48, 24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 220,
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  Container(
                    width: 180,
                    height: 180,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: palette.surface,
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: palette.accent.withOpacity(0.5), width: 2),
                    ),
                    child: ProfileAvatar(avatar: avatar, palette: palette, pixelSize: 9),
                  ),
                  const SizedBox(height: 16),
                  Text(profile.name, style: TextStyle(color: palette.text, fontSize: 26, fontWeight: FontWeight.w300)),
                  const SizedBox(height: 4),
                  Text(
                    "${avatar.name} · ${palette.name}".toUpperCase(),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: palette.muted, fontFamily: TeocText.retroFont, fontSize: 10, letterSpacing: 1),
                  ),
                  const SizedBox(height: 24),
                  FocusBox(
                    accent: palette.accent,
                    radius: 20,
                    background: palette.accent,
                    padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 10),
                    onPressed: () => Navigator.of(context).maybePop(),
                    builder: (context, focused) => Text(
                      "Listo",
                      style: TextStyle(
                        color: palette.light ? Colors.white : const Color(0xFF0D0E12),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 40),
            Expanded(
              child: SingleChildScrollView(
                clipBehavior: Clip.none,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _title("Ícono", palette),
                    Wrap(
                      spacing: 14,
                      runSpacing: 14,
                      children: [
                        for (int i = 0; i < TeocAvatar.all.length; i++)
                          FocusBox(
                            autofocus: TeocAvatar.all[i].id == avatar.id,
                            accent: palette.accent,
                            radius: 18,
                            background: TeocAvatar.all[i].id == avatar.id ? palette.accentSoft : palette.surface,
                            borderColor: palette.border,
                            focusScale: 1.08,
                            onPressed: () => service.setAvatar(profile, TeocAvatar.all[i]),
                            builder: (context, focused) => SizedBox(
                              width: 84,
                              height: 84,
                              child: Center(
                                child: ProfileAvatar(avatar: TeocAvatar.all[i], palette: palette, pixelSize: 5),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    _title("Colores", palette),
                    Wrap(
                      spacing: 14,
                      runSpacing: 14,
                      children: [
                        for (final option in TeocPalette.all)
                          FocusBox(
                            accent: palette.accent,
                            radius: 18,
                            background: option.id == palette.id ? palette.accentSoft : palette.surface,
                            borderColor: palette.border,
                            focusScale: 1.06,
                            padding: const EdgeInsets.all(10),
                            onPressed: () => service.setPalette(profile, option),
                            builder: (context, focused) => SizedBox(
                              width: 150,
                              child: Row(
                                children: [
                                  Container(
                                    width: 34,
                                    height: 34,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(colors: [option.background.first, option.accent]),
                                      border: Border.all(color: palette.border),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      option.name,
                                      style: TextStyle(color: palette.text, fontSize: 13),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _title(String text, TeocPalette palette) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(
          text.toUpperCase(),
          style: TextStyle(
            color: palette.text,
            fontFamily: TeocText.retroFont,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      );
}
