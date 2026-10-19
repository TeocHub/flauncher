/*
 * Teoc Launcher — pantalla de inicio.
 *
 *  ┌ avatar · saludo · fecha ───────────────── clima · hora ┐
 *  │ Tus apps                         │ Carta del día        │
 *  │ Accesos (PS4, Digital Monster…)  │ Luna y astrología    │
 *  │ Titulares para ti                │ Mascota              │
 *  │ Calendario gamer · Recordatorios │                      │
 *  └──────────────────────────────────┴──────────────────────┘
 */

import 'dart:async';

import 'package:flauncher/flauncher.dart';
import 'package:flauncher/flauncher_channel.dart';
import 'package:flauncher/models/app.dart';
import 'package:flauncher/providers/apps_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'app_tile.dart';
import 'daily.dart';
import 'digital_monster_device.dart';
import 'favorites_editor.dart';
import 'focus_box.dart';
import 'mascot.dart';
import 'news.dart';
import 'pixel_sprite.dart';
import 'portal_card.dart';
import 'profile_picker.dart';
import 'profiles.dart';
import 'remote_content.dart';
import 'tarot_view.dart';
import 'teoc_config.dart';
import 'teoc_theme.dart';
import 'weather.dart';

class TeocHome extends StatefulWidget {
  const TeocHome({super.key});

  @override
  State<TeocHome> createState() => _TeocHomeState();
}

class _TeocHomeState extends State<TeocHome> {
  late FLauncherChannel _channel;
  DateTime _now = DateTime.now();
  WeatherNow? _weather;
  List<NewsItem> _news = [];
  bool _newsLoading = true;
  String? _newsProfileId;
  List<Map<String, dynamic>> _inputs = [];
  Timer? _clockTimer;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _channel = context.read<FLauncherChannel>();

    _clockTimer = Timer.periodic(const Duration(seconds: 20), (_) {
      if (mounted) {
        setState(() => _now = DateTime.now());
      }
    });
    _refreshTimer = Timer.periodic(const Duration(minutes: 30), (_) {
      _loadWeather();
      _loadNews(force: true);
    });

    _loadWeather();
    _loadInputs();
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadWeather() async {
    final weather = await fetchWeather();
    if (mounted && weather != null) {
      setState(() => _weather = weather);
    }
  }

  Future<void> _loadInputs() async {
    try {
      final inputs = await _channel.getTvInputs();
      inputs.sort((a, b) => (_isPlayStation(b) ? 1 : 0) - (_isPlayStation(a) ? 1 : 0));
      if (mounted) {
        setState(() => _inputs = inputs.take(3).toList());
      }
    }
    catch (_) {}
  }

  Future<void> _loadNews({bool force = false}) async {
    final profile = context.read<ProfileService>().current;
    if (!force && _newsProfileId == profile.id) {
      return;
    }
    _newsProfileId = profile.id;
    setState(() => _newsLoading = true);
    final news = await fetchNewsForTopics(profile.newsTopics, perTopic: 2);
    if (mounted && _newsProfileId == profile.id) {
      setState(() {
        _news = news.take(8).toList();
        _newsLoading = false;
      });
    }
  }

  static bool _isPlayStation(Map<String, dynamic> input) {
    final label = (input["label"] ?? "").toString().toLowerCase();
    return label.contains("ps4") || label.contains("playstation") || label.contains("ps5");
  }

  String _greeting() {
    final hour = _now.hour;
    if (hour < 6) return "Buenas noches";
    if (hour < 12) return "Buenos días";
    if (hour < 20) return "Buenas tardes";
    return "Buenas noches";
  }

  @override
  Widget build(BuildContext context) {
    final profiles = context.watch<ProfileService>();
    final profile = profiles.current;
    final content = context.watch<RemoteContentService>();
    final appsService = context.watch<AppsService>();

    if (_newsProfileId != profile.id) {
      // Cambió el perfil: cargar sus noticias
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _loadNews();
        }
      });
    }

    final favorites = _favoriteApps(appsService, profiles);
    final reminders = content.remindersFor(profile.id);
    final upcoming = content.upcoming();

    return Scaffold(
      backgroundColor: TeocColors.night,
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(-0.9, -1.1),
            radius: 1.6,
            colors: [profile.accentSoft, const Color(0xFF111218), TeocColors.night],
            stops: const [0, 0.5, 1],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 18, 28, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _topBar(profiles, profile),
              const SizedBox(height: 14),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        clipBehavior: Clip.none,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 48, top: 6),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _sectionTitle("Apps de ${profile.name}", profile.accent),
                              _appsRow(favorites, profile),
                              const SizedBox(height: 20),
                              _sectionTitle("Accesos", profile.accent),
                              _portalsRow(profile),
                              const SizedBox(height: 20),
                              _sectionTitle("Titulares para ti", profile.accent),
                              _newsList(profile),
                              const SizedBox(height: 20),
                              _sectionTitle("Calendario gamer", profile.accent),
                              _calendarRow(upcoming, profile),
                              const SizedBox(height: 20),
                              _sectionTitle("Recordatorios de hoy", profile.accent),
                              _remindersList(reminders, profile),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 22),
                    SizedBox(
                      width: 290,
                      child: _sidePanel(profile, reminders.length, upcoming),
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

  List<App> _favoriteApps(AppsService appsService, ProfileService profiles) {
    final byPackage = {for (final app in appsService.applications) app.packageName: app};
    return profiles.currentFavorites
        .map((packageName) => byPackage[packageName])
        .whereType<App>()
        .toList();
  }

  // ---------- Barra superior ----------

  Widget _topBar(ProfileService profiles, TeocProfile profile) {
    String date;
    try {
      date = DateFormat("EEEE d 'de' MMMM", "es").format(_now);
    }
    catch (_) {
      date = DateFormat("EEEE d MMMM").format(_now);
    }
    if (date.isNotEmpty) {
      date = date[0].toUpperCase() + date.substring(1);
    }
    final moon = MoonPhase.of(_now);
    final weather = _weather;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        FocusBox(
          accent: profile.accent,
          radius: 40,
          background: profile.accentSoft.withOpacity(0.6),
          padding: const EdgeInsets.all(8),
          onPressed: profiles.requestPicker,
          builder: (context, focused) => ProfileAvatar(profile: profile, pixelSize: 3.4),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${_greeting()}, ${profile.name}",
                style: const TextStyle(
                  color: TeocColors.cream,
                  fontSize: 28,
                  fontWeight: FontWeight.w300,
                  shadows: TeocText.softShadow,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                "$date   ·   ${moon.symbol} ${moon.name}",
                style: TextStyle(
                  color: profile.accent,
                  fontFamily: TeocText.retroFont,
                  fontSize: 11,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
        if (weather != null) ...[
          Icon(weather.icon, color: TeocColors.cream, size: 26),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "${weather.temperature.round()}°",
                style: const TextStyle(color: TeocColors.cream, fontSize: 22, fontWeight: FontWeight.w300),
              ),
              Text(
                weather.description.toUpperCase(),
                style: const TextStyle(
                  color: TeocColors.muted,
                  fontFamily: TeocText.retroFont,
                  fontSize: 9,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(width: 22),
        ],
        Text(
          DateFormat("HH:mm").format(_now),
          style: const TextStyle(
            color: TeocColors.cream,
            fontSize: 34,
            fontWeight: FontWeight.w200,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String text, Color accent) => Padding(
        padding: const EdgeInsets.only(bottom: 10, left: 2),
        child: Row(
          children: [
            Container(width: 4, height: 14, color: accent),
            const SizedBox(width: 8),
            Text(
              text.toUpperCase(),
              style: const TextStyle(
                color: TeocColors.cream,
                fontFamily: TeocText.retroFont,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      );

  // ---------- Apps ----------

  Widget _appsRow(List<App> favorites, TeocProfile profile) {
    final List<Widget> tiles = [];
    for (int i = 0; i < favorites.length; i++) {
      tiles.add(Padding(
        padding: const EdgeInsets.only(right: 16),
        child: TeocAppTile(
          key: ValueKey("home-${profile.id}-${favorites[i].packageName}"),
          app: favorites[i],
          accent: profile.accent,
          autofocus: i == 0,
        ),
      ));
    }
    tiles.add(FocusBox(
      autofocus: favorites.isEmpty,
      accent: profile.accent,
      radius: 14,
      background: TeocColors.surface.withOpacity(0.6),
      onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FavoritesEditor())),
      builder: (context, focused) => SizedBox(
        width: 110,
        height: 99,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: focused ? profile.accent : TeocColors.muted, size: 28),
            const SizedBox(height: 6),
            Text(
              favorites.isEmpty ? "Elegir apps" : "Editar",
              style: TextStyle(color: focused ? TeocColors.cream : TeocColors.muted, fontSize: 12),
            ),
          ],
        ),
      ),
    ));

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(children: tiles),
      ),
    );
  }

  // ---------- Accesos ----------

  Widget _portalsRow(TeocProfile profile) {
    final List<Widget> cards = [];

    for (final input in _inputs) {
      final id = (input["id"] ?? "").toString();
      final label = (input["label"] ?? "Entrada").toString();
      final isPlayStation = _isPlayStation(input);
      cards.add(TeocPortalCard(
        leading: Icon(
          isPlayStation ? Icons.sports_esports : Icons.settings_input_hdmi,
          color: isPlayStation ? profile.accent : TeocColors.cream,
          size: 26,
        ),
        title: isPlayStation ? "PlayStation 4" : label,
        caption: isPlayStation ? label.toUpperCase() : "ENTRADA HDMI",
        accent: profile.accent,
        width: 210,
        onPressed: () => _channel.launchTvInput(id),
      ));
    }

    cards.add(TeocPortalCard(
      leading: PixelSprite(
        rows: deviceIcon,
        pixelSize: 3.4,
        dark: TeocColors.night,
        mid: TeocColors.cream,
        accent: profile.accent,
      ),
      title: TeocConfig.companyName,
      caption: "PROYECTOS",
      accent: profile.accent,
      width: 210,
      onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DigitalMonsterDevice())),
    ));

    cards.add(TeocPortalCard(
      leading: Icon(Icons.apps, color: TeocColors.cream, size: 26),
      title: "Todas las apps",
      caption: "BIBLIOTECA",
      accent: profile.accent,
      width: 190,
      onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FLauncher())),
    ));

    cards.add(TeocPortalCard(
      leading: Icon(Icons.settings_outlined, color: TeocColors.cream, size: 26),
      title: "Ajustes",
      caption: "SISTEMA",
      accent: profile.accent,
      width: 170,
      onPressed: () => _channel.openSettings(),
    ));

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            for (final card in cards) Padding(padding: const EdgeInsets.only(right: 16), child: card),
          ],
        ),
      ),
    );
  }

  // ---------- Noticias ----------

  Widget _newsList(TeocProfile profile) {
    if (_newsLoading && _news.isEmpty) {
      return _hint("Buscando titulares…");
    }
    if (_news.isEmpty) {
      return _hint("Sin titulares por ahora (¿hay internet?)");
    }
    return Column(
      children: [
        for (final item in _news)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: FocusBox(
              accent: profile.accent,
              radius: 12,
              focusScale: 1.02,
              background: TeocColors.surface.withOpacity(0.55),
              focusedBackground: TeocColors.surfaceHigh.withOpacity(0.9),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              onPressed: () => _channel.openWebPage(item.link),
              builder: (context, focused) => Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: profile.accent.withOpacity(0.16),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      item.topic.toUpperCase(),
                      style: TextStyle(
                        color: profile.accent,
                        fontFamily: TeocText.retroFont,
                        fontSize: 9,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item.title,
                      maxLines: focused ? 3 : 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: TeocColors.cream, fontSize: 14, height: 1.3),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    [item.source, item.age].where((part) => part.isNotEmpty).join(" · "),
                    style: const TextStyle(color: TeocColors.muted, fontSize: 11),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // ---------- Calendario ----------

  Widget _calendarRow(List<CalendarEntry> entries, TeocProfile profile) {
    if (entries.isEmpty) {
      return _hint("Nada en el calendario. Agrega fechas en teoc/contenido.json");
    }
    final now = DateTime.now();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            for (final entry in entries)
              Padding(
                padding: const EdgeInsets.only(right: 14),
                child: FocusBox(
                  accent: profile.accent,
                  radius: 14,
                  background: TeocColors.surface.withOpacity(0.6),
                  focusedBackground: TeocColors.surfaceHigh.withOpacity(0.9),
                  padding: const EdgeInsets.all(10),
                  builder: (context, focused) => SizedBox(
                    width: 210,
                    height: 62,
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          decoration: BoxDecoration(
                            color: entry.kind == "evento"
                                ? TeocColors.gold.withOpacity(0.18)
                                : profile.accent.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "${entry.date.day}",
                                style: const TextStyle(color: TeocColors.cream, fontSize: 20, fontWeight: FontWeight.w600, height: 1),
                              ),
                              Text(
                                _monthShort(entry.date.month),
                                style: const TextStyle(
                                  color: TeocColors.muted,
                                  fontFamily: TeocText.retroFont,
                                  fontSize: 9,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                entry.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: TeocColors.cream, fontSize: 13, fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                entry.detail,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: TeocColors.muted, fontSize: 10),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _daysLeftLabel(entry.daysLeft(now)),
                                style: TextStyle(
                                  color: entry.daysLeft(now) <= 3 ? TeocColors.gold : profile.accent,
                                  fontFamily: TeocText.retroFont,
                                  fontSize: 9,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
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

  static String _monthShort(int month) {
    const months = ["ENE", "FEB", "MAR", "ABR", "MAY", "JUN", "JUL", "AGO", "SEP", "OCT", "NOV", "DIC"];
    final index = month < 1 ? 0 : (month > 12 ? 11 : month - 1);
    return months[index];
  }

  static String _daysLeftLabel(int days) {
    if (days <= 0) return "¡HOY!";
    if (days == 1) return "MAÑANA";
    return "EN $days DÍAS";
  }

  // ---------- Recordatorios ----------

  Widget _remindersList(List<Reminder> reminders, TeocProfile profile) {
    if (reminders.isEmpty) {
      return _hint("Nada pendiente hoy ✦");
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final reminder in reminders)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: FocusBox(
              accent: profile.accent,
              radius: 12,
              focusScale: 1.02,
              background: TeocColors.surface.withOpacity(0.55),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              builder: (context, focused) => Row(
                children: [
                  Icon(
                    reminder.forProfile == "todos" ? Icons.home_outlined : Icons.person_outline,
                    size: 16,
                    color: profile.accent,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      reminder.text,
                      style: const TextStyle(color: TeocColors.cream, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _hint(String text) => Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 4),
        child: Text(
          text,
          style: const TextStyle(color: TeocColors.muted, fontSize: 13),
        ),
      );

  // ---------- Panel lateral ----------

  Widget _sidePanel(TeocProfile profile, int remindersCount, List<CalendarEntry> upcoming) {
    final card = TarotCard.ofDay(profile.id, _now);
    final moon = MoonPhase.of(_now);
    final signName = Astro.signName(profile.zodiacSign);

    String? nextRelease;
    if (upcoming.isNotEmpty) {
      final next = upcoming.first;
      final days = next.daysLeft(_now);
      nextRelease = days <= 0
          ? "¡Hoy sale ${next.title}!"
          : "Faltan $days días para ${next.title}.";
    }

    return SingleChildScrollView(
      clipBehavior: Clip.none,
      child: Padding(
        padding: const EdgeInsets.only(top: 6, bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TarotPanel(card: card, accent: profile.accent, ownerName: profile.name),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: TeocColors.surface.withOpacity(0.72),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white.withOpacity(0.07)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(moon.symbol, style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          signName == null ? moon.name.toUpperCase() : "${moon.name} · $signName".toUpperCase(),
                          style: TextStyle(
                            color: profile.accent,
                            fontFamily: TeocText.retroFont,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    Astro.energyOfDay(profile.id, profile.zodiacSign, _now),
                    style: const TextStyle(color: TeocColors.cream, fontSize: 12, height: 1.35),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            MascotPanel(
              accent: profile.accent,
              weather: _weather,
              tip: DailyTip.ofDay(profile.id, _now),
              remindersCount: remindersCount,
              nextRelease: nextRelease,
            ),
          ],
        ),
      ),
    );
  }
}
