/*
 * Teoc Launcher — sprites pixel.
 * '#' = oscuro, 'o' = medio, '+' = acento, '.' = vacío.
 */

import 'dart:async';

import 'package:flutter/material.dart';

/// La mascota de Digital Monster: un monstruito con cuernos.
class MonsterSprites {
  static const List<String> idleA = [
    "..#........#..",
    "..##......##..",
    "...#oooooo#...",
    "..#oooooooo#..",
    ".#oo+#oo#+oo#.",
    ".#oo##oo##oo#.",
    ".#oooooooooo#.",
    ".#ooo#++#ooo#.",
    "..#oo####oo#..",
    "..#oooooooo#..",
    "...#oo##oo#...",
    "...##....##...",
  ];

  static const List<String> idleB = [
    "..............",
    "..#........#..",
    "..##......##..",
    "...#oooooo#...",
    "..#oooooooo#..",
    ".#oo+#oo#+oo#.",
    ".#oo##oo##oo#.",
    ".#oooooooooo#.",
    ".#ooo#++#ooo#.",
    "..#oo####oo#..",
    "..#oooooooo#..",
    "..##......##..",
  ];

  static const List<String> blink = [
    "..#........#..",
    "..##......##..",
    "...#oooooo#...",
    "..#oooooooo#..",
    ".#oooooooooo#.",
    ".#oo##oo##oo#.",
    ".#oooooooooo#.",
    ".#ooo#++#ooo#.",
    "..#oo####oo#..",
    "..#oooooooo#..",
    "...#oo##oo#...",
    "...##....##...",
  ];

  static const List<String> sleepA = [
    "..........+...",
    "........+.....",
    "..#....+...#..",
    "..##......##..",
    "...#oooooo#...",
    "..#oooooooo#..",
    ".#oo####o##o#.",
    ".#oooooooooo#.",
    ".#oooo##oooo#.",
    "..#oooooooo#..",
    "..##########..",
    "..............",
  ];

  static const List<String> sleepB = [
    "...........+..",
    ".........+....",
    "..#.....+..#..",
    "..##......##..",
    "...#oooooo#...",
    "..#oooooooo#..",
    ".#oo####o##o#.",
    ".#oooooooooo#.",
    ".#oooo##oooo#.",
    "..#oooooooo#..",
    "..##########..",
    "..............",
  ];

  static const List<String> rainA = [
    "....++++++....",
    "..++++++++++..",
    ".+++++++++++++",
    "......#.......",
    "..#...#....#..",
    "..##..#...##..",
    "..#oooooooo#..",
    ".#oo+#oo#+oo#.",
    ".#oooooooooo#.",
    ".#ooo####ooo#.",
    "..#oooooooo#..",
    "...##....##...",
  ];

  static const List<String> partyA = [
    "+............+",
    "..#...+....#..",
    "..##......##..",
    "+..#oooooo#..+",
    "..#oooooooo#..",
    ".#oo+#oo#+oo#.",
    ".#oo##oo##oo#.",
    ".#oo#++++#oo#.",
    ".#ooo####ooo#.",
    "..#oooooooo#..",
    "...#oo##oo#...",
    "..##......##..",
  ];

  static const List<String> partyB = [
    "......+.......",
    "+.#........#.+",
    "..##......##..",
    "...#oooooo#...",
    "+.#oooooooo#.+",
    ".#oo+#oo#+oo#.",
    ".#oo##oo##oo#.",
    ".#oo#++++#oo#.",
    ".#ooo####ooo#.",
    "..#oooooooo#..",
    "...#oo##oo#...",
    "...##....##...",
  ];

  static const List<List<String>> idle = [idleA, idleB, idleA, blink];
  static const List<List<String>> sleep = [sleepA, sleepB];
  static const List<List<String>> rain = [rainA, idleA];
  static const List<List<String>> party = [partyA, partyB];
}

/// Ícono chico del dispositivo Digital Monster.
const List<String> deviceIcon = [
  "..########..",
  ".#oooooooo#.",
  ".#o++++++o#.",
  ".#o+####+o#.",
  ".#o+#++#+o#.",
  ".#o+####+o#.",
  ".#o++++++o#.",
  ".#oooooooo#.",
  ".#o#o##o#o#.",
  "..########..",
];

class PixelSprite extends StatelessWidget {
  final List<String> rows;
  final double pixelSize;
  final Color dark;
  final Color mid;
  final Color? accent;

  const PixelSprite({
    super.key,
    required this.rows,
    required this.pixelSize,
    required this.dark,
    required this.mid,
    this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final int height = rows.length;
    int width = 0;
    for (final row in rows) {
      if (row.length > width) {
        width = row.length;
      }
    }
    return CustomPaint(
      size: Size(width * pixelSize, height * pixelSize),
      painter: _PixelPainter(rows, pixelSize, dark, mid, accent ?? mid),
    );
  }
}

class _PixelPainter extends CustomPainter {
  final List<String> rows;
  final double pixelSize;
  final Color dark;
  final Color mid;
  final Color accent;

  _PixelPainter(this.rows, this.pixelSize, this.dark, this.mid, this.accent);

  @override
  void paint(Canvas canvas, Size size) {
    final darkPaint = Paint()..color = dark;
    final midPaint = Paint()..color = mid;
    final accentPaint = Paint()..color = accent;

    for (int y = 0; y < rows.length; y++) {
      final row = rows[y];
      for (int x = 0; x < row.length; x++) {
        final char = row[x];
        Paint? paint;
        if (char == '#') {
          paint = darkPaint;
        }
        else if (char == 'o') {
          paint = midPaint;
        }
        else if (char == '+') {
          paint = accentPaint;
        }
        if (paint == null) {
          continue;
        }
        // +0.5 evita líneas finas entre pixeles al escalar
        final rect = Rect.fromLTWH(x * pixelSize, y * pixelSize, pixelSize + 0.5, pixelSize + 0.5);
        canvas.drawRect(rect, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PixelPainter oldDelegate) =>
      oldDelegate.rows != rows ||
      oldDelegate.pixelSize != pixelSize ||
      oldDelegate.dark != dark ||
      oldDelegate.mid != mid ||
      oldDelegate.accent != accent;
}

/// Alterna los cuadros del sprite para que "respire".
class AnimatedPixelSprite extends StatefulWidget {
  final List<List<String>> frames;
  final double pixelSize;
  final Color dark;
  final Color mid;
  final Color? accent;
  final Duration frameDuration;

  const AnimatedPixelSprite({
    super.key,
    required this.frames,
    required this.pixelSize,
    required this.dark,
    required this.mid,
    this.accent,
    this.frameDuration = const Duration(milliseconds: 550),
  });

  @override
  State<AnimatedPixelSprite> createState() => _AnimatedPixelSpriteState();
}

class _AnimatedPixelSpriteState extends State<AnimatedPixelSprite> {
  int _frame = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(widget.frameDuration, (_) {
      if (mounted) {
        setState(() => _frame = (_frame + 1) % widget.frames.length);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final frames = widget.frames;
    final rows = frames[_frame % frames.length];
    return PixelSprite(
      rows: rows,
      pixelSize: widget.pixelSize,
      dark: widget.dark,
      mid: widget.mid,
      accent: widget.accent,
    );
  }
}
