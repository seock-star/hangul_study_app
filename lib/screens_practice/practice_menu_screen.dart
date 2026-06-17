import 'package:flutter/material.dart';
import 'practical_learning_screen.dart';
import 'homework_screen.dart';
import 'listening_game_screen.dart';
import '../screens_game/game_menu_screen.dart'; // 🌟 미리 폴더 연동 준비

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
            _PracticeMenuButton(
              emoji: '🖼️', title: '숙제 : 실전 낱말 학습', color: Colors.blueAccent[400]!,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PracticalLearningScreen())),
            ),
            const SizedBox(height: 18),
            _PracticeMenuButton(
              emoji: '⭐', title: '숙제 : 글자 맞히기', color: Colors.amber[700]!,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HomeworkScreen())),
            ),
            const SizedBox(height: 18),
            _PracticeMenuButton(
              emoji: '🎧', title: '숙제 : 소리 듣고 맞히기', color: Colors.purple[500]!,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ListeningGameScreen())),
            ),
            const SizedBox(height: 18),
            _PracticeMenuButton(
              emoji: '🎮', title: '게임하기', color: Colors.red[500]!,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GameMenuScreen())),
            ),
          ],
        ),
      ),
    );
  }
}

class _PracticeMenuButton extends StatelessWidget {
  final String emoji; final String title; final Color color; final VoidCallback onTap;
  const _PracticeMenuButton({required this.emoji, required this.title, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color, foregroundColor: Colors.white,
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