import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:signature/signature.dart';

class PracticalLearningScreen extends StatefulWidget {
  const PracticalLearningScreen({super.key});
  @override
  State<PracticalLearningScreen> createState() => _PracticalLearningScreenState();
}

class _PracticalLearningScreenState extends State<PracticalLearningScreen> {
  List<Map<String, String>> practicalWords = [];
  int currentIndex = 0;
  final SignatureController _sigController = SignatureController(penStrokeWidth: 10, penColor: Colors.black);
  final FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _loadDataFromFile(); 
  }

  Future<void> _loadDataFromFile() async {
    String fileText = await rootBundle.loadString('assets/practical_words.txt');
    setState(() {
      practicalWords = fileText.split('\n')
          .where((line) => line.contains(':'))
          .map((line) {
            var parts = line.split(':');
            return {'icon': parts[0].trim(), 'word': parts[1].trim()};
          }).toList();
    });
    _playInstruction();
  }

  void _playInstruction() async {
    await flutterTts.setLanguage("ko-KR");
    await flutterTts.setSpeechRate(0.35);
    await flutterTts.speak('사진을 보고 무엇인지 들어보세요. 그 다음 아래에 따라 써보세요.');
    await Future.delayed(const Duration(seconds: 3));
    if (practicalWords.isNotEmpty) {
      await flutterTts.speak(practicalWords[currentIndex]['word']!);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (practicalWords.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    var item = practicalWords[currentIndex];
    return Scaffold(
      appBar: AppBar(title: const Text('실전 낱말 학습'), backgroundColor: Colors.blueAccent, foregroundColor: Colors.white),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(item['icon']!, style: const TextStyle(fontSize: 100)),
            Text(item['word']!, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Container(
              height: 200, decoration: BoxDecoration(border: Border.all(color: Colors.blue), borderRadius: BorderRadius.circular(10)),
              child: Signature(controller: _sigController, backgroundColor: Colors.yellow[50]!),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(onPressed: () => _sigController.clear(), child: const Text('지우기', style: TextStyle(fontSize: 20))),
                ElevatedButton(onPressed: () {
                  if (currentIndex < practicalWords.length - 1) {
                    setState(() { currentIndex++; _sigController.clear(); _playInstruction(); });
                  } else { Navigator.pop(context); }
                }, child: const Text('다음 단어 👉', style: TextStyle(fontSize: 20))),
              ],
            )
          ],
        ),
      ),
    );
  }
}