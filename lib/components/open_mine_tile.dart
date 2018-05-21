import 'package:flutter/material.dart';
import 'package:mine_sweeper/components/board.dart';
import 'package:mine_sweeper/main.dart';
class OpenMineTile extends StatelessWidget{

  final TileState state;
  final int count;
  OpenMineTile({this.state,this.count});

  final List textColor = [
    Colors.blue,
    Colors.green,
    Colors.red,
    Colors.purple,
    Colors.cyan,
    Colors.amber,
    Colors.brown,
    Colors.black,
  ];

  @override
  Widget build(BuildContext context) {
    Widget text;
    if(state == TileState.open){
      if(count != 0){
        text = RichText(
          text: TextSpan(
            text: '$count',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: textColor[count-1],
            ),
          ),
          textAlign: TextAlign.center,
        );
      }
    }
    else{
      text = RichText(
        text: TextSpan(
          text: '*',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        textAlign: TextAlign.center,
      );
    }
    return buildTile(buildInnerTile(text));
  }

}