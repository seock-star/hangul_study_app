import 'package:flutter/material.dart';
import 'learning_screen.dart';
import 'advanced_learning_screen.dart';

class StudyMenuScreen extends StatelessWidget {
  const StudyMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📖 공부하기'),
        backgroundColor: Colors.green[600],
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.green[50],
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),
            _StudyButton(
              emoji: '🔤',
              title: '자음 (ㄱ, ㄴ, ㄷ...)',
              color: Colors.green[700]!,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LearningScreen(type: 'consonant', title: '자음'))),
            ),
            const SizedBox(height: 18),
            _StudyButton(
              emoji: '🔡',
              title: '모음 (ㅏ, ㅑ, ㅓ...)',
              color: Colors.teal[600]!,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LearningScreen(type: 'vowel', title: '모음'))),
            ),
            const SizedBox(height: 18),
            _StudyButton(
              emoji: '🅰️',
              title: '가나다 (가, 나, 다...)',
              color: Colors.cyan[700]!,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LearningScreen(type: 'syllable', title: '가나다'))),
            ),
            const SizedBox(height: 18),
            _StudyButton(
              emoji: '📚',
              title: '심화 학습 (가갸거겨...)',
              color: Colors.indigo[600]!,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdvancedLearningScreen())),
            ),
          ],
        ),
      ),
    );
  }
}

class _StudyButton extends StatelessWidget {
  final String emoji;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _StudyButton({required this.emoji, required this.title, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
        textStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        elevation: 4,
      ),
      onPressed: onTap,
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(width: 16),
          Text(title),
        ],
      ),
    );
  }
}