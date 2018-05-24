import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mine_sweeper/main.dart';
import 'dart:math';
import 'covered_mini_tile.dart';
import 'open_mine_tile.dart';
import '../utils/audio.dart';
import 'package:firebase_admob/firebase_admob.dart';

//import '../utils/app_id.dart' show APP_ID;

const String APP_ID = 'ca-app-pub-6530126704027329~8724032630';
const String BANNER_AD_UNIT_ID = 'ca-app-pub-6530126704027329/3028852821';
const String INTERSTITIAL_AD_UNIT_ID = 'ca-app-pub-6530126704027329/1256606154';

class Board extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return new BoardState();
  }
}

final String FLAG = "flag.mp3";
final String WIN = "win.mp3";
final String LOSS = "loss.mp3";

enum Hardness { easy, medium, hard }

class BoardState extends State<Board>{

  static final MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
    keywords: ['Games','Puzzles'],
    testDevices: APP_ID != null ? [APP_ID] : null
  );

  BannerAd bannerAd;
  InterstitialAd interstitialAd;

  BannerAd buildBanner(){
    return BannerAd(
      adUnitId: BANNER_AD_UNIT_ID,
      size: AdSize.banner,
      listener: (MobileAdEvent event){
        //if(event == MobileAdEvent.loaded)
         // bannerAd..show();
        print(event);
      }
    );
  }

  InterstitialAd buildInterstitialAd(){
    return InterstitialAd(
      adUnitId: INTERSTITIAL_AD_UNIT_ID,
      targetingInfo: targetingInfo,
      listener: (MobileAdEvent event){
        print(event);
      }
    );
  }

  AudioPlay audio;

  Hardness hardness = Hardness.hard;

  String hardnessText = "Hard";

  int rows = 9;
  int cols = 9;
  int numOfMines = 3;

  List<List<TileState>> uiState;
  List<List<bool>> tiles;

  bool alive;
  bool wonGame;
  int minesFound;
  Timer timer;
  Stopwatch stopwatch = Stopwatch();


  @override
  void dispose() {
    timer?.cancel();
    bannerAd?.dispose();
    interstitialAd?.dispose();
    super.dispose();
  }

  void resetBoard(){

    alive = true;
    wonGame = false;
    minesFound = 0;
    stopwatch.reset();

    if(hardness == Hardness.easy) {
      numOfMines = 3;
      rows = 4;
      cols = 4;
    }
    else if (hardness == Hardness.medium)
    {
      numOfMines = 6;
      rows = 6;
      cols = 6;
    }
    else if(hardness == Hardness.hard)
    {
      numOfMines = 9;
      rows = 8;
      cols = 8;
    }
    timer?.cancel();
    timer = Timer.periodic(Duration(seconds: 1),(Timer timer){
      setState(() {
      });
    });

    uiState = new List<List<TileState>>.generate(rows, (row){
      return new List<TileState>.filled(cols, TileState.covered);
    });

    tiles = new List<List<bool>>.generate(rows, (row){
      return new List<bool>.filled(cols, false);
    });

    Random random = Random();
    int remainingMines = numOfMines;
    while(remainingMines > 0){
      int pos = random.nextInt(rows * cols);
      int row = pos ~/ rows;
      int col = pos % cols;
      if(!tiles[row][col]){
        tiles[row][col] = true;
        remainingMines--;
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    audio = new AudioPlay();
    resetBoard();
    super.initState();

    FirebaseAdMob.instance.initialize(appId: APP_ID);
    bannerAd = buildBanner()..load();
    interstitialAd = buildInterstitialAd()..load();
  }

  Widget buildBoard(){

    bool hasCoveredCell = false;

    List<Row> boardRow = <Row>[];
    for(int y=0;y< rows;y++){
      List<Widget> rowChildren = <Widget>[];
      for(int x=0;x<cols;x++){
        TileState state = uiState[y][x];
        int count = mineCount(x, y);

        if(!alive){
          if(state != TileState.blown){
            state = tiles[y][x] ? TileState.revealed : state;
          }
        }

        if(state == TileState.covered || state == TileState.flagged){
          rowChildren.add(GestureDetector(
            onLongPress: (){
              if(alive) {
                if (audio == null)
                  audio = new AudioPlay();
                if(!tiles[y][x])
                  audio.play(FLAG);
                else
                  audio.play(WIN);
                //flagPlayer.play("http://www.rxlabz.com/labz/audio2.mp3");
              }
              flag(x, y);
            },
            onTap: (){
             if(state == TileState.covered){
               if(alive) {
                 if (audio == null)
                   audio = new AudioPlay();
                 if (!tiles[y][x])
                   audio.play(FLAG);
                 else
                   audio.play(LOSS);
               }
               probe(x, y);
             }

            },
            child: Listener(
              child: CoveredMineTile(
                flagged: state == TileState.flagged,
                posX: x,
                posY: y,
              ),
            ),
          ));
          if(state == TileState.covered){
            hasCoveredCell = true;
          }
        }
        else {
          rowChildren.add(OpenMineTile(
            state: state,
            count: count,
          ));
        }
      }
      boardRow.add(Row(
        children: rowChildren,
        mainAxisAlignment: MainAxisAlignment.center,
        key: ValueKey<int>(y),
      ));
    }
    if(!hasCoveredCell){
      if((minesFound == numOfMines) && alive){
        wonGame = true;
        stopwatch.stop();
      }
    }
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: boardRow,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int timeElasped = stopwatch.elapsedMilliseconds ~/1000;
    double position =0.0;

    bannerAd..load()..show();

    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        centerTitle: true,
        title: Text('Mine Sweeper'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(45.0),
          child: Row(
            children: <Widget>[
              FlatButton(
                child: Text(
                  "Reset Game",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: (){
                  resetBoard();
                  interstitialAd..load()..show();
                },
                highlightColor: Colors.green,
                splashColor: Colors.redAccent,
                shape: StadiumBorder(
                  side: BorderSide(color: Colors.blue[200])
                ),
                color: Colors.blueAccent[100],
              ),
              Container(
                height: 40.0,
                alignment: Alignment.center,
                child: RichText(
                  text: TextSpan(
                    text: wonGame ? " You've Won! $timeElasped seconds" :
                        alive ?
                            " [Mines Found: $minesFound] [Total Mines: $numOfMines]\n [$timeElasped seconds]"
                            : " You've Lost: $timeElasped seconds"

                  ),

                ),
              ),
            ],
          ),
        ),
      ),
      body: Container(
        color: Colors.white,
        child: Center(
          child: Column(
            children: <Widget>[
              buildBoard(),
              Row(
                children: <Widget>[

                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void probe(int x,int y){
    if(!alive)
      return;
    if(uiState[y][x] == TileState.flagged)
      return;
    setState(() {
      if(tiles[y][x]){
        uiState[y][x] = TileState.blown;
        alive = false;
        timer.cancel();
      }
      else{
        open(x, y);
        if(!stopwatch.isRunning)
          stopwatch.start();
      }
    });
  }

  void open(int x,int y){
    if(!inBoard(x, y))
      return;
    if(uiState[y][x] ==TileState.open)
      return;
    uiState[y][x] = TileState.open;
    if(mineCount(x, y) > 0)
      return;
    open(x-1, y);
    open(x+1, y);
    open(x-1, y-1);
    open(x+1, y-1);
    open(x-1, y+1);
    open(x+1, y+1);
    open(x, y-1);
    open(x, y+1);
  }

  void flag(int x,int y){
    if(!alive)
      return;
    setState(() {

      if(uiState[y][x] == TileState.flagged){
        uiState[y][x] = TileState.covered;
        if(tiles[y][x])
        --minesFound;
      }
      else{
        uiState[y][x] = TileState.flagged;
        if(tiles[y][x])
        ++minesFound;
      }
    });
  }

  int mineCount(int x,int y){
    int count = 0;
    count += bombs(x-1,y);
    count += bombs(x+1,y);
    count += bombs(x,y-1);
    count += bombs(x,y+1);
    count += bombs(x-1,y-1);
    count += bombs(x-1,y+1);
    count += bombs(x+1,y-1);
    count += bombs(x+1,y+1);
    return count;
  }

  int bombs(int x,int y) => inBoard(x, y) && tiles[y][x] ? 1 : 0;

  bool inBoard(int x,int y) => x >= 0 && x < cols && y >= 0 && y < rows;

}

Widget buildTile(Widget child){
  return Container(
    padding: const EdgeInsets.all(1.0),
    height: 25.0,
    width: 25.0,
    color: Colors.grey[400],
    margin: const EdgeInsets.all(2.0),
    child: child,
  );
}

Widget buildInnerTile(Widget child){
  return Container(
    padding: const EdgeInsets.all(1.0),
    height: 15.0,
    width: 15.0,
    margin: const EdgeInsets.all(2.0),
    child: child,
  );
}