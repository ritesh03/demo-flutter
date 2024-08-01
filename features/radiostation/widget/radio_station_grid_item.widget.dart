import 'package:flutter/material.dart'  hide SearchBar;
import 'package:flutter_scale_tap/flutter_scale_tap.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/photo/photo.dart';

class RadioStationGridItem extends StatelessWidget {
  const RadioStationGridItem({
    Key? key,
    required this.width,
    required this.radioStation,
    required this.onRadioStationTap,
    this.padding = EdgeInsets.zero,
  }) : super(key: key);

  final double width;
  final RadioStation radioStation;
  final Function(RadioStation radioStation) onRadioStationTap;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return ScaleTap(
        onPressed: () => onRadioStationTap(radioStation),
        child: Container(
            width: width,
            padding: padding,

            /// For ScaleTap to recognize whole item as tappable
            color: Colors.transparent,
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildThumbnail(),
                  SizedBox(height: ComponentInset.small.h),
                  _buildTitle(),
                ])));
  }

  Widget _buildThumbnail() {
    return AspectRatio(
        aspectRatio: 1,
        child: Photo.radioStation(
          radioStation.thumbnail,
          options: PhotoOptions(
            width: width,
            height: width,
            borderRadius: BorderRadius.circular(ComponentRadius.normal.r),
          ),
        ));
  }

  Widget _buildTitle() {
    return Container(
        height: ComponentSize.smaller.h,
        padding: EdgeInsets.symmetric(horizontal: 2.w),
        child: Text(
          radioStation.title,
          overflow: TextOverflow.ellipsis,
          style: TextStyles.boldBody,
          maxLines: 1,
        ));
  }
}
