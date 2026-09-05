import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/family_members_service.dart';
import '../../../core/services/tts_service.dart';
import 'widgets/game_completion_dialog.dart';

class MemoryTreeGameScreen extends ConsumerStatefulWidget {
  const MemoryTreeGameScreen({super.key});

  @override
  ConsumerState<MemoryTreeGameScreen> createState() => _MemoryTreeGameScreenState();
}

class _MemoryTreeGameScreenState extends ConsumerState<MemoryTreeGameScreen> {
  int _currentIndex = 0;
  String? _selectedRelation;
  int _score = 0;

  final List<Map<String, String>> _relationOptions = const [
    {'relation': 'Beta (बेटा)', 'hi': 'आपका बेटा'},
    {'relation': 'Beti (बेटी)', 'hi': 'आपकी बेटी'},
    {'relation': 'Pota / Poti (पोता/पोती)', 'hi': 'आपका पोता / पोती'},
    {'relation': 'Patni / Pati (जीवनसाथी)', 'hi': 'आपका जीवनसाथी'},
  ];

  @override
  void initState() {
    super.initState();
    _playAudioPrompt();
  }

  void _playAudioPrompt() {
    final members = ref.read(familyMembersProvider);
    if (members.isNotEmpty && _currentIndex < members.length) {
      final m = members[_currentIndex];
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(ttsServiceProvider).speak(
              'यह फोटो ध्यान से देखिए। यह ${m.name} हैं। यह आपके परिवार में कौन हैं?',
              langCode: 'hi',
            );
      });
    }
  }

  Widget _buildMemberImage(FamilyMember member) {
    if (member.photoPath != null && member.photoPath!.isNotEmpty) {
      if (member.photoPath!.startsWith('assets/')) {
        return Image.asset(member.photoPath!, fit: BoxFit.cover);
      } else {
        final f = File(member.photoPath!);
        if (f.existsSync()) {
          return Image.file(f, fit: BoxFit.cover);
        }
      }
    }
    return Container(
      color: member.avatarColor.withOpacity(0.2),
      child: Icon(member.icon, color: member.avatarColor, size: 64),
    );
  }

  void _submitAnswer(FamilyMember currentMember) {
    if (_selectedRelation == null) return;

    if (_selectedRelation!.toLowerCase().contains(currentMember.relation.toLowerCase()) ||
        currentMember.relation.toLowerCase().contains(_selectedRelation!.toLowerCase())) {
      _score += 10;
      ref.read(ttsServiceProvider).speak('बहुत सुंदर! आपने ${currentMember.name} को सही पहचाना।', langCode: 'hi');
    } else {
      ref.read(ttsServiceProvider).speak('यह ${currentMember.name} हैं, आपके ${currentMember.relation}।', langCode: 'hi');
    }

    final members = ref.read(familyMembersProvider);
    if (_currentIndex < members.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedRelation = null;
      });
      _playAudioPrompt();
    } else {
      final totalMax = members.length * 10;
      final finalPercentage = (totalMax > 0) ? (_score * 10 / totalMax).round() : 10;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => GameCompletionDialog(
          gameTitle: 'Memory Tree (परिवार पहचान)',
          score: finalPercentage,
          onPlayAgain: () {
            Navigator.pop(ctx);
            setState(() {
              _currentIndex = 0;
              _selectedRelation = null;
              _score = 0;
            });
            _playAudioPrompt();
          },
          onNextGame: () {
            Navigator.pop(ctx);
            context.go('/game/mera-bazaar');
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const brandPink = Color(0xFFE91E63);
    const textDark = Color(0xFF0F172A);
    final members = ref.watch(familyMembersProvider);

    if (members.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Memory Tree')),
        body: const Center(child: Text('No family members registered yet.')),
      );
    }

    final currentMember = members[_currentIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFFDF2F8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, size: 28, color: textDark),
          onPressed: () => context.go('/khel'),
        ),
        title: const Text(
          'Memory Tree (परिवार पहचान)',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: textDark),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.volume_up_rounded, color: brandPink, size: 28),
            onPressed: _playAudioPrompt,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Memory Tree Header Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFEC4899), Color(0xFFBE185D)],
                  ),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 26,
                      backgroundColor: Colors.white24,
                      child: Icon(Icons.park_rounded, color: Colors.white, size: 30),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Member ${_currentIndex + 1} of ${members.length}',
                            style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            currentMember.name,
                            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Photo Container Frame
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFFBCFE8), width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: brandPink.withOpacity(0.12),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: _buildMemberImage(currentMember),
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Yeh aapke parivaar mein kaun hain? (Select Relation):',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF475569)),
              ),

              const SizedBox(height: 12),

              // Relationship Options Grid
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.6,
                  ),
                  itemCount: _relationOptions.length,
                  itemBuilder: (context, idx) {
                    final option = _relationOptions[idx];
                    final isSel = _selectedRelation == option['relation'];

                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedRelation = option['relation'];
                        });
                      },
                      borderRadius: BorderRadius.circular(18),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSel ? const Color(0xFFFCE7F3) : Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isSel ? brandPink : const Color(0xFFF472B6).withOpacity(0.3),
                            width: isSel ? 2.5 : 1,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              option['hi']!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                color: isSel ? brandPink : textDark,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              option['relation']!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _selectedRelation != null ? () => _submitAnswer(currentMember) : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brandPink,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Confirm Relation (पहचान की पुष्टि करें)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
