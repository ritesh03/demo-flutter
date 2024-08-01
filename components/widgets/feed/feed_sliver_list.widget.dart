import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/feed/feed_routing.dart';

import 'feed.widget.dart';

class FeedSliverList extends StatelessWidget {
  const FeedSliverList({
    Key? key,
    required this.feeds,
    this.padding,
    this.routing,
  }) : super(key: key);
  final List<Feed> feeds;
  final EdgeInsets? padding;
  final FeedRouting? routing;
  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (_, index) {
          final feed = feeds[index];
          if (feed.isEmpty) {
            return const SizedBox.shrink();
          }
          return Padding(
              padding: padding ?? EdgeInsets.only(top: ComponentInset.medium.r),
              child: FeedWidget(
                feed: feed,
                itemSpacing: ComponentInset.normal.r,
                routing: routing,
                titleTextStyle: TextStyles.boldHeading3,
              ));
        },
        childCount: feeds.length,
      ),
    );
  }
}
