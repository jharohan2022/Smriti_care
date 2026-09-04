import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/tts_service.dart';

class AshaGameplayDataScreen extends ConsumerStatefulWidget {
  const AshaGameplayDataScreen({super.key});

  @override
  ConsumerState<AshaGameplayDataScreen> createState() => _AshaGameplayDataScreenState();
}

class _AshaGameplayDataScreenState extends ConsumerState<AshaGameplayDataScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(ttsServiceProvider).speak(
            'खेल पूरा हुआ! शाबाश! आपने आठ सही उत्तर दिए।',
          );
    });
  }

  @override
  Widget build(BuildContext context) {
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
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Khel Pura Hua!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: textDark,
                ),
              ),

              const SizedBox(height: 20),

              // Celebration Elder Avatar
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFA7F3D0), width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: emeraldBrand.withOpacity(0.12),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text('👴🎉', style: TextStyle(fontSize: 48)),
                ),
              ),

              const SizedBox(height: 24),

              // Telemetry Metrics Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildMetricRow(
                      icon: Icons.check_circle_outline_rounded,
                      color: const Color(0xFF10B981),
                      title: 'Sahi Uttar',
                      value: '8 / 10',
                    ),
                    const Divider(height: 24),
                    _buildMetricRow(
                      icon: Icons.timer_outlined,
                      color: const Color(0xFF3B82F6),
                      title: 'Samay',
                      value: '38 sec',
                    ),
                    const Divider(height: 24),
                    _buildMetricRow(
                      icon: Icons.search_rounded,
                      color: const Color(0xFFF59E0B),
                      title: 'Prayas',
                      value: '2',
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Action Button: Shabashi!
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () {
                    context.push('/asha/assessment/baseline');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: emeraldBrand,
                    foregroundColor: Colors.white,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text(
                    'Shabashi!',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Sync Status Badge
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.cloud_done_rounded, color: emeraldBrand, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      'Yeh jaankari surakshit roop se save ho gayi hai.',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF065F46).withOpacity(0.85),
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

  Widget _buildMetricRow({
    required IconData icon,
    required Color color,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF475569),
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }
}
