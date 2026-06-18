import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:signature/signature.dart';
import 'package:flutter_application_1/utils/quiz_data_loader.dart';

class PracticalLearningScreen extends StatefulWidget {
  const PracticalLearningScreen({super.key});
  @override
  State<PracticalLearningScreen> createState() => _PracticalLearningScreenState();
}

class _PracticalLearningScreenState extends State<PracticalLearningScreen> {
  List<PracticalWord> practicalWords = [];
  int currentIndex = 0;
  final SignatureController _sigController =
      SignatureController(penStrokeWidth: 10, penColor: Colors.black);
  final FlutterTts flutterTts = FlutterTts();
  String _instructionText = '불러오는 중...';
  DateTime? _lastInstructionTime;

  @override
  void initState() {
    super.initState();
    _loadDataFromFile();
  }

  @override
  void dispose() {
    flutterTts.stop();
    _sigController.dispose();
    super.dispose();
  }

  Future<void> _loadDataFromFile() async {
    final words = await loadRandomPracticalWords(999);
    setState(() => practicalWords = words);
    _playInstruction();
  }

  Future<void> _playInstruction() async {
    if (practicalWords.isEmpty) return;
    final word = practicalWords[currentIndex].word;
    setState(() {
      _instructionText = '사진을 보고 "$word" 를\n아래 빈칸에 따라 써보세요!';
    });

    final now = DateTime.now();
    if (_lastInstructionTime != null &&
        now.difference(_lastInstructionTime!).inSeconds < 60) {
      await flutterTts.setSpeechRate(0.35);
      await flutterTts.speak(word);
      return;
    }
    _lastInstructionTime = now;
    await flutterTts.setSpeechRate(0.35);
    await flutterTts.speak('사진을 보고 무엇인지 들어보세요. 그 다음 아래에 따라 써보세요.');
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) await flutterTts.speak(word);
  }

  @override
  Widget build(BuildContext context) {
    if (practicalWords.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('실전 낱말 학습')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final item = practicalWords[currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('실전 낱말 학습'),
        backgroundColor: Colors.blueAccent[400],
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            flutterTts.stop();
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(        // ← 스크롤 추가
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            // ── 진행 상황 표시 ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${currentIndex + 1} / ${practicalWords.length} 번째 단어',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.volume_up, size: 20),
                  label: const Text('다시 듣기'),
                  onPressed: _playInstruction,
                ),
              ],
            ),
            const SizedBox(height: 8),

            // ── 지시 문구 카드 ──
            Card(
              color: Colors.blue[50],
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 14, horizontal: 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(Icons.info_outline,
                        color: Colors.blue, size: 28),
                    const SizedBox(width: 12),
                    Flexible(        // ← 글씨 커져도 안 넘치게
                      child: Text(
                        _instructionText,
                        style: const TextStyle(
                            fontSize: 20, height: 1.5, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ── 그림 + 단어 카드 ──
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 24, horizontal: 20),
                child: Column(
                  children: [
                    Text(item.icon,
                        style: const TextStyle(fontSize: 100)),
                    const SizedBox(height: 12),
                    Text(
                      item.word,
                      style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87),
                    ),
                    const SizedBox(height: 8),
                    // 소리 듣기 버튼
                    OutlinedButton.icon(
                      icon: const Icon(Icons.volume_up, size: 22),
                      label: const Text('소리 듣기',
                          style: TextStyle(fontSize: 18)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.blueAccent,
                        side: const BorderSide(
                            color: Colors.blueAccent, width: 2),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                      ),
                      onPressed: () => flutterTts.speak(item.word),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ── 따라쓰기 영역 ──
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.edit, color: Colors.blueAccent),
                        const SizedBox(width: 8),
                        Text(
                          '따라 써보세요',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent[700]),
                        ),
                        const Spacer(),
                        TextButton.icon(
                          icon: const Icon(Icons.refresh, size: 18),
                          label: const Text('지우기'),
                          onPressed: () => _sigController.clear(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: Colors.blueAccent, width: 2),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.yellow[50],
                      ),
                      child: Signature(
                        controller: _sigController,
                        height: 220,
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ── 이전 / 다음 버튼 ──
            Row(
              children: [
                // 이전 버튼 (첫 번째 단어면 비활성화)
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.arrow_back_ios, size: 18),
                    label: const Text('이전 단어',
                        style: TextStyle(fontSize: 18)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: currentIndex == 0
                          ? Colors.grey[300]
                          : Colors.blueAccent[100],
                      foregroundColor: currentIndex == 0
                          ? Colors.grey
                          : Colors.blueAccent[700],
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: currentIndex == 0 ? 0 : 3,
                    ),
                    onPressed: currentIndex == 0
                        ? null
                        : () {
                            flutterTts.stop();
                            setState(() {
                              currentIndex--;
                              _sigController.clear();
                            });
                            _playInstruction();
                          },
                  ),
                ),
                const SizedBox(width: 12),
                // 다음 버튼
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.arrow_forward_ios, size: 18),
                    label: Text(
                      currentIndex < practicalWords.length - 1
                          ? '다음 단어'
                          : '완료 🎉',
                      style: const TextStyle(fontSize: 18),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 4,
                    ),
                    onPressed: () {
                      flutterTts.stop();
                      if (currentIndex < practicalWords.length - 1) {
                        setState(() {
                          currentIndex++;
                          _sigController.clear();
                        });
                        _playInstruction();
                      } else {
                        Navigator.pop(context);
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}