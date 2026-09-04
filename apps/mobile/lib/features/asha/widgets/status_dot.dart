import 'package:flutter/material.dart';

import '../../../core/database/models/patient_local.dart';

/// Color-coded triage indicator. Color is reinforced with an icon + semantic
/// label so status is never conveyed by color alone (colorblind-safe, a11y).
class StatusDot extends StatelessWidget {
  const StatusDot({super.key, required this.status, this.size = 22, this.showLabel = false});

  final PatientStatus status;
  final double size;
  final bool showLabel;

  ({Color color, IconData icon, String label}) get _spec => switch (status) {
        PatientStatus.ok => (color: const Color(0xFF2E7D32), icon: Icons.check_circle, label: 'On track'),
        PatientStatus.warning => (color: const Color(0xFFF9A825), icon: Icons.error, label: 'Needs attention'),
        PatientStatus.alert => (color: const Color(0xFFC62828), icon: Icons.warning_rounded, label: 'Alert'),
      };

  @override
  Widget build(BuildContext context) {
    final s = _spec;
    return Semantics(
      label: 'Status: ${s.label}',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(s.icon, color: s.color, size: size),
          if (showLabel) ...[
            const SizedBox(width: 6),
            Text(s.label, style: TextStyle(color: s.color, fontWeight: FontWeight.w600)),
          ],
        ],
      ),
    );
  }
}
