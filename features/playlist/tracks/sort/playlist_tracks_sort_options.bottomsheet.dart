import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/bottomsheet/bottomsheet_drag_handle.widget.dart';
import 'package:kwotmusic/components/widgets/bottomsheet/material_bottom_sheet.dart';
import 'package:kwotmusic/components/widgets/bottomsheet/widget/bottom_sheet_selectable_tile.widget.dart';
import 'package:kwotmusic/core.dart';
import 'package:kwotmusic/l10n/localizations.dart';

class PlaylistTracksSortOptionsBottomSheet extends StatefulWidget {
  //=
  static Future<PlaylistTrackSortBy?> show(
    BuildContext context, {
    required PlaylistTrackSortBy sortBy,
  }) {
    return showMaterialBottomSheet<PlaylistTrackSortBy>(
      context,
      expand: false,
      builder: (_, __) => PlaylistTracksSortOptionsBottomSheet(sortBy: sortBy),
    );
  }

  const PlaylistTracksSortOptionsBottomSheet({
    Key? key,
    required this.sortBy,
  }) : super(key: key);

  final PlaylistTrackSortBy sortBy;

  @override
  State<PlaylistTracksSortOptionsBottomSheet> createState() =>
      _PlaylistTracksSortOptionsBottomSheetState();
}

class _PlaylistTracksSortOptionsBottomSheetState
    extends State<PlaylistTracksSortOptionsBottomSheet> {
  //=

  @override
  Widget build(BuildContext context) {
    final localization = LocaleResources.of(context);
    return Container(
        padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.r),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const BottomSheetDragHandle(),
          SizedBox(height: ComponentInset.normal.h),

          /// SORT BY
          Text(
            localization.sortBy,
            style: TextStyles.boldBody
                .copyWith(color: DynamicTheme.get(context).white()),
          ),
          SizedBox(height: ComponentInset.medium.h),

          /// SORT BY: TITLE
          BottomSheetSelectableTile(
              text: localization.playlistTrackSortByTitle,
              onTap: () => _onSortOptionTapped(PlaylistTrackSortBy.title),
              isSelected: (widget.sortBy == PlaylistTrackSortBy.title)),
          SizedBox(height: ComponentInset.small.h),

          /// SORT BY: ALBUM
          BottomSheetSelectableTile(
              text: localization.playlistTrackSortByAlbum,
              onTap: () => _onSortOptionTapped(PlaylistTrackSortBy.album),
              isSelected: (widget.sortBy == PlaylistTrackSortBy.album)),
          SizedBox(height: ComponentInset.small.h),

          /// SORT BY: ARTIST
          BottomSheetSelectableTile(
              text: localization.playlistTrackSortByArtist,
              onTap: () => _onSortOptionTapped(PlaylistTrackSortBy.artist),
              isSelected: (widget.sortBy == PlaylistTrackSortBy.artist)),
          SizedBox(height: ComponentInset.small.h),

          /// SORT BY: RECENTLY ADDED
          BottomSheetSelectableTile(
              text: localization.playlistTrackSortByRecentlyAdded,
              onTap: () =>
                  _onSortOptionTapped(PlaylistTrackSortBy.recentlyAdded),
              isSelected: (widget.sortBy == PlaylistTrackSortBy.recentlyAdded)),
          SizedBox(height: ComponentInset.normal.h),
        ]));
  }

  void _onSortOptionTapped(PlaylistTrackSortBy sortBy) {
    RootNavigation.pop(context, sortBy);
  }
}
