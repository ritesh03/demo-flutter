import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/photo/svg_asset_photo.dart';
import '../../../../components/widgets/bottomsheet/bottomsheet_drag_handle.widget.dart';

import '../../../../l10n/localizations.dart';

class CommentBottomSheetLiveShow extends StatefulWidget {
  CommentBottomSheetLiveShow({
    Key? key,
  }) : super(key: key);

  @override
  State<CommentBottomSheetLiveShow> createState() =>
      _CommentBottomSheetLiveShowState();
}

class _CommentBottomSheetLiveShowState
    extends State<CommentBottomSheetLiveShow> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      return  Container(
            height: (WidgetsBinding.instance.window.viewInsets.bottom > 0.0)?double.maxFinite:416.h,
            color: DynamicTheme.get(context).neutral80(),
            child: Column(
              children: <Widget>[
                Center(
                  child: BottomSheetDragHandle(
                    margin: EdgeInsets.only(
                        top: ComponentInset.small.h,
                        bottom: ComponentInset.small.h),
                  ),
                ),
                Container(
                  height: 325.h,
                  child: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        _BuildCommentView(),
                        SizedBox(
                          height: 8.h,
                        ),
                        _BuildCommentView(),
                        SizedBox(
                          height: 8.h,
                        ),
                        _BuildCommentView(),
                        SizedBox(
                          height: 8.h,
                        ),
                        _BuildCommentView(),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 8.h,
                ),
                Align(
                    alignment: Alignment.bottomCenter,
                    child: _SearchField()),

              ],
          )
      );
    });
  }
}

class _BuildCommentView extends StatelessWidget {
  const _BuildCommentView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: ComponentSize.smallest.w),
      child: Container(
        decoration: BoxDecoration(
            color: DynamicTheme.get(context).black(),
            borderRadius: BorderRadius.circular(ComponentInset.small.r)),
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: ComponentSize.small8.w,
              vertical: ComponentSize.small8.h),
          child: Column(
            children: <Widget>[
              _buildUserProfileDetails(context),
              Text(
                "This is a text message from a user and can be as long as the user has written",
                style: TextStyles.body
                    .copyWith(color: DynamicTheme.get(context).white()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

_buildUserProfileDetails(BuildContext context) {
  return Row(
    children: <Widget>[
      CircleAvatar(
        backgroundColor: Colors.red,
        radius: ComponentRadius.large.r,
      ),
      SizedBox(
        width: 8.w,
      ),
      Text(
        "Susan R.",
        maxLines: 1,
        style: TextStyles.boldHeading5
            .copyWith(color: DynamicTheme.get(context).white()),
      ),
      Expanded(child: Container()),
      Text(
        "10:23",
        maxLines: 1,
        style: TextStyles.heading6
            .copyWith(color: DynamicTheme.get(context).neutral10()),
      )
      /*Photo.any(
        ,
        options: PhotoOptions(
          fit: BoxFit.contain,
          height: 32.h,
          width: 32.w,
          borderRadius:
          BorderRadius.circular(ComponentRadius.large.r),
        ),
      ),*/
    ],
  );
}

class _SearchField extends StatelessWidget {
  _SearchField({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.w),
        child: Container(
          height: 48.h,
          decoration: BoxDecoration(
              color: DynamicTheme.get(context).neutral60(),
              borderRadius: BorderRadius.circular(ComponentInset.small.r)),
          child: TextFormField(
            style: TextStyle(
                fontFamily: "Poppins",
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: DynamicTheme.get(context).neutral20()),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(left: 16.w,top: 15.h),
              suffixIcon: Padding(
                padding:  EdgeInsets.only(top:15.h,bottom: 5.h),
                child: SvgAssetPhoto(Assets.sendCommentIcon,width: 14.w, height: 13.h,fit: BoxFit.contain,),
              ),
              hintStyle: TextStyle(
                  fontFamily: "Poppins",
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: DynamicTheme.get(context).neutral20()),
              hintText: LocaleResources.of(context).writeHere,
            ),
          ),
        ));
  }
}
