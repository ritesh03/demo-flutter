import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotdata/models/models.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/button.dart';
import 'package:kwotmusic/l10n/localizations.dart';

class FeedActionButton extends StatelessWidget {
  const FeedActionButton({
    Key? key,
    required this.feed,
    required this.onTap,
  }) : super(key: key);

  final Feed feed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Button(
      height: ComponentSize.smaller.h,
      onPressed: onTap,
      text: feed.actionButtonTitle ?? LocaleResources.of(context).seeAll,
      type: ButtonType.text,
    );
  }
}

class AlignedFeedActionButton extends StatelessWidget {
  const AlignedFeedActionButton({
    Key? key,
    required this.feed,
    required this.onTap,
  }) : super(key: key);

  final Feed feed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Alignment buttonAlignment;
    switch (feed.actionButtonPosition) {
      case FeedActionButtonPosition.bottomCenter:
        buttonAlignment = Alignment.center;
        break;
      case FeedActionButtonPosition.bottomLeft:
        buttonAlignment = Alignment.centerLeft;
        break;
      case FeedActionButtonPosition.bottomRight:
        buttonAlignment = Alignment.centerRight;
        break;
      case FeedActionButtonPosition.inline:
        return const SizedBox.shrink();
    }

    return Container(
      alignment: buttonAlignment,
      child: FeedActionButton(feed: feed, onTap: onTap),
    );
  }
}
