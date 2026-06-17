import 'package:flutter/material.dart';

class ShadowingGameScreen extends StatefulWidget {
  const ShadowingGameScreen({super.key});
  @override
  State<ShadowingGameScreen> createState() => _ShadowingGameScreenState();
}

class _ShadowingGameScreenState extends State<ShadowingGameScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🎤 따라 읽기 챌린지'), backgroundColor: Colors.orange, foregroundColor: Colors.white),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text(
            '🎤 음성인식 엔진 세팅 중\n\n(다음 정식 패치 버전에서 전면 개방됩니다!)',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22, color: Colors.grey, height: 1.6),
          ),
        ),
      ),
    );
  }
}