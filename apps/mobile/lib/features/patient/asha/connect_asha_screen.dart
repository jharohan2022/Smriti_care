import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/patient_device_service.dart';
import '../../../core/services/tts_service.dart';

class ConnectAshaScreen extends ConsumerWidget {
  const ConnectAshaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patient = ref.watch(patientDeviceProvider);
    const textDark = Color(0xFF1E1B4B);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Kabhi Baat Karni Ho?',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: textDark,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            children: [
              const SizedBox(height: 12),

              // ASHA Didi Avatar Container
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFDCFCE7),
                        border: Border.all(color: const Color(0xFF86EFAC), width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF10B981).withOpacity(0.2),
                            blurRadius: 18,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          '👩‍⚕️',
                          style: TextStyle(fontSize: 54),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      patient.ashaName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Aap apni ASHA didi se baat kar sakte hain.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF475569),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Action 1 (Big Green): Baat Karein (Phone / Voice)
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF16A34A),
                  foregroundColor: Colors.white,
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ).buildElevatedButton(
                  onPressed: () {
                    ref.read(ttsServiceProvider).speak(
                          'आशा दीदी को फोन मिलाया जा रहा है...',
                        );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Calling ${patient.ashaName} (${patient.ashaPhone})...'),
                        backgroundColor: const Color(0xFF16A34A),
                      ),
                    );
                  },
                  icon: Icons.phone_in_talk_rounded,
                  label: 'Baat Karein (Phone / Voice)',
                ),
              ),

              const SizedBox(height: 14),

              // Action 2: Video Baat
              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5CF6),
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ).buildElevatedButton(
                  onPressed: () {
                    ref.read(ttsServiceProvider).speak(
                          'वीडियो कॉल शुरू हो रहा है...',
                        );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Starting Video Call with ${patient.ashaName}...'),
                        backgroundColor: const Color(0xFF8B5CF6),
                      ),
                    );
                  },
                  icon: Icons.videocam_rounded,
                  label: 'Video Baat',
                ),
              ),

              const SizedBox(height: 14),

              // Action 3: Message
              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0284C7),
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ).buildElevatedButton(
                  onPressed: () {
                    ref.read(ttsServiceProvider).speak(
                          'संदेश भेजा जा रहा है: कृपया घर आएं या संपर्क करें।',
                        );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Sent quick alert message to ASHA didi.'),
                        backgroundColor: Color(0xFF0284C7),
                      ),
                    );
                  },
                  icon: Icons.chat_rounded,
                  label: 'Message',
                ),
              ),

              const Spacer(),

              // Reassuring Footer
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF1F2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFECDD3)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.favorite_rounded, color: Color(0xFFE11D48), size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Wo hamesha aapke saath hain ❤️',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFBE123C),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

extension on ButtonStyle {
  Widget buildElevatedButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: this,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}
