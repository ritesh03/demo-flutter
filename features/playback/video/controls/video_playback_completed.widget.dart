import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/button.dart';
import 'package:kwotmusic/l10n/localizations.dart';

class VideoPlaybackCompleted extends StatelessWidget {
  const VideoPlaybackCompleted({
    Key? key,
    required this.message,
    this.onReplayTap,
  }) : super(key: key);

  final String message;
  final VoidCallback? onReplayTap;

  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: Alignment.center,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          _buildText(context),
          if (onReplayTap != null) SizedBox(height: ComponentInset.smaller.r),
          if (onReplayTap != null) _buildReplayButton(context)
        ]));
  }

  Widget _buildText(BuildContext context) {
    return Text(message,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style:
            TextStyles.body.copyWith(color: DynamicTheme.get(context).white()));
  }

  Widget _buildReplayButton(BuildContext context) {
    return Button(
        text: LocaleResources.of(context).videoReplayButton,
        type: ButtonType.text,
        height: ComponentSize.small.r,
        onPressed: () => onReplayTap?.call());
  }
}
