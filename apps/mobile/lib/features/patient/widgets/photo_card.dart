import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// A large photographic card for the [EasyDashboardScreen]. Recognised by image,
/// reinforced by a big label. If the asset is missing (fresh install, no
/// download yet) it degrades to a solid color + icon rather than a broken image.
class PhotoCard extends StatelessWidget {
  const PhotoCard({
    super.key,
    required this.label,
    required this.imageAsset,
    required this.fallbackIcon,
    required this.onTap,
    this.accent = A11y.patientPrimary,
  });

  final String label;
  final String imageAsset;
  final IconData fallbackIcon;
  final VoidCallback onTap;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Ink(
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: accent, width: 4),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  imageAsset,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: accent.withValues(alpha: 0.15),
                    child: Icon(fallbackIcon, size: 96, color: accent),
                  ),
                ),
                // Legibility scrim behind the label.
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.black54,
                    child: Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: A11y.patientLabel,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
