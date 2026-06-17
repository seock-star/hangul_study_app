import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/study/learning_screen.dart';
import 'package:flutter_application_1/screens/study/advanced_learning_screen.dart';
import 'package:flutter_application_1/widgets/common_button.dart';

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
            StudyButton(
              emoji: '🔤',
              title: '자음 (ㄱ, ㄴ, ㄷ...)',
              color: Colors.green[700]!,
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const LearningScreen(type: 'consonant', title: '자음'))),
            ),
            const SizedBox(height: 18),
            StudyButton(
              emoji: '🔡',
              title: '모음 (ㅏ, ㅑ, ㅓ...)',
              color: Colors.teal[600]!,
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const LearningScreen(type: 'vowel', title: '모음'))),
            ),
            const SizedBox(height: 18),
            StudyButton(
              emoji: '🅰️',
              title: '가나다 (가, 나, 다...)',
              color: Colors.cyan[700]!,
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const LearningScreen(type: 'syllable', title: '가나다'))),
            ),
            const SizedBox(height: 18),
            StudyButton(
              emoji: '📚',
              title: '심화 학습 (가갸거겨...)',
              color: Colors.indigo[600]!,
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const AdvancedLearningScreen())),
            ),
          ],
        ),
      ),
    );
  }
}
