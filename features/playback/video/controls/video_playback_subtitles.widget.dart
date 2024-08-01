import 'package:flutter/material.dart'  hide SearchBar;
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/multi_value_listenable_builder.widget.dart';
import 'package:kwotmusic/features/playback/playback.dart';

class VideoPlaybackSubtitlesWidget extends StatefulWidget {
  const VideoPlaybackSubtitlesWidget({Key? key}) : super(key: key);

  @override
  State<VideoPlaybackSubtitlesWidget> createState() =>
      _VideoPlaybackSubtitlesWidgetState();
}

class _VideoPlaybackSubtitlesWidgetState
    extends State<VideoPlaybackSubtitlesWidget> {
  //=

  late TextStyle _subtitleTextStyle;
  late TextStyle _subtitleStrokeTextStyle;

  @override
  void initState() {
    super.initState();

    _subtitleTextStyle =
        TextStyles.body.copyWith(color: DynamicTheme.get(context).white());

    _subtitleStrokeTextStyle = TextStyles.body.copyWith(
        foreground: Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.r
          ..color = DynamicTheme.get(context).black());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: double.infinity,
        width: double.infinity,
        padding: EdgeInsets.only(
            bottom: ComponentInset.medium.r,
            left: ComponentInset.large.w,
            right: ComponentInset.large.w),
        child: TwoValuesListenableBuilder<bool, VideoPlaybackSubtitle?>(
            valueListenable1: videoPlayerManager.isCaptionsOptionEnabledNotifier,
            valueListenable2: videoPlayerManager.currentSubtitleNotifier,
            builder: (_, enabled, subtitle, __) {
              if (!enabled || subtitle == null) {
                return Container();
              }

              return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: subtitle.texts.map((text) {
                    return _buildSubtitleText(text);
                  }).toList());
            }));
  }

  Widget _buildSubtitleText(String text) {
    return Stack(children: [
      HtmlWidget(text, textStyle: _subtitleStrokeTextStyle),
      HtmlWidget(text, textStyle: _subtitleTextStyle),
    ]);
  }
}
