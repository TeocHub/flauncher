/*
 * Teoc Launcher — tarjeta de acceso (PS4, Digital Monster, Ajustes…)
 * y tarjeta resumen de la fila "Hoy".
 */

import 'package:flutter/material.dart';

import 'focus_box.dart';
import 'palettes.dart';
import 'teoc_theme.dart';

class TeocPortalCard extends StatelessWidget {
  final TeocPalette palette;
  final Widget leading;
  final String title;
  final String caption;
  final VoidCallback onPressed;
  final double width;
  final double height;
  final bool autofocus;

  const TeocPortalCard({
    super.key,
    required this.palette,
    required this.leading,
    required this.title,
    required this.caption,
    required this.onPressed,
    this.width = 200,
    this.height = 76,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return FocusBox(
      autofocus: autofocus,
      accent: palette.accent,
      radius: 16,
      background: palette.surface,
      focusedBackground: palette.surfaceHigh,
      borderColor: palette.border,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      onPressed: onPressed,
      builder: (context, focused) => SizedBox(
        width: width - 28,
        height: height - 20,
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: palette.accentSoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: leading,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: palette.text, fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: focused ? palette.accent : palette.muted,
                      fontFamily: TeocText.retroFont,
                      fontSize: 10,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
