/*
 * Teoc Launcher — carta de tarot del día.
 */

import 'package:flutter/material.dart';

import 'daily.dart';
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
