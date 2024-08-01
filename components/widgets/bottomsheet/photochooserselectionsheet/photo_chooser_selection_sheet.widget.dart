import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/bottomsheet/bottomsheet_drag_handle.widget.dart';
import 'package:kwotmusic/components/widgets/bottomsheet/material_bottom_sheet.dart';
import 'package:kwotmusic/components/widgets/bottomsheet/widget/bottom_sheet_tile.widget.dart';
import 'package:kwotmusic/core.dart';
import 'package:kwotmusic/l10n/localizations.dart';

enum PhotoChooser { camera, gallery }

class PhotoChooserSelectionSheet extends StatelessWidget {
  //=
  static Future<PhotoChooser?> show(
    BuildContext context, {
    required String title,
  }) {
    return showMaterialBottomSheet<PhotoChooser>(
      context,
      expand: false,
      builder: (_, __) => PhotoChooserSelectionSheet(title: title),
    );
  }

  const PhotoChooserSelectionSheet({
    Key? key,
    required this.title,
  }) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.r),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const BottomSheetDragHandle(),
          SizedBox(height: ComponentInset.normal.h),
          SizedBox(
              height: ComponentSize.smaller.h,
              child: Text(title,
                  style: TextStyles.boldHeading3,
                  overflow: TextOverflow.ellipsis)),
          SizedBox(height: ComponentInset.normal.h),
          SizedBox(height: ComponentInset.normal.h),
          BottomSheetTile(
              iconPath: Assets.iconCamera,
              text: LocaleResources.of(context).useCamera,
              onTap: () => RootNavigation.pop(context, PhotoChooser.camera)),
          SizedBox(height: ComponentInset.small.h),
          BottomSheetTile(
              iconPath: Assets.iconGallery,
              text: LocaleResources.of(context).useGallery,
              onTap: () => RootNavigation.pop(context, PhotoChooser.gallery)),
          SizedBox(height: ComponentInset.normal.h)
        ]));
  }
}
