import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/button.dart';
import 'package:kwotmusic/l10n/localizations.dart';

class VideoPlaybackError extends StatelessWidget {
  const VideoPlaybackError({
    Key? key,
    required this.error,
    this.onRetry,
  }) : super(key: key);

  final String error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: Alignment.center,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          _buildErrorText(context),
          if (onRetry != null) SizedBox(height: ComponentInset.smaller.r),
          if (onRetry != null) _buildRetryButton(context)
        ]));
  }

  Widget _buildErrorText(BuildContext context) {
    return Text(LocaleResources.of(context).errorBroadcastCanNotBePlayed,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyles.body.copyWith(
          color: DynamicTheme.get(context).white(),
        ));
  }

  Widget _buildRetryButton(BuildContext context) {
    return Button(
        text: LocaleResources.of(context).tryAgainButton,
        type: ButtonType.text,
        height: ComponentSize.small.r,
        onPressed: () => onRetry?.call());
  }
}
