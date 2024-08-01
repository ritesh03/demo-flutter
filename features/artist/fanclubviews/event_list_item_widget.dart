import 'package:flutter/cupertino.dart';
import 'package:flutter_scale_tap/flutter_scale_tap.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kwotdata/models/artist/upcoming.events.dart';
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
import 'eventMeetGreetView/event_meet_view.dart';

class EventListItemWidget extends StatelessWidget {
  String? artistName;
  String artistId;
  UpcomingEvents  events;
   EventListItemWidget({Key? key,this.artistName,required this.artistId,required this.events}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ScaleTap(
          onPressed: (){
            DashboardNavigation.pushNamed(context, Routes.eventMeetView, arguments: EventMeetView(artistId: artistId,));
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: ComponentSize.eventViewHeight.h,
                width: ComponentSize.eventViewWidth.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(ComponentRadius.normal.r)
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children:<Widget> [
                    _buildPhotoView(events),
                    Positioned(
                      top: ComponentSize.small8.h,
                        left: ComponentSize.small8.w,
                        child: _buildDateTimeWidget(context,events)),
                    Positioned(
                        right: 8.w,
                        bottom: 8.h,
                        child: _buildEventFeeWidget(context,events)),

                  ],
                ),
              ),
              SizedBox(height: ComponentInset.small.h,),
              Text(events.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyles.heading5),
              Text(events.place??"",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyles.heading6.copyWith(color: DynamicTheme.get(context).neutral10()))
            ],
          ),
        ),

      ],
    );
  }
}
 Widget _buildPhotoView(UpcomingEvents  events){
  return Photo.skit(
    events.image,
    options: PhotoOptions(
      width: ComponentSize.eventViewWidth.w,
      height: ComponentSize.eventViewHeight.h,
      borderRadius: BorderRadius.circular(ComponentRadius.normal.r),
    ),
  );

 }

 Widget _buildDateTimeWidget(BuildContext context,UpcomingEvents  events){
  return Container(
    height: ComponentSize.small.h,
    decoration: BoxDecoration(
        color: DynamicTheme.get(context).black().withOpacity(0.5),
      borderRadius: BorderRadius.circular(ComponentRadius.normal.r)
    ),
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: ComponentRadius.normal.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            events.type??"",
            style: TextStyles.boldHeading5,
          ),
          Text(
            " - ${DateConvertor.dateToEventPageFormat(events.date)}h",
            style: TextStyles.heading5,
          ),
        ],
      ),
    ),

  );

 }

Widget _buildEventFeeWidget(BuildContext context,UpcomingEvents  events){
  return Container(
    height: ComponentSize.small.h,
    decoration: BoxDecoration(
        color: DynamicTheme.get(context).black().withOpacity(0.5),
        borderRadius: BorderRadius.circular(ComponentRadius.normal.r)
    ),
    child: Padding(
      padding:  EdgeInsets.symmetric(horizontal: ComponentRadius.normal.w),
      child:  events.isFreeEvent
          ? Center(
        child: Text(
          "Free",
          style: TextStyles.boldHeading7,
        ),
      )
          : Center(
          child: Text(
            "Just for fans - ${SharedPref.prefs!.getString(SharedPref.currencySymbol) ?? ""}${((num.parse(SharedPref.prefs!.getString(SharedPref.userAmount) ?? "0") ?? 0).toDouble() * (num.parse(events.payment?.price != null?events.payment?.price.toString()??"0":"0" ))).toString()}",
            style: TextStyles.robotoBoldHeading6,
          )),
    ),

  );

}

