import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:signature/signature.dart';
import 'package:flutter_application_1/utils/quiz_data_loader.dart';


class PracticalLearningScreen extends StatefulWidget {
  const PracticalLearningScreen({super.key});
  @override
  State<PracticalLearningScreen> createState() => _PracticalLearningScreenState();
}
DateTime? _lastInstructionTime; // 🌟 마지막 안내 음성 시각
class _PracticalLearningScreenState extends State<PracticalLearningScreen> {
  List<PracticalWord> practicalWords = [];
  int currentIndex = 0;
  final SignatureController _sigController =
      SignatureController(penStrokeWidth: 10, penColor: Colors.black);
  final FlutterTts flutterTts = FlutterTts();

  // 1. 현재 지시 문구를 상태로 관리
  String _instructionText = '불러오는 중...';

  @override
  void initState() {
    super.initState();
    _loadDataFromFile();
  }

  // 2. 뒤로가기 시 음성 중단
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

  // 🌟 마지막 안내로부터 60초 안 지났으면 단어만 읽기
  final now = DateTime.now();
  if (_lastInstructionTime != null &&
      now.difference(_lastInstructionTime!).inSeconds < 60) {
    await flutterTts.setSpeechRate(0.35);
    await flutterTts.speak(word);
    return;
  }

  // 60초 지났으면 안내 멘트 + 단어 읽기
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
        // 2. AppBar 뒤로가기 눌러도 stop() 호출되도록 WillPopScope 대신 leading 활용
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            flutterTts.stop();
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 1. 지시 문구 카드 (글자로 표시)
            Card(
              color: Colors.blue[50],
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.blue, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _instructionText,
                        style: const TextStyle(fontSize: 20, height: 1.5, color: Colors.black87),
                      ),
                    ),
                    // 다시 듣기 버튼
                    IconButton(
                      icon: const Icon(Icons.volume_up, color: Colors.blue, size: 30),
                      onPressed: _playInstruction,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            Text(item.icon, style: const TextStyle(fontSize: 100)),
            Text(item.word,
                style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            Container(
              height: 200,
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue),
                  borderRadius: BorderRadius.circular(10)),
              child: Signature(controller: _sigController, backgroundColor: Colors.white),
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _sigController.clear(),
                  child: const Text('지우기'),
                ),
                ElevatedButton(
                  onPressed: () {
                    flutterTts.stop(); // 다음 단어로 넘길 때도 이전 음성 중단
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
                  child: const Text('다음 단어 👉'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}