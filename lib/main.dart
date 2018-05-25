import 'package:flutter/material.dart';
import 'components/board.dart';
import 'landing_page.dart';
import 'win_loss_overlay.dart';

enum TileState {covered,blown,open,flagged,revealed}

void main() {
  runApp(new MaterialApp(
    home: new LandingPage(),
    routes: <String,WidgetBuilder>{
      "gamepage" : (BuildContext context) => new MineSweeper(),
      "winoverlay" : (BuildContext context) => new WinLossOverlay(true, (){
        print('Won');
      }),
      "lossoverlay" : (BuildContext context) => new WinLossOverlay(false, (){
        print('Lost');
      }),
    },
    debugShowCheckedModeBanner: false,
  ));
}

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
