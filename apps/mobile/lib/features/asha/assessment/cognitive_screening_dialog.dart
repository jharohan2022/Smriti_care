import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/cognitive_screening_service.dart';
import '../../../core/services/tts_service.dart';

class CognitiveScreeningModal extends ConsumerStatefulWidget {
  const CognitiveScreeningModal({
    super.key,
    this.patientName,
    this.onCompleted,
  });

  final String? patientName;
  final ValueChanged<ScreeningResult>? onCompleted;

  static Future<ScreeningResult?> show(
    BuildContext context, {
    String? patientName,
  }) {
    return showModalBottomSheet<ScreeningResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CognitiveScreeningModal(patientName: patientName),
    );
  }

  @override
  ConsumerState<CognitiveScreeningModal> createState() => _CognitiveScreeningModalState();
}

class _CognitiveScreeningModalState extends ConsumerState<CognitiveScreeningModal> {
  int _currentIndex = 0;
  final Map<String, int> _answers = {};
  bool _isFinished = false;
  ScreeningResult? _finalResult;

  @override
  void initState() {
    super.initState();
    // Default initialize all questions to max score (2) for convenience
    for (final q in CognitiveScreeningService.questions) {
      _answers[q.id] = 2;
    }
  }

  void _speakQuestion(ScreeningQuestion q) {
    final tts = ref.read(ttsServiceProvider);
    tts.speak(
      '${q.questionTitle}. ${q.questionTextHi}',
      langCode: 'hi',
    );
  }

  void _nextQuestion() {
    if (_currentIndex < CognitiveScreeningService.questions.length - 1) {
      setState(() {
        _currentIndex++;
      });
      _speakQuestion(CognitiveScreeningService.questions[_currentIndex]);
    } else {
      _finishAssessment();
    }
  }

  void _prevQuestion() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
      _speakQuestion(CognitiveScreeningService.questions[_currentIndex]);
    }
  }

  void _finishAssessment() {
    final result = CognitiveScreeningService.calculateResult(_answers);
    ref.read(cognitiveScreeningProvider.notifier).submitScreening(_answers);

    setState(() {
      _isFinished = true;
      _finalResult = result;
    });

    if (widget.onCompleted != null) {
      widget.onCompleted!(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final questions = CognitiveScreeningService.questions;
    final currentQ = questions[_currentIndex];
    final patientDisplayName = widget.patientName ?? 'Buzurg (मरीज़)';

    const brandEmerald = Color(0xFF059669);
    const textDark = Color(0xFF0F172A);

    int totalLiveScore = 0;
    for (final score in _answers.values) {
      totalLiveScore += score;
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Header Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: const BoxDecoration(
              color: Color(0xFFF1F5F9),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: brandEmerald.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.psychology_rounded, color: brandEmerald, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '12-Question Cognitive Screening',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: textDark),
                      ),
                      Text(
                        'Patient: $patientDisplayName • NER Protocol',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context, _finalResult),
                ),
              ],
            ),
          ),

          Expanded(
            child: _isFinished ? _buildResultView(brandEmerald, textDark) : _buildQuestionView(currentQ, questions.length, totalLiveScore, brandEmerald, textDark),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionView(ScreeningQuestion currentQ, int totalQuestions, int totalLiveScore, Color brandEmerald, Color textDark) {
    final selectedScore = _answers[currentQ.id] ?? 2;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress & Score Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFA7F3D0)),
                ),
                child: Text(
                  'Question ${_currentIndex + 1} / $totalQuestions',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF065F46)),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Text(
                  'Score: $totalLiveScore / 24 Pts',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF92400E)),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Linear Progress Indicator
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (_currentIndex + 1) / totalQuestions,
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor: AlwaysStoppedAnimation<Color>(brandEmerald),
              minHeight: 6,
            ),
          ),

          const SizedBox(height: 16),

          // Domain Header Badge
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFBFDBFE)),
            ),
            child: Text(
              '${currentQ.domainTitleHi} (${currentQ.domainTitle})',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF1E40AF)),
            ),
          ),

          const SizedBox(height: 14),

          // Question Title & Text
          Text(
            currentQ.questionTitle,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: textDark),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentQ.questionTextHi,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF0F172A), height: 1.3),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        currentQ.questionText,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () => _speakQuestion(currentQ),
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Color(0xFFECFDF5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.volume_up_rounded, color: Color(0xFF059669), size: 24),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          const Text(
            'Patient Ka Uttar (Select Patient Score):',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF475569)),
          ),
          const SizedBox(height: 8),

          // Options List
          Expanded(
            child: ListView.separated(
              itemCount: currentQ.options.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final option = currentQ.options[index];
                final isSelected = selectedScore == option.score;

                return InkWell(
                  onTap: () {
                    setState(() {
                      _answers[currentQ.id] = option.score;
                    });
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFECFDF5) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? brandEmerald : const Color(0xFFCBD5E1),
                        width: isSelected ? 2.5 : 1.2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                          color: isSelected ? brandEmerald : const Color(0xFF94A3B8),
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                option.labelHi,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: isSelected ? const Color(0xFF065F46) : textDark,
                                ),
                              ),
                              Text(
                                option.label,
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF64748B)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Navigation Controls
          Row(
            children: [
              if (_currentIndex > 0)
                Expanded(
                  child: OutlinedButton(
                    onPressed: _prevQuestion,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Peechhe (Back)'),
                  ),
                ),
              if (_currentIndex > 0) const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _nextQuestion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brandEmerald,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 2,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _currentIndex == totalQuestions - 1 ? 'Finish & Evaluate Baseline' : 'Aage Badhien (Next)',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(width: 6),
                      Icon(_currentIndex == totalQuestions - 1 ? Icons.check_circle_rounded : Icons.arrow_forward_rounded, size: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultView(Color brandEmerald, Color textDark) {
    final result = _finalResult!;
    final config = result.config;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: config.stageColor.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.verified_rounded, color: config.stageColor, size: 54),
          ),
          const SizedBox(height: 14),

          Text(
            'Baseline Assessment Complete!',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: textDark),
          ),
          const SizedBox(height: 6),
          Text(
            'Total Score: ${result.totalScore} / 24 Points',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: config.stageColor),
          ),

          const SizedBox(height: 18),

          // Stage Badge Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: config.stageColor, width: 2),
              boxShadow: [
                BoxShadow(
                  color: config.stageColor.withOpacity(0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: config.stageColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    config.stageLabel,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Clinical Status: ${config.clinicalStatus}',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
                ),
                const SizedBox(height: 6),
                Text(
                  config.systemBehaviorSummary,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Automated Game Machine Learning Sensitivity Parameters
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Automated Game Difficulty Parameters:',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF334155)),
                ),
                const SizedBox(height: 10),
                _buildConfigRow('Target Items Count:', '${config.itemCount} Items'),
                _buildConfigRow('Game Response Timer:', '${config.timerSeconds} Seconds'),
                _buildConfigRow('Gameplay Mode:', config.gameDifficultyMode),
              ],
            ),
          ),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context, result),
              style: ElevatedButton.styleFrom(
                backgroundColor: brandEmerald,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 3,
              ),
              child: const Text(
                'Confirm & Apply Patient Stage',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfigRow(String title, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
          Text(val, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
        ],
      ),
    );
  }
}
