import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ScreeningOption {
  final int score;
  final String label;
  final String labelHi;

  const ScreeningOption({
    required this.score,
    required this.label,
    required this.labelHi,
  });
}

class ScreeningQuestion {
  final String id;
  final int questionNumber;
  final int domainNumber;
  final String domainTitle;
  final String domainTitleHi;
  final String questionTitle;
  final String questionText;
  final String questionTextHi;
  final int maxScore;
  final List<ScreeningOption> options;

  const ScreeningQuestion({
    required this.id,
    required this.questionNumber,
    required this.domainNumber,
    required this.domainTitle,
    required this.domainTitleHi,
    required this.questionTitle,
    required this.questionText,
    required this.questionTextHi,
    required this.maxScore,
    required this.options,
  });
}

class GameModelConfig {
  final int stage;
  final String stageLabel;
  final String clinicalStatus;
  final int itemCount;
  final int timerSeconds;
  final String gameDifficultyMode;
  final String systemBehaviorSummary;
  final Color stageColor;

  const GameModelConfig({
    required this.stage,
    required this.stageLabel,
    required this.clinicalStatus,
    required this.itemCount,
    required this.timerSeconds,
    required this.gameDifficultyMode,
    required this.systemBehaviorSummary,
    required this.stageColor,
  });
}

class ScreeningResult {
  final int totalScore;
  final Map<String, int> scores;
  final GameModelConfig config;
  final DateTime completedAt;

  const ScreeningResult({
    required this.totalScore,
    required this.scores,
    required this.config,
    required this.completedAt,
  });

  static GameModelConfig evaluateStage(int totalScore) {
    if (totalScore >= 20) {
      return const GameModelConfig(
        stage: 0,
        stageLabel: 'Stage 0 — Normal',
        clinicalStatus: 'Normal Baseline',
        itemCount: 5,
        timerSeconds: 10,
        gameDifficultyMode: 'Standard Difficulty',
        systemBehaviorSummary: 'Baseline monitoring; standard game difficulty (5 items, 10s timer).',
        stageColor: Color(0xFF10B981),
      );
    } else if (totalScore >= 14) {
      return const GameModelConfig(
        stage: 1,
        stageLabel: 'Stage 1 — Mild (MCI)',
        clinicalStatus: 'Mild Cognitive Impairment (MCI)',
        itemCount: 4,
        timerSeconds: 12,
        gameDifficultyMode: 'Moderate Difficulty',
        systemBehaviorSummary: 'Heightened trend sensitivity; moderate difficulty (4 items, 12s timer).',
        stageColor: Color(0xFFF59E0B),
      );
    } else if (totalScore >= 8) {
      return const GameModelConfig(
        stage: 2,
        stageLabel: 'Stage 2 — Moderate',
        clinicalStatus: 'Moderate Dementia',
        itemCount: 3,
        timerSeconds: 15,
        gameDifficultyMode: 'Simplified Gameplay',
        systemBehaviorSummary: 'Close ASHA follow-up; simplified gameplay (3 items, 15s timer).',
        stageColor: Color(0xFFF97316),
      );
    } else {
      return const GameModelConfig(
        stage: 3,
        stageLabel: 'Stage 3 — Severe',
        clinicalStatus: 'Severe Dementia',
        itemCount: 3,
        timerSeconds: 20,
        gameDifficultyMode: 'Voice-Only Assistive Mode',
        systemBehaviorSummary: 'Immediate ASHA/clinical referral; voice-only assistive mode.',
        stageColor: Color(0xFFEF4444),
      );
    }
  }
}

class CognitiveScreeningService {
  static const List<ScreeningQuestion> questions = [
    // Domain 1: Orientation (Time & Place) (3 Qs | 6 Pts)
    ScreeningQuestion(
      id: 'q1',
      questionNumber: 1,
      domainNumber: 1,
      domainTitle: 'Domain 1: Orientation (Time & Place)',
      domainTitleHi: 'डोमेन 1: दिशाज्ञान (समय और स्थान)',
      questionTitle: 'Q1: Temporal Orientation (Day / Season)',
      questionText: '"Aaj kaun sa din hai ya kaun sa mausam/samay chal raha hai?"',
      questionTextHi: 'आज कौन सा दिन है या कौन सा मौसम/समय चल रहा है?',
      maxScore: 2,
      options: [
        ScreeningOption(score: 2, label: '2 Pts — Exact day / season', labelHi: '2 अंक — सटीक दिन या मौसम'),
        ScreeningOption(score: 1, label: '1 Pt — Approximation', labelHi: '1 अंक — लगभग सही / अनुमानित'),
        ScreeningOption(score: 0, label: '0 Pts — Incorrect / Disoriented', labelHi: '0 अंक — गलत उत्तर / भ्रमित'),
      ],
    ),
    ScreeningQuestion(
      id: 'q2',
      questionNumber: 2,
      domainNumber: 1,
      domainTitle: 'Domain 1: Orientation (Time & Place)',
      domainTitleHi: 'डोमेन 1: दिशाज्ञान (समय और स्थान)',
      questionTitle: 'Q2: Spatial Orientation (Village / Location)',
      questionText: '"Aap abhi kis gaon/mohalle ya ghar mein hain?"',
      questionTextHi: 'आप अभी किस गाँव/मोहल्ले या घर में हैं?',
      maxScore: 2,
      options: [
        ScreeningOption(score: 2, label: '2 Pts — Correct village / location', labelHi: '2 अंक — सही गाँव या स्थान'),
        ScreeningOption(score: 0, label: '0 Pts — Disoriented / Incorrect', labelHi: '0 अंक — गलत स्थान / भ्रमित'),
      ],
    ),
    ScreeningQuestion(
      id: 'q3',
      questionNumber: 3,
      domainNumber: 1,
      domainTitle: 'Domain 1: Orientation (Time & Place)',
      domainTitleHi: 'डोमेन 1: दिशाज्ञान (समय और स्थान)',
      questionTitle: 'Q3: Route & Spatial Recall',
      questionText: '"Bazaar/khet se ghar aane ka rasta yaad hai? Aap kis taraf se aate hain?"',
      questionTextHi: 'बाज़ार/खेत से घर आने का रास्ता याद है? आप किस तरफ से आते हैं?',
      maxScore: 2,
      options: [
        ScreeningOption(score: 2, label: '2 Pts — Describes landmarks / route clearly', labelHi: '2 अंक — स्पष्ट रास्ता बताया'),
        ScreeningOption(score: 1, label: '1 Pt — Hesitant / partial description', labelHi: '1 अंक — हिचकिचाहट / अधूरा'),
        ScreeningOption(score: 0, label: '0 Pts — Cannot recall route', labelHi: '0 अंक — याद नहीं है'),
      ],
    ),

    // Domain 2: Memory (Registration, Delayed Recall & Recognition) (3 Qs | 6 Pts)
    ScreeningQuestion(
      id: 'q4',
      questionNumber: 4,
      domainNumber: 2,
      domainTitle: 'Domain 2: Memory (Registration & Recall)',
      domainTitleHi: 'डोमेन 2: स्मरण शक्ति (पंजीकरण और स्मरण)',
      questionTitle: 'Q4: Immediate 3-Item Registration',
      questionText: '"Main aapko 3 cheezein bol raha hoon: Chai, Chaabi, Chashma. Inhein dohraiye."',
      questionTextHi: 'मैं आपको 3 चीज़ें बोल रहा हूँ: चाय, चाबी, चश्मा। इन्हें दोहराइए।',
      maxScore: 2,
      options: [
        ScreeningOption(score: 2, label: '2 Pts — Repeats all 3 items correctly', labelHi: '2 अंक — तीनों शब्द सही दोहराए'),
        ScreeningOption(score: 1, label: '1 Pt — Repeats 1–2 items', labelHi: '1 अंक — 1 या 2 शब्द दोहराए'),
        ScreeningOption(score: 0, label: '0 Pts — Cannot repeat any item', labelHi: '0 अंक — एक भी नहीं दोहरा सके'),
      ],
    ),
    ScreeningQuestion(
      id: 'q5',
      questionNumber: 5,
      domainNumber: 2,
      domainTitle: 'Domain 2: Memory (Registration & Recall)',
      domainTitleHi: 'डोमेन 2: स्मरण शक्ति (पंजीकरण और स्मरण)',
      questionTitle: 'Q5: Delayed 3-Item Recall (After 2–3 mins)',
      questionText: '"Abhi thodi der pehle jo 3 cheezein batayi thi, unke naam bataiye?"',
      questionTextHi: 'अभी थोड़ी देर पहले जो 3 चीज़ें बताई थीं (चाय, चाबी, चश्मा), उनके नाम बताइए?',
      maxScore: 2,
      options: [
        ScreeningOption(score: 2, label: '2 Pts — Recalls all 3 without cue', labelHi: '2 अंक — बिना इशारे तीनों याद हैं'),
        ScreeningOption(score: 1, label: '1 Pt — Recalls 1–2 with category cue', labelHi: '1 अंक — संकेत मिलने पर 1-2 याद आए'),
        ScreeningOption(score: 0, label: '0 Pts — Cannot recall', labelHi: '0 अंक — याद नहीं आ सका'),
      ],
    ),
    ScreeningQuestion(
      id: 'q6',
      questionNumber: 6,
      domainNumber: 2,
      domainTitle: 'Domain 2: Memory (Registration & Recall)',
      domainTitleHi: 'डोमेन 2: स्मरण शक्ति (पंजीकरण और स्मरण)',
      questionTitle: 'Q6: Autobiographical & Family Recall',
      questionText: '"Yeh photo/aawaz pehchaniye — yeh parivaar mein kaun hain?"',
      questionTextHi: 'यह फोटो/आवाज़ पहचानिए — यह परिवार में कौन हैं?',
      maxScore: 2,
      options: [
        ScreeningOption(score: 2, label: '2 Pts — Immediate recognition', labelHi: '2 अंक — तुरंत पहचान लिया'),
        ScreeningOption(score: 1, label: '1 Pt — Recognizes after hint', labelHi: '1 अंक — हिंट मिलने पर पहचाना'),
        ScreeningOption(score: 0, label: '0 Pts — Unfamiliar / Unrecognized', labelHi: '0 अंक — नहीं पहचान सके'),
      ],
    ),

    // Domain 3: Attention & Working Memory (2 Qs | 4 Pts)
    ScreeningQuestion(
      id: 'q7',
      questionNumber: 7,
      domainNumber: 3,
      domainTitle: 'Domain 3: Attention & Working Memory',
      domainTitleHi: 'डोमेन 3: ध्यान और कार्यशील स्मृति',
      questionTitle: 'Q7: Sequential / Routine Reverse Recall',
      questionText: '"Hafte ke dino ke naam ya 1 se 5 tak ginti ulte kram mein bataiye (5, 4, 3, 2, 1)?"',
      questionTextHi: 'हफ़्ते के दिनों के नाम या 1 से 5 तक गिनती उल्टे क्रम में बताइए (5, 4, 3, 2, 1)?',
      maxScore: 2,
      options: [
        ScreeningOption(score: 2, label: '2 Pts — Full reverse sequence correct', labelHi: '2 अंक — पूरा उल्टा क्रम सही बताया'),
        ScreeningOption(score: 1, label: '1 Pt — 1 error or hesitation', labelHi: '1 अंक — 1 गलती या हिचकिचाहट'),
        ScreeningOption(score: 0, label: '0 Pts — Unable to follow', labelHi: '0 अंक — नहीं कर सके'),
      ],
    ),
    ScreeningQuestion(
      id: 'q8',
      questionNumber: 8,
      domainNumber: 3,
      domainTitle: 'Domain 3: Attention & Working Memory',
      domainTitleHi: 'डोमेन 3: ध्यान और कार्यशील स्मृति',
      questionTitle: 'Q8: Simple Market Transaction / Estimation',
      questionText: '"Agar aapke paas 10 rupaye hain aur 4 rupaye ki chai li, toh kitne bachenge?"',
      questionTextHi: 'अगर आपके पास ₹10 हैं और ₹4 की चाय ली, तो कितने बचेंगे?',
      maxScore: 2,
      options: [
        ScreeningOption(score: 2, label: '2 Pts — Correct answer (₹6)', labelHi: '2 अंक — सटीक उत्तर (₹6)'),
        ScreeningOption(score: 1, label: '1 Pt — Close approximation', labelHi: '1 अंक — लगभग सही उत्तर'),
        ScreeningOption(score: 0, label: '0 Pts — Unable / Incorrect', labelHi: '0 अंक — गलत या उत्तर देने में असमर्थ'),
      ],
    ),

    // Domain 4: Language & Comprehension (2 Qs | 4 Pts)
    ScreeningQuestion(
      id: 'q9',
      questionNumber: 9,
      domainNumber: 4,
      domainTitle: 'Domain 4: Language & Comprehension',
      domainTitleHi: 'डोमेन 4: भाषा और समझ',
      questionTitle: 'Q9: Visual Object Naming',
      questionText: '"Yeh kaun si cheez hai?" (ASHA points to 2 objects: e.g. watch, comb, cup)',
      questionTextHi: 'यह कौन सी चीज़ है? (आशा दीदी 2 वस्तुओं जैसे घड़ी, कंधी या कप की तरफ इशारा करती हैं)',
      maxScore: 2,
      options: [
        ScreeningOption(score: 2, label: '2 Pts — Names both objects correctly', labelHi: '2 अंक — दोनों वस्तुओं का सही नाम बताया'),
        ScreeningOption(score: 1, label: '1 Pt — Names 1 object correctly', labelHi: '1 अंक — 1 वस्तु का नाम बताया'),
        ScreeningOption(score: 0, label: '0 Pts — Word-finding difficulty / Cannot name', labelHi: '0 अंक — नाम बताने में असमर्थ'),
      ],
    ),
    ScreeningQuestion(
      id: 'q10',
      questionNumber: 10,
      domainNumber: 4,
      domainTitle: 'Domain 4: Language & Comprehension',
      domainTitleHi: 'डोमेन 4: भाषा और समझ',
      questionTitle: 'Q10: 2-Step Motor Command Execution',
      questionText: '"Kripya yeh kagaz uthaiye aur samne mez/chaarpai par rakhiye."',
      questionTextHi: 'कृपया यह कागज़ उठाइए और सामने मेज़ या चारपाई पर रखिए।',
      maxScore: 2,
      options: [
        ScreeningOption(score: 2, label: '2 Pts — Executes both steps smoothly', labelHi: '2 अंक — दोनों कदम आसानी से पूरे किए'),
        ScreeningOption(score: 1, label: '1 Pt — Executes only 1 step', labelHi: '1 अंक — केवल 1 कदम पूरा किया'),
        ScreeningOption(score: 0, label: '0 Pts — Cannot follow command', labelHi: '0 अंक — निर्देश का पालन नहीं कर सके'),
      ],
    ),

    // Domain 5: Executive Function & Daily Living (ADLs) (2 Qs | 4 Pts)
    ScreeningQuestion(
      id: 'q11',
      questionNumber: 11,
      domainNumber: 5,
      domainTitle: 'Domain 5: Executive Function & Daily Living',
      domainTitleHi: 'डोमेन 5: निर्णय क्षमता और दैनिक जीवन कार्य',
      questionTitle: 'Q11: Independent Daily Activity (ADL / Self-Care)',
      questionText: '"Kya aap bina kisi ki madad ke kapde pehenna aur dawa samay par lena kar lete hain?"',
      questionTextHi: 'क्या आप बिना किसी की मदद के कपड़े पहनना और दवा समय पर लेना कर लेते हैं?',
      maxScore: 2,
      options: [
        ScreeningOption(score: 2, label: '2 Pts — Completely independent', labelHi: '2 अंक — पूर्णतः स्वतंत्र'),
        ScreeningOption(score: 1, label: '1 Pt — Needs occasional prompting', labelHi: '1 अंक — कभी-कभी याद दिलाने की आवश्यकता'),
        ScreeningOption(score: 0, label: '0 Pts — Requires full assistance', labelHi: '0 अंक — पूर्ण सहायता की आवश्यकता'),
      ],
    ),
    ScreeningQuestion(
      id: 'q12',
      questionNumber: 12,
      domainNumber: 5,
      domainTitle: 'Domain 5: Executive Function & Daily Living',
      domainTitleHi: 'डोमेन 5: निर्णय क्षमता और दैनिक जीवन कार्य',
      questionTitle: 'Q12: Practical Situational Problem Solving',
      questionText: '"Agar aap raste mein ho aur achanak tez baarish shuru ho jaye, toh aap kya karenge?"',
      questionTextHi: 'अगर आप रास्ते में हों और अचानक तेज़ बारिश शुरू हो जाए, तो आप क्या करेंगे?',
      maxScore: 2,
      options: [
        ScreeningOption(score: 2, label: '2 Pts — Logical response (Find shelter / umbrella)', labelHi: '2 अंक — तार्किक उत्तर (छाँव में रुकना / छतरी लेना)'),
        ScreeningOption(score: 0, label: '0 Pts — Illogical or no response', labelHi: '0 अंक — अतार्किक या कोई उत्तर नहीं'),
      ],
    ),
  ];

  static ScreeningResult calculateResult(Map<String, int> scores) {
    int total = 0;
    for (final q in questions) {
      total += scores[q.id] ?? 0;
    }
    final config = ScreeningResult.evaluateStage(total);
    return ScreeningResult(
      totalScore: total,
      scores: Map.unmodifiable(scores),
      config: config,
      completedAt: DateTime.now(),
    );
  }
}

class CognitiveScreeningNotifier extends StateNotifier<ScreeningResult?> {
  CognitiveScreeningNotifier()
      : super(
          CognitiveScreeningService.calculateResult({
            'q1': 2,
            'q2': 2,
            'q3': 1,
            'q4': 2,
            'q5': 1,
            'q6': 2,
            'q7': 1,
            'q8': 2,
            'q9': 2,
            'q10': 1,
            'q11': 1,
            'q12': 0,
          }), // Default sample baseline result (18 pts -> Stage 1)
        );

  void submitScreening(Map<String, int> scores) {
    state = CognitiveScreeningService.calculateResult(scores);
  }
}

final cognitiveScreeningProvider =
    StateNotifierProvider<CognitiveScreeningNotifier, ScreeningResult?>((ref) {
  return CognitiveScreeningNotifier();
});
