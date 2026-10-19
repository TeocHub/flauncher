/*
 * Teoc Launcher — Teoc-Vice: menú de proyectos al estilo de un Digivice.
 */

import 'package:flauncher/flauncher_channel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'pixel_sprite.dart';
import 'teoc_config.dart';
import 'teoc_theme.dart';

class TeocViceScreen extends StatelessWidget {
  const TeocViceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TeocColors.night,
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.2),
            radius: 1.1,
            colors: [Color(0xFF1C2219), TeocColors.night],
          ),
        ),
        alignment: Alignment.center,
        child: const _DeviceShell(),
      ),
    );
  }
}

class _DeviceShell extends StatelessWidget {
  const _DeviceShell();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 600,
      padding: const EdgeInsets.fromLTRB(26, 18, 26, 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(44),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [TeocColors.shellLight, TeocColors.shell],
        ),
        border: Border.all(color: Colors.black.withOpacity(0.5), width: 3),
        boxShadow: const [
          BoxShadow(color: Colors.black87, blurRadius: 30, offset: Offset(0, 12)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Text(
                "TEOC-VICE",
                style: TextStyle(
                  color: TeocColors.gold,
                  fontFamily: TeocText.retroFont,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  letterSpacing: 4,
                ),
              ),
              const Spacer(),
              _led(TeocColors.moss),
              const SizedBox(width: 8),
              _led(TeocColors.gold),
            ],
          ),
          const SizedBox(height: 12),
          const _LcdScreen(),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _button(),
              const SizedBox(width: 22),
              _button(big: true),
              const SizedBox(width: 22),
              _button(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _led(Color color) => Container(
        width: 9,
        height: 9,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: color.withOpacity(0.7), blurRadius: 6)],
        ),
      );

  Widget _button({bool big = false}) => Container(
        width: big ? 30 : 22,
        height: big ? 30 : 22,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: TeocColors.shell,
          border: Border.all(color: Colors.black54, width: 2),
          boxShadow: const [
            BoxShadow(color: Colors.white10, offset: Offset(-1, -1), blurRadius: 1),
          ],
        ),
      );
}

class _LcdScreen extends StatelessWidget {
  const _LcdScreen();

  @override
  Widget build(BuildContext context) {
    final projects = TeocConfig.projects;

    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: TeocColors.lcd,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withOpacity(0.6), width: 4),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          children: [
            const Positioned.fill(
              child: RepaintBoundary(child: CustomPaint(painter: _LcdGridPainter())),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 150,
                    child: Column(
                      children: [
                        const SizedBox(height: 18),
                        const AnimatedPixelSprite(
                          frames: velamonFrames,
                          pixelSize: 7,
                          dark: TeocColors.lcdDark,
                          mid: TeocColors.lcdMid,
                        ),
                        const SizedBox(height: 14),
                        _lcdText("VELAMON", size: 14, bold: true),
                        const SizedBox(height: 2),
                        _lcdText("LV.${projects.length}  HP ████", size: 10),
                      ],
                    ),
                  ),
                  Container(width: 2, color: TeocColors.lcdDark.withOpacity(0.5)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _lcdText("» PROYECTOS", size: 13, bold: true),
                        const SizedBox(height: 8),
                        Expanded(
                          child: projects.isEmpty
                              ? _lcdText("Sin proyectos aún.\nAgrégalos en teoc_config.dart", size: 11)
                              : ListView.builder(
                                  itemCount: projects.length,
                                  itemBuilder: (context, index) => _ProjectEntry(
                                    project: projects[index],
                                    autofocus: index == 0,
                                  ),
                                ),
                        ),
                        _lcdText("OK:ABRIR   ATRÁS:SALIR", size: 10),
                      ],
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

Widget _lcdText(String text, {double size = 12, bool bold = false, Color color = TeocColors.lcdDark}) => Text(
      text,
      style: TextStyle(
        color: color,
        fontFamily: TeocText.retroFont,
        fontSize: size,
        fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        letterSpacing: 1,
        height: 1.3,
      ),
    );

class _ProjectEntry extends StatefulWidget {
  final TeocProject project;
  final bool autofocus;

  const _ProjectEntry({required this.project, required this.autofocus});

  @override
  State<_ProjectEntry> createState() => _ProjectEntryState();
}

class _ProjectEntryState extends State<_ProjectEntry> {
  bool _focused = false;

  Future<void> _open(BuildContext context) async {
    final channel = context.read<FLauncherChannel>();
    final messenger = ScaffoldMessenger.of(context);
    bool opened = false;
    try {
      opened = await channel.openWebPage(widget.project.url);
    }
    catch (_) {
      opened = false;
    }
    if (!opened) {
      messenger.showSnackBar(
        const SnackBar(content: Text("No se pudo abrir el proyecto")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: InkWell(
        autofocus: widget.autofocus,
        focusColor: Colors.transparent,
        highlightColor: Colors.transparent,
        splashColor: TeocColors.lcdMid.withOpacity(0.3),
        onTap: () => _open(context),
        onFocusChange: (focused) {
          setState(() => _focused = focused);
          if (focused) {
            Scrollable.ensureVisible(context, alignment: 0.5, duration: const Duration(milliseconds: 100));
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          color: _focused ? TeocColors.lcdDark : Colors.transparent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _lcdText(
                "${_focused ? "▶" : " "} ${widget.project.name.toUpperCase()}",
                size: 13,
                bold: true,
                color: _focused ? TeocColors.lcd : TeocColors.lcdDark,
              ),
              _lcdText(
                "  ${widget.project.description}",
                size: 10,
                color: _focused ? TeocColors.lcd : TeocColors.lcdMid,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LcdGridPainter extends CustomPainter {
  const _LcdGridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = TeocColors.lcdDark.withOpacity(0.06)
      ..strokeWidth = 1;
    const step = 4.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
