import 'dart:io';

import 'package:flutter/material.dart'  hide SearchBar;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kwotdata/models/artist/get.artist.events.dart';
import 'package:kwotdata/models/liveshows/live_shows.dart';
import 'package:kwotmusic/core.dart';
import 'package:kwotmusic/features/artist/fanclubviews/paymentbottomsheetevents/open_payment_bottom_sheet.dart';
import 'package:kwotmusic/features/artist/fanclubviews/watchshowbottomsheet/watch_show_bottom_sheet_view.dart';
import 'package:kwotmusic/util/string.extensions.dart';
import 'package:provider/provider.dart';
import '../../../../components/kit/assets.dart';
import '../../../../components/kit/component_inset.dart';
import '../../../../components/kit/component_radius.dart';
import '../../../../components/kit/component_size.dart';
import '../../../../components/kit/textstyles.dart';
import '../../../../components/kit/theme/dynamic_theme.dart';
import '../../../../components/widgets/alert_box_buy_token.dart';
import '../../../../components/widgets/button.dart';
import '../../../../components/widgets/list/item_list.widget.dart';
import '../../../../components/widgets/notificationbar/notification_bar.dart';
import '../../../../components/widgets/photo/photo.dart';
import '../../../../components/widgets/segmented_control_tabs.widget.dart';
import '../../../../components/widgets/textfield.dart';
import '../../../../l10n/localizations.dart';
import '../../../../navigation/dashboard_navigation.dart';
import '../../../../router/routes.dart';
import '../../../../util/date_time_methods.dart';
import '../../../../util/prefs.dart';
import '../../../../util/util_url_launcher.dart';
import '../../../dashboard/dashboard_config.dart';
import '../../../show/countdown/live_show_countdown.model.dart';
import '../watchshowbottomsheet/open_watch_show_bottom_sheet.dart';
import 'event_meet_model.dart';

class EventMeetView extends StatefulWidget {
  String artistId;
  EventMeetView({Key? key, required this.artistId}) : super(key: key);

  @override
  State<EventMeetView> createState() => _EventMeetViewState();
}

class _EventMeetViewState extends State<EventMeetView>
    with TickerProviderStateMixin {
  late final TabController _eventStepBarController;
  final searchController = TextEditingController();
  late final PageController _pageController;
  EventMeetModel get eventModel => context.read<EventMeetModel>();

  @override
  void initState() {
    eventModel.init(widget.artistId);
    eventModel.fetchProfile();
    _eventStepBarController = TabController(
        length: EventSteps.values.length, vsync: this, initialIndex: 0);
    _pageController = PageController(
      keepPage: true,
    );
    _eventStepBarController.addListener(() {
      if (_eventStepBarController.index == 0) {
       // _pageController.jumpToPage(0);
        if (eventModel.getEventsController.hasListeners) {
          eventModel.getEventsController.refresh();
        }
      } else {
       // _pageController.jumpToPage(1);
        if (eventModel.getEventsController.hasListeners) {
          eventModel.getEventsController.refresh();
        }
      }
    });
    eventModel.pageController = _pageController;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(
              // _PageTopBar
              145.h +
                  // SizedBox
                  ComponentInset.small.r +
                  // _SubscriptionPlanPurchaseStepBar
                  ComponentSize.normal.r +
                  // SizedBox
                  ComponentInset.normal.r,
            ),
            child: Column(children: [_buildProfileTopBar(context)]),
          ),
          body: Selector<EventMeetModel, bool>(
              selector: (_, model) => model.canShowCircularProgress,
              builder: (_, canShow, __) {
                if (!canShow) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return Selector<EventMeetModel, bool>(
                    selector: (_, model) => model.isEventListEmpty,
                    builder: (_, isEventListEmpty, __) {
                      if (isEventListEmpty) {
                        return _buildEmptyEventWidget(context);
                      }
                      return _BuildAllEventView(
                        eventModel: eventModel,
                        contoller: _eventStepBarController,
                      );

                        PageView(
                          controller: _pageController,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [

                            /*_BuildAllEventView(
                              eventModel: eventModel,
                              contoller: _eventStepBarController,
                            ),*/
                          ]);
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
              text: LocaleResources.of(context).eventsMeetGreets,
            ),
            SizedBox(
              height: ComponentInset.normal.h,
            ),
            _EventViewStepBar(
                controller: _eventStepBarController,
                height: ComponentSize.normal.h,
                localeResource: LocaleResources.of(context),
                margin:
                    EdgeInsets.symmetric(horizontal: ComponentInset.normal.r)),
            SizedBox(
              height: ComponentInset.normal.h,
            ),
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
  EventMeetModel eventModel;

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
            hintText: LocaleResources.of(context).searchEvent,
            onQueryChanged: eventModel.updateSearchQuery,
            onQueryCleared: eventModel.clearSearchQuery));
  }
}

class _BuildAllEventView extends StatelessWidget {
  EventMeetModel eventModel;
  TabController contoller;
  _BuildAllEventView(
      {Key? key, required this.eventModel, required this.contoller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ItemListWidget<GetArtistEvents, EventMeetModel>(
        footerSlivers: [DashboardConfigAwareFooter.asSliver()],
        // columnItemSpacing: ComponentInset.normal.r,
        itemBuilder: (context, event, index) {
          if (contoller.index == 0) {
            var symbol = event.payment != null
                ? event.payment!.currencySymbol ?? ""
                : "";
            return Padding(
              padding: EdgeInsets.only(
                bottom: ComponentInset.medium.h,
              ),
              child: _EventListItem(
                  isFromAll: false,
                  symbol: symbol,
                  buttonVisibility: true,
                  getEvent: event,
                  onTapJoin: () =>
                      _onTapJoinButton(context, eventModel, index, event)),
            );
          } else {
            if (event.isJoined) {
              var symbol = event.payment != null
                  ? event.payment!.currencySymbol ?? ""
                  : "";
              return Padding(
                padding: EdgeInsets.only(
                  bottom: ComponentInset.medium.h,
                ),
                child: _EventListItem(
                    isFromAll: true,
                    symbol: symbol,
                    buttonVisibility: false,
                    getEvent: event,
                    onTapJoin: () =>
                        _onTapJoinButton(context, eventModel, index, event)),
              );
            } else {
              return const SizedBox.shrink();
            }
          }
        });
  }
}

class _EventViewStepBar extends StatelessWidget {
  const _EventViewStepBar({
    Key? key,
    required this.controller,
    required this.height,
    required this.localeResource,
    required this.margin,
  }) : super(key: key);

  final TabController controller;
  final double height;
  final EdgeInsets margin;
  final TextLocaleResource localeResource;

  @override
  Widget build(BuildContext context) {
    return ControlledSegmentedControlTabBar<EventSteps>(
        controller: controller,
        height: height,
        items: EventSteps.values,
        margin: margin,
        itemTitle: (step) {
          switch (step) {
            case EventSteps.all:
              return localeResource.all;
            case EventSteps.myEvents:
              return localeResource.myEvents;
          }
        });
  }
}

class _EventListItem extends StatelessWidget {
  bool isFromAll;
  bool buttonVisibility;
  GetArtistEvents getEvent;
  VoidCallback onTapJoin;
  String? symbol;

  _EventListItem(
      {Key? key,
      required this.isFromAll,
      required this.buttonVisibility,
      required this.getEvent,
      required this.onTapJoin,
      required this.symbol})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        if(getEvent.isJoined){
          OpenWatchShowBottomSheet.show(context,  onTapWatch: () {
            DashboardNavigation.pushNamed(
              context,
              Routes.liveShowCountdown,
              arguments: LiveShowCountdownArgs(show: LiveShow(showTitle: getEvent.title,isFreeEvent: getEvent.isFreeEvent,date: DateTime.parse(getEvent.date),)),
            );
            RootNavigation.pop(context);
          }, image: getEvent.image??"", title: getEvent.title??"", tokens: getEvent.payment?.token.toString() ?? "0", artistName: "${getEvent.artist?.firstName??""} ${getEvent.artist?.lastName??""}");
        }
      },
      child: SizedBox(
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
                      child: _buildEventFeeWidget(context, getEvent, symbol)),
                  isFromAll
                      ? Positioned(
                          left: ComponentSize.small8.w,
                          bottom: ComponentSize.small8.h,
                          child: _buildEventTimingWidget(context, getEvent))
                      : Container()
                ],
              ),
            ),
            SizedBox(
              height: ComponentInset.small.h,
            ),
            _TitleAndJoinButton(
              isFromAll: isFromAll,
              buttonVisibility: buttonVisibility,
              getEvent: getEvent,
              onTapJoin: onTapJoin,
            )
          ],
        ),
      ),
    );
  }
}

Widget _buildDateTimeWidget(BuildContext context, GetArtistEvents getEvent) {
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
          Text(
            getEvent.type.toCapitalized(),
            style: TextStyles.boldHeading5,
          ),
          Text(
            " - ${DateConvertor.dateToEventPageFormat(getEvent.date)}h",
            style: TextStyles.heading5,
          ),
        ],
      ),
    ),
  );
}

class _TitleAndJoinButton extends StatelessWidget {
  bool isFromAll;
  bool buttonVisibility;
  GetArtistEvents getEvent;
  VoidCallback onTapJoin;
  _TitleAndJoinButton(
      {Key? key,
      required this.isFromAll,
      required this.buttonVisibility,
      required this.getEvent,
      required this.onTapJoin})
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
                    getEvent.title ?? "",
                    style: TextStyles.boldHeading5,
                  ),
                  Text(
                    getEvent.place ?? "",
                    style: TextStyles.heading5
                        .copyWith(color: DynamicTheme.get(context).neutral10()),
                  ),
                ],
              ),
              AppIconButton(
                  width: ComponentSize.large.r,
                  height: ComponentSize.large.r,
                  assetColor: DynamicTheme.get(context).white(),
                  assetPath: Assets.iconOptions,
                  fit: BoxFit.contain,
                  padding: EdgeInsets.only(
                      top: ComponentInset.small.h,
                      bottom: ComponentInset.small.h,
                      left: 20.w),
                  onPressed: () {})
            ],
          ),
          buttonVisibility
              ? SizedBox(
                  height: ComponentInset.small.h,
                )
              : Container(),
          buttonVisibility
              ? getEvent.isJoined
                  ? _buildYouAreOneEvent(context, getEvent)
                  : Button(
                      text: LocaleResources.of(context).join,
                      height: ComponentSize.large.h,
                      type: ButtonType.primary,
                      width: MediaQuery.of(context).size.width,
                      onPressed: onTapJoin)
              : Container(),
        ],
      ),
    );
  }
}

Widget _buildEventFeeWidget(
    BuildContext context, GetArtistEvents getEvent, String? symbol) {
  return Container(
    height: ComponentSize.small.h,
    decoration: BoxDecoration(
        color: DynamicTheme.get(context).black().withOpacity(0.5),
        borderRadius: BorderRadius.circular(ComponentRadius.normal.r)),
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: ComponentRadius.normal.w),
      child: getEvent.isFreeEvent
          ? Center(
              child: Text(
                "Free",
                style: TextStyles.boldHeading7,
              ),
            )
          : Center(
              child: Text(
              "Just for fans - ${SharedPref.prefs!.getString(SharedPref.currencySymbol) ?? ""}${((num.parse(SharedPref.prefs!.getString(SharedPref.userAmount) ?? "0") ?? 0).toDouble() * (num.parse(getEvent.payment?.price != null?getEvent.payment?.price.toString()??"0":"0" ))).toString()}",
              style: TextStyles.robotoBoldHeading6,
            )),
    ),
  );
}

Widget _buildEventTimingWidget(BuildContext context, GetArtistEvents getEvent) {
  return Container(
    height: ComponentSize.smaller.h,
    decoration: BoxDecoration(
        color: DynamicTheme.get(context).success(),
        borderRadius: BorderRadius.circular(ComponentRadius.normal.r)),
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: ComponentRadius.normal.w),
      child: Center(
          child: Text(
        DateConvertor.differenceBetweenNowToEvent(getEvent.date),
        style: TextStyles.boldHeading6
            .copyWith(color: DynamicTheme.get(context).black()),
      )),
    ),
  );
}

Widget _buildYouAreOneEvent(BuildContext context, GetArtistEvents getEvent) {
  return Container(
    height: ComponentSize.smaller.h,
    decoration: BoxDecoration(
        color: DynamicTheme.get(context).success(),
        borderRadius: BorderRadius.circular(ComponentRadius.normal.r)),
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            LocaleResources.of(context).youAreOnThisEvent,
            style: TextStyles.boldHeading6
                .copyWith(color: DynamicTheme.get(context).black()),
          ),
          Text(
            DateConvertor.differenceBetweenNowToEvent(getEvent.date),
            style: TextStyles.boldHeading6
                .copyWith(color: DynamicTheme.get(context).black()),
          ),
        ],
      ),
    ),
  );
}

Widget _buildPhotoView(GetArtistEvents getEvent) {
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

_onTapJoinButton(BuildContext context, EventMeetModel eventModel, int index, GetArtistEvents event) {
  if (event.isFreeEvent ) {
    OpenWatchShowBottomSheet.show(context,  onTapWatch: () {
      DashboardNavigation.pushNamed(
        context,
        Routes.liveShowCountdown,
        arguments: LiveShowCountdownArgs(show: LiveShow(showTitle: event.title,isFreeEvent: event.isFreeEvent,date: DateTime.parse(event.date),)),
      );
      RootNavigation.pop(context);
    }, image: event.image??"", title: event.title??"", tokens: event.payment?.token ?? "0", artistName: "${event.artist?.firstName??""} ${event.artist?.lastName??""}");
  } else {
    OpenPaymentBottomSheet.show(context,  onTapPayment: () {
      if (eventModel.profileResult!.data().tokens! >= int.parse((event.payment!.token !=null?event.payment!.token.toString():"0" ))) {
        ShowAlertBox.showAlertConfirmSubscription(context, onTapCancel: () {
          RootNavigation.pop(context);
        }, onTapBuy: () {
          eventModel.joinEventEvents(context, event.id).then((value) {
            if (value) {
              RootNavigation.popUntilRoot(context);
              showDefaultNotificationBar(
                NotificationBarInfo.success(
                    message:
                    LocaleResources.of(context).yourPurchaseConfirmation),
              );
            } else {
              RootNavigation.popUntilRoot(context);
              showDefaultNotificationBar(
                const NotificationBarInfo.error(
                    message: "Oops, something went wrong."),
              );
            }
          });
        },
            planName: event.title ?? "",
            tokens: event.payment!.token =="null"?"":event.payment!.token.toString(),
            isFromAEvent: true);
      } else {
          if (eventModel.billingDetailResult!.message != "Successful") {
            ShowAlertBox.showAlertForAddBillingDetails(context, onTapCancel: () {
              RootNavigation.pop(context);
            }, onTapBuy: () {
              DashboardNavigation.pushNamed(context, Routes.addBillingDetails).then((value) {
                eventModel.fetchBillingDetail();
              });
              RootNavigation.pop(context);
              RootNavigation.pop(context);
            });
          } else {
            if(Platform.isIOS) {
              DashboardNavigation.pushNamed(context, Routes.myWalletPage).then((value) {
                eventModel.fetchProfile();
              });
              RootNavigation.pop(context);
            }else {
              UrlLauncherUtil.buyToken(context).then((value) {
                eventModel.fetchProfile();
              });
            }
          }
      }
    },image: event.image??"", title: event.title??"", tokens: event.payment?.token.toString() ?? "0", artistName: "${event.artist?.firstName??""} ${event.artist?.lastName??""}");

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
