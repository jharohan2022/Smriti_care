import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/tts_service.dart';

class FriendlyGreetingScreen extends ConsumerStatefulWidget {
  const FriendlyGreetingScreen({super.key});

  @override
  ConsumerState<FriendlyGreetingScreen> createState() => _FriendlyGreetingScreenState();
}

class _FriendlyGreetingScreenState extends ConsumerState<FriendlyGreetingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isListening = false;

  final String _greetingText =
      'नमस्ते! मैं स्मरण हूँ आपका साथी। आज हम साथ में थोड़ा याद करेंगे, थोड़ा खेलेंगे, और दिन को बनाएंगे थोड़ा और खुश!';

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _speakGreeting();
    });
  }

  void _speakGreeting() {
    ref.read(ttsServiceProvider).speak(_greetingText);
  }

  void _handleMicTap() {
    setState(() {
      _isListening = true;
    });

    ref.read(ttsServiceProvider).speak('सुन रहा हूँ... बोलिए!');

    Future.delayed(const Duration(milliseconds: 2200), () {
      if (mounted) {
        setState(() {
          _isListening = false;
        });
        context.go('/home');
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const brandPurple = Color(0xFF6B4EE6);
    const softLavender = Color(0xFFF5F3FF);
    const textDark = Color(0xFF1E1B4B);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: textDark, size: 28),
          onPressed: () => context.go('/home'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.volume_up_rounded, color: brandPurple, size: 30),
            tooltip: 'बोलकर सुनाएं (Read aloud)',
            onPressed: _speakGreeting,
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Column(
            children: [
              const Spacer(flex: 1),

              // Cheerful Sun Graphic Container
              Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFEF3C7),
                  border: Border.all(color: const Color(0xFFFDE68A), width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF59E0B).withOpacity(0.2),
                      blurRadius: 20,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        '☀️',
                        style: TextStyle(fontSize: 54),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFBBF24),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'शुभ प्रभात',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF78350F),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Greeting Text Header & Description
              const Text(
                'Namaste!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Main Smarana hoon\nAapka saathi.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: brandPurple,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Aaj hum saath mein thoda yaad karenge, thoda khellenge, aur din ko banayenge thoda aur khush!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF4B5563),
                    height: 1.45,
                  ),
                ),
              ),

              const Spacer(flex: 2),

              // Big Circular Purple Mic Button: "Bas boliye..."
              Column(
                children: [
                  ScaleTransition(
                    scale: _pulseAnimation,
                    child: GestureDetector(
                      onTap: _handleMicTap,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isListening ? const Color(0xFFDC2626) : brandPurple,
                          boxShadow: [
                            BoxShadow(
                              color: (_isListening ? Colors.red : brandPurple).withOpacity(0.35),
                              blurRadius: 24,
                              spreadRadius: 6,
                            ),
                          ],
                        ),
                        child: Icon(
                          _isListening ? Icons.graphic_eq_rounded : Icons.mic_rounded,
                          color: Colors.white,
                          size: 46,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _isListening ? 'सुन रहा हूँ...' : 'Bas boliye...',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: brandPurple,
                    ),
                  ),
                ],
              ),

              const Spacer(flex: 2),

              // Manual Selection Button: "Main khud chununga"
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: () {
                    context.go('/home');
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: brandPurple,
                    backgroundColor: softLavender,
                    side: const BorderSide(color: Color(0xFFDDD6FE), width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.keyboard_rounded, size: 22, color: brandPurple),
                      SizedBox(width: 8),
                      Text(
                        'Main khud chununga',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
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
}
