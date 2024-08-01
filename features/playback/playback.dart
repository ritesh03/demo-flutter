import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/api/audioplayer.dart';
import 'package:kwotmusic/features/playback/video/video_playback.manager.dart';

export 'package:better_player/better_player.dart';
export 'package:playback_progress_bar/playback_progress_bar.dart';

export 'audio/audio_playback.bottomsheet.dart';
export 'audio/playback_item_actions.model.dart';
export 'audio/queue/play_queue_list_item.widget.dart';
export 'video/controls/video_controls_state.dart';
export 'video/controls/video_controls_visibility.model.dart';
export 'video/controls/video_playback_completed.widget.dart';
export 'video/controls/video_playback_controls.dart';
export 'video/controls/video_playback_error.widget.dart';
export 'video/controls/video_playback_subtitles.widget.dart';
export 'video/settings/video_playback_settings.bottomsheet.dart';
export 'video/video_handler.dart';
export 'video/video_handler_config.dart';
export 'video/video_item.dart';
export 'video/video_playback.manager.dart';
export 'video/video_playback_resolution.dart';
export 'video/video_playback_state.dart';
export 'video/video_playback_subtitle.dart';
export 'video/video_playback_subtitle_track.dart';
export 'video/video_playback_track.dart';
export 'video/widget/video_player.widget.dart';
export 'widget/compact_playback_bar.widget.dart';
export 'widget/playback_next_item_button.widget.dart';
export 'widget/playback_playing_queue_button.widget.dart';
export 'widget/playback_previous_item_button.widget.dart';
export 'widget/playback_remaining_duration.widget.dart';
export 'widget/playback_repeat_button.widget.dart';
export 'widget/playback_seek_backward_button.widget.dart';
export 'widget/playback_seek_forward_button.widget.dart';
export 'widget/playback_shuffle_button.widget.dart';
export 'widget/playbutton/audio_play_button.widget.dart';
export 'widget/playbutton/play_button.widget.dart';
export 'widget/playbutton/video_play_button.widget.dart';
export 'widget/player_artwork.widget.dart';
export 'widget/player_title_bar.widget.dart';
export 'widget/seekbar/audio_player_seekbar.widget.dart';
export 'widget/seekbar/player_seek_bar.widget.dart';
export 'widget/seekbar/video_player_seekbar.widget.dart';

AudioPlayerManager get audioPlayerManager => locator<AudioPlayerManager>();

VideoPlaybackManager get videoPlayerManager => locator<VideoPlaybackManager>();
