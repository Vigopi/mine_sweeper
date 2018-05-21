import 'package:flutter/material.dart';
import 'board.dart';
class CoveredMineTile extends StatelessWidget{

  final bool flagged;
  final int posX;
  final int posY;

  CoveredMineTile({this.flagged,this.posX,this.posY});

  @override
  Widget build(BuildContext context) {
    Widget text;
    if(flagged){
      text = buildInnerTile(RichText(
        text: TextSpan(
          text: 'F',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        textAlign: TextAlign.center,
      ));
    }
    Widget innerTile = Container(
      padding: const EdgeInsets.all(1.0),
      margin: const EdgeInsets.all(2.0),
      height: 20.0,
      width: 20.0,
      color: Colors.grey[350],
      child: text,
    );

    return buildTile(innerTile);
  }
}