import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(HangmanApp());
}

class HangmanApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Juego del Ahorcado',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: ModeSelectionScreen(),
    );
  }
}

class ModeSelectionScreen extends StatefulWidget {
  @override
  _ModeSelectionScreenState createState() => _ModeSelectionScreenState();
}

class _ModeSelectionScreenState extends State<ModeSelectionScreen> {
  bool onlyOnePlayer = false;
  bool useRealWord = true;
  int wordLength = 5;
  final List<String> wordList = [
    'murcielago',
    'flutter',
    'raton',
    'sol',
    'teclado',
    'pantalla',
    'ahorcado'
  ];
  final TextEditingController _controller = TextEditingController();

  String generateRandomWord(int n) {
    const letters = 'abcdefghijklmnopqrstuvwxyz';
    return List.generate(n, (_) => letters[Random().nextInt(letters.length)]).join();
  }

  void startGame() {
    String secretWord = '';

    if (onlyOnePlayer) {
      secretWord = useRealWord
          ? wordList[Random().nextInt(wordList.length)]
          : generateRandomWord(wordLength);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => HangmanGameScreen(
            secretWord: secretWord,
            isAgainstComputer: true,
          ),
        ),
      );
    } else {
      // Dos jugadores humanos
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Jugador 1: Ingrese la palabra'),
          content: TextField(
            controller: _controller,
            obscureText: true,
            decoration: InputDecoration(hintText: 'Palabra secreta'),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                secretWord = _controller.text.trim().toLowerCase();
                _controller.clear();
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => HangmanGameScreen(
                      secretWord: secretWord,
                      isAgainstComputer: false,
                    ),
                  ),
                );
              },
              child: Text('Iniciar Juego'),
            )
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Configuración del Juego')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            SwitchListTile(
              title: Text('¿Solo hay un jugador?'),
              value: onlyOnePlayer,
              onChanged: (value) => setState(() => onlyOnePlayer = value),
            ),
            if (onlyOnePlayer)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RadioListTile(
                    title: Text('Usar palabra real'),
                    value: true,
                    groupValue: useRealWord,
                    onChanged: (_) => setState(() => useRealWord = true),
                  ),
                  RadioListTile(
                    title: Text('Generar palabra aleatoria'),
                    value: false,
                    groupValue: useRealWord,
                    onChanged: (_) => setState(() => useRealWord = false),
                  ),
                  if (!useRealWord)
                    Row(
                      children: [
                        Text('Longitud:'),
                        Expanded(
                          child: Slider(
                            value: wordLength.toDouble(),
                            min: 3,
                            max: 10,
                            divisions: 7,
                            label: '$wordLength',
                            onChanged: (val) => setState(() => wordLength = val.toInt()),
                          ),
                        )
                      ],
                    )
                ],
              ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: startGame,
              child: Text('Comenzar Juego'),
            )
          ],
        ),
      ),
    );
  }
}

class HangmanGameScreen extends StatefulWidget {
  final String secretWord;
  final bool isAgainstComputer;

  HangmanGameScreen({
    required this.secretWord,
    required this.isAgainstComputer,
  });

  @override
  _HangmanGameScreenState createState() => _HangmanGameScreenState();
}

class _HangmanGameScreenState extends State<HangmanGameScreen> {
  late List<String> displayWord;
  Set<String> guessedLetters = {};
  int attempts = 6;

  @override
  void initState() {
    super.initState();
    displayWord = List.filled(widget.secretWord.length, '_');
  }

  void guessLetter(String letter) {
    setState(() {
      guessedLetters.add(letter);
      if (widget.secretWord.contains(letter)) {
        for (int i = 0; i < widget.secretWord.length; i++) {
          if (widget.secretWord[i] == letter) {
            displayWord[i] = letter;
          }
        }
      } else {
        attempts--;
      }

      if (!displayWord.contains('_')) {
        _showEndDialog('¡Ganaste!', 'La palabra era: ${widget.secretWord}');
      } else if (attempts == 0) {
        _showEndDialog('¡Perdiste!', 'La palabra era: ${widget.secretWord}');
      }
    });
  }

  void _showEndDialog(String title, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Cierra diálogo
              Navigator.pop(context); // Vuelve al menú
            },
            child: Text('Volver al inicio'),
          )
        ],
      ),
    );
  }

  Widget buildKeyboard() {
    const letters = 'abcdefghijklmnopqrstuvwxyz';
    return Wrap(
      spacing: 5,
      runSpacing: 5,
      children: letters.split('').map((char) {
        return ElevatedButton(
          onPressed: guessedLetters.contains(char) ? null : () => guessLetter(char),
          child: Text(char),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Juego del Ahorcado'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              widget.isAgainstComputer
                  ? 'Modo: Contra la Computadora'
                  : 'Modo: Jugador vs Jugador',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('Intentos restantes: $attempts', style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            HangmanFigure(attemptsLeft: attempts), // <-- Muñeco agregado aquí
            SizedBox(height: 20),
            Text(displayWord.join(' '), style: TextStyle(fontSize: 32, letterSpacing: 2)),
            SizedBox(height: 30),
            buildKeyboard(),
          ],
        ),
      ),
    );
  }
}

// Widget para el dibujo del ahorcado
class HangmanFigure extends StatelessWidget {
  final int attemptsLeft;

  const HangmanFigure({required this.attemptsLeft});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(200, 300),
      painter: HangmanPainter(attemptsLeft),
    );
  }
}

class HangmanPainter extends CustomPainter {
  final int attemptsLeft;

  HangmanPainter(this.attemptsLeft);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 4;

    // Base
    canvas.drawLine(Offset(20, size.height - 20), Offset(size.width - 20, size.height - 20), paint);

    // Poste
    canvas.drawLine(Offset(50, size.height - 20), Offset(50, 20), paint);

    // Techo
    canvas.drawLine(Offset(50, 20), Offset(size.width / 2, 20), paint);

    // Cuerda
    canvas.drawLine(Offset(size.width / 2, 20), Offset(size.width / 2, 60), paint);

    if (attemptsLeft <= 5) {
      // Cabeza
      canvas.drawCircle(Offset(size.width / 2, 80), 20, paint);
    }
    if (attemptsLeft <= 4) {
      // Cuerpo
      canvas.drawLine(Offset(size.width / 2, 100), Offset(size.width / 2, 160), paint);
    }
    if (attemptsLeft <= 3) {
      // Brazo izquierdo
      canvas.drawLine(Offset(size.width / 2, 110), Offset(size.width / 2 - 30, 140), paint);
    }
    if (attemptsLeft <= 2) {
      // Brazo derecho
      canvas.drawLine(Offset(size.width / 2, 110), Offset(size.width / 2 + 30, 140), paint);
    }
    if (attemptsLeft <= 1) {
      // Pierna izquierda
      canvas.drawLine(Offset(size.width / 2, 160), Offset(size.width / 2 - 30, 200), paint);
    }
    if (attemptsLeft <= 0) {
      // Pierna derecha
      canvas.drawLine(Offset(size.width / 2, 160), Offset(size.width / 2 + 30, 200), paint);
    }
  }

  @override
  bool shouldRepaint(covariant HangmanPainter oldDelegate) {
    return oldDelegate.attemptsLeft != attemptsLeft;
  }
}
