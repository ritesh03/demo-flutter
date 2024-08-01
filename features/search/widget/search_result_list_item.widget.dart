import 'package:easy_rich_text/easy_rich_text.dart';
import 'package:flutter/material.dart'  hide SearchBar;
import 'package:flutter_scale_tap/flutter_scale_tap.dart';
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/button.dart';
import 'package:kwotmusic/components/widgets/photo/photo.dart';
import 'package:kwotmusic/features/search/search_actions.model.dart';
import 'package:kwotmusic/util/search_kind_ext.dart';

class SearchResultListItem extends StatelessWidget {
  const SearchResultListItem({
    Key? key,
    required this.item,
    this.query,
    required this.onTap,
    required this.onOptionsTap,
  }) : super(key: key);

  final SearchResultItem item;
  final String? query;
  final Function(SearchResultItem) onTap;
  final Function(SearchResultItem)? onOptionsTap;

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

  Widget _buildContent(
    BuildContext context, {
    required double height,
  }) {
    return ScaleTap(
        onPressed: () => onTap(item),
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

  Widget _buildThumbnail(
    BuildContext context, {
    required double size,
  }) {
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
    final title = item.title;

    final defaultTextStyle = TextStyles.boldBody
        .copyWith(color: DynamicTheme.get(context).neutral20());

    final highlightedTextStyle =
        TextStyles.boldBody.copyWith(color: DynamicTheme.get(context).white());

    final query = this.query;
    if (query == null || !title.contains(query)) {
      return Text(title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: highlightedTextStyle);
    }

    return EasyRichText(title,
        caseSensitive: false,
        defaultStyle: defaultTextStyle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        patternList: [
          EasyRichTextPattern(
              targetString: query,
              hasSpecialCharacters: true,
              matchWordBoundaries: false,
              style: highlightedTextStyle)
        ]);
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
    if (onOptionsTap == null) return Container();
    return AppIconButton(
        width: ComponentSize.small.r,
        height: ComponentSize.small.r,
        assetColor: DynamicTheme.get(context).white(),
        assetPath: Assets.iconOptions,
        onPressed: () => onOptionsTap!(item));
  }
}
