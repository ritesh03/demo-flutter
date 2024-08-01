import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/photo/photo.dart';
import 'package:kwotmusic/l10n/localizations.dart';

class RadioStationCompactPreview extends StatelessWidget {
  const RadioStationCompactPreview({
    Key? key,
    required this.radioStation,
    this.margin,
    this.padding,
  }) : super(key: key);

  final RadioStation radioStation;
  final EdgeInsets? margin;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: margin,
        padding: padding,
        child: Row(children: [
          _buildThumbnail(),
          SizedBox(width: ComponentInset.normal.w),
          Expanded(
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitle(context),
                  _buildSubtitle(context),
                ]),
          )
        ]));
  }

  Widget _buildThumbnail() {
    return Photo.radioStation(
      radioStation.thumbnail,
      options: PhotoOptions(
          width: 104.r,
          height: 104.r,
          borderRadius: BorderRadius.circular(ComponentRadius.normal.r)),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Text(radioStation.title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyles.boldHeading3
            .copyWith(color: DynamicTheme.get(context).white()));
  }

  Widget _buildSubtitle(BuildContext context) {
    return Text(LocaleResources.of(context).radioStation,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyles.heading5
            .copyWith(color: DynamicTheme.get(context).neutral10()));
  }
}
