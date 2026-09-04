import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AshaBaselineScreen extends StatelessWidget {
  const AshaBaselineScreen({super.key});

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
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Vyaktigat Aadhar Taiyar',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: textDark,
                ),
              ),

              const SizedBox(height: 24),

              // Baseline Bar Chart Graphic Container
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
                    // Visual Chart Illustration
                    SizedBox(
                      height: 145,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _buildBar(height: 35, label: 'S1', color: const Color(0xFF94A3B8)),
                          _buildBar(height: 55, label: 'S2', color: const Color(0xFF38BDF8)),
                          _buildBar(height: 75, label: 'S3', color: const Color(0xFF34D399)),
                          _buildBar(height: 85, label: 'S4', color: emeraldBrand, hasBadge: true),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Pehle kuch sessions se vyaktigat\nperformance pattern taiyar kiya ja raha hai...',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF334155),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Personalized Reference Quote Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFA7F3D0)),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('💡', style: TextStyle(fontSize: 20)),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Har buzurg alag hote hain, isliye hum unka khud ka aadhar banate hain.',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF065F46),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Action Button: Performance Trend Analysis ➔
              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: () {
                    context.push('/asha/assessment/trend');
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
                        'Performance Analysis',
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

  Widget _buildBar({
    required double height,
    required String label,
    required Color color,
    bool hasBadge = false,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (hasBadge)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF059669),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text('Live', style: TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        const SizedBox(height: 4),
        Container(
          width: 38,
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
        ),
      ],
    );
  }
}
