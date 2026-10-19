/*
 * Teoc Launcher — paleta: noche minimalista, toque místico (violeta y oro),
 * natural (musgo y crema) y retro (tipografía monoespaciada).
 */

import 'package:flutter/material.dart';

class TeocColors {
  static const Color night = Color(0xFF0E0F13);
  static const Color surface = Color(0xFF17181F);
  static const Color surfaceHigh = Color(0xFF20212B);
  static const Color violet = Color(0xFF8C6BC8);
  static const Color violetDeep = Color(0xFF2A2140);
  static const Color gold = Color(0xFFD8B46A);
  static const Color moss = Color(0xFF7FA37A);
  static const Color cream = Color(0xFFEDE6D6);
  static const Color muted = Color(0xFF9A968C);

  // Pantalla LCD del Teoc-Vice
  static const Color lcd = Color(0xFF9BAA7E);
  static const Color lcdDark = Color(0xFF2B3320);
  static const Color lcdMid = Color(0xFF5E6B48);
  static const Color shell = Color(0xFF2E3329);
  static const Color shellLight = Color(0xFF454B3E);
}

class TeocText {
  static const String retroFont = "monospace";

  static const List<Shadow> softShadow = [
    Shadow(color: Colors.black54, offset: Offset(0, 2), blurRadius: 8)
  ];
}
