/*
 * Teoc Launcher — sprites pixel para el Teoc-Vice.
 * '#' = pixel oscuro, 'o' = pixel medio, '.' = vacío.
 */

import 'dart:async';

import 'package:flutter/material.dart';

/// "Velamon": una velita digital con su llama, la mascota del Teoc-Vice.
const List<List<String>> velamonFrames = [
  [
    ".....##.....",
    "....#oo#....",
    "...#oooo#...",
    "...#oooo#...",
    "....#oo#....",
    "..########..",
    "..#......#..",
    "..#.#..#.#..",
    "..#......#..",
    "..#..##..#..",
    "..#......#..",
    "..########..",
    "...#....#...",
    "..##....##..",
  ],
  [
    "....##......",
    "...#oo#.....",
    "...#ooo#....",
    "...#oooo#...",
    "....#oo#....",
    "..########..",
    "..#......#..",
    "..#......#..",
    "..#.#..#.#..",
    "..#..##..#..",
    "..#......#..",
    "..########..",
    "..#......#..",
    ".##......##.",
  ],
];

class PixelSprite extends StatelessWidget {
  final List<String> rows;
  final double pixelSize;
  final Color dark;
  final Color mid;

  const PixelSprite({
    super.key,
    required this.rows,
    required this.pixelSize,
    required this.dark,
    required this.mid,
  });

  @override
  Widget build(BuildContext context) {
    final int height = rows.length;
    final int width = rows.isEmpty ? 0 : rows.first.length;
    return CustomPaint(
      size: Size(width * pixelSize, height * pixelSize),
      painter: _PixelPainter(rows, pixelSize, dark, mid),
    );
  }
}

class _PixelPainter extends CustomPainter {
  final List<String> rows;
  final double pixelSize;
  final Color dark;
  final Color mid;

  _PixelPainter(this.rows, this.pixelSize, this.dark, this.mid);

  @override
  void paint(Canvas canvas, Size size) {
    final darkPaint = Paint()..color = dark;
    final midPaint = Paint()..color = mid;

    for (int y = 0; y < rows.length; y++) {
      final row = rows[y];
      for (int x = 0; x < row.length; x++) {
        final char = row[x];
        if (char == '.') {
          continue;
        }
        final rect = Rect.fromLTWH(x * pixelSize, y * pixelSize, pixelSize, pixelSize);
        canvas.drawRect(rect, char == '#' ? darkPaint : midPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PixelPainter oldDelegate) =>
      oldDelegate.rows != rows || oldDelegate.pixelSize != pixelSize;
}

/// Alterna los cuadros del sprite para que "respire".
class AnimatedPixelSprite extends StatefulWidget {
  final List<List<String>> frames;
  final double pixelSize;
  final Color dark;
  final Color mid;
  final Duration frameDuration;

  const AnimatedPixelSprite({
    super.key,
    required this.frames,
    required this.pixelSize,
    required this.dark,
    required this.mid,
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
  Widget build(BuildContext context) => PixelSprite(
        rows: widget.frames[_frame],
        pixelSize: widget.pixelSize,
        dark: widget.dark,
        mid: widget.mid,
      );
}
