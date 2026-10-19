/*
 * Teoc Launcher — elegir las apps favoritas de cada perfil.
 */

import 'package:flauncher/providers/apps_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_tile.dart';
import 'profiles.dart';
import 'teoc_theme.dart';

class FavoritesEditor extends StatelessWidget {
  const FavoritesEditor({super.key});

  @override
  Widget build(BuildContext context) {
    final profiles = context.watch<ProfileService>();
    final apps = context.watch<AppsService>().applications
        .where((app) => !app.hidden && app.packageName != "cl.teoc.launcher")
        .toList();
    final profile = profiles.current;

    return Scaffold(
      backgroundColor: TeocColors.night,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(40, 28, 40, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Apps de ${profile.name}",
              style: const TextStyle(color: TeocColors.cream, fontSize: 28, fontWeight: FontWeight.w300),
            ),
            const SizedBox(height: 4),
            Text(
              "OK: agregar o quitar de tu inicio   ·   ATRÁS: volver",
              style: TextStyle(
                color: profile.accent,
                fontFamily: TeocText.retroFont,
                fontSize: 11,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                clipBehavior: Clip.none,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: Wrap(
                    spacing: 18,
                    runSpacing: 18,
                    children: [
                      for (int i = 0; i < apps.length; i++)
                        TeocAppTile(
                          key: ValueKey("fav-${apps[i].packageName}"),
                          app: apps[i],
                          accent: profile.accent,
                          width: 160,
                          autofocus: i == 0,
                          onPressed: () => profiles.toggleFavorite(apps[i].packageName),
                          badge: profiles.isFavorite(apps[i].packageName)
                              ? Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(color: profile.accent, shape: BoxShape.circle),
                                  child: const Icon(Icons.star, size: 14, color: TeocColors.night),
                                )
                              : null,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
