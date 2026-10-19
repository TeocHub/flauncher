/*
 * Teoc Launcher — panel lateral que se desliza desde la derecha
 * para mostrar el detalle de cada tarjeta de "Hoy".
 */

import 'package:flutter/material.dart';

import 'focus_box.dart';
import 'palettes.dart';
import 'teoc_theme.dart';

Future<void> showSideSheet({
  required BuildContext context,
  required TeocPalette palette,
  required String eyebrow,
  required String title,
  required Widget Function(BuildContext context) builder,
  bool autofocusClose = true,
}) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: title,
    barrierColor: Colors.black.withOpacity(palette.light ? 0.25 : 0.55),
    transitionDuration: const Duration(milliseconds: 260),
    pageBuilder: (dialogContext, _, __) => Align(
      alignment: Alignment.centerRight,
      child: Material(
        color: palette.light ? const Color(0xFFFFFBFD) : palette.surfaceHigh,
        elevation: 24,
        child: SizedBox(
          width: 460,
          height: double.infinity,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(32, 32, 32, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  eyebrow.toUpperCase(),
                  style: TextStyle(
                    color: palette.accent,
                    fontFamily: TeocText.retroFont,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  title,
                  style: TextStyle(color: palette.text, fontSize: 26, fontWeight: FontWeight.w300),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    clipBehavior: Clip.none,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: builder(dialogContext),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                FocusBox(
                  autofocus: autofocusClose,
                  accent: palette.accent,
                  radius: 20,
                  background: palette.accentSoft,
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 9),
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  builder: (context, focused) => Text(
                    "Cerrar",
                    style: TextStyle(color: palette.text, fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
    transitionBuilder: (context, animation, _, child) => SlideTransition(
      position: Tween<Offset>(begin: const Offset(0.25, 0), end: Offset.zero)
          .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
      child: FadeTransition(opacity: animation, child: child),
    ),
  );
}
