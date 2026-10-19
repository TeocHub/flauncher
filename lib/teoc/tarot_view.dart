/*
 * Teoc Launcher — carta de tarot del día.
 */

import 'package:flutter/material.dart';

import 'daily.dart';
import 'focus_box.dart';
import 'teoc_theme.dart';

class TarotCardFace extends StatelessWidget {
  final TarotCard card;
  final Color accent;
  final double width;

  const TarotCardFace({super.key, required this.card, required this.accent, this.width = 74});

  @override
  Widget build(BuildContext context) {
    final height = width * 1.62;
    return Container(
      width: width,
      height: height,
      padding: EdgeInsets.all(width * 0.07),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(width * 0.1),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF2E2347), Color(0xFF15121F)],
        ),
        border: Border.all(color: TeocColors.gold.withOpacity(0.85), width: 1.5),
        boxShadow: [BoxShadow(color: accent.withOpacity(0.25), blurRadius: 14)],
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(width * 0.06),
          border: Border.all(color: TeocColors.gold.withOpacity(0.35), width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: EdgeInsets.only(top: width * 0.05),
              child: Text(
                card.numeral,
                style: TextStyle(
                  color: TeocColors.gold,
                  fontFamily: "serif",
                  fontSize: width * 0.14,
                  letterSpacing: 1,
                ),
              ),
            ),
            Text(
              card.symbol,
              style: TextStyle(color: TeocColors.cream, fontSize: width * 0.42, height: 1),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: width * 0.05, left: 2, right: 2),
              child: Text(
                card.name.toUpperCase(),
                textAlign: TextAlign.center,
                maxLines: 2,
                style: TextStyle(
                  color: TeocColors.gold,
                  fontFamily: "serif",
                  fontSize: width * 0.085,
                  letterSpacing: 0.5,
                  height: 1.1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TarotPanel extends StatelessWidget {
  final TarotCard card;
  final Color accent;
  final String ownerName;

  const TarotPanel({super.key, required this.card, required this.accent, required this.ownerName});

  @override
  Widget build(BuildContext context) {
    return FocusBox(
      accent: accent,
      radius: 18,
      background: TeocColors.surface.withOpacity(0.72),
      focusedBackground: TeocColors.surfaceHigh.withOpacity(0.9),
      padding: const EdgeInsets.all(12),
      onPressed: () => _showDetail(context),
      builder: (context, focused) => Row(
        children: [
          TarotCardFace(card: card, accent: accent),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "CARTA DEL DÍA",
                  style: TextStyle(
                    color: accent,
                    fontFamily: TeocText.retroFont,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  card.name,
                  style: const TextStyle(color: TeocColors.cream, fontSize: 17, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  card.meaning,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: TeocColors.muted, fontSize: 12, height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDetail(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: TeocColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: accent.withOpacity(0.6)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TarotCardFace(card: card, accent: accent, width: 130),
              const SizedBox(width: 28),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 320),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "La carta de $ownerName para hoy",
                      style: TextStyle(color: accent, fontFamily: TeocText.retroFont, fontSize: 11, letterSpacing: 1),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "${card.numeral} · ${card.name}",
                      style: const TextStyle(color: TeocColors.cream, fontSize: 26, fontWeight: FontWeight.w300),
                    ),
                    const SizedBox(height: 14),
                    Text(card.meaning, style: const TextStyle(color: TeocColors.cream, fontSize: 15, height: 1.4)),
                    const SizedBox(height: 12),
                    Text(
                      "✦ ${card.advice}",
                      style: const TextStyle(color: TeocColors.gold, fontSize: 15, height: 1.4),
                    ),
                    const SizedBox(height: 22),
                    TextButton(
                      autofocus: true,
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      child: const Text("Cerrar"),
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
}
