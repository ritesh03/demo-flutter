import 'package:flutter/material.dart'  hide SearchBar;
import 'package:flutter_scale_tap/flutter_scale_tap.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/photo/photo.dart';

class RadioStationListItem extends StatelessWidget {
  const RadioStationListItem({
    Key? key,
    required this.radioStation,
    required this.onRadioStationTap,
  }) : super(key: key);

  final RadioStation radioStation;
  final Function(RadioStation radioStation) onRadioStationTap;

  @override
  Widget build(BuildContext context) {
    final itemHeight = 80.h;
    return ScaleTap(
      onPressed: () => onRadioStationTap(radioStation),
      child: Container(
          height: itemHeight,

          /// For ScaleTap to recognize whole item as tappable
          color: Colors.transparent,
          child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            _buildThumbnail(size: itemHeight),
            Expanded(child: _buildTitle()),
          ])),
    );
  }

  Widget _buildThumbnail({required double size}) {
    return Photo.radioStation(
      radioStation.thumbnail,
      options: PhotoOptions(
        width: size,
        height: size,
        borderRadius: BorderRadius.circular(ComponentRadius.normal.r),
      ),
    );
  }

  Widget _buildTitle() {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: ComponentInset.small.w),
        child: Text(
          radioStation.title,
          overflow: TextOverflow.ellipsis,
          style: TextStyles.boldBody,
          maxLines: 2,
        ));
  }
}
