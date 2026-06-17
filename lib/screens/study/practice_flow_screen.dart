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
              if (_spokenText.contains(widget.letter) || _spokenText.contains(widget.sound)) {
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
      appBar: AppBar(title: Text('${widget.letter} 학습하기'), backgroundColor: Colors.blue[400]),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text('1. 듣기', style: TextStyle(fontSize: 18, fontWeight: step >= 1 ? FontWeight.bold : FontWeight.normal, color: step >= 1 ? Colors.blue : Colors.grey)),
                Text('👉 2. 따라쓰기', style: TextStyle(fontSize: 18, fontWeight: step >= 2 ? FontWeight.bold : FontWeight.normal, color: step >= 2 ? Colors.blue : Colors.grey)),
                Text('👉 3. 발음하기', style: TextStyle(fontSize: 18, fontWeight: step >= 3 ? FontWeight.bold : FontWeight.normal, color: step >= 3 ? Colors.blue : Colors.grey)),
              ],
            ),
            const SizedBox(height: 30),

            if (step == 1) ...[
              const Text('글자를 보고 소리를 들어보세요.', style: TextStyle(fontSize: 24), textAlign: TextAlign.center),
              const Spacer(),
              Center(child: Text(widget.letter, style: const TextStyle(fontSize: 150, fontWeight: FontWeight.bold))),
              const Spacer(),
              ElevatedButton.icon(
                icon: const Icon(Icons.volume_up, size: 40, color: Colors.blue),
                label: const Text(' 소리 듣기'),
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(20), textStyle: const TextStyle(fontSize: 24)),
                onPressed: _speakLetter,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, padding: const EdgeInsets.all(20), textStyle: const TextStyle(fontSize: 24)),
                onPressed: () { setState(() => step = 2); _speakInstruction(2); },
                child: const Text('다음으로 👉'),
              ),
            ],

            if (step == 2) ...[
              Text('아래 빈칸에 직접 "${widget.letter}" 글자를 써보세요.', style: const TextStyle(fontSize: 22), textAlign: TextAlign.center),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(border: Border.all(color: Colors.blue, width: 3), borderRadius: BorderRadius.circular(10)),
                child: Signature(controller: _signatureController, height: 300, backgroundColor: Colors.yellow[50]!),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: const Text('지우기'),
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(15), textStyle: const TextStyle(fontSize: 20)),
                    onPressed: () => _signatureController.clear(),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, padding: const EdgeInsets.all(15), textStyle: const TextStyle(fontSize: 20)),
                    onPressed: () { setState(() => step = 3); _speakInstruction(3); },
                    child: const Text('다음으로 👉'),
                  ),
                ],
              ),
            ],

            if (step == 3) ...[
              Text('마이크 버튼을 누르고 "${widget.sound}" 라고 또박또박 말해보세요!', style: const TextStyle(fontSize: 22), textAlign: TextAlign.center),
              const Spacer(),
              Center(
                child: IconButton(
                  icon: Icon(_isListening ? Icons.mic : Icons.mic_none, size: 80, color: _isListening ? Colors.red : Colors.blue),
                  onPressed: _listenToVoice,
                ),
              ),
              const SizedBox(height: 20),
              Text(_spokenText, style: const TextStyle(fontSize: 24, color: Colors.grey), textAlign: TextAlign.center),
              const Spacer(),
              if (_isCorrect) ...[
                const Text('🎉 참 잘했어요! 정답입니다!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green), textAlign: TextAlign.center),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white, padding: const EdgeInsets.all(20), textStyle: const TextStyle(fontSize: 24)),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('완료하고 돌아가기 🏠'),
                ),
              ] else if (!_isListening && _spokenText != "버튼을 누르고 말해보세요!") ...[
                const Text('다시 한번 천천히 말해볼까요? 🤔', style: TextStyle(fontSize: 20, color: Colors.red), textAlign: TextAlign.center),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
