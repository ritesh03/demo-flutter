import 'dart:async';

import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotdata/api/audioplayer.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/features/playback/playback.dart';
import 'package:rxdart/rxdart.dart';

import 'audio_play_button_container.dart';
import 'audio_play_button_content.dart';

class _PlayButtonState {
  _PlayButtonState({
    this.playingItemId,
    this.playerPlayState = PlayerPlayState.paused,
  });

  final String? playingItemId;
  final PlayerPlayState playerPlayState;

  @override
  bool operator ==(Object? other) {
    return (other is _PlayButtonState) &&
        other.runtimeType == runtimeType &&
        other.playingItemId == playingItemId &&
        other.playerPlayState == playerPlayState;
  }

  @override
  int get hashCode => Object.hash(playingItemId, playerPlayState);
}

class PlaybackItemPlayButton extends StatefulWidget {
  const PlaybackItemPlayButton({
    Key? key,
    required this.scopeId,
    required this.size,
    this.iconSize,
    required this.onTap,
  }) : super(key: key);

  final String scopeId;
  final double size;
  final double? iconSize;
  final VoidCallback onTap;

  @override
  State<PlaybackItemPlayButton> createState() => _PlaybackItemPlayButtonState();
}

class _PlaybackItemPlayButtonState extends State<PlaybackItemPlayButton> {
  late _PlayButtonState _buttonState;
  late StreamSubscription _streamSubscription;

  @override
  void initState() {
    super.initState();

    _buttonState = _PlayButtonState();
    _streamSubscription =
        Rx.combineLatest2<String?, PlayerPlayState, _PlayButtonState>(
            audioPlayerManager.playbackItemContentIdStream,
            audioPlayerManager.playerPlayStateStream,
            (playingItemId, playerPlayState) {
      return _PlayButtonState(
        playingItemId: playingItemId,
        playerPlayState: playerPlayState,
      );
    }).distinct().listen((buttonState) {
      setState(() {
        _buttonState = buttonState;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final inScope = (widget.scopeId == _buttonState.playingItemId);
    return AudioPlayButtonContainer(
      size: widget.size,
      isInScope: inScope,
      state: _buttonState.playerPlayState,
      onTap: _onTap,
      child: AudioPlayButtonContent(
        foregroundColor: DynamicTheme.get(context).white(),
        iconPadding: EdgeInsets.all(ComponentInset.small.r),
        iconSize: widget.iconSize ?? widget.size,
        isInScope: inScope,
        state: _buttonState.playerPlayState,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _streamSubscription.cancel();
  }

  void _onTap() {
    if (_buttonState.playerPlayState == PlayerPlayState.loading) return;
    widget.onTap();
  }
}
