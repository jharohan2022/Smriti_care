import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/tts_service.dart';

class DailyActivityItem {
  final String title;
  final String description;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final String voiceText;

  const DailyActivityItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.voiceText,
  });
}

class DailyActivitiesScreen extends ConsumerWidget {
  const DailyActivitiesScreen({super.key});

  static const List<DailyActivityItem> _activities = [
    DailyActivityItem(
      title: 'Thodi Walk Karein',
      description: 'Ghar ke aangan ya park mein 10 minute chaliye',
      icon: Icons.directions_walk_rounded,
      iconColor: Color(0xFF2563EB),
      bgColor: Color(0xFFEFF6FF),
      voiceText: 'थोड़ी वॉक करें! घर के आँगन या पार्क में दस मिनट ताज़ी हवा में टहलिए।',
    ),
    DailyActivityItem(
      title: 'Kahani Sunein',
      description: 'Panchatantra aur Dadi-Nani ki prerna-dayak kahaniyan',
      icon: Icons.auto_stories_rounded,
      iconColor: Color(0xFF059669),
      bgColor: Color(0xFFECFDF5),
      voiceText: 'कहानी सुनें! आज हम पंचतंत्र की प्रेरणादायक कहानी सुनेंगे।',
    ),
    DailyActivityItem(
      title: 'Geet Sunein',
      description: 'Purane madhur geet aur shanti bhajan',
      icon: Icons.music_note_rounded,
      iconColor: Color(0xFF9333EA),
      bgColor: Color(0xFFFAF5FF),
      voiceText: 'गीत सुनें! अपने मनपसंद पुराने मधुर गीत और भजन का आनंद लें।',
    ),
    DailyActivityItem(
      title: 'Saans ki Exercise',
      description: 'Pranayama aur gehri saans lene ka abhyas',
      icon: Icons.self_improvement_rounded,
      iconColor: Color(0xFF0284C7),
      bgColor: Color(0xFFF0F9FF),
      voiceText: 'साँस की कसरत! गहरी साँस अंदर लें... और धीरे-धीरे बाहर छोड़ें।',
    ),
    DailyActivityItem(
      title: 'Halki Yaadasht Khel',
      description: 'Doston aur parivar ke chehre pehchaniye',
      icon: Icons.extension_rounded,
      iconColor: Color(0xFFE11D48),
      bgColor: Color(0xFFFFF1F2),
      voiceText: 'हल्की याददाश्त खेल! चलिए परिवार और दोस्तों की तस्वीरें पहचानते हैं।',
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const brandPurple = Color(0xFF6B4EE6);
    const textDark = Color(0xFF1E1B4B);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: textDark, size: 28),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Aaj Kya Karein?',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: textDark,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            children: [
              Expanded(
                child: ListView.separated(
                  itemCount: _activities.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = _activities[index];

                    return GestureDetector(
                      onTap: () {
                        ref.read(ttsServiceProvider).speak(item.voiceText);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Selected: ${item.title}'),
                            backgroundColor: item.iconColor,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: item.bgColor,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(item.icon, color: item.iconColor, size: 26),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: textDark,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    item.description,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right_rounded,
                              color: Color(0xFF94A3B8),
                              size: 26,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 8),

              // Button to Move to Mood Check
              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: () {
                    context.push('/mood-check');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brandPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Mood Check Karein',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded, size: 22),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
