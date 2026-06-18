import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:signature/signature.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class PracticeFlowScreen extends StatefulWidget {
  final String letter;
  final String sound;
  const PracticeFlowScreen({super.key, required this.letter, required this.sound});

  @override
  State<PracticeFlowScreen> createState() => _PracticeFlowScreenState();
}

class _PracticeFlowScreenState extends State<PracticeFlowScreen> {
  int step = 1;
  final FlutterTts flutterTts = FlutterTts();
  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 15,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  bool _isListening = false;
  String _spokenText = "버튼을 누르고 말해보세요!";
  bool _isCorrect = false;

  @override
  void initState() {
    super.initState();
    _initTts();
    _initStt();
  }

  @override
  void dispose() {
    flutterTts.stop();
    _signatureController.dispose();
    super.dispose();
  }

  void _initTts() async {
    await flutterTts.setLanguage("ko-KR");
    await flutterTts.setSpeechRate(0.35);
    _speakInstruction(1);
  }

  void _speakInstruction(int currentStep) async {
    if (currentStep == 1) {
      await flutterTts.speak('글자를 보고 소리를 들어보세요.');
    } else if (currentStep == 2) {
      await flutterTts.speak('아래 빈칸에 직접, ${widget.letter}, 글자를 써보세요.');
    } else if (currentStep == 3) {
      await flutterTts.speak('마이크 버튼을 누르고, ${widget.sound}, 라고 또박또박 말해보세요!');
    }
  }

  void _initStt() async {
    await _speechToText.initialize();
  }

  void _speakLetter() => flutterTts.speak(widget.sound);

  void _listenToVoice() async {
    if (!_isListening) {
      final available = await _speechToText.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speechToText.listen(
          localeId: "ko_KR",
          onResult: (result) {
            setState(() {
              _spokenText = result.recognizedWords;
              if (_spokenText.contains(widget.letter) ||
                  _spokenText.contains(widget.sound)) {
                _isCorrect = true;
              }
            });
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      _speechToText.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.letter} 학습하기'),
        backgroundColor: Colors.blue[400],
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            flutterTts.stop();
            Navigator.pop(context);
          },
        ),
      ),
      // ← 전체를 SingleChildScrollView로 감싸기
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            // ── 단계 표시 ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _StepLabel(label: '1. 듣기',    isActive: step >= 1),
                _StepLabel(label: '2. 따라쓰기', isActive: step >= 2),
                _StepLabel(label: '3. 발음하기', isActive: step >= 3),
              ],
            ),
            const SizedBox(height: 30),

            // ────────────── 1단계: 듣기 ──────────────
            if (step == 1) ...[
              const Text('글자를 보고 소리를 들어보세요.',
                  style: TextStyle(fontSize: 24),
                  textAlign: TextAlign.center),
              const SizedBox(height: 40),
              Center(
                child: Text(widget.letter,
                    style: const TextStyle(
                        fontSize: 150, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                icon: const Icon(Icons.volume_up, size: 40, color: Colors.blue),
                label: const Text(' 소리 듣기'),
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(20),
                    textStyle: const TextStyle(fontSize: 24)),
                onPressed: _speakLetter,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(20),
                    textStyle: const TextStyle(fontSize: 24)),
                onPressed: () {
                  setState(() => step = 2);
                  _speakInstruction(2);
                },
                child: const Text('다음으로 👉'),
              ),
            ],

            // ────────────── 2단계: 따라쓰기 ──────────────
            if (step == 2) ...[
              Text('아래 빈칸에 직접 "${widget.letter}" 글자를 써보세요.',
                  style: const TextStyle(fontSize: 22),
                  textAlign: TextAlign.center),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue, width: 3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Signature(
                    controller: _signatureController,
                    height: 260,
                    backgroundColor: Colors.yellow[50]!),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.refresh),
                      label: const Text('지우기'),
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(15),
                          textStyle: const TextStyle(fontSize: 20)),
                      onPressed: () => _signatureController.clear(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.all(15),
                          textStyle: const TextStyle(fontSize: 20)),
                      onPressed: () {
                        setState(() => step = 3);
                        _speakInstruction(3);
                      },
                      child: const Text('다음으로 👉'),
                    ),
                  ),
                ],
              ),
            ],

            // ────────────── 3단계: 발음하기 ──────────────
            if (step == 3) ...[
              Text('마이크 버튼을 누르고\n"${widget.sound}" 라고 또박또박 말해보세요!',
                  style: const TextStyle(fontSize: 22),
                  textAlign: TextAlign.center),
              const SizedBox(height: 40),
              Center(
                child: GestureDetector(
                  onTap: _listenToVoice,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isListening
                          ? Colors.red[100]
                          : Colors.blue[100],
                      border: Border.all(
                        color: _isListening ? Colors.red : Colors.blue,
                        width: 4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (_isListening ? Colors.red : Colors.blue)
                              .withOpacity(0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Icon(
                      _isListening ? Icons.mic : Icons.mic_none,
                      size: 70,
                      color: _isListening ? Colors.red : Colors.blue,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _isListening ? '🔴 듣는 중...' : '마이크를 눌러 말하세요',
                style: TextStyle(
                    fontSize: 18,
                    color: _isListening ? Colors.red : Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              if (_spokenText != "버튼을 누르고 말해보세요!")
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '내가 한 말: "$_spokenText"',
                    style: const TextStyle(fontSize: 18, color: Colors.blueGrey),
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 20),
              if (_isCorrect) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.green, width: 2),
                  ),
                  child: const Text(
                    '🎉 참 잘했어요! 정답입니다!',
                    style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.green),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(20),
                      textStyle: const TextStyle(fontSize: 24)),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('완료하고 돌아가기 🏠'),
                ),
              ] else if (!_isListening &&
                  _spokenText != "버튼을 누르고 말해보세요!") ...[
                const Text(
                  '다시 한번 천천히 말해볼까요? 🤔',
                  style: TextStyle(fontSize: 20, color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 30),
            ],
          ],
        ),
      ),
    );
  }
}

// ── 단계 표시 라벨 ──
class _StepLabel extends StatelessWidget {
  final String label;
  final bool isActive;
  const _StepLabel({required this.label, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? Colors.blue[400] : Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 15,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          color: isActive ? Colors.white : Colors.grey,
        ),
      ),
    );
  }
}