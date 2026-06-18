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
      body: SingleChildScrollView(        // ← 스크롤 추가
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),
            _StudyButton(
              emoji: '🔤',
              title: '자음 (ㄱ, ㄴ, ㄷ...)',
              color: Colors.green[700]!,
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const LearningScreen(type: 'consonant', title: '자음'))),
            ),
            const SizedBox(height: 18),
            _StudyButton(
              emoji: '🔡',
              title: '모음 (ㅏ, ㅑ, ㅓ...)',
              color: Colors.teal[600]!,
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const LearningScreen(type: 'vowel', title: '모음'))),
            ),
            const SizedBox(height: 18),
            _StudyButton(
              emoji: '🅰️',
              title: '가나다 (가, 나, 다...)',
              color: Colors.cyan[700]!,
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const LearningScreen(type: 'syllable', title: '가나다'))),
            ),
            const SizedBox(height: 18),
            _StudyButton(
              emoji: '📚',
              title: '심화 학습 (가갸거겨...)',
              color: Colors.indigo[600]!,
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const AdvancedLearningScreen())),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// ── 버튼 위젯 (글씨 커져도 안 깨지게 개선) ──
class _StudyButton extends StatelessWidget {
  final String emoji;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _StudyButton({
    required this.emoji,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color, width: 2.5),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: IntrinsicHeight(        // ← 글씨 커지면 버튼도 같이 커짐
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 왼쪽 이모지 영역
              Container(
                width: 80,
                constraints: const BoxConstraints(minHeight: 80),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(18),
                    bottomLeft: Radius.circular(18),
                  ),
                ),
                child: Text(emoji, style: const TextStyle(fontSize: 36)),
              ),
              // 오른쪽 텍스트 영역
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ),
                ),
              ),
              // 오른쪽 화살표
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Icon(Icons.arrow_forward_ios,
                    color: color, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}