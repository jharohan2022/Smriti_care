import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/tts_service.dart';
import 'widgets/game_completion_dialog.dart';

class BazaarItem {
  final String id;
  final String titleHi;
  final String titleEn;
  final int price;
  final String iconEmoji;

  const BazaarItem({
    required this.id,
    required this.titleHi,
    required this.titleEn,
    required this.price,
    required this.iconEmoji,
  });
}

class BazaarTask {
  final String promptHi;
  final String promptEn;
  final int totalBudget;
  final List<String> requiredItemIds;
  final int expectedRemainingBalance;
  final List<int> balanceOptions;

  const BazaarTask({
    required this.promptHi,
    required this.promptEn,
    required this.totalBudget,
    required this.requiredItemIds,
    required this.expectedRemainingBalance,
    required this.balanceOptions,
  });
}

class MeraBazaarGameScreen extends ConsumerStatefulWidget {
  const MeraBazaarGameScreen({super.key});

  @override
  ConsumerState<MeraBazaarGameScreen> createState() => _MeraBazaarGameScreenState();
}

class _MeraBazaarGameScreenState extends ConsumerState<MeraBazaarGameScreen> {
  static const List<BazaarItem> _storeItems = [
    BazaarItem(id: 'tea', titleHi: 'चाय (Tea)', titleEn: 'Tea', price: 4, iconEmoji: '☕'),
    BazaarItem(id: 'rice', titleHi: 'चावल (Rice)', titleEn: 'Rice', price: 10, iconEmoji: '🍚'),
    BazaarItem(id: 'banana', titleHi: 'केला (Banana)', titleEn: 'Banana', price: 5, iconEmoji: '🍌'),
    BazaarItem(id: 'jaggery', titleHi: 'गुड़ (Jaggery)', titleEn: 'Jaggery', price: 6, iconEmoji: '🧈'),
    BazaarItem(id: 'soap', titleHi: 'साबुन (Soap)', titleEn: 'Soap', price: 8, iconEmoji: '🧼'),
  ];

  static const List<BazaarTask> _tasks = [
    BazaarTask(
      promptHi: 'आपके पास ₹10 हैं। आपने ₹4 की गरम चाय खरीदी। अब आपके पास कितने रुपये बचेंगे?',
      promptEn: 'You have ₹10. You bought tea for ₹4. How much money remains?',
      totalBudget: 10,
      requiredItemIds: ['tea'],
      expectedRemainingBalance: 6,
      balanceOptions: [6, 4, 8, 2],
    ),
    BazaarTask(
      promptHi: 'आपके पास ₹20 हैं। आपने ₹10 का चावल और ₹5 का केला खरीदा। कुल कितने रुपये बचेंगे?',
      promptEn: 'You have ₹20. You bought rice for ₹10 and banana for ₹5. How much money remains?',
      totalBudget: 20,
      requiredItemIds: ['rice', 'banana'],
      expectedRemainingBalance: 5,
      balanceOptions: [5, 10, 8, 15],
    ),
    BazaarTask(
      promptHi: 'आपके पास ₹15 हैं। आपने ₹6 का गुड़ और ₹4 की चाय खरीदी। कुल कितने रुपये बचेंगे?',
      promptEn: 'You have ₹15. You bought jaggery for ₹6 and tea for ₹4. How much money remains?',
      totalBudget: 15,
      requiredItemIds: ['jaggery', 'tea'],
      expectedRemainingBalance: 5,
      balanceOptions: [5, 7, 9, 3],
    ),
  ];

  int _currentTaskIndex = 0;
  int? _selectedBalance;
  int _score = 0;

  @override
  void initState() {
    super.initState();
    _playTaskPrompt();
  }

  void _playTaskPrompt() {
    final task = _tasks[_currentTaskIndex];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(ttsServiceProvider).speak(task.promptHi, langCode: 'hi');
    });
  }

  void _selectBalance(int bal) {
    setState(() {
      _selectedBalance = bal;
    });
  }

  void _submitAnswer() {
    if (_selectedBalance == null) return;
    final task = _tasks[_currentTaskIndex];

    if (_selectedBalance == task.expectedRemainingBalance) {
      _score += 10;
      ref.read(ttsServiceProvider).speak('बहुत बढ़िया! सही हिसाब लगाया। ₹${task.expectedRemainingBalance} बचेंगे।', langCode: 'hi');
    } else {
      ref.read(ttsServiceProvider).speak('कोई बात नहीं, सही उत्तर ₹${task.expectedRemainingBalance} था।', langCode: 'hi');
    }

    if (_currentTaskIndex < _tasks.length - 1) {
      setState(() {
        _currentTaskIndex++;
        _selectedBalance = null;
      });
      _playTaskPrompt();
    } else {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => GameCompletionDialog(
          title: 'Mera Bazaar (मेरा बाज़ार)',
          subtitle: 'शानदार! आपने बाज़ार की खरीदारी पूरी कर ली।',
          stars: 3,
          onPlayAgain: () {
            setState(() {
              _currentTaskIndex = 0;
              _selectedBalance = null;
              _score = 0;
            });
            _playTaskPrompt();
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const brandOrange = Color(0xFFF57C00);
    const textDark = Color(0xFF0F172A);
    final task = _tasks[_currentTaskIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFFFF7ED),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, size: 28, color: textDark),
          onPressed: () => context.go('/khel'),
        ),
        title: const Text(
          'Mera Bazaar (मेरा बाज़ार)',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: textDark),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.volume_up_rounded, color: brandOrange, size: 28),
            onPressed: _playTaskPrompt,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Market Header Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF97316), Color(0xFFC2410C)],
                  ),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: brandOrange.withOpacity(0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.white24,
                      child: Text('🛒', style: TextStyle(fontSize: 32)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Task ${_currentTaskIndex + 1} of ${_tasks.length}',
                            style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Total Budget: ₹${task.totalBudget}',
                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Task Prompt Box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFFED7AA)),
                ),
                child: Text(
                  task.promptHi,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: textDark, height: 1.35),
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                'Bazaar Rate Card (बाज़ार रेट कार्ड):',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF475569)),
              ),
              const SizedBox(height: 8),

              // Horizontal Store Price Items List
              SizedBox(
                height: 72,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _storeItems.length,
                  itemBuilder: (context, idx) {
                    final item = _storeItems[idx];
                    return Container(
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFFED7AA)),
                      ),
                      child: Row(
                        children: [
                          Text(item.iconEmoji, style: const TextStyle(fontSize: 26)),
                          const SizedBox(width: 8),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.titleHi.split(' ')[0], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                              Text('₹${item.price}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: brandOrange)),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Kitne rupaye bachenge? (Select Remaining Balance):',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF475569)),
              ),

              const SizedBox(height: 12),

              // Options Grid
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.8,
                  ),
                  itemCount: task.balanceOptions.length,
                  itemBuilder: (context, idx) {
                    final bal = task.balanceOptions[idx];
                    final isSel = _selectedBalance == bal;

                    return InkWell(
                      onTap: () => _selectBalance(bal),
                      borderRadius: BorderRadius.circular(18),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSel ? const Color(0xFFFFEDD5) : Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isSel ? brandOrange : const Color(0xFFE2E8F0),
                            width: isSel ? 2.5 : 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '₹$bal Bachenge',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: isSel ? brandOrange : textDark,
                            ),
                          ),
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
                  onPressed: _selectedBalance != null ? _submitAnswer : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brandOrange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Confirm Purchase (खरीदारी की पुष्टि)', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
