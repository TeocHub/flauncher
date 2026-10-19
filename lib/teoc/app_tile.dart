/*
 * Teoc Launcher — tarjeta grande de app.
 */

import 'dart:typed_data';

import 'package:flauncher/models/app.dart';
import 'package:flauncher/providers/apps_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'focus_box.dart';
import 'palettes.dart';

class _AppImage {
  final bool isBanner;
  final Uint8List bytes;

  const _AppImage(this.isBanner, this.bytes);
}

final Map<String, Future<_AppImage>> _imageCache = {};

Future<_AppImage> _loadImage(AppsService service, String packageName) {
  return _imageCache.putIfAbsent(packageName, () async {
    Uint8List bytes = await service.getAppBanner(packageName);
    if (bytes.isNotEmpty) {
      return _AppImage(true, bytes);
    }
    bytes = await service.getAppIcon(packageName);
    return _AppImage(false, bytes);
  });
}

class TeocAppTile extends StatelessWidget {
  final App app;
  final TeocPalette palette;
  final double width;
  final bool autofocus;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final Widget? badge;

  const TeocAppTile({
    super.key,
    required this.app,
    required this.palette,
    this.width = 176,
    this.autofocus = false,
    this.onPressed,
    this.onLongPress,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final service = context.read<AppsService>();

    return FocusBox(
      autofocus: autofocus,
      accent: palette.accent,
      radius: 14,
      focusScale: 1.08,
      background: palette.surface,
      borderColor: palette.border,
      onPressed: onPressed ?? () => service.launchApp(app),
      onLongPress: onLongPress,
      builder: (context, focused) => SizedBox(
        width: width,
        height: width * 9 / 16,
        child: Stack(
          fit: StackFit.expand,
          children: [
            FutureBuilder<_AppImage>(
              future: _loadImage(service, app.packageName),
              builder: (context, snapshot) {
                final data = snapshot.data;
                if (data == null || data.bytes.isEmpty) {
                  return _nameOnly();
                }
                if (data.isBanner) {
                  return Image.memory(data.bytes, fit: BoxFit.cover, gaplessPlayback: true);
                }
                return Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      Expanded(flex: 2, child: Image.memory(data.bytes, gaplessPlayback: true)),
                      const SizedBox(width: 8),
                      Expanded(flex: 3, child: _label()),
                    ],
                  ),
                );
              },
            ),
            if (badge != null) Positioned(top: 6, right: 6, child: badge!),
          ],
        ),
      ),
    );
  }

  Widget _label() => Text(
        app.name,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: palette.text, fontSize: 12),
      );

  Widget _nameOnly() => Center(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: _label(),
        ),
      );
}
