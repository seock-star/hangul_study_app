import 'package:flutter/material.dart';

/// 공부하기 / 실습하기 메뉴에서 공통으로 쓰는 버튼
class StudyButton extends StatelessWidget {
  final String emoji;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const StudyButton({
    super.key,
    required this.emoji,
    required this.title,
    required this.color,
    required this.onTap,
  });

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
