import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_application_1/utils/quiz_data_loader.dart';

/// 🎤 따라 읽기 챌린지 - assets에서 10문제 무작위
class ShadowingGameScreen extends StatefulWidget {
  const ShadowingGameScreen({super.key});
  @override
  State<ShadowingGameScreen> createState() => _ShadowingGameScreenState();
}

class _ShadowingGameScreenState extends State<ShadowingGameScreen> {
  final FlutterTts _tts = FlutterTts();
  final stt.SpeechToText _stt = stt.SpeechToText();

  List<PracticalWord> _quizList = [];
  int _step = 0, _correct = 0;
  bool _isListening = false;
  String _spoken = '';
  bool _answered = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tts.setLanguage("ko-KR");
    _tts.setSpeechRate(0.35);
    _stt.initialize();
    _loadQuiz();
  }

  Future<void> _loadQuiz() async {
    final words = await loadRandomPracticalWords(10);
    setState(() { _quizList = words; _isLoading = false; });
    Future.delayed(const Duration(milliseconds: 400), _speakCurrent);
  }

  void _speakCurrent() => _tts.speak(_quizList[_step].word);

  void _listen() async {
    if (_answered) return;
    if (!_isListening) {
      final avail = await _stt.initialize();
      if (!avail) return;
      setState(() { _isListening = true; _spoken = ''; });
      _stt.listen(localeId: "ko_KR", onResult: (r) => setState(() => _spoken = r.recognizedWords));
    } else {
      _stt.stop();
      setState(() => _isListening = false);
      _checkAnswer();
    }
  }

  void _checkAnswer() {
    final target = _quizList[_step].word;
    final isOk = _spoken.contains(target) || target.contains(_spoken.replaceAll(' ', ''));
    setState(() => _answered = true);
    if (isOk) { _correct++; _tts.speak(getRandomPraise()); }
    else { _tts.speak('아쉬워요. 다시 들어볼까요?'); }
  }

  void _next() {
    if (_step + 1 >= _quizList.length) { _showResult(); return; }
    setState(() { _step++; _spoken = ''; _answered = false; _isListening = false; });
    Future.delayed(const Duration(milliseconds: 400), _speakCurrent);
  }

  void _showResult() {
    showDialog(context: context, barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('🎉 완료!'),
        content: Text('${_quizList.length}문제 중 $_correct개 성공! 목소리가 멋져요! 🎤'),
        actions: [
          TextButton(onPressed: () { Navigator.pop(context); _loadQuiz(); }, child: const Text('다시 하기', style: TextStyle(fontSize: 20))),
          TextButton(onPressed: () { Navigator.pop(context); Navigator.pop(context); }, child: const Text('끝내기', style: TextStyle(fontSize: 20))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final s = _quizList[_step];
    final isOk = _spoken.contains(s.word) || s.word.contains(_spoken.replaceAll(' ', ''));
    return Scaffold(
      appBar: AppBar(title: Text('🎤 따라 읽기  ${_step + 1}/${_quizList.length}'),
          backgroundColor: Colors.orange[700], foregroundColor: Colors.white),
      backgroundColor: Colors.orange[50],
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            LinearProgressIndicator(value: (_step + 1) / _quizList.length, minHeight: 12, color: Colors.orange, backgroundColor: Colors.grey[300], borderRadius: BorderRadius.circular(8)),
            const SizedBox(height: 30),
            Text(s.icon, style: const TextStyle(fontSize: 80)),
            const SizedBox(height: 16),
            Text(s.word, style: const TextStyle(fontSize: 52, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.volume_up, size: 30),
              label: const Text('다시 듣기'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange[300], foregroundColor: Colors.white, textStyle: const TextStyle(fontSize: 20), padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
              onPressed: _speakCurrent,
            ),
            const Spacer(),
            Text('아래 마이크를 누르고 따라 말해보세요!', style: TextStyle(fontSize: 18, color: Colors.orange[800]), textAlign: TextAlign.center),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _listen,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 100, height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isListening ? Colors.red : Colors.orange[400],
                  boxShadow: [BoxShadow(color: (_isListening ? Colors.red : Colors.orange).withOpacity(0.4), blurRadius: 20, spreadRadius: 4)],
                ),
                child: Icon(_isListening ? Icons.mic : Icons.mic_none, size: 54, color: Colors.white),
              ),
            ),
            const SizedBox(height: 12),
            Text(_isListening ? '🔴 듣는 중... (다시 누르면 완료)' : '마이크를 눌러 말하세요', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
            if (_spoken.isNotEmpty) Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text('내가 한 말: "$_spoken"', style: const TextStyle(fontSize: 18, color: Colors.blueGrey)),
            ),
            if (_answered) Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(isOk ? '🎉 잘 하셨어요!' : '❌ 다시 도전해 보세요!',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isOk ? Colors.green : Colors.red)),
            ),
            const SizedBox(height: 20),
            if (_answered) ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange[700], foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18), textStyle: const TextStyle(fontSize: 22)),
              onPressed: _next,
              child: Text(_step + 1 >= _quizList.length ? '결과 보기 🏆' : '다음 문제 👉'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
