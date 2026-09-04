import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../patients/asha_patient_repository.dart';

class AshaFollowupScreen extends ConsumerStatefulWidget {
  const AshaFollowupScreen({super.key, required this.patientId, this.patient});
  final String patientId;
  final AshaPatientRecord? patient;

  @override
  ConsumerState<AshaFollowupScreen> createState() => _AshaFollowupScreenState();
}

class _AshaFollowupScreenState extends ConsumerState<AshaFollowupScreen> {
  void _showAddNoteDialog(AshaPatientRecord record) {
    final noteCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Clinical Note / Tippani'),
        content: TextField(
          controller: noteCtrl,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Enter observation / family routine update...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (noteCtrl.text.trim().isNotEmpty) {
                ref.read(ashaPatientsProvider.notifier).addNote(record.id, noteCtrl.text.trim());
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Note added successfully!')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF059669), foregroundColor: Colors.white),
            child: const Text('Save Note'),
          ),
        ],
      ),
    );
  }

  void _showScheduleDialog(AshaPatientRecord record) {
    showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 3)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    ).then((picked) {
      if (picked != null) {
        ref.read(ashaPatientsProvider.notifier).updatePatient(
              record.copyWith(nextVisitDate: '${picked.day}/${picked.month}/${picked.year} at 10:30 AM'),
            );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Scheduled visit for ${record.name} on ${picked.day}/${picked.month}/${picked.year}')),
        );
      }
    });
  }

  void _showReferralDialog(AshaPatientRecord record) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.local_hospital_rounded, color: Color(0xFFDC2626)),
            SizedBox(width: 8),
            Text('Medical Referral'),
          ],
        ),
        content: Text(
          'Generate PHC Tele-consultation & Specialist Referral for ${record.name}?\n\nThis will alert the Primary Health Center Medical Officer.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Referral Slip Generated & Dispatched to Sonapur PHC.'),
                  backgroundColor: Color(0xFFDC2626),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626), foregroundColor: Colors.white),
            child: const Text('Confirm Referral'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allPatients = ref.watch(ashaPatientsProvider);
    final patient = allPatients.firstWhere(
      (p) => p.id == widget.patientId,
      orElse: () =>
          widget.patient ??
          const AshaPatientRecord(
            id: 'PAT-101',
            name: 'Ramesh Das',
            age: 72,
            village: 'Rampur Gaon',
            district: 'Sonapur',
            state: 'Assam',
            language: 'Hindi',
            phone: '9876543211',
            caregiverName: 'Suresh Das',
            status: AshaTriageStatus.needsAttention,
            score: 5,
            durationSec: 54,
            trendNote: 'Performance mein mahatvapurn girawat dikhi hai. ASHA review avashyak hai.',
          ),
    );

    const emeraldBrand = Color(0xFF059669);
    const textDark = Color(0xFF0F172A);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: textDark, size: 28),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'ASHA Action',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: textDark,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Patient Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: patient.status.bgColor,
                      child: Text(
                        patient.name.contains('Lakshmi') || patient.name.contains('Kamla')
                            ? '👵'
                            : '👴',
                        style: const TextStyle(fontSize: 32),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            patient.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: textDark,
                            ),
                          ),
                          Text(
                            '${patient.age} saal • ${patient.village}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: patient.status.bgColor,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: patient.status.color.withOpacity(0.4)),
                            ),
                            child: Text(
                              patient.status.label,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: patient.status.color,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 4 Action Tiles
              _buildActionTile(
                icon: Icons.home_rounded,
                iconColor: const Color(0xFF059669),
                bgColor: const Color(0xFFECFDF5),
                title: 'Home Visit Karein',
                subtitle: 'Buzurg se milkar sthiti dekhein',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Starting Home Visit for ${patient.name}...')),
                  );
                },
              ),

              const SizedBox(height: 12),

              _buildActionTile(
                icon: Icons.event_available_rounded,
                iconColor: const Color(0xFF2563EB),
                bgColor: const Color(0xFFEFF6FF),
                title: 'Follow-up Schedule',
                subtitle: patient.nextVisitDate != null
                    ? 'Scheduled: ${patient.nextVisitDate}'
                    : 'Agli mulaqat ki tithi tay karein',
                onTap: () => _showScheduleDialog(patient),
              ),

              const SizedBox(height: 12),

              _buildActionTile(
                icon: Icons.local_hospital_rounded,
                iconColor: const Color(0xFFDC2626),
                bgColor: const Color(0xFFFEF2F2),
                title: 'Medical Referral',
                subtitle: 'PHC / Doctor ke paas bhejein',
                onTap: () => _showReferralDialog(patient),
              ),

              const SizedBox(height: 12),

              _buildActionTile(
                icon: Icons.note_add_rounded,
                iconColor: const Color(0xFF7C3AED),
                bgColor: const Color(0xFFFAF5FF),
                title: 'Notes Add Karein',
                subtitle: patient.notes.isNotEmpty
                    ? '${patient.notes.length} notes recorded'
                    : 'Apni tippani likhein',
                onTap: () => _showAddNoteDialog(patient),
              ),

              const SizedBox(height: 24),

              // Reassurance Footer Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF1F2),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFFECDD3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.favorite_rounded, color: Color(0xFFE11D48), size: 22),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Aapka samay, buzurgon ke behtar kal ka sahara hai. ❤️',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFBE123C),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: iconColor, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8), size: 24),
          ],
        ),
      ),
    );
  }
}
