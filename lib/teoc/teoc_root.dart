/*
 * Teoc Launcher — raíz: decide entre "¿Quién está viendo?" y el inicio,
 * y abre el modo ambiente cuando nadie toca el control.
 */

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'ambient.dart';
import 'home.dart';
import 'profile_picker.dart';
import 'profiles.dart';
import 'teoc_config.dart';

class TeocRoot extends StatefulWidget {
  const TeocRoot({super.key});

  @override
  State<TeocRoot> createState() => _TeocRootState();
}

class _TeocRootState extends State<TeocRoot> with WidgetsBindingObserver {
  DateTime _lastInput = DateTime.now();
  DateTime? _pausedAt;
  Timer? _idleTimer;
  bool _ambientOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    HardwareKeyboard.instance.addHandler(_onKey);
    _idleTimer = Timer.periodic(const Duration(seconds: 30), (_) => _checkIdle());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    HardwareKeyboard.instance.removeHandler(_onKey);
    _idleTimer?.cancel();
    super.dispose();
  }

  bool _onKey(KeyEvent event) {
    _lastInput = DateTime.now();
    return false; // no consume la tecla
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _pausedAt = DateTime.now();
    }
    else if (state == AppLifecycleState.resumed) {
      _lastInput = DateTime.now();
      final pausedAt = _pausedAt;
      _pausedAt = null;
      if (pausedAt != null &&
          DateTime.now().difference(pausedAt).inHours >= TeocConfig.askProfileAfterHours &&
          mounted) {
        context.read<ProfileService>().requestPicker();
      }
    }
  }

  void _checkIdle() {
    if (!mounted || _ambientOpen) {
      return;
    }
    if (WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed) {
      return;
    }
    final route = ModalRoute.of(context);
    if (route != null && !route.isCurrent) {
      return; // hay otra pantalla encima (ajustes, proyectos…)
    }
    if (DateTime.now().difference(_lastInput).inMinutes >= TeocConfig.ambientAfterMinutes) {
      _openAmbient();
    }
  }

  Future<void> _openAmbient() async {
    _ambientOpen = true;
    await Navigator.of(context).push(
      PageRouteBuilder(
        opaque: true,
        transitionDuration: const Duration(milliseconds: 900),
        reverseTransitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, __, ___) => const AmbientScreen(),
        transitionsBuilder: (_, animation, __, child) => FadeTransition(opacity: animation, child: child),
      ),
    );
    _ambientOpen = false;
    _lastInput = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final needsPicker = context.select<ProfileService, bool>((service) => service.needsPicker);
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      child: needsPicker
          ? const ProfilePicker(key: ValueKey("picker"))
          : const TeocHome(key: ValueKey("home")),
    );
  }
}
