import 'package:flutter/material.dart';

class WinLossOverlay extends StatefulWidget{
  final bool isWin;
  final VoidCallback _onTap;
  WinLossOverlay(this.isWin,this._onTap);
  @override
  State<StatefulWidget> createState() {
    return new WinLossOverlayState();
  }

}

class WinLossOverlayState extends State<WinLossOverlay>{
  @override
  Widget build(BuildContext context) {
    return new Material(
      color: Colors.black54,
      child: new InkWell(
        onTap: () => widget._onTap,
        child: new Container(
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                widget.isWin ?
                Text("You Won the game!")
                    :
                Text("You lost the game!"),
                Text("Tap to start new Game"),
              ],
            )
        ),
      ),
    );
  }
}