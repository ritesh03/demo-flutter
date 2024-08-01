import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart'  hide SearchBar;
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../components/kit/theme/dynamic_theme.dart';

class CustomOrientationControls extends StatelessWidget {
   CustomOrientationControls(
      {Key? key,this.iconSize = 20, this.fontSize = 12,})
      : super(key: key);
  final double iconSize;
  final double fontSize;


  @override
  Widget build(BuildContext context) {
    FlickVideoManager flickVideoManager =
        Provider.of<FlickVideoManager>(context);

    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: FlickAutoHideChild(
            child: Container(color: Colors.black38),
          ),
        ),
        Positioned.fill(
          child: FlickShowControlsAction(
            child: FlickSeekVideoAction(
              child: Center(
                child: flickVideoManager.nextVideoAutoPlayTimer != null
                    ? FlickAutoPlayCircularProgress(
                        colors: FlickAutoPlayTimerProgressColors(
                          backgroundColor: Colors.white30,
                          color: DynamicTheme.get(context).primary10(),
                        ),
                      )
                    : const FlickAutoHideChild(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: FlickPlayToggle(size: 50),
                        ),
                      ),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: FlickAutoHideChild(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          FlickCurrentPosition(
                            fontSize: fontSize,
                          ),
                          Text(
                            ' / ',
                            style: TextStyle(
                                color: Colors.white, fontSize: fontSize),
                          ),
                          FlickTotalDuration(
                            fontSize: fontSize,
                          ),
                        ],
                      ),
                      Expanded(
                        child: Container(),
                      ),
                      FlickFullScreenToggle(
                        size: iconSize,
                      ),
                    ],
                  ),
                  FlickVideoProgressBar(
                    flickProgressBarSettings: FlickProgressBarSettings(
                      height: 5,
                      handleRadius: 5,
                      curveRadius: 50,
                      backgroundColor: Colors.white24,
                      bufferedColor: Colors.white38,
                      playedColor: DynamicTheme.get(context).primary40(),
                      handleColor: DynamicTheme.get(context).primary10(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
