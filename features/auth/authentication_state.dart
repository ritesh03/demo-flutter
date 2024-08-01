import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotmusic/components/widgets/page/page_state.dart';
import 'package:kwotmusic/features/playback/audio/audio_playback_actions.model.dart';

abstract class AuthenticationState<T extends StatefulWidget>
    extends PageState<T> {
  //=

  @override
  void initState() {
    super.initState();

    // Stop playback
    locator<AudioPlaybackActionsModel>().stopPlayback();
  }
}
