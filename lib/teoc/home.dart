/*
 * Teoc Launcher — pantalla de inicio.
 *
 * Tres zonas, cada una con un motivo:
 *   1. Arriba: quién eres, el saludo y la hora (y la mascota, discreta).
 *   2. Centro: lo que vienes a hacer → tus apps y accesos.
 *   3. Abajo, "Hoy": resúmenes de una línea. El detalle se abre en un panel
 *      lateral solo cuando lo pides (clima, carta, luna, titulares,
 *      calendario, recordatorios).
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
import 'palettes.dart';
import 'pixel_sprite.dart';
import 'portal_card.dart';
import 'profile_picker.dart';
import 'profiles.dart';
import 'remote_content.dart';
import 'side_sheet.dart';
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
  WeatherReport? _weather;
  List<NewsItem> _news = [];
  bool _newsLoading = true;
  String? _newsProfileId;
  DateTime? _newsUpdatedAt;
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
    final weather = await fetchWeatherReport();
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
    final news = await fetchNewsForTopics(profile.newsTopics, perTopic: 3);
    if (mounted && _newsProfileId == profile.id) {
      setState(() {
        _news = news.take(12).toList();
        _newsLoading = false;
        _newsUpdatedAt = DateTime.now();
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

  String _dateText() {
    String date;
    try {
      date = DateFormat("EEEE d 'de' MMMM", "es").format(_now);
    }
    catch (_) {
      date = DateFormat("EEEE d MMMM").format(_now);
    }
    if (date.isEmpty) return date;
    return date[0].toUpperCase() + date.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final profiles = context.watch<ProfileService>();
    final profile = profiles.current;
    final palette = profiles.palette;
    final avatar = profiles.avatarOf(profile);
    final content = context.watch<RemoteContentService>();
    final appsService = context.watch<AppsService>();

    if (_newsProfileId != profile.id) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _loadNews();
        }
      });
    }

    final favorites = _favoriteApps(appsService, profiles);
    final reminders = content.remindersFor(profile.id);
    final upcoming = content.upcoming(limit: 8);

    return Scaffold(
      backgroundColor: palette.background.last,
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        decoration: BoxDecoration(gradient: palette.gradient),
        child: SingleChildScrollView(
          clipBehavior: Clip.none,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(40, 26, 40, 36),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _topBar(profiles, profile, palette, avatar, reminders, upcoming),
                const SizedBox(height: 26),
                _label("Para ti", palette),
                _appsRow(favorites, profile, palette),
                const SizedBox(height: 22),
                _label("Accesos", palette),
                _portalsRow(palette),
                const SizedBox(height: 22),
                _label("Hoy", palette),
                _todayRow(profile, palette, reminders, upcoming),
              ],
            ),
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

  Widget _label(String text, TeocPalette palette) => Padding(
        padding: const EdgeInsets.only(bottom: 10, left: 2),
        child: Text(
          text.toUpperCase(),
          style: TextStyle(
            color: palette.muted,
            fontFamily: TeocText.retroFont,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.5,
          ),
        ),
      );

  // ======================================================================
  // 1. Arriba
  // ======================================================================

  Widget _topBar(ProfileService profiles, TeocProfile profile, TeocPalette palette, TeocAvatar avatar,
      List<Reminder> reminders, List<CalendarEntry> upcoming) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        FocusBox(
          accent: palette.accent,
          radius: 40,
          background: palette.surface,
          borderColor: palette.border,
          padding: const EdgeInsets.all(9),
          onPressed: () => _openProfileMenu(profiles, profile, palette),
          builder: (context, focused) => ProfileAvatar(avatar: avatar, palette: palette, pixelSize: 3.2),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${_greeting()}, ${profile.name}",
                style: TextStyle(
                  color: palette.text,
                  fontSize: 28,
                  fontWeight: FontWeight.w300,
                  shadows: palette.textShadow,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _dateText(),
                style: TextStyle(color: palette.muted, fontSize: 13),
              ),
            ],
          ),
        ),
        MascotBadge(
          palette: palette,
          weather: _weather?.now,
          messages: _mascotMessages(profile, reminders, upcoming),
        ),
        const SizedBox(width: 18),
        Text(
          DateFormat("HH:mm").format(_now),
          style: TextStyle(
            color: palette.text,
            fontSize: 40,
            fontWeight: FontWeight.w200,
            letterSpacing: 1,
            shadows: palette.textShadow,
          ),
        ),
      ],
    );
  }

  List<String> _mascotMessages(TeocProfile profile, List<Reminder> reminders, List<CalendarEntry> upcoming) {
    final List<String> messages = [DailyTip.ofDay(profile.id, _now)];
    if (_now.hour < 6) {
      messages.insert(0, "Zzz… ya es tarde. ¿Un capítulo más y a dormir?");
    }
    final weather = _weather;
    if (weather != null) {
      final today = weather.today;
      if (today != null && today.rainChance >= 50) {
        messages.add("Hoy hay ${today.rainChance}% de probabilidad de lluvia. ¡Paraguas!");
      }
      else if (weather.now.temperature >= 28) {
        messages.add("Hace ${weather.now.temperature.round()}°: ¡hidrátate!");
      }
      else if (weather.now.temperature <= 8) {
        messages.add("Hace ${weather.now.temperature.round()}°: abrígate bien.");
      }
    }
    if (reminders.isNotEmpty) {
      messages.add("No olvides: ${reminders.first.text.toLowerCase()}.");
    }
    if (upcoming.isNotEmpty) {
      final next = upcoming.first;
      final days = next.daysLeft(_now);
      messages.add(days <= 0 ? "¡Hoy sale ${next.title}!" : "Faltan $days días para ${next.title}.");
    }
    return messages;
  }

  void _openProfileMenu(ProfileService profiles, TeocProfile profile, TeocPalette palette) {
    showSideSheet(
      context: context,
      palette: palette,
      eyebrow: "Perfil",
      title: profile.name,
      autofocusClose: false,
      builder: (sheetContext) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _menuButton(palette, Icons.swap_horiz, "Cambiar de perfil", autofocus: true, onPressed: () {
            Navigator.of(sheetContext).pop();
            profiles.requestPicker();
          }),
          _menuButton(palette, Icons.palette_outlined, "Personalizar ícono y colores", onPressed: () {
            Navigator.of(sheetContext).pop();
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => ProfileEditor(profile: profile)));
          }),
          _menuButton(palette, Icons.star_outline, "Elegir mis apps", onPressed: () {
            Navigator.of(sheetContext).pop();
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FavoritesEditor()));
          }),
        ],
      ),
    );
  }

  Widget _menuButton(TeocPalette palette, IconData icon, String text,
          {required VoidCallback onPressed, bool autofocus = false}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: FocusBox(
          autofocus: autofocus,
          accent: palette.accent,
          radius: 14,
          focusScale: 1.02,
          background: palette.surface,
          borderColor: palette.border,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          onPressed: onPressed,
          builder: (context, focused) => Row(
            children: [
              Icon(icon, color: focused ? palette.accent : palette.muted, size: 20),
              const SizedBox(width: 14),
              Text(text, style: TextStyle(color: palette.text, fontSize: 15)),
            ],
          ),
        ),
      );

  // ======================================================================
  // 2. Centro: apps y accesos
  // ======================================================================

  Widget _appsRow(List<App> favorites, TeocProfile profile, TeocPalette palette) {
    final List<Widget> tiles = [];
    for (int i = 0; i < favorites.length; i++) {
      tiles.add(Padding(
        padding: const EdgeInsets.only(right: 16),
        child: TeocAppTile(
          key: ValueKey("home-${profile.id}-${favorites[i].packageName}"),
          app: favorites[i],
          palette: palette,
          width: 168,
          autofocus: i == 0,
        ),
      ));
    }
    tiles.add(FocusBox(
      autofocus: favorites.isEmpty,
      accent: palette.accent,
      radius: 14,
      background: palette.surface,
      borderColor: palette.border,
      onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FavoritesEditor())),
      builder: (context, focused) => SizedBox(
        width: 94,
        height: 94.5,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: focused ? palette.accent : palette.muted, size: 26),
            const SizedBox(height: 4),
            Text(
              favorites.isEmpty ? "Elegir apps" : "Editar",
              style: TextStyle(color: focused ? palette.text : palette.muted, fontSize: 11),
            ),
          ],
        ),
      ),
    ));

    return _horizontal(tiles);
  }

  Widget _portalsRow(TeocPalette palette) {
    final List<Widget> cards = [];

    for (final input in _inputs) {
      final id = (input["id"] ?? "").toString();
      final label = (input["label"] ?? "Entrada").toString();
      final isPlayStation = _isPlayStation(input);
      cards.add(TeocPortalCard(
        palette: palette,
        leading: Icon(isPlayStation ? Icons.sports_esports : Icons.settings_input_hdmi, color: palette.accent, size: 22),
        title: isPlayStation ? "PlayStation 4" : label,
        caption: isPlayStation ? label.toUpperCase() : "ENTRADA HDMI",
        onPressed: () => _channel.launchTvInput(id),
      ));
    }

    cards.add(TeocPortalCard(
      palette: palette,
      leading: PixelSprite(
        rows: deviceIcon,
        pixelSize: 2.8,
        dark: palette.light ? palette.text : const Color(0xFF0D0E12),
        mid: palette.light ? Colors.white : palette.highlight,
        accent: palette.accent,
      ),
      title: TeocConfig.companyName,
      caption: "PROYECTOS",
      onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DigitalMonsterDevice())),
    ));

    cards.add(TeocPortalCard(
      palette: palette,
      leading: Icon(Icons.apps, color: palette.accent, size: 22),
      title: "Todas las apps",
      caption: "BIBLIOTECA",
      width: 190,
      onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FLauncher())),
    ));

    cards.add(TeocPortalCard(
      palette: palette,
      leading: Icon(Icons.settings_outlined, color: palette.accent, size: 22),
      title: "Ajustes",
      caption: "SISTEMA",
      width: 160,
      onPressed: () => _channel.openSettings(),
    ));

    return _horizontal(cards);
  }

  Widget _horizontal(List<Widget> children) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              for (final child in children)
                if (child is Padding) child else Padding(padding: const EdgeInsets.only(right: 16), child: child),
            ],
          ),
        ),
      );

  // ======================================================================
  // 3. Hoy: resúmenes que abren su detalle
  // ======================================================================

  Widget _todayRow(TeocProfile profile, TeocPalette palette, List<Reminder> reminders, List<CalendarEntry> upcoming) {
    final card = TarotCard.ofDay(profile.id, _now);
    final moon = MoonPhase.of(_now);
    final weather = _weather;

    final List<Widget> cards = [
      _todayCard(
        palette: palette,
        icon: Icon(weather?.now.icon ?? Icons.cloud_outlined, color: palette.accent, size: 22),
        eyebrow: "Clima",
        value: weather == null ? "—" : "${weather.now.temperature.round()}° ${weather.now.description}",
        detail: weather == null ? "Cargando…" : weather.todaySummary,
        onPressed: () => _openWeather(palette),
      ),
      _todayCard(
        palette: palette,
        icon: TarotCardFace(card: card, accent: palette.accent, width: 24),
        eyebrow: "Carta del día",
        value: card.name,
        detail: "Ver su mensaje",
        onPressed: () => _openTarot(profile, palette, card),
      ),
      _todayCard(
        palette: palette,
        icon: Text(moon.symbol, style: const TextStyle(fontSize: 22)),
        eyebrow: "Luna",
        value: moon.name,
        detail: Astro.signName(profile.zodiacSign) ?? "Energía del día",
        onPressed: () => _openMoon(profile, palette),
      ),
      _todayCard(
        palette: palette,
        icon: Icon(Icons.article_outlined, color: palette.accent, size: 22),
        eyebrow: "Titulares",
        value: _newsLoading && _news.isEmpty ? "Buscando…" : "${_news.length} para ti",
        detail: profile.newsTopics.take(2).join(" · "),
        onPressed: () => _openNews(profile, palette),
      ),
      _todayCard(
        palette: palette,
        icon: Icon(Icons.sports_esports_outlined, color: palette.accent, size: 22),
        eyebrow: "Calendario",
        value: upcoming.isEmpty ? "Sin fechas" : upcoming.first.title,
        detail: upcoming.isEmpty ? "Agrega en contenido.json" : _daysLeftText(upcoming.first.daysLeft(_now)),
        onPressed: () => _openCalendar(palette, upcoming),
      ),
      _todayCard(
        palette: palette,
        icon: Icon(Icons.checklist, color: palette.accent, size: 22),
        eyebrow: "Recordatorios",
        value: reminders.isEmpty ? "Nada pendiente" : (reminders.length == 1 ? "1 para hoy" : "${reminders.length} para hoy"),
        detail: reminders.isEmpty ? "Día libre ✦" : reminders.first.text,
        onPressed: () => _openReminders(palette, reminders),
      ),
    ];

    return _horizontal(cards);
  }

  Widget _todayCard({
    required TeocPalette palette,
    required Widget icon,
    required String eyebrow,
    required String value,
    required String detail,
    required VoidCallback onPressed,
  }) {
    return FocusBox(
      accent: palette.accent,
      radius: 16,
      background: palette.surface,
      focusedBackground: palette.surfaceHigh,
      borderColor: palette.border,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      onPressed: onPressed,
      builder: (context, focused) => SizedBox(
        width: 172,
        height: 62,
        child: Row(
          children: [
            SizedBox(width: 30, child: Center(child: icon)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    eyebrow.toUpperCase(),
                    style: TextStyle(
                      color: focused ? palette.accent : palette.muted,
                      fontFamily: TeocText.retroFont,
                      fontSize: 9,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: palette.text, fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    detail,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: palette.muted, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _daysLeftText(int days) {
    if (days <= 0) return "¡Sale hoy!";
    if (days == 1) return "Sale mañana";
    return "En $days días";
  }

  // ---------------- Paneles de detalle ----------------

  TextStyle _body(TeocPalette palette) => TextStyle(color: palette.text, fontSize: 15, height: 1.45);

  TextStyle _small(TeocPalette palette) => TextStyle(color: palette.muted, fontSize: 12, height: 1.4);

  void _openWeather(TeocPalette palette) {
    final weather = _weather;
    if (weather == null) {
      _loadWeather();
      return;
    }
    final today = weather.today;
    showSideSheet(
      context: context,
      palette: palette,
      eyebrow: "Clima · ${TeocConfig.weatherCityName}",
      title: "${weather.now.temperature.round()}° · ${weather.now.description}",
      builder: (_) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (today != null)
            Text(
              "Hoy: máxima ${today.max.round()}°, mínima ${today.min.round()}° y ${today.rainChance}% de probabilidad de lluvia.",
              style: _body(palette),
            ),
          const SizedBox(height: 22),
          Text("PRÓXIMAS HORAS", style: _eyebrow(palette)),
          const SizedBox(height: 10),
          SizedBox(
            height: 92,
            child: Row(
              children: [
                for (final hour in weather.hours.where((h) => h.time.hour % 2 == 0).take(7))
                  Expanded(
                    child: Column(
                      children: [
                        Text(DateFormat("HH").format(hour.time) + "h", style: _small(palette)),
                        const SizedBox(height: 6),
                        Icon(hour.icon, color: palette.accent, size: 20),
                        const SizedBox(height: 6),
                        Text("${hour.temperature.round()}°", style: TextStyle(color: palette.text, fontSize: 15)),
                        if (hour.rainChance >= 20)
                          Text("${hour.rainChance}%", style: TextStyle(color: palette.accent, fontSize: 10)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Text("PRÓXIMOS DÍAS", style: _eyebrow(palette)),
          const SizedBox(height: 8),
          for (final day in weather.days.skip(1))
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 7),
              child: Row(
                children: [
                  SizedBox(width: 90, child: Text(_weekday(day.date), style: _body(palette))),
                  Icon(day.icon, color: palette.accent, size: 20),
                  const SizedBox(width: 10),
                  Expanded(child: Text(day.description, style: _small(palette))),
                  Text("${day.max.round()}° / ${day.min.round()}°", style: _body(palette)),
                ],
              ),
            ),
          const SizedBox(height: 14),
          Text("Se actualiza cada 30 minutos.", style: _small(palette)),
        ],
      ),
    );
  }

  String _weekday(DateTime date) {
    try {
      final text = DateFormat("EEEE", "es").format(date);
      return text[0].toUpperCase() + text.substring(1);
    }
    catch (_) {
      return DateFormat("EEEE").format(date);
    }
  }

  TextStyle _eyebrow(TeocPalette palette) => TextStyle(
        color: palette.accent,
        fontFamily: TeocText.retroFont,
        fontSize: 10,
        fontWeight: FontWeight.bold,
        letterSpacing: 2,
      );

  void _openTarot(TeocProfile profile, TeocPalette palette, TarotCard card) {
    showSideSheet(
      context: context,
      palette: palette,
      eyebrow: "La carta de ${profile.name} para hoy",
      title: "${card.numeral} · ${card.name}",
      builder: (_) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: TarotCardFace(card: card, accent: palette.accent, width: 130)),
          const SizedBox(height: 22),
          Text(card.meaning, style: _body(palette)),
          const SizedBox(height: 12),
          Text("✦ ${card.advice}", style: _body(palette).copyWith(color: palette.accent)),
          const SizedBox(height: 18),
          Text("Cambia cada día a medianoche. Cada perfil tiene su propia carta.", style: _small(palette)),
        ],
      ),
    );
  }

  void _openMoon(TeocProfile profile, TeocPalette palette) {
    final moon = MoonPhase.of(_now);
    final nextFull = _nextPhase("Luna llena");
    final nextNew = _nextPhase("Luna nueva");
    final sign = Astro.signName(profile.zodiacSign);

    showSideSheet(
      context: context,
      palette: palette,
      eyebrow: sign == null ? "Luna y energía" : "Luna · $sign",
      title: "${moon.symbol}  ${moon.name}",
      builder: (_) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(Astro.energyOfDay(profile.id, profile.zodiacSign, _now), style: _body(palette)),
          const SizedBox(height: 22),
          if (nextFull != null) _keyValue(palette, "🌕  Próxima luna llena", _shortDate(nextFull)),
          if (nextNew != null) _keyValue(palette, "🌑  Próxima luna nueva", _shortDate(nextNew)),
          const SizedBox(height: 18),
          Text(
            sign == null
                ? "Agrega tu signo en teoc_config.dart para una energía personalizada."
                : "La energía cambia cada día; la fase lunar, cada 3 o 4 días.",
            style: _small(palette),
          ),
        ],
      ),
    );
  }

  DateTime? _nextPhase(String name) {
    final start = DateTime(_now.year, _now.month, _now.day, 12);
    String previous = MoonPhase.of(start).name;
    for (int i = 1; i <= 31; i++) {
      final day = start.add(Duration(days: i));
      final current = MoonPhase.of(day).name;
      if (current == name && previous != name) {
        return day;
      }
      previous = current;
    }
    return null;
  }

  String _shortDate(DateTime date) {
    try {
      return DateFormat("EEEE d 'de' MMMM", "es").format(date);
    }
    catch (_) {
      return DateFormat("EEEE d MMMM").format(date);
    }
  }

  Widget _keyValue(TeocPalette palette, String key, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Expanded(child: Text(key, style: _body(palette))),
            Text(value, style: _small(palette)),
          ],
        ),
      );

  void _openNews(TeocProfile profile, TeocPalette palette) {
    final updated = _newsUpdatedAt;
    showSideSheet(
      context: context,
      palette: palette,
      eyebrow: "Titulares para ${profile.name}",
      title: profile.newsTopics.join(" · "),
      autofocusClose: _news.isEmpty,
      builder: (_) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_news.isEmpty)
            Text(_newsLoading ? "Buscando titulares…" : "Sin titulares por ahora. ¿Hay internet?", style: _body(palette)),
          for (int i = 0; i < _news.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: FocusBox(
                autofocus: i == 0,
                accent: palette.accent,
                radius: 12,
                focusScale: 1.0,
                background: palette.surface,
                borderColor: palette.border,
                padding: const EdgeInsets.all(12),
                onPressed: () => _channel.openWebPage(_news[i].link),
                builder: (context, focused) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      [_news[i].topic.toUpperCase(), _news[i].source, _news[i].age]
                          .where((part) => part.isNotEmpty)
                          .join("  ·  "),
                      style: TextStyle(
                        color: palette.accent,
                        fontFamily: TeocText.retroFont,
                        fontSize: 9,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(_news[i].title, style: TextStyle(color: palette.text, fontSize: 14, height: 1.35)),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 8),
          Text(
            updated == null
                ? "OK abre la nota completa."
                : "OK abre la nota completa · Actualizado a las ${DateFormat("HH:mm").format(updated)} · cada 30 min",
            style: _small(palette),
          ),
        ],
      ),
    );
  }

  void _openCalendar(TeocPalette palette, List<CalendarEntry> upcoming) {
    showSideSheet(
      context: context,
      palette: palette,
      eyebrow: "Calendario gamer",
      title: "Lo que viene",
      builder: (_) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (upcoming.isEmpty) Text("Agrega lanzamientos y eventos en teoc/contenido.json.", style: _body(palette)),
          for (final entry in upcoming)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(color: palette.accentSoft, borderRadius: BorderRadius.circular(10)),
                    child: Column(
                      children: [
                        Text("${entry.date.day}", style: TextStyle(color: palette.text, fontSize: 18, fontWeight: FontWeight.w600)),
                        Text(_monthShort(entry.date.month), style: _small(palette).copyWith(fontSize: 9)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(entry.title, style: TextStyle(color: palette.text, fontSize: 15, fontWeight: FontWeight.w500)),
                        if (entry.detail.isNotEmpty) Text(entry.detail, style: _small(palette)),
                      ],
                    ),
                  ),
                  Text(
                    _daysLeftText(entry.daysLeft(_now)),
                    style: TextStyle(color: palette.accent, fontSize: 12),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 14),
          Text("Se edita en teoc/contenido.json y se actualiza cada hora.", style: _small(palette)),
        ],
      ),
    );
  }

  static String _monthShort(int month) {
    const months = ["ENE", "FEB", "MAR", "ABR", "MAY", "JUN", "JUL", "AGO", "SEP", "OCT", "NOV", "DIC"];
    final index = month < 1 ? 0 : (month > 12 ? 11 : month - 1);
    return months[index];
  }

  void _openReminders(TeocPalette palette, List<Reminder> reminders) {
    showSideSheet(
      context: context,
      palette: palette,
      eyebrow: "Recordatorios",
      title: "Para hoy",
      builder: (_) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (reminders.isEmpty) Text("Nada pendiente hoy ✦", style: _body(palette)),
          for (final reminder in reminders)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Icon(
                    reminder.forProfile == "todos" ? Icons.home_outlined : Icons.person_outline,
                    color: palette.accent,
                    size: 18,
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(reminder.text, style: _body(palette))),
                ],
              ),
            ),
          const SizedBox(height: 14),
          Text("Se editan en teoc/contenido.json y se actualizan cada hora.", style: _small(palette)),
        ],
      ),
    );
  }
}
