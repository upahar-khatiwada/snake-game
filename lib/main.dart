import 'dart:math';

import 'package:flutter/material.dart';
import 'package:snake_game/enums.dart';
import 'dart:async';

void main() {
  runApp(const SnakeGame());
}

class SnakeGame extends StatefulWidget {
  const SnakeGame({super.key});

  @override
  State<SnakeGame> createState() => _SnakeGameState();
}

class _SnakeGameState extends State<SnakeGame> {
  bool canPauseNow = false;
  // Direction dir = Direction.values[Random().nextInt(Direction.values.length)];
  Timer? gameTimer;

  Direction dir = Direction.up;
  List<int> snakeArray = <int>[61, 81, 101];
  late int totalGridCount;
  late int foodPosition;
  late List<int> availableFoodPositions;

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
    gameTimer = Timer.periodic(const Duration(milliseconds: 300), (
      Timer timer,
    ) {
      if (!canPauseNow) {
        timer.cancel();
      } else {
        snakeMovement();
      }
    });
  }

  void snakeMovement() {
    setState(() {
      switch (dir) {
        case Direction.up:
          if (snakeArray.first < 20) {
            snakeArray = snakeArray.map((int pos) {
              return pos + totalGridCount - 20;
            }).toList();
          } else {
            snakeArray = snakeArray.map((int pos) {
              return pos - 20;
            }).toList();
          }
          break;
        case Direction.down:
          if (snakeArray.first > (totalGridCount - 20)) {
            snakeArray = snakeArray
                .map((int pos) => pos - totalGridCount + 20)
                .toList();
          } else {
            snakeArray = snakeArray.map((int pos) => pos + 20).toList();
          }
          break;
        case Direction.left:
          if ((snakeArray.first) % 20 == 0) {
            snakeArray = snakeArray.map((int pos) => pos + 20 - 1).toList();
          } else {
            snakeArray = snakeArray.map((int pos) => pos - 1).toList();
          }
          break;
        case Direction.right:
          if ((snakeArray.first + 1) % 20 == 0) {
            snakeArray = snakeArray.map((int pos) => pos - 20 + 1).toList();
          } else {
            snakeArray = snakeArray.map((int pos) => pos + 1).toList();
          }
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    final int totalGridCount = (screenHeight * 0.845).toInt();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.grey,
        appBar: AppBar(
          backgroundColor: Colors.grey,
          title: const Text('Score: 10', style: TextStyle(color: Colors.black)),
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

              if (dir != Direction.right && details.delta.dx > 0) {
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
      ),
    );
  }
}
