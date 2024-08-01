import 'dart:async';

import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/api/audioplayer.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/features/playback/playback.dart';
import 'package:rxdart/rxdart.dart';

import 'audio_play_button_container.dart';
import 'audio_play_button_content.dart';

class _PlayButtonState {
  _PlayButtonState({
    this.playingSourceId,
    this.playerPlayState = PlayerPlayState.paused,
  });

  final String? playingSourceId;
  final PlayerPlayState playerPlayState;

  @override
  bool operator ==(Object? other) {
    return (other is _PlayButtonState) &&
        other.runtimeType == runtimeType &&
        other.playingSourceId == playingSourceId &&
        other.playerPlayState == playerPlayState;
  }

  @override
  int get hashCode => Object.hash(playingSourceId, playerPlayState);
}

class PlaybackSourcePlayButton extends StatefulWidget {
  const PlaybackSourcePlayButton({
    Key? key,
    required this.scopeId,
    required this.size,
    this.iconSize,
    this.outOfScopeChild,
    required this.onTap,
  }) : super(key: key);

  final String scopeId;
  final double size;
  final double? iconSize;
  final Widget? outOfScopeChild;
  final VoidCallback onTap;

  @override
  State<PlaybackSourcePlayButton> createState() =>
      _PlaybackSourcePlayButtonState();
}

class _PlaybackSourcePlayButtonState extends State<PlaybackSourcePlayButton> {
  late _PlayButtonState _buttonState;
  late StreamSubscription _streamSubscription;

  @override
  void initState() {
    super.initState();

    _buttonState = _PlayButtonState();
    _streamSubscription =
        Rx.combineLatest3<String?, String?, PlayerPlayState, _PlayButtonState>(
      locator<KwotData>().playQueueRepository.loadingSourceIdStream,
      locator<KwotData>().playQueueRepository.primarySourceIdStream,
      audioPlayerManager.playerPlayStateStream,
      (loadingSourceId, playingSourceId, playerPlayState) {
        if (loadingSourceId != null) {
          return _PlayButtonState(
            playingSourceId: loadingSourceId,
            playerPlayState: PlayerPlayState.loading,
          );
        }

        return _PlayButtonState(
          playingSourceId: playingSourceId,
          playerPlayState: playerPlayState,
        );
      },
    ).distinct().listen((buttonState) {
      setState(() {
        _buttonState = buttonState;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final inScope = (widget.scopeId == _buttonState.playingSourceId);
    if (!inScope && widget.outOfScopeChild != null) {
      return widget.outOfScopeChild!;
    }

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
