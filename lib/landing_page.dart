import 'package:flutter/material.dart';

class LandingPage extends StatelessWidget{
  @override
  Widget build(BuildContext context)
  {
    return new Material(
      color: Colors.blueAccent,
      child: new InkWell(
        onTap: ()=>Navigator.of(context).pushNamed("gamepage"),
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Text("Play Mine Sweeper",textDirection: TextDirection.rtl,style: new TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 35.0),),
            new Text("Tap to start",textDirection: TextDirection.rtl,style: new TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 20.0),),
          ],
        ),
      ),
    );
  }
}