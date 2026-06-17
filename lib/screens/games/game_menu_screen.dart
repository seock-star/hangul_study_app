import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/games/matching_game_screen.dart';
import 'package:flutter_application_1/screens/games/fill_blank_game_screen.dart';
import 'package:flutter_application_1/screens/games/word_order_game_screen.dart';
import 'package:flutter_application_1/screens/games/shadowing_game_screen.dart';
import 'package:flutter_application_1/screens/games/word_chain_game_screen.dart';

class GameMenuScreen extends StatelessWidget {
  const GameMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎮 게임하기'),
        backgroundColor: Colors.red[500],
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.red[50],
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ListView(
          children: [
            const SizedBox(height: 10),
            _GameMenuCard(emoji: '🃏', title: '짝 맞추기', desc: '그림과 글자를 짝지어 맞춰요', color: Colors.pink[400]!,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MatchingGameScreen()))),
            const SizedBox(height: 16),
            _GameMenuCard(emoji: '🔤', title: '빈칸 채우기', desc: '빠진 글자를 찾아 완성해요', color: Colors.blue[500]!,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FillBlankGameScreen()))),
            const SizedBox(height: 16),
            _GameMenuCard(emoji: '🔀', title: '순서 맞추기', desc: '뒤섞인 글자를 바른 순서로 놓아요', color: Colors.green[600]!,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WordOrderGameScreen()))),
            const SizedBox(height: 16),
            _GameMenuCard(emoji: '🎤', title: '따라 읽기 챌린지', desc: '들리는 단어를 따라 말해요', color: Colors.orange[700]!,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ShadowingGameScreen()))),
            const SizedBox(height: 16),
            _GameMenuCard(emoji: '🔗', title: '끝말잇기', desc: '마지막 글자로 시작하는 단어를 골라요', color: Colors.purple[500]!,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WordChainGameScreen()))),
          ],
        ),
      ),
    );
  }
}

class _GameMenuCard extends StatelessWidget {
  final String emoji, title, desc;
  final Color color;
  final VoidCallback onTap;
  const _GameMenuCard({required this.emoji, required this.title, required this.desc, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color, width: 2.5),
          boxShadow: [BoxShadow(color: color.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(
              width: 70, height: 70,
              decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(16)),
              child: Center(child: Text(emoji, style: const TextStyle(fontSize: 38))),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
                const SizedBox(height: 4),
                Text(desc, style: const TextStyle(fontSize: 16, color: Colors.black54)),
              ]),
            ),
            Icon(Icons.arrow_forward_ios, color: color),
          ],
        ),
      ),
    );
  }
}
