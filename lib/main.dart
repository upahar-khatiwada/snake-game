import 'dart:math';
import 'package:flutter/material.dart';
import 'package:snake_game/enums.dart';
import 'dart:async';

void main() {
  runApp(
    const MaterialApp(debugShowCheckedModeBanner: false, home: SnakeGame()),
  );
}

class SnakeGame extends StatefulWidget {
  const SnakeGame({super.key});

  @override
  State<SnakeGame> createState() => _SnakeGameState();
}

class _SnakeGameState extends State<SnakeGame> {
  bool canPauseNow = false;
  bool isOut = false;
  // Direction dir = Direction.values[Random().nextInt(Direction.values.length)];

  Direction dir = Direction.up;
  List<int> snakeArray = <int>[61, 81, 101];
  late int totalGridCount;
  late int foodPosition;
  late List<int> availableFoodPositions;
  int currentScore = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    totalGridCount = (MediaQuery.of(context).size.height * 0.845).toInt();

    availableFoodPositions = List<int>.generate(
      totalGridCount,
      (int index) => index,
    ).where((int pos) => !snakeArray.contains(pos)).toList();

    foodPosition =
        availableFoodPositions[Random().nextInt(availableFoodPositions.length)];
  }

  void startGame() {
    Timer.periodic(const Duration(milliseconds: 250), (Timer timer) {
      if (!canPauseNow) {
        timer.cancel();
      } else {
        snakeMovement();
      }
    });
  }

  Future<void> gameOver() async {
    setState(() {
      isOut = true;
    });

    if (mounted) {
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Game Over!!!'),
            content: Text('Score: $currentScore'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);

                  setState(() {
                    currentScore = 0;
                    isOut = false;
                    canPauseNow = true;

                    dir = Direction.up;
                    snakeArray = <int>[61, 81, 101];

                    availableFoodPositions = List<int>.generate(
                      totalGridCount,
                      (int index) => index,
                    ).where((int pos) => !snakeArray.contains(pos)).toList();

                    foodPosition =
                        availableFoodPositions[Random().nextInt(
                          availableFoodPositions.length,
                        )];
                  });

                  startGame();
                },
                child: const Text('Play Again!'),
              ),
            ],
          );
        },
      );
    }
  }

  void snakeMovement() {
    if (!isOut) {
      setState(() {
        int head;
        switch (dir) {
          case Direction.up:
            head = (snakeArray.first < 20)
                ? snakeArray.first + totalGridCount - 20
                : snakeArray.first - 20;
            break;

          case Direction.down:
            head = (snakeArray.first >= totalGridCount - 20)
                ? snakeArray.first - totalGridCount + 20
                : snakeArray.first + 20;
            break;

          case Direction.left:
            head = (snakeArray.first % 20 == 0)
                ? snakeArray.first + 19
                : snakeArray.first - 1;
            break;

          case Direction.right:
            head = ((snakeArray.first + 1) % 20 == 0)
                ? snakeArray.first - 19
                : snakeArray.first + 1;
            break;
        }

        if (snakeArray.contains(head)) {
          isOut = true;
          gameOver();
          return;
        }

        snakeArray.insert(0, head);

        if (head == foodPosition) {
          currentScore += 1;

          availableFoodPositions = List<int>.generate(
            totalGridCount,
            (int index) => index,
          ).where((int pos) => !snakeArray.contains(pos)).toList();

          foodPosition =
              availableFoodPositions[Random().nextInt(
                availableFoodPositions.length,
              )];
        } else {
          snakeArray.removeLast();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    final int totalGridCount = (screenHeight * 0.845).toInt();
    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(
        backgroundColor: Colors.grey,
        title: Text(
          'Score: $currentScore',
          style: const TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            onPressed: () {
              setState(() {
                canPauseNow = !canPauseNow;
                startGame();
              });
            },
            icon: canPauseNow
                ? const Icon(Icons.pause)
                : const Icon(Icons.play_arrow),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.only(
          right: screenWidth * 0.03,
          left: screenWidth * 0.03,
          bottom: screenHeight * 0.07,
        ),
        child: GestureDetector(
          onVerticalDragUpdate: (DragUpdateDetails details) {
            if (dir != Direction.up && details.delta.dy > 0) {
              dir = Direction.down;
            }

            if (dir != Direction.down && details.delta.dy < 0) {
              dir = Direction.up;
            }
          },
          onHorizontalDragUpdate: (DragUpdateDetails details) {
            if (dir != Direction.left && details.delta.dx > 0) {
              dir = Direction.right;
            }

            if (dir != Direction.right && details.delta.dx < 0) {
              dir = Direction.left;
            }
          },
          child: Container(
            decoration: BoxDecoration(
              border: BoxBorder.all(color: Colors.black38),
            ),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 20,
              ),
              physics: const NeverScrollableScrollPhysics(),
              itemCount: totalGridCount,
              itemBuilder: (BuildContext context, int index) {
                if (snakeArray.contains(index)) {
                  if (snakeArray.first == index) {
                    return Padding(
                      padding: const EdgeInsets.all(0.5),
                      child: Container(color: Colors.red),
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.all(0.5),
                    child: Container(color: Colors.black),
                  );
                }

                if (index == foodPosition) {
                  return Padding(
                    padding: const EdgeInsets.all(0.5),
                    child: Container(color: Colors.green),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.all(0.5),
                  child: Container(color: Colors.white),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
