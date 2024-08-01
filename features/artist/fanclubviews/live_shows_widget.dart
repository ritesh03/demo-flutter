import 'package:flutter/cupertino.dart';
import 'package:flutter_scale_tap/flutter_scale_tap.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kwotdata/models/liveshows/live_shows.dart';
import '../../../components/kit/component_inset.dart';
import '../../../components/kit/component_radius.dart';
import '../../../components/kit/component_size.dart';
import '../../../components/kit/textstyles.dart';
import '../../../components/kit/theme/dynamic_theme.dart';
import '../../../components/widgets/photo/photo.dart';
import '../../../navigation/dashboard_navigation.dart';
import '../../../router/routes.dart';
import '../../../util/date_time_methods.dart';
import '../../../util/prefs.dart';
import 'liveshowsview/live_show_view.dart';

class LiveShowsWidget extends StatelessWidget {
  String? artistName;
  String artistId;
  LiveShow show;
  LiveShowsWidget(
      {Key? key, this.artistName, required this.artistId, required this.show})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ScaleTap(
          onPressed: () {

            DashboardNavigation.pushNamed(context, Routes.liveShowView,
                arguments: LiveShowView(
                  artistId: show.artistId?.id??"",
                ));
            /*DashboardNavigation.pushNamed(context, Routes.liveStreaming,
                arguments: LiveStreamingView(
                  showTitle: show.showTitle ?? "",
                  artistImage: show.artistId?.thumbnail ?? "",
                  channelName: show.channelName ?? "",
                  serverUrl: show.agoraUrl ?? "",
                ));*/
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: ComponentSize.eventViewHeight.h,
                width: ComponentSize.eventViewWidth.w,
                decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(ComponentRadius.normal.r)),
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    _buildPhotoView(show),
                    Positioned(
                        top: ComponentSize.small8.h,
                        left: ComponentSize.small8.w,
                        child: _buildDateTimeWidget(context, show)),
                    Positioned(
                        right: 8.w,
                        bottom: 8.h,
                        child: _buildEventFeeWidget(context, show)),
                  ],
                ),
              ),
              SizedBox(
                height: ComponentInset.small.h,
              ),
              Text(show.showTitle ?? "",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyles.heading5),
              Text("",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyles.heading6
                      .copyWith(color: DynamicTheme.get(context).neutral10()))
            ],
          ),
        ),
      ],
    );
  }
}

Widget _buildPhotoView(LiveShow shows) {
  return Photo.skit(
    shows.image,
    options: PhotoOptions(
      width: ComponentSize.eventViewWidth.w,
      height: ComponentSize.eventViewHeight.h,
      borderRadius: BorderRadius.circular(ComponentRadius.normal.r),
    ),
  );
}

Widget _buildDateTimeWidget(BuildContext context, LiveShow shows) {
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
            shows.type??"",
            style: TextStyles.boldHeading5,
          ),*/
          Text(
            "${DateConvertor.dateToEventPageFormat(shows.date.toString())}h",
            style: TextStyles.heading5,
          ),
        ],
      ),
    ),
  );
}

Widget _buildEventFeeWidget(BuildContext context, LiveShow shows) {
  return Container(
    height: ComponentSize.small.h,
    decoration: BoxDecoration(
        color: DynamicTheme.get(context).black().withOpacity(0.5),
        borderRadius: BorderRadius.circular(ComponentRadius.normal.r)),
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: ComponentRadius.normal.w),
      child: shows.isFreeEvent ?? false
          ? Center(
              child: Text(
                "Free",
                style: TextStyles.boldHeading7,
              ),
            )
          : Center(
              child: Text(
              "Just for fans - ${SharedPref.prefs!.getString(SharedPref.currencySymbol)??""}${((num.parse(SharedPref.prefs!.getString(SharedPref.userAmount)??"0")??0).toDouble() * (num.parse(shows.payment?.token != null?shows.payment?.token??"0":"0"))).toString()}",
              style: TextStyles.robotoBoldHeading6,
            )),
    ),
  );
}
