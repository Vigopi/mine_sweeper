import 'package:flutter/material.dart';
import 'components/board.dart';

enum TileState {covered,blown,open,flagged,revealed}

void main() => runApp(new MineSweeper());

class MineSweeper extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    // ignore: new_with_abstract_class
    return new MaterialApp(
      title: "Mine Sweeper",
      home: Board(),
      debugShowCheckedModeBanner: false,
    );
  }
}
