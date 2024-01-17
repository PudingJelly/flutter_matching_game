import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(const MatchingGameApp());
}

class MatchingGameApp extends StatelessWidget {
  const MatchingGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MatchingGame(),
    );
  }
}

class MatchingGame extends StatefulWidget {
  const MatchingGame({super.key});

  @override
  _MatchingGameState createState() => _MatchingGameState();
}

class _MatchingGameState extends State<MatchingGame> {
  late List<int> tileIndices;
  late List<bool> revealedTiles;
  List<bool> cardEnabled = List.filled(16, true); // 각 카드의 활성화 상태
  int? firstSelectedIndex;
  int? secondSelectedIndex;
  int selectedCardCount = 0;
  late Timer timer;

  @override
  void initState() {
    super.initState();
    initializeGame();
  }

  @override
  void dispose() {
    timer.cancel(); // 타이머 해제
    super.dispose();
    print('타이머 종료');
  }

  void initializeGame() {
    tileIndices = List.generate(8, (index) => index + 1);
    tileIndices = [...tileIndices, ...tileIndices];
    tileIndices.shuffle();

    revealedTiles = List<bool>.filled(16, true); // 초기에는 모두 뒤집혀 있음
    cardEnabled = List.filled(16, true); // 초기에는 모든 카드가 활성화 상태
    resetSelectedIndices();
    startTimer();

    // 새로운 게임이 시작될 때 초기 카드 레이아웃을 10초 동안 보여줌
    Future.delayed(const Duration(seconds: 10), () {
      setState(() {
        revealedTiles = List<bool>.filled(16, false);
      });
    });
  }

  void resetSelectedIndices() {
    firstSelectedIndex = null;
    secondSelectedIndex = null;
    selectedCardCount = 0;
  }

  void startTimer() {
    timer = Timer(const Duration(seconds: 10), () {
      // 일정 시간 후에 모든 카드를 가리기
      setState(() {
        revealedTiles = List<bool>.filled(16, false);
      });
    });
  }

  void checkMatch() {
    if (firstSelectedIndex != null && secondSelectedIndex != null) {
      int firstIndex = firstSelectedIndex!;
      int secondIndex = secondSelectedIndex!;

      if (firstIndex >= 0 &&
          firstIndex < revealedTiles.length &&
          secondIndex >= 0 &&
          secondIndex < revealedTiles.length &&
          tileIndices[firstIndex] == tileIndices[secondIndex]) {
        // 일치할 경우
        setState(() {
          revealedTiles[firstIndex] = true;
          revealedTiles[secondIndex] = true;
        });

        if (revealedTiles.every((element) => element)) {
          // 모든 짝을 맞춤
          showNewGameDialog();
        }
      } else {
        // 일치하지 않을 경우
        Future.delayed(const Duration(milliseconds: 500), () {
          setState(() {
            revealedTiles[firstIndex] = false;
            revealedTiles[secondIndex] = false;
            cardEnabled[firstIndex] = true; // 첫 번째 카드 활성화
            cardEnabled[secondIndex] = true; // 두 번째 카드 활성화
          });
        });
      }
    }
    resetSelectedIndices();
  }

  void revealCard(int index) {
    setState(() {
      revealedTiles[index] = !revealedTiles[index];
      selectedCardCount++;
      if (selectedCardCount == 1) {
        firstSelectedIndex = index;
      } else if (selectedCardCount == 2) {
        secondSelectedIndex = index;
        checkMatch();
      }
    });
  }

  void showRefeshGameDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Text('게임을 다시 시작하시겠습니까?'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  startNewGame();
                },
                child: const Text('다시하기'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("종료"),
              ),
            ],
          );
        });
  }

  void showNewGameDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('완성!!'),
          content: const Text('새로운 게임을 시작하시겠습니까?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                startNewGame();
              },
              child: const Text('다시하기'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('종료'),
            ),
          ],
        );
      },
    );
  }

  void startNewGame() {
    // 사용자가 새 게임을 시작하는 경우
    timer.cancel(); // 기존 타이머 해제
    setState(() {
      tileIndices.shuffle(); // 숫자 다시 섞기
    });
    initializeGame();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Matching Game'),
        ),
        body: Container(
          color: Colors.grey[900],
          padding: const EdgeInsets.only(top: 120),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
            ),
            itemCount: 16,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (!revealedTiles[index] &&
                        selectedCardCount < 2 &&
                        cardEnabled[index]) {
                      revealCard(index); // 카드 뒤집기
                      cardEnabled[index] = false; // 선택된 카드 비활성화
                    }
                  });
                },
                child: Container(
                  margin: const EdgeInsets.all(4),
                  color: revealedTiles[index] ? Colors.green : Colors.white54,
                  child: Center(
                    child: revealedTiles[index]
                        ? Text(
                            '${tileIndices[index]}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                            ),
                          )
                        : null,
                  ),
                ),
              );
            },
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // 진행 중인 게임을 다시 시작
            showRefeshGameDialog();
          },
          child: const Icon(Icons.refresh),
        ),
      ),
    );
  }
}
