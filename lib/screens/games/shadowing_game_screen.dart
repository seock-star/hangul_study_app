import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_application_1/utils/quiz_data_loader.dart';

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
  bool _isPlaying = false;
  String _spoken = '';
  bool _answered = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tts.setLanguage("ko-KR");
    _tts.setSpeechRate(0.35);
    _tts.setCompletionHandler(() {
      setState(() => _isPlaying = false);
    });
    _stt.initialize();
    _loadQuiz();
  }

  @override
  void dispose() {
    _tts.stop();
    _stt.stop();
    super.dispose();
  }

  Future<void> _loadQuiz() async {
    final words = await loadRandomPracticalWords(10);
    setState(() {
      _quizList = words;
      _isLoading = false;
    });
    Future.delayed(const Duration(milliseconds: 400), _speakCurrent);
  }

  Future<void> _speakCurrent() async {
    if (_isPlaying) return;
    setState(() => _isPlaying = true);
    await _tts.stop();
    await Future.delayed(const Duration(milliseconds: 100));
    await _tts.speak(_quizList[_step].word);
  }

  void _listen() async {
    if (_answered) return;
    if (!_isListening) {
      final avail = await _stt.initialize();
      if (!avail) return;
      setState(() {
        _isListening = true;
        _spoken = '';
      });
      _stt.listen(
        localeId: "ko_KR",
        onResult: (r) => setState(() => _spoken = r.recognizedWords),
      );
    } else {
      _stt.stop();
      setState(() => _isListening = false);
      _checkAnswer();
    }
  }

  void _checkAnswer() {
    final target = _quizList[_step].word;
    final isOk = _spoken.contains(target) ||
        target.contains(_spoken.replaceAll(' ', ''));
    setState(() => _answered = true);
    if (isOk) {
      _correct++;
      _tts.speak(getRandomPraise());
    } else {
      _tts.speak('아쉬워요. 다시 들어볼까요?');
    }
  }

  void _next() {
    if (_step + 1 >= _quizList.length) {
      _showResult();
      return;
    }
    setState(() {
      _step++;
      _spoken = '';
      _answered = false;
      _isListening = false;
    });
    Future.delayed(const Duration(milliseconds: 400), _speakCurrent);
  }

  void _showResult() {
    _tts.speak(
        '따라 읽기 챌린지를 모두 마쳤어요! $_correct개 성공했어요! 목소리가 정말 멋져요!');
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24)),
        title: const Text('🎉 완료!',
            style: TextStyle(fontSize: 26),
            textAlign: TextAlign.center),
        content: Text(
          '${_quizList.length}문제 중 $_correct개 성공!\n목소리가 멋져요! 🎤',
          style: const TextStyle(fontSize: 20, height: 1.6),
          textAlign: TextAlign.center,
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: const TextStyle(fontSize: 20),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      _step = 0;
                      _correct = 0;
                      _spoken = '';
                      _answered = false;
                      _isListening = false;
                    });
                    _loadQuiz();
                  },
                  child: const Text('다시 하기'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: const TextStyle(fontSize: 20),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    _tts.stop();
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: const Text('끝내기'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator()));
    }

    final s = _quizList[_step];
    final isOk = _spoken.contains(s.word) ||
        s.word.contains(_spoken.replaceAll(' ', ''));

    return Scaffold(
      appBar: AppBar(
        title: Text('🎤 따라 읽기  ${_step + 1}/${_quizList.length}',
            style: const TextStyle(fontSize: 20)),
        backgroundColor: Colors.orange[700],
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            _tts.stop();
            _stt.stop();
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            // ── 진행 바 ──
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: (_step + 1) / _quizList.length,
                      minHeight: 14,
                      color: Colors.orange,
                      backgroundColor: Colors.grey[300],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text('${_step + 1} / ${_quizList.length}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 24),

            // ── 문제 카드 ──
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 28, horizontal: 20),
                child: Column(
                  children: [
                    // 이모지
                    Text(s.icon,
                        style: const TextStyle(fontSize: 90)),
                    const SizedBox(height: 12),
                    // 단어
                    Text(
                      s.word,
                      style: const TextStyle(
                          fontSize: 42, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    // 다시 듣기 버튼
                    ElevatedButton.icon(
                      icon: Icon(
                        _isPlaying
                            ? Icons.volume_up
                            : Icons.play_circle,
                        size: 24,
                      ),
                      label: Text(
                        _isPlaying ? '재생중...' : '다시 듣기',
                        style: const TextStyle(fontSize: 18),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange[300],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 28, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                      ),
                      onPressed: _isPlaying ? null : _speakCurrent,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ── 마이크 카드 ──
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              color: _answered
                  ? (isOk ? Colors.green[50] : Colors.red[50])
                  : Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 24, horizontal: 20),
                child: Column(
                  children: [
                    // 안내 문구
                    Text(
                      _answered
                          ? (isOk
                              ? '🎉 정확해요! 잘하셨어요!'
                              : '❌ 다시 도전해 보세요!')
                          : '마이크를 누르고 따라 말해보세요!',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _answered
                            ? (isOk ? Colors.green[700] : Colors.red[700])
                            : Colors.orange[800],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),

                    // 마이크 버튼
                    if (!_answered)
                      GestureDetector(
                        onTap: _listen,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 130,
                          height: 130,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _isListening
                                ? Colors.red[100]
                                : Colors.orange[100],
                            border: Border.all(
                              color: _isListening
                                  ? Colors.red
                                  : Colors.orange[400]!,
                              width: 4,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: (_isListening
                                        ? Colors.red
                                        : Colors.orange)
                                    .withOpacity(0.3),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _isListening
                                    ? Icons.mic
                                    : Icons.mic_none,
                                size: 60,
                                color: _isListening
                                    ? Colors.red
                                    : Colors.orange[700],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _isListening ? '듣는 중...' : '눌러서 말하기',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: _isListening
                                      ? Colors.red
                                      : Colors.orange[700],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // 인식된 말
                    if (_spoken.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.record_voice_over,
                                color: Colors.grey, size: 20),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                '내가 한 말: "$_spoken"',
                                style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.blueGrey),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ── 다음 문제 버튼 ──
            if (_answered)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isOk ? Colors.green : Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  textStyle: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                ),
                onPressed: _next,
                child: Text(
                  _step + 1 >= _quizList.length
                      ? '결과 보기 🏆'
                      : isOk
                          ? '다음 문제 👉'
                          : '다음 문제로 넘어가기 👉',
                ),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}