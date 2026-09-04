import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// A minimum-160×160 dp action. Big icon over a big label, generous rounding,
/// high contrast. Used for the single most important action on a screen.
class GiantButton extends StatelessWidget {
  const GiantButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.background,
    this.foreground,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final Color? background;
  final Color? foreground;

  @override
  Widget build(BuildContext context) {
    final fg = foreground ?? A11y.patientOnPrimary;
    return Semantics(
      button: true,
      label: label,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: background ?? A11y.patientPrimary,
          foregroundColor: fg,
          minimumSize: const Size(A11y.patientTapTarget, A11y.patientTapTarget),
          padding: const EdgeInsets.all(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 72, color: fg),
            const SizedBox(height: 12),
            Text(label, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
