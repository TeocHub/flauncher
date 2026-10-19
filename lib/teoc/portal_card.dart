/*
 * Teoc Launcher — tarjeta de acceso rápido (PS4, Teoc-Vice, etc.).
 */

import 'package:flutter/material.dart';

import 'teoc_theme.dart';

class TeocPortalCard extends StatefulWidget {
  final Widget leading;
  final String title;
  final String caption;
  final VoidCallback onPressed;
  final Color accent;
  final double width;

  const TeocPortalCard({
    super.key,
    required this.leading,
    required this.title,
    required this.caption,
    required this.onPressed,
    this.accent = TeocColors.violet,
    this.width = 230,
  });

  @override
  State<TeocPortalCard> createState() => _TeocPortalCardState();
}

class _TeocPortalCardState extends State<TeocPortalCard> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _focused ? 1.06 : 1.0,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      child: SizedBox(
        width: widget.width,
        height: 84,
        child: Material(
          color: (_focused ? TeocColors.surfaceHigh : TeocColors.surface).withOpacity(0.88),
          borderRadius: BorderRadius.circular(16),
          clipBehavior: Clip.antiAlias,
          elevation: _focused ? 12 : 0,
          shadowColor: Colors.black,
          child: InkWell(
            focusColor: Colors.transparent,
            highlightColor: widget.accent.withOpacity(0.15),
            splashColor: widget.accent.withOpacity(0.2),
            onTap: widget.onPressed,
            onFocusChange: (focused) {
              setState(() => _focused = focused);
              if (focused) {
                Scrollable.ensureVisible(
                  context,
                  alignment: 0.5,
                  curve: Curves.easeInOut,
                  duration: const Duration(milliseconds: 100),
                );
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _focused ? TeocColors.gold : Colors.white.withOpacity(0.08),
                  width: _focused ? 2.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: widget.accent.withOpacity(0.16),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: widget.leading,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: TeocColors.cream,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          widget.caption,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: _focused ? TeocColors.gold : TeocColors.muted,
                            fontFamily: TeocText.retroFont,
                            fontSize: 11,
                            letterSpacing: 0.8,
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
      ),
    );
  }
}
