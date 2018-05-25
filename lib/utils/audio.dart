import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:audioplayer/audioplayer.dart';
//import 'package:audioplayers/audioplayer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';

typedef void OnError(Exception exception);

enum PlayerState { stopped, playing, paused }

class AudioPlay{
  Duration duration;
  Duration position;

  AudioPlayer audioPlayer;

  AudioPlay(){
    initAudioPlayer();
  }

  PlayerState playerState = PlayerState.stopped;

  get isPlaying => playerState == PlayerState.playing;
  get isPaused => playerState == PlayerState.paused;

  get durationText =>
      duration != null ? duration.toString().split('.').first : '';
  get positionText =>
      position != null ? position.toString().split('.').first : '';

  bool isMuted = false;

  void initAudioPlayer() {
    audioPlayer = new AudioPlayer();

    audioPlayer.setDurationHandler((d){
      duration = d;
    });

    audioPlayer.setPositionHandler((p) => () {
      position = p;
    });

    audioPlayer.setCompletionHandler(() {
      onComplete();

        position = duration;
    });

    audioPlayer.setErrorHandler((msg) {

        playerState = PlayerState.stopped;
        duration = new Duration(seconds: 0);
        position = new Duration(seconds: 0);
      });
  }

  Future<ByteData> loadAsset(String file) async {
    return await rootBundle.load('lib/sounds/${file}');
  }

  Future play(String fileName) async {
    final File file = new File("${(await getTemporaryDirectory()).path}/${fileName}");;
    await file.writeAsBytes((await loadAsset(fileName)).buffer.asUint8List());
    final result = await audioPlayer.play(file.path, isLocal: true);
    if (result == 1)
        print('_AudioAppState.play... PlayerState.playing');
        playerState = PlayerState.playing;
  }

  Future pause() async {
    final result = await audioPlayer.pause();
    if (result == 1)
      playerState = PlayerState.paused;
  }

  Future stop() async {
    final result = await audioPlayer.stop();
    if (result == 1)
        playerState = PlayerState.stopped;
        position = new Duration();
  }

  void onComplete() {
    playerState = PlayerState.stopped;
  }

}
