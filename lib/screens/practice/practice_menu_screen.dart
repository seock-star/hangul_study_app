import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/practice/homework_screen.dart';
import 'package:flutter_application_1/screens/practice/listening_game_screen.dart';
import 'package:flutter_application_1/screens/practice/practical_learning_screen.dart';
import 'package:flutter_application_1/screens/games/game_menu_screen.dart';
import 'package:flutter_application_1/widgets/common_button.dart';

class PracticeMenuScreen extends StatelessWidget {
  const PracticeMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('✏️ 실습하기'),
        backgroundColor: Colors.orange[700],
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.orange[50],
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),
            StudyButton(
              emoji: '🖼️',
              title: '숙제 : 실전 낱말 학습',
              color: Colors.blueAccent[400]!,
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const PracticalLearningScreen())),
            ),
            const SizedBox(height: 18),
            StudyButton(
              emoji: '⭐',
              title: '숙제 : 글자 맞히기',
              color: Colors.amber[700]!,
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const HomeworkScreen())),
            ),
            const SizedBox(height: 18),
            StudyButton(
              emoji: '🎧',
              title: '숙제 : 소리 듣고 맞히기',
              color: Colors.purple[500]!,
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ListeningGameScreen())),
            ),
            const SizedBox(height: 18),
            StudyButton(
              emoji: '🎮',
              title: '게임하기',
              color: Colors.red[500]!,
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const GameMenuScreen())),
            ),
          ],
        ),
      ),
    );
  }
}
