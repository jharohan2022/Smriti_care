import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/family_members_service.dart';
import '../../../core/services/patient_device_service.dart';
import '../../../core/services/tts_service.dart';

class PatientProfileScreen extends ConsumerStatefulWidget {
  const PatientProfileScreen({super.key});

  @override
  ConsumerState<PatientProfileScreen> createState() => _PatientProfileScreenState();
}

class _PatientProfileScreenState extends ConsumerState<PatientProfileScreen> {
  void _openAshaAdminDialog() {
    final pinController = TextEditingController();
    String? errorMessage;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.security_rounded, color: Color(0xFF6B4EE6)),
              SizedBox(width: 10),
              Text(
                'ASHA Admin Access',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter 4-Digit ASHA Security PIN to configure patient or reset device binding.',
                style: TextStyle(fontSize: 13, color: Color(0xFF475569)),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: pinController,
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 4,
                decoration: InputDecoration(
                  hintText: 'PIN (Default: 1234)',
                  prefixIcon: const Icon(Icons.pin_rounded),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  errorText: errorMessage,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final isValid = await ref
                    .read(patientDeviceProvider.notifier)
                    .verifyAshaPin(pinController.text.trim());
                if (!isValid) {
                  setDialogState(() {
                    errorMessage = 'Incorrect ASHA PIN! (Default: 1234)';
                  });
                  return;
                }
                Navigator.pop(ctx);
                _showAshaManagementSheet();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6B4EE6),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Unlock Admin'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAshaManagementSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.verified_user_rounded, color: Color(0xFF16A34A), size: 28),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'ASHA Device Administration',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Text(
              'Only authorized ASHA workers have permission to manage or unbind patient profiles from this dedicated device.',
              style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 20),

            // Option 1: Add/Edit Dynamic Family Member
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.group_add_rounded, color: Color(0xFF2563EB)),
              ),
              title: const Text('Add Family Member (Dynamic Photos)', style: TextStyle(fontWeight: FontWeight.w800)),
              subtitle: const Text('Add photo & relationship for cognitive games'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(ctx);
                _showAddFamilyMemberDialog();
              },
            ),

            const Divider(),

            // Option 2: Reset & Unbind Device
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.restart_alt_rounded, color: Color(0xFFDC2626)),
              ),
              title: const Text('Unbind & Reset Device (ASHA Only)', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFFDC2626))),
              subtitle: const Text('Remove patient profile & unbind device'),
              trailing: const Icon(Icons.chevron_right, color: Color(0xFFDC2626)),
              onTap: () {
                Navigator.pop(ctx);
                _confirmDeviceReset();
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showAddFamilyMemberDialog() {
    final nameCtrl = TextEditingController();
    final relationCtrl = TextEditingController();
    final noteCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Add Family Member', style: TextStyle(fontWeight: FontWeight.w800)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Name (e.g. Vikas)'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: relationCtrl,
                decoration: const InputDecoration(labelText: 'Relation (e.g. Son / बेटा)'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: noteCtrl,
                decoration: const InputDecoration(labelText: 'Memory Note / Routine'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.isNotEmpty) {
                ref.read(familyMembersProvider.notifier).addFamilyMember(
                      FamilyMember(
                        id: 'fam-${DateTime.now().millisecondsSinceEpoch}',
                        name: nameCtrl.text.trim(),
                        relation: relationCtrl.text.trim().isNotEmpty ? relationCtrl.text.trim() : 'Family (परिवार)',
                        relationHi: 'परिवार',
                        icon: Icons.face_retouching_natural_rounded,
                        avatarColor: const Color(0xFF7C3AED),
                        memoryNote: noteCtrl.text.trim().isNotEmpty ? noteCtrl.text.trim() : 'Loved family member.',
                      ),
                    );
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Family Member added successfully!')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6B4EE6),
              foregroundColor: Colors.white,
            ),
            child: const Text('Save Member'),
          ),
        ],
      ),
    );
  }

  void _confirmDeviceReset() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFDC2626)),
            SizedBox(width: 8),
            Text('Reset Device Binding?', style: TextStyle(fontWeight: FontWeight.w800)),
          ],
        ),
        content: const Text(
          'Are you sure you want to unbind this patient from this device? All local offline sessions will be cleared.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await ref.read(patientDeviceProvider.notifier).resetDeviceWithAshaPin('1234');
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Device reset successfully by ASHA worker.'),
                  backgroundColor: Color(0xFFDC2626),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirm Reset'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final patient = ref.watch(patientDeviceProvider);
    final familyMembers = ref.watch(familyMembersProvider);

    const brandPurple = Color(0xFF6B4EE6);
    const textDark = Color(0xFF1E1B4B);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Aur (और) / Profile',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: textDark,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.volume_up_rounded, color: brandPurple, size: 28),
            tooltip: 'Sunein',
            onPressed: () {
              ref.read(ttsServiceProvider).speak(
                    'यह आपकी प्रोफ़ाइल है। आपका नाम ${patient.name} है, और आपकी आशा दीदी ${patient.ashaName} हैं।',
                  );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1-Device = 1-Patient Dedicated Device Status Badge
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDE9FE),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFDDD6FE)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.phone_android_rounded, color: brandPurple, size: 22),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'One Device • One Patient (Locked)',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF4C1D95),
                            ),
                          ),
                          Text(
                            'Permanent local patient profile (No user login/logout required)',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF6D28D9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Patient Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
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
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 40,
                      backgroundColor: Color(0xFFEDE9FE),
                      child: Text('👴', style: TextStyle(fontSize: 44)),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      patient.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'ID: ${patient.id} • Age: ${patient.age} Yrs',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF475569),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      patient.condition,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Dynamic Family Section
              const Text(
                'Mera Parivar (मेरा परिवार)',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 10),

              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: familyMembers.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final member = familyMembers[index];

                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: member.avatarColor.withOpacity(0.15),
                          child: Icon(member.icon, color: member.avatarColor, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                member.name,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: textDark,
                                ),
                              ),
                              Text(
                                member.relation,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: member.avatarColor,
                                ),
                              ),
                              Text(
                                member.memoryNote,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // Protected ASHA Worker Admin Tile (Only ASHA can reset/unbind)
              GestureDetector(
                onTap: _openAshaAdminDialog,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAF5FF),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFDDD6FE), width: 1.5),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.admin_panel_settings_rounded, color: brandPurple, size: 28),
                      SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ASHA Worker Mode (आशा प्रबंधन)',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: brandPurple,
                              ),
                            ),
                            Text(
                              'PIN Protected • Add family & device unbind permission',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.lock_outline_rounded, color: brandPurple, size: 22),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
