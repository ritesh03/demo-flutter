import 'package:flutter/material.dart'  hide SearchBar;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/widgets/feed/feed_action_button.widget.dart';
import 'package:kwotmusic/components/widgets/feed/feed_routing.dart';
import 'package:kwotmusic/components/widgets/feed/feed_title_bar.widget.dart';
import 'package:kwotmusic/components/widgets/glow/glow.widget.dart';

import '../../../features/artist/fanclubviews/eventMeetGreetView/event_meet_view.dart';
import '../../../navigation/dashboard_navigation.dart';
import '../../../router/routes.dart';
import '../../../util/util_url_launcher.dart';
import '../../kit/textstyles.dart';
import '../../kit/theme/dynamic_theme.dart';
import 'feed_widget_items_builder.dart';

class FeedWidget extends StatelessWidget {
  const FeedWidget({
    Key? key,
    required this.feed,
    required this.itemSpacing,
    this.titleTextStyle,
    this.routing,
  }) : super(key: key);

  final Feed feed;
  final double itemSpacing;
  final TextStyle? titleTextStyle;
  final FeedRouting? routing;

  @override
  Widget build(BuildContext context) {
    if (feed.items.isEmpty) return Container();


    final itemsBuilder = FeedWidgetItemsBuilder.instance;
    final feedTitle = feed.title;
    final feedSubTitle = feed.subTitle;
    final widget = Column(
        children: [
      /// TITLE BAR
    if(feedSubTitle == null || feedSubTitle.isEmpty)...[
      if (feedTitle != null)
        FeedTitleBar(
          title: feedTitle,
          titleTextStyle: titleTextStyle,
          padding: EdgeInsets.symmetric(horizontal: itemSpacing),
          trailing: (feedTitle == "Upcoming events" ||feedTitle == "Fan Connects" || feedTitle == "Active discount"?true:feed.canLoadMore) && feed.actionButtonPosition.isInline
              ? FeedActionButton(feed: feed, onTap: () => _onSeeAllTap(context))
              :feedTitle == "Merchandising"?_buildVisitButton(context): null,
        ),
      /// SPACING: Title<->Items
      if (feedTitle != null) SizedBox(height: itemSpacing),
      ]else...[
        if(feedSubTitle == "Videos")...[
          exclusiveContentWidget(context,feed.id),
        ],
      FeedTitleBar(
        title: feedSubTitle,
        titleTextStyle: TextStyles.boldHeading4,
        padding: EdgeInsets.symmetric(horizontal: itemSpacing),
        trailing: feed.canLoadMore && feed.actionButtonPosition.isInline
            ? FeedActionButton(feed: feed, onTap: () => _onSeeAllTap(context))
            : null,
      ),
      if (feedSubTitle != null) SizedBox(height: itemSpacing),
    ],
      /// ITEMS
      itemsBuilder.buildItemList(
        context: context,
        feed: feed,
        itemSpacing: itemSpacing,
        routing: routing,
      ),
      /// SPACING: Items<->FeedActionButton
      if (feed.canLoadMore && !feed.actionButtonPosition.isInline)
        SizedBox(height: itemSpacing),
      /// FEED ACTION BUTTON: Other Positions
      if (feed.canLoadMore && !feed.actionButtonPosition.isInline)
        Padding(
            padding: EdgeInsets.symmetric(horizontal: itemSpacing),
            child: AlignedFeedActionButton(
                feed: feed, onTap: () => _onSeeAllTap(context))),
    ]);
      if (!feed.isEmpty && feed.structure.isGrid) {
        return Stack(children: [const Positioned.fill(child: Glow()), widget]);
      }
    return widget;
  }

  void _onSeeAllTap(BuildContext context) {
    final routing = this.routing ?? locator<FeedRouting>();
    routing.handleSeeAllTap(context, feed: feed);
  }
}

Widget exclusiveContentWidget(BuildContext context, String id){

  return  Padding(
    padding:  EdgeInsets.symmetric(horizontal: 16.w),
    child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text("Exclusive content",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyles.boldHeading3),
              GestureDetector(
                onTap: (){
                  DashboardNavigation.pushNamed(
                    context,
                    Routes.exclusiveContentView,
                  );
                },
                child: Text("See all",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyles.boldHeading5.copyWith(color:DynamicTheme.get(context).secondary100())),
              ),
            ],
          ),
  );
}

Widget _buildVisitButton(BuildContext context){
  return GestureDetector(
    onTap: ()=> _onTermsTextTapped(context),
    child: Text("Visit",
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyles.boldHeading5.copyWith(color:DynamicTheme.get(context).secondary100())),
  );
  
}
void _onTermsTextTapped(BuildContext context) {
  UrlLauncherUtil.openMerchandisingPage(context);
}