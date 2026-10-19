/*
 * Teoc Launcher — contenedor enfocable con el control remoto,
 * con borde de acento y leve zoom al seleccionarlo.
 */

import 'package:flutter/material.dart';

import 'teoc_theme.dart';

class FocusBox extends StatefulWidget {
  final Widget Function(BuildContext context, bool focused) builder;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final Color accent;
  final double radius;
  final double focusScale;
  final bool autofocus;
  final Color? background;
  final Color? focusedBackground;
  final EdgeInsetsGeometry padding;
  final FocusNode? focusNode;
  final Color? borderColor;

  const FocusBox({
    super.key,
    required this.builder,
    this.onPressed,
    this.onLongPress,
    this.accent = TeocColors.gold,
    this.radius = 16,
    this.focusScale = 1.05,
    this.autofocus = false,
    this.background,
    this.focusedBackground,
    this.padding = EdgeInsets.zero,
    this.focusNode,
    this.borderColor,
  });

  @override
  State<FocusBox> createState() => _FocusBoxState();
}

class _FocusBoxState extends State<FocusBox> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(widget.radius);
    final background = _focused
        ? (widget.focusedBackground ?? widget.background ?? Colors.transparent)
        : (widget.background ?? Colors.transparent);

    return AnimatedScale(
      scale: _focused ? widget.focusScale : 1.0,
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOut,
      child: Material(
        color: background,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        elevation: _focused ? 10 : 0,
        shadowColor: Colors.black,
        child: InkWell(
          focusNode: widget.focusNode,
          autofocus: widget.autofocus,
          focusColor: Colors.transparent,
          highlightColor: widget.accent.withOpacity(0.12),
          splashColor: widget.accent.withOpacity(0.2),
          onTap: widget.onPressed ?? () {},
          onLongPress: widget.onLongPress,
          onFocusChange: (focused) {
            if (!mounted) {
              return;
            }
            setState(() => _focused = focused);
            if (focused) {
              Scrollable.ensureVisible(
                context,
                alignment: 0.5,
                curve: Curves.easeInOut,
                duration: const Duration(milliseconds: 120),
              );
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: widget.padding,
            decoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(
                color: _focused ? widget.accent : (widget.borderColor ?? Colors.white.withOpacity(0.07)),
                width: _focused ? 2.5 : 1,
              ),
            ),
            child: widget.builder(context, _focused),
          ),
        ),
      ),
    );
  }
}
