import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter_tts/flutter_tts.dart';

class CountdownScreen extends StatefulWidget {
  final int contador;
  final VoidCallback onFinish;
   const CountdownScreen({super.key,required this.contador,required this.onFinish});

  @override
  State<CountdownScreen> createState() => _CountdownScreenState();
}

class _CountdownScreenState extends State<CountdownScreen>
    with TickerProviderStateMixin {
  late int _count ;
  AnimationController? _controller;

  final FlutterTts flutterTts = FlutterTts();
  
  @override
  void initState() {
    super.initState();
    _count = widget.contador;
    _initTts();
    _startCountdown();
  }

  Future<void> _initTts() async {
    await flutterTts.setLanguage("es-ES");
    await flutterTts.setPitch(1.0);
    await flutterTts.awaitSpeakCompletion(true);
  }

  Future<void> _startCountdown() async {
    await flutterTts.speak("");
    await Future.delayed(const Duration(milliseconds: 200));
    // Mensaje inicial
    await _speakAndWait(
    _count == 5
        ? "Detección inicia en 5"
        : "Detección inicia en 3",
  );

  while (_count > 1 && mounted) {
    setState(() => _count--);

    await _animateTick();

    await _speakAndWait("$_count");
  }

  if (!mounted) return;
    widget.onFinish();
  }

  Future<void> _speakAndWait(String text) async {
    await flutterTts.speak(text);
    await flutterTts.awaitSpeakCompletion(true);
  }
  
  Future<void> _animateTick() async {
    _controller?.dispose();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    await _controller!.forward(from: 0.0);
  }

  Future<void> speak(String text)  async {
     flutterTts.setLanguage("es-ES"); // Español
     flutterTts.setPitch(1.0); // Tono normal
     flutterTts.speak(text);
  }

  @override
  void dispose() {
    flutterTts.stop();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer( // evita que bloquee toques en la cámara
        child: Container(
          color: Colors.black.withValues(alpha: 0.0), // completamente transparente
          alignment: Alignment.center,
          child: Text(
            "$_count",
            style: const TextStyle(
              fontSize: 120,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
    );
  }
}
