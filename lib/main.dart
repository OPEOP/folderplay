import 'dart:async';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import 'package:Folderplay/managers/path_manager.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Folderplay',
      theme: ThemeData(
          // primarySwatch: Colors.blue,
          ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

enum STATUS {
  PLAYING,
  PAUSED,
  STOPPED,
  NEXT_SONG,
  PREVIOUS_SONG,
}

class _MyHomePageState extends State<MyHomePage> {
  PathManager _pm = PathManager();
  AudioPlayer _player = AudioPlayer();
  Timer? _everySecond;

  // StreamController<STATUS> _statusStream = StreamController<STATUS>();
  List<String> _playlist = [];
  bool _isPlaying = false;
  bool _isPaused = false;
  bool _isStopped = false;
  int _currentSongIndex = 0;
  Duration _currentPosition = Duration.zero;

  @override
  void initState() {
    super.initState();

    _player.playerStateStream.listen((state) {
      switch (state.processingState) {
        case ProcessingState.idle:
          {}
          break;
        case ProcessingState.loading:
          {}
          break;
        case ProcessingState.buffering:
          {}
          break;
        case ProcessingState.ready:
          {}
          break;
        case ProcessingState.completed:
          {
            _nextSong();
          }
      }
    });
  }

  void _positionUpdate() {
    _everySecond = Timer.periodic(Duration(seconds: 1), (Timer t) {
      setState(() {
        _currentPosition = _player.position;
      });
    });
  }

  void _stopPositionUpdate() {
    _everySecond!.cancel();
  }

  _stateManager(STATUS status) {
    if (!_hasPlaylist) return;

    switch (status) {
      case STATUS.PLAYING:
        {
          setState(() {
            _isPlaying = true;
            _isPaused = false;
            _isStopped = false;

            _player.setFilePath(_playlist[_currentSongIndex], initialPosition: _currentPosition);
            _player.play();
          });
          _positionUpdate();
        }
        break;
      case STATUS.PAUSED:
        {
          setState(() {
            _isPlaying = false;
            _isPaused = true;
            _isStopped = false;
            _currentPosition = _player.position;

            _player.setFilePath(_playlist[_currentSongIndex], initialPosition: _currentPosition);
            _player.pause();
          });
          _stopPositionUpdate();
        }
        break;
      case STATUS.STOPPED:
        {
          setState(() {
            _isPlaying = false;
            _isPaused = false;
            _isStopped = true;
            _currentPosition = Duration.zero;

            _player.setFilePath(_playlist[_currentSongIndex], initialPosition: _currentPosition);
            _player.pause();
          });
          _stopPositionUpdate();
        }
        break;
      case STATUS.NEXT_SONG:
        {
          setState(() {
            _isPlaying = true;
            _isPaused = false;
            _isStopped = false;
            _currentPosition = Duration.zero;
            _currentSongIndex = _currentSongIndex + 1;

            _player.setFilePath(_playlist[_currentSongIndex], initialPosition: _currentPosition);
            _player.play();
          });
          _positionUpdate();
        }
        break;
      case STATUS.PREVIOUS_SONG:
        {
          setState(() {
            _isPlaying = true;
            _isPaused = false;
            _isStopped = false;
            _currentPosition = Duration.zero;
            _currentSongIndex = _currentSongIndex - 1;

            _player.setFilePath(_playlist[_currentSongIndex], initialPosition: _currentPosition);
            _player.play();
          });
          _positionUpdate();
        }
        break;
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  void _selectFolder() async {
    List<String> newPlaylist = await _pm.getSelectedFolderFilesPaths();

    setState(() {
      _playlist = newPlaylist;
      _playlist.forEach((element) {
        print('==> $element');
      });
    });
  }

  // TODO: show slider with position of playble place
  // TODO: show 00:00:00 changing position
  // TODO: show 00:00:00 duration of song
  // TODO: show selectable list of songs
  void play() {
    if (_isPlaying) return;

    _stateManager(STATUS.PLAYING);
  }

  stop() {
    if (_isStopped) return;

    _stateManager(STATUS.STOPPED);
  }

  pause() {
    if (_isPaused) return;

    _stateManager(STATUS.PAUSED);
  }

  void _previousSong() {
    if (!_hasPreviousSong) return;

    _stateManager(STATUS.PREVIOUS_SONG);
  }

  void _nextSong() {
    if (!_hasNextSong) return;

    _stateManager(STATUS.NEXT_SONG);
  }

  bool get _hasNextSong => (_playlist.length - 2) - _currentSongIndex > 0;

  bool get _hasPreviousSong => _currentSongIndex > 0;

  bool get _hasPlaylist => _playlist.length > 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Folderplay'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text('Song: ${_hasPlaylist ? _playlist[_currentSongIndex] : ''}'),
                ),
                Flexible(
                  child: Text('Duration of song: ${_hasPlaylist ? _player.duration : ''}'),
                ),
                Flexible(
                  child: Text('Position: ${_hasPlaylist ? _currentPosition : ''}'),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(onPressed: _selectFolder, child: Text('Select Folder')),
                TextButton(onPressed: _hasPreviousSong ? _previousSong : null, child: Text('Previous')),
                TextButton(
                    onPressed: _hasPlaylist
                        ? !_isPlaying
                            ? play
                            : pause
                        : null,
                    child: Text(_isPlaying ? 'Pause' : 'Play')),
                TextButton(onPressed: _hasNextSong ? _nextSong : null, child: Text('Next')),
              ],
            )
          ],
        ),
      ),
    );
  }
}
