import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/l10n/localizations.dart';
import 'package:readmore/readmore.dart';

class PodcastDescription extends StatelessWidget {
  const PodcastDescription({
    Key? key,
    required this.text,
  }) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return ReadMoreText(
      text,
      trimLines: 2,
      style: TextStyles.body,
      trimMode: TrimMode.Line,
      trimCollapsedText: LocaleResources.of(context).readMore,
      trimExpandedText: LocaleResources.of(context).readLess,
      moreStyle: TextStyles.boldBody,
      lessStyle: TextStyles.boldBody,
    );
  }
}
