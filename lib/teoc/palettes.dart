/*
 * Teoc Launcher — paletas de color por perfil (oscuras y pastel)
 * y avatares pixel para elegir.
 */

import 'package:flutter/material.dart';

class TeocPalette {
  final String id;
  final String name;
  final bool light;
  final List<Color> background;
  final Color surface;
  final Color surfaceHigh;
  final Color text;
  final Color muted;
  final Color accent;
  final Color accentSoft;
  final Color border;
  final Color highlight;

  const TeocPalette({
    required this.id,
    required this.name,
    required this.light,
    required this.background,
    required this.surface,
    required this.surfaceHigh,
    required this.text,
    required this.muted,
    required this.accent,
    required this.accentSoft,
    required this.border,
    required this.highlight,
  });

  List<Shadow> get textShadow => light
      ? const []
      : const [Shadow(color: Colors.black54, offset: Offset(0, 2), blurRadius: 8)];

  Gradient get gradient => RadialGradient(
        center: const Alignment(-0.9, -1.1),
        radius: 1.7,
        colors: background,
        stops: const [0, 0.5, 1],
      );

  static TeocPalette byId(String? id) =>
      all.firstWhere((palette) => palette.id == id, orElse: () => all.first);

  static const List<TeocPalette> all = [
    TeocPalette(
      id: "noche",
      name: "Noche violeta",
      light: false,
      background: [Color(0xFF2E2347), Color(0xFF121319), Color(0xFF0D0E12)],
      surface: Color(0xFF17181F),
      surfaceHigh: Color(0xFF23242E),
      text: Color(0xFFEDE6D6),
      muted: Color(0xFF9A968C),
      accent: Color(0xFFB48CF2),
      accentSoft: Color(0xFF3A2A5E),
      border: Color(0x14FFFFFF),
      highlight: Color(0xFFEDE6D6),
    ),
    TeocPalette(
      id: "bosque",
      name: "Bosque",
      light: false,
      background: [Color(0xFF26331F), Color(0xFF13171A), Color(0xFF0B0C10)],
      surface: Color(0xFF161A18),
      surfaceHigh: Color(0xFF212823),
      text: Color(0xFFE8EBDD),
      muted: Color(0xFF97A08F),
      accent: Color(0xFF9CCB8A),
      accentSoft: Color(0xFF2B3D26),
      border: Color(0x14FFFFFF),
      highlight: Color(0xFFE8EBDD),
    ),
    TeocPalette(
      id: "oceano",
      name: "Océano",
      light: false,
      background: [Color(0xFF173B47), Color(0xFF101619), Color(0xFF0B0D10)],
      surface: Color(0xFF141B1F),
      surfaceHigh: Color(0xFF1D2A31),
      text: Color(0xFFE3EEF2),
      muted: Color(0xFF8FA3AB),
      accent: Color(0xFF6FD3E8),
      accentSoft: Color(0xFF173B47),
      border: Color(0x14FFFFFF),
      highlight: Color(0xFFE3EEF2),
    ),
    TeocPalette(
      id: "brasa",
      name: "Brasa",
      light: false,
      background: [Color(0xFF45241A), Color(0xFF16120F), Color(0xFF0D0B0A)],
      surface: Color(0xFF1B1613),
      surfaceHigh: Color(0xFF29201B),
      text: Color(0xFFF2E6DA),
      muted: Color(0xFFA6968A),
      accent: Color(0xFFF0A36B),
      accentSoft: Color(0xFF4A2A1C),
      border: Color(0x14FFFFFF),
      highlight: Color(0xFFF2E6DA),
    ),
    TeocPalette(
      id: "algodon",
      name: "Algodón pastel",
      light: true,
      background: [Color(0xFFFDE0EC), Color(0xFFEDE4FB), Color(0xFFDDF4EC)],
      surface: Color(0xCCFFFFFF),
      surfaceHigh: Color(0xFFFFFFFF),
      text: Color(0xFF3D3550),
      muted: Color(0xFF8C84A0),
      accent: Color(0xFFE48DB7),
      accentSoft: Color(0xFFF8D3E4),
      border: Color(0x1F3D3550),
      highlight: Color(0xFFFFFFFF),
    ),
    TeocPalette(
      id: "menta",
      name: "Menta pastel",
      light: true,
      background: [Color(0xFFD8F3EA), Color(0xFFE3EDFB), Color(0xFFF5F0FA)],
      surface: Color(0xCCFFFFFF),
      surfaceHigh: Color(0xFFFFFFFF),
      text: Color(0xFF2F3E46),
      muted: Color(0xFF7D8E92),
      accent: Color(0xFF4FB898),
      accentSoft: Color(0xFFCBEEDF),
      border: Color(0x1F2F3E46),
      highlight: Color(0xFFFFFFFF),
    ),
    TeocPalette(
      id: "lavanda",
      name: "Lavanda pastel",
      light: true,
      background: [Color(0xFFE9E0FB), Color(0xFFFBE8F1), Color(0xFFFFF4E0)],
      surface: Color(0xCCFFFFFF),
      surfaceHigh: Color(0xFFFFFFFF),
      text: Color(0xFF3A3352),
      muted: Color(0xFF8A82A3),
      accent: Color(0xFF9A7FD6),
      accentSoft: Color(0xFFE2D8F7),
      border: Color(0x1F3A3352),
      highlight: Color(0xFFFFFFFF),
    ),
    TeocPalette(
      id: "durazno",
      name: "Durazno pastel",
      light: true,
      background: [Color(0xFFFFE6D5), Color(0xFFFDE2EE), Color(0xFFE6EEFF)],
      surface: Color(0xCCFFFFFF),
      surfaceHigh: Color(0xFFFFFFFF),
      text: Color(0xFF45352F),
      muted: Color(0xFF9A8880),
      accent: Color(0xFFEE9A73),
      accentSoft: Color(0xFFFBDCCB),
      border: Color(0x1F45352F),
      highlight: Color(0xFFFFFFFF),
    ),
  ];
}

class TeocAvatar {
  final String id;
  final String name;
  final List<String> rows;

  const TeocAvatar(this.id, this.name, this.rows);

  static TeocAvatar byId(String? id) =>
      all.firstWhere((avatar) => avatar.id == id, orElse: () => all.first);

  static const List<TeocAvatar> all = [
    TeocAvatar("orbe", "Orbe", [
      "....++++....",
      "..++....++..",
      ".+...oo...+.",
      ".+..oooo..+.",
      "+..oooooo..+",
      "+..o#oo#o..+",
      "+..oooooo..+",
      "+...o##o...+",
      ".+..oooo..+.",
      ".+...oo...+.",
      "..++....++..",
      "....++++....",
    ]),
    TeocAvatar("monstruo", "Monstruo", [
      "....+..+....",
      "...++..++...",
      "..+oooooo+..",
      ".+oooooooo+.",
      ".+o##oo##o+.",
      ".+o#+oo#+o+.",
      ".+oooooooo+.",
      "..+oo##oo+..",
      "...+oooo+...",
      "..+o+..+o+..",
      ".+o+....+o+.",
      ".++......++.",
    ]),
    TeocAvatar("gato", "Gato", [
      ".#........#.",
      ".##......##.",
      ".#o#....#o#.",
      ".#oo####oo#.",
      ".#oooooooo#.",
      "#oo+#oo#+oo#",
      "#oo##oo##oo#",
      "#oooo##oooo#",
      ".#oo#oo#oo#.",
      ".#oooooooo#.",
      "..#oooooo#..",
      "...######...",
    ]),
    TeocAvatar("fantasma", "Fantasma", [
      "....####....",
      "..##oooo##..",
      ".#oooooooo#.",
      ".#oo#oo#oo#.",
      "#ooo#oo#ooo#",
      "#oooooooooo#",
      "#oooo##oooo#",
      "#oooooooooo#",
      "#oooooooooo#",
      "#oooooooooo#",
      "#o#oo##oo#o#",
      ".#.##..##.#.",
    ]),
    TeocAvatar("hongo", "Hongo", [
      "....####....",
      "..##o++o##..",
      ".#oooooooo#.",
      "#o++oooo++o#",
      "#o++oooo++o#",
      "#oooooooooo#",
      ".##########.",
      "...#++++#...",
      "...#+##+#...",
      "...#++++#...",
      "...#++++#...",
      "....####....",
    ]),
    TeocAvatar("estrella", "Estrella", [
      ".....##.....",
      "....#oo#....",
      "....#oo#....",
      "#####oo#####",
      "#oooooooooo#",
      ".#oo#oo#oo#.",
      "..#oooooo#..",
      "..#oo##oo#..",
      ".#oo#..#oo#.",
      ".#o#....#o#.",
      "#o#......#o#",
      "##........##",
    ]),
    TeocAvatar("corazon", "Corazón", [
      "............",
      ".###....###.",
      "#ooo#..#ooo#",
      "#o+oo##oooo#",
      "#o+oooooooo#",
      "#oooooooooo#",
      ".#oooooooo#.",
      "..#oooooo#..",
      "...#oooo#...",
      "....#oo#....",
      ".....##.....",
      "............",
    ]),
    TeocAvatar("slime", "Slime", [
      "............",
      "............",
      ".....##.....",
      "....#oo#....",
      "...#oooo#...",
      "..#o+oooo#..",
      ".#oo#oo#oo#.",
      ".#oooooooo#.",
      "#oooo##oooo#",
      "#oooooooooo#",
      ".##########.",
      "............",
    ]),
  ];
}
