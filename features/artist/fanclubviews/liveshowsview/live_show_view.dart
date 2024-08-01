import 'package:flutter/material.dart'  hide SearchBar;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kwotdata/models/liveshows/live_shows.dart';
import 'package:kwotmusic/core.dart';
import 'package:kwotmusic/features/artist/fanclubviews/liveshowsview/live_show_model.dart';
import 'package:provider/provider.dart';
import '../../../../components/kit/assets.dart';
import '../../../../components/kit/component_inset.dart';
import '../../../../components/kit/component_radius.dart';
import '../../../../components/kit/component_size.dart';
import '../../../../components/kit/textstyles.dart';
import '../../../../components/kit/theme/dynamic_theme.dart';
import '../../../../components/widgets/button.dart';
import '../../../../components/widgets/list/item_list.widget.dart';
import '../../../../components/widgets/photo/photo.dart';
import '../../../../components/widgets/textfield.dart';
import '../../../../l10n/localizations.dart';
import '../../../../navigation/dashboard_navigation.dart';
import '../../../../router/routes.dart';
import '../../../../util/date_time_methods.dart';
import '../../../../util/prefs.dart';
import '../../../dashboard/dashboard_config.dart';
import '../../../livestreaming/live_streaming_view.dart';
import '../../../show/countdown/live_show_countdown.model.dart';


class LiveShowView extends StatefulWidget {
  String artistId;
  LiveShowView({Key? key, required this.artistId}) : super(key: key);

  @override
  State<LiveShowView> createState() => _LiveShowViewState();
}

class _LiveShowViewState extends State<LiveShowView>
    with TickerProviderStateMixin {
  final searchController = TextEditingController();
  LiveShowModel get eventModel => context.read<LiveShowModel>();

  @override
  void initState() {
    eventModel.init(widget.artistId);
    //  eventModel.fetchProfile();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(
              // _PageTopBar
              95.h +
                  // SizedBox
                  ComponentInset.small.r +
                  // _SubscriptionPlanPurchaseStepBar
                  ComponentSize.normal.r +
                  // SizedBox
                  ComponentInset.normal.r,
            ),
            child: Column(children: [_buildProfileTopBar(context)]),
          ),
          body: Selector<LiveShowModel, bool>(
              selector: (_, model) => model.canShowCircularProgress,
              builder: (_, canShow, __) {
                if (!canShow) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return Selector<LiveShowModel, bool>(
                    selector: (_, model) => model.isEventListEmpty,
                    builder: (_, isEventListEmpty, __) {
                      if (isEventListEmpty) {
                        return _buildEmptyEventWidget(context);
                      }
                      return ItemListWidget<LiveShow, LiveShowModel>(
                          footerSlivers: [
                            DashboardConfigAwareFooter.asSliver()
                          ],
                          itemBuilder: (context, event, index) {
                            return Padding(
                              padding: EdgeInsets.only(
                                bottom: ComponentInset.medium.h,
                              ),
                              child: _EventListItem(
                                  getEvent: event,
                                  onTapJoin: () => _onTapJoinButton(context, event)),
                            );
                          });
                    });
              })),
    );
  }

  Widget _buildProfileTopBar(BuildContext context) {
    return Stack(
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              AppIconButton(
                  width: ComponentSize.large.r,
                  height: ComponentSize.large.r,
                  assetColor: DynamicTheme.get(context).white(),
                  assetPath: Assets.iconArrowLeft,
                  padding: EdgeInsets.all(ComponentInset.small.r),
                  onPressed: () => DashboardNavigation.pop(context)),
              const Spacer(),
            ]),
            _BuildPageTopBarWidget(
              text: LocaleResources.of(context).fanConnects,
            ),
            SizedBox(
              height: ComponentInset.normal.h,
            ),
            /*_EventViewStepBar(
                controller: _eventStepBarController,
                height: ComponentSize.normal.h,
                localeResource: LocaleResources.of(context),
                margin: EdgeInsets.symmetric(horizontal: ComponentInset.normal.r)),*/
            _SearchField(
              controller: searchController,
              eventModel: eventModel,
            ),
            SizedBox(
              height: ComponentInset.normal.h,
            ),
          ],
        ),
      ],
    );
  }
}

class _BuildPageTopBarWidget extends StatelessWidget {
  const _BuildPageTopBarWidget({
    Key? key,
    required this.text,
  }) : super(key: key);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.w),
      child: Column(
        children: [
          Text(text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyles.boldHeading2
                  .copyWith(color: DynamicTheme.get(context).neutral10())),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  TextEditingController controller;
  LiveShowModel eventModel;

  _SearchField({
    Key? key,
    required this.controller,
    required this.eventModel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.w),
        child: SearchBar(
            hintText: LocaleResources.of(context).searchFanConnect,
            onQueryChanged: eventModel.updateSearchQuery,
            onQueryCleared: eventModel.clearSearchQuery));
  }
}

class _EventListItem extends StatelessWidget {
  LiveShow getEvent;
  VoidCallback onTapJoin;

  _EventListItem({
    Key? key,
    required this.getEvent,
    required this.onTapJoin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 2,
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                _buildPhotoView(getEvent),
                Positioned(
                    top: ComponentSize.small8.h,
                    left: ComponentSize.small8.w,
                    child: _buildDateTimeWidget(context, getEvent)),
                Positioned(
                    right: ComponentSize.small8.w,
                    bottom: ComponentSize.small8.h,
                    child: _buildEventFeeWidget(
                      context,
                      getEvent,
                    )),
              ],
            ),
          ),
          SizedBox(
            height: ComponentInset.small.h,
          ),
          _TitleAndJoinButton(
            getEvent: getEvent,
            onTapJoin: onTapJoin,
          )
        ],
      ),
    );
  }
}

Widget _buildDateTimeWidget(BuildContext context, LiveShow getEvent) {
  return Container(
    height: ComponentSize.small.h,
    decoration: BoxDecoration(
        color: DynamicTheme.get(context).black().withOpacity(0.5),
        borderRadius: BorderRadius.circular(ComponentRadius.normal.r)),
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: ComponentRadius.normal.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          /*Text(
            getEvent.type.toCapitalized(),
            style: TextStyles.boldHeading5,
          ),*/
          getEvent.isCurrentLiveShow ?? false
              ? Text(
                  "Live",
                  style: TextStyles.heading5
                      .copyWith(color: DynamicTheme.get(context).primary120()),
                )
              : Text(
                  " ${DateConvertor.dateToEventPageFormat(getEvent.date.toString())}h",
                  style: TextStyles.heading5,
                ),
        ],
      ),
    ),
  );
}

class _TitleAndJoinButton extends StatelessWidget {
  LiveShow getEvent;
  VoidCallback onTapJoin;
  _TitleAndJoinButton(
      {Key? key, required this.getEvent, required this.onTapJoin})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.w),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    getEvent.showTitle ?? "",
                    style: TextStyles.boldHeading5,
                  ),
                  Text(
                    "",
                    style: TextStyles.heading5
                        .copyWith(color: DynamicTheme.get(context).neutral10()),
                  ),
                ],
              ),
              /*AppIconButton(
                  width: ComponentSize.large.r,
                  height: ComponentSize.large.r,
                  assetColor: DynamicTheme.get(context).white(),
                  assetPath: Assets.iconOptions,
                  fit: BoxFit.contain,
                  padding: EdgeInsets.only(
                      top: ComponentInset.small.h,
                      bottom: ComponentInset.small.h,
                      left: 20.w),
                  onPressed: () {})*/
            ],
          ),

          // buttonVisibility
          //     ?getEvent.isJoined?_buildYouAreOneEvent(context,getEvent):
          Button(
                  text: LocaleResources.of(context).join,
                  height: ComponentSize.large.h,
                  type: ButtonType.primary,
                  width: MediaQuery.of(context).size.width,
                  onPressed: onTapJoin)

          // : Container(),
        ],
      ),
    );
  }
}

Widget _buildEventFeeWidget(
  BuildContext context,
  LiveShow getEvent,
) {
  return Container(
    height: ComponentSize.small.h,
    decoration: BoxDecoration(
        color: DynamicTheme.get(context).black().withOpacity(0.5),
        borderRadius: BorderRadius.circular(ComponentRadius.normal.r)),
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: ComponentRadius.normal.w),
      child: getEvent.isFreeEvent ?? false
          ? Center(
              child: Text(
                "Free",
                style: TextStyles.boldHeading7,
              ),
            )
          : Center(
              child: Text(
              "Just for fans - ${SharedPref.prefs!.getString(SharedPref.currencySymbol) ?? ""}${((num.parse(SharedPref.prefs!.getString(SharedPref.userAmount) ?? "0") ?? 0).toDouble() * (num.parse(getEvent.payment != null?getEvent.payment!.price ==null? "0":getEvent.payment!.price.toString():"0"))).toString()}",
              style: TextStyles.robotoBoldHeading6,
            )),
    ),
  );
}

Widget _buildEventTimingWidget(BuildContext context, LiveShow getEvent) {
  return Container(
    height: ComponentSize.smaller.h,
    decoration: BoxDecoration(
        color: DynamicTheme.get(context).success(),
        borderRadius: BorderRadius.circular(ComponentRadius.normal.r)),
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: ComponentRadius.normal.w),
      child: Center(
          child: Text(
        DateConvertor.differenceBetweenNowToEvent(getEvent.date.toString()),
        style: TextStyles.boldHeading6
            .copyWith(color: DynamicTheme.get(context).black()),
      )),
    ),
  );
}

Widget _buildPhotoView(LiveShow getEvent) {
  return Photo.skit(
    getEvent.image,
    options: PhotoOptions(
      height: 217.h,
    ),
  );
}

enum EventSteps {
  all(position: 0),
  myEvents(position: 1);

  final int position;
  const EventSteps({
    required this.position,
  });
}

_onTapJoinButton(BuildContext context,LiveShow event) {

  if(event.isCurrentLiveShow??false){
    DashboardNavigation.pushNamed(context, Routes.liveStreaming,
      arguments: LiveStreamingView(
        showTitle: event.showTitle ?? "",
        artistImage: event.artistId?.thumbnail ?? "",
        channelName: event.channelName ?? "",
        serverUrl: event.agoraUrl ?? "", rtcToken: event.rtcUrl??"",
      ));
  }else{
    DashboardNavigation.pushNamed(
      context,
      Routes.liveShowCountdown,
      arguments: LiveShowCountdownArgs(show: event),
    );
  }



}

_buildEmptyEventWidget(BuildContext context) {
  return Center(
    child: Text(LocaleResources.of(context).noEventFound,
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
        textAlign: TextAlign.center,
        style: TextStyles.boldHeading2
            .copyWith(color: DynamicTheme.get(context).white())),
  );
}
