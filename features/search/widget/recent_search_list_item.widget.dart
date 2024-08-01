import 'package:flutter/material.dart'  hide SearchBar;
import 'package:flutter_scale_tap/flutter_scale_tap.dart';
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/button.dart';
import 'package:kwotmusic/components/widgets/photo/photo.dart';
import 'package:kwotmusic/features/search/search_actions.model.dart';
import 'package:kwotmusic/util/search_kind_ext.dart';

class RecentSearchListItem extends StatelessWidget {
  const RecentSearchListItem({
    Key? key,
    required this.item,
    required this.onTap,
    required this.onRemoveTap,
  }) : super(key: key);

  final SearchResultItem item;
  final VoidCallback onTap;
  final VoidCallback onRemoveTap;

  @override
  Widget build(BuildContext context) {
    final itemHeight = ComponentSize.large.r;
    return SizedBox(
      height: itemHeight,
      child: Stack(children: [
        Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            right: ComponentSize.small.r,
            child: _buildContent(context, height: itemHeight)),
        Positioned(
            top: 0, bottom: 0, right: 0, child: _buildRemoveButton(context)),
      ]),
    );
  }

  Widget _buildContent(BuildContext context, {required double height}) {
    return ScaleTap(
        onPressed: () => onTap(),
        child: Container(
            height: height,

            /// For ScaleTap to recognize whole item as tappable
            color: Colors.transparent,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildThumbnail(context, size: height),
                SizedBox(width: ComponentInset.small.r),
                Expanded(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      _buildTitle(context),
                      _buildSubtitle(context),
                    ])),
              ],
            )));
  }

  Widget _buildThumbnail(BuildContext context, {required double size}) {
    return Photo.kind(
      item.thumbnail,
      kind: item.kind.photoKind,
      options: PhotoOptions(
          width: size,
          height: size,
          borderRadius: BorderRadius.circular(ComponentRadius.normal.r)),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Text(item.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyles.boldBody
            .copyWith(color: DynamicTheme.get(context).white()));
  }

  Widget _buildSubtitle(BuildContext context) {
    final subtitle = locator<SearchActionsModel>()
        .getSubtitleFromSearchResultItem(context, item: item);

    return Text(subtitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyles.heading6
            .copyWith(color: DynamicTheme.get(context).neutral10()));
  }

  Widget _buildRemoveButton(BuildContext context) {
    return AppIconButton(
        width: ComponentSize.smaller.r,
        height: ComponentSize.smaller.r,
        assetColor: DynamicTheme.get(context).neutral60(),
        assetPath: Assets.iconCrossBold,
        onPressed: onRemoveTap);
  }
}
