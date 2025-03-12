import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(ChangeNotifierProvider(
    create: (_) => GameProvider(),
    child: const CardMatchingGame(),
  ));
}

class CardMatchingGame extends StatelessWidget {
  const CardMatchingGame({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Card Matching Game')),
        body: const GameBoard(),
      ),
    );
  }
}

class GameBoard extends StatelessWidget {
  const GameBoard({super.key});

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('Time: ${game.elapsedTime}s | Score: ${game.score}',
              style: const TextStyle(fontSize: 18)),
        ),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            padding: const EdgeInsets.all(16),
            itemCount: game.cards.length,
            itemBuilder: (context, index) {
              return CardWidget(card: game.cards[index]);
            },
          ),
        ),
        ElevatedButton(
          onPressed: game.resetGame,
          child: const Text('Restart Game'),
        ),
      ],
    );
  }
}

class CardWidget extends StatelessWidget {
  final CardModel card;
  const CardWidget({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context, listen: false);
    return GestureDetector(
      onTap: () => game.flipCard(card),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: card.isFaceUp
            ? Container(
          key: ValueKey(card.id),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.black),
          ),
          child: Center(child: Text(card.value)),
        )
            : Container(
          key: ValueKey('${card.id}-back'),
          color: Colors.blue,
        ),
      ),
    );
  }
}

class GameProvider extends ChangeNotifier {
  List<CardModel> cards = [];
  CardModel? firstSelected;
  int score = 0;
  int elapsedTime = 0;
  Timer? _timer;

  GameProvider() {
    _initializeGame();
  }

  void _initializeGame() {
    List<String> values = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'];
    values = [...values, ...values];
    values.shuffle();
    cards = List.generate(values.length, (index) => CardModel(id: '$index', value: values[index]));
    score = 0;
    elapsedTime = 0;
    _startTimer();
  }

  void flipCard(CardModel card) {
    if (card.isFaceUp || card.isMatched) return;
    card.isFaceUp = true;
    notifyListeners();

    if (firstSelected == null) {
      firstSelected = card;
    } else {
      if (firstSelected!.value == card.value) {
        firstSelected!.isMatched = true;
        card.isMatched = true;
        score += 10;
      } else {
        Future.delayed(const Duration(seconds: 1), () {
          firstSelected!.isFaceUp = false;
          card.isFaceUp = false;
          notifyListeners();
        });
      }
      firstSelected = null;
    }
    notifyListeners();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      elapsedTime++;
      notifyListeners();
    });
  }

  void resetGame() {
    _initializeGame();
    notifyListeners();
  }
}

class CardModel {
  final String id;
  final String value;
  bool isFaceUp;
  bool isMatched;

  CardModel({required this.id, required this.value, this.isFaceUp = false, this.isMatched = false});
}
