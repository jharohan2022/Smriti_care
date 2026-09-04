import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AshaResultsScreen extends StatelessWidget {
  const AshaResultsScreen({super.key});

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
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Analysis Result',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: textDark,
                ),
              ),

              const SizedBox(height: 20),

              // Status 1: STABLE
              _buildStatusCard(
                title: 'STABLE',
                description: 'Sab kuch theek hai. Regular practice jaari rakhein.',
                icon: Icons.check_circle_rounded,
                iconColor: const Color(0xFF10B981),
                bgColor: const Color(0xFFECFDF5),
                borderColor: const Color(0xFFA7F3D0),
                isSelected: false,
              ),

              const SizedBox(height: 14),

              // Status 2: MONITOR (Current Active)
              _buildStatusCard(
                title: 'MONITOR',
                description: 'Halke parivartan dikhe hain. Niyamit nazar rakhein.',
                icon: Icons.warning_amber_rounded,
                iconColor: const Color(0xFFD97706),
                bgColor: const Color(0xFFFFFBEB),
                borderColor: const Color(0xFFFDE68A),
                isSelected: true,
              ),

              const SizedBox(height: 14),

              // Status 3: NEEDS ATTENTION
              _buildStatusCard(
                title: 'NEEDS ATTENTION',
                description: 'Performance mein mahatvapurn girawat dikhi hai. ASHA review avashyak hai.',
                icon: Icons.error_rounded,
                iconColor: const Color(0xFFDC2626),
                bgColor: const Color(0xFFFEF2F2),
                borderColor: const Color(0xFFFECDD3),
                isSelected: false,
              ),

              const Spacer(),

              // Action Button: Dashboard Par Jayein ➔
              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: () {
                    context.go('/asha/dashboard');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: emeraldBrand,
                    foregroundColor: Colors.white,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Dashboard Par Jayein',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded, size: 22),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard({
    required String title,
    required String description,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required Color borderColor,
    required bool isSelected,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: borderColor,
          width: isSelected ? 2.5 : 1.2,
        ),
        boxShadow: [
          if (isSelected)
            BoxShadow(
              color: iconColor.withOpacity(0.12),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: iconColor,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF334155),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
