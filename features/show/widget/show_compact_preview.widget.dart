import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/photo/photo.dart';

class ShowCompactPreview extends StatelessWidget {
  const ShowCompactPreview({
    Key? key,
    required this.show,
    this.margin,
    this.padding,
  }) : super(key: key);

  final Show show;
  final EdgeInsets? margin;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: margin,
        padding: padding,
        child: Row(
            crossAxisAlignment: show.isFreeOrPurchased
                ? CrossAxisAlignment.center
                : CrossAxisAlignment.start,
            children: [
              _buildThumbnail(),
              SizedBox(width: ComponentInset.normal.w),
              Expanded(
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTitle(context),
                      _buildSubtitle(context),
                      _buildPrice(context),
                    ]),
              )
            ]));
  }

  Widget _buildThumbnail() {
    return Photo.show(
      show.thumbnail,
      options: PhotoOptions(
          width: 104.r,
          height: 72.r,
          borderRadius: BorderRadius.circular(ComponentRadius.normal.r)),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Text(show.title,
        maxLines: show.isFreeOrPurchased ? 2 : 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyles.boldHeading3.copyWith(
          color: DynamicTheme.get(context).white(),
        ));
  }

  Widget _buildSubtitle(BuildContext context) {
    return Text(show.artist.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyles.heading4.copyWith(
          color: DynamicTheme.get(context).neutral20(),
        ));
  }

  Widget _buildPrice(BuildContext context) {
    if (show.isFreeOrPurchased) {
      return Container();
    }

    return Text(show.price,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyles.boldHeading4.copyWith(
          color: DynamicTheme.get(context).white(),
        ));
  }
}
