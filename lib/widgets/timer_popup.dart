import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class TimerPopup extends StatefulWidget {
  @override
  _TimerPopupState createState() => _TimerPopupState();
}

class _TimerPopupState extends State<TimerPopup> {
  int _minutes = 0;
  int _seconds = 0;
  bool _isRunning = false;
  bool _isPaused = false;
  Duration _duration = Duration();
  Timer? _timer; // Initialize as nullable
  final AudioPlayer _audioPlayer = AudioPlayer();

  void _startTimer() {
    setState(() {
      _isRunning = true;
      _isPaused = false;
      _duration = Duration(minutes: _minutes, seconds: _seconds);
    });

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_duration.inSeconds > 0) {
          _duration -= Duration(seconds: 1);
        } else {
          _timer?.cancel();
          _isRunning = false;
          _playSound(); // Play sound when timer ends
        }
      });
    });
  }

  void _pauseTimer() {
    if (_isRunning) {
      _timer?.cancel();
      setState(() {
        _isPaused = true;
      });
    }
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _isPaused = false;
      _duration = Duration();
    });
  }

  void _restartTimer() {
    _timer?.cancel();
    setState(() {
      _duration = Duration(minutes: _minutes, seconds: _seconds);
      _startTimer();
    });
  }

  Future<void> _playSound() async {
    try {
      // Ensure the asset path is correct
      await _audioPlayer.play(AssetSource('sounds/Alarm1.wav'));
    } catch (e) {
      print('Error playing sound: $e');
    }
  }

  @override
  void dispose() {
    _timer?.cancel(); // Safely cancel the timer if it's running
    _audioPlayer.dispose(); // Dispose the audio player
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isLightTheme = theme.brightness == Brightness.light;
    final Color textColor = isLightTheme ? Color(0xFF283330) : Colors.white;
    final Color backgroundColor =
        isLightTheme ? Colors.white : Color(0xFF283330);

    return AlertDialog(
      title: Text(
        'Set Timer',
        style: TextStyle(fontSize: 22, color: textColor),
      ),
      backgroundColor: backgroundColor,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              SizedBox(height: 15),
              Expanded(
                child: TextField(
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      _minutes = int.tryParse(value) ?? 0;
                    });
                  },
                  decoration: InputDecoration(labelText: 'Minutes'),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: TextField(
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      _seconds = int.tryParse(value) ?? 0;
                    });
                  },
                  decoration: InputDecoration(labelText: 'Seconds'),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Text(
            'Time Remaining: ${_duration.inMinutes}:${(_duration.inSeconds % 60).toString().padLeft(2, '0')}',
            style: TextStyle(fontSize: 22, color: textColor),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: _isRunning && !_isPaused ? _pauseTimer : _startTimer,
                child: Text(_isRunning && !_isPaused ? 'Pause' : 'Start'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: _stopTimer,
                child: Text('Stop'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: _isRunning ? _restartTimer : null,
                child: Text('Restart'),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Close', style: TextStyle(color: backgroundColor),),
          style: ElevatedButton.styleFrom(
            backgroundColor: textColor,
          ),
        ),
      ],
    );
  }
}
