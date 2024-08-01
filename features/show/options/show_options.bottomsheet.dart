import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/bottomsheet/bottomsheet_drag_handle.widget.dart';
import 'package:kwotmusic/components/widgets/bottomsheet/material_bottom_sheet.dart';
import 'package:kwotmusic/components/widgets/bottomsheet/widget/bottom_sheet_tile.widget.dart';
import 'package:kwotmusic/components/widgets/button.dart';
import 'package:kwotmusic/components/widgets/feed/feed_routing.dart';
import 'package:kwotmusic/core.dart';
import 'package:kwotmusic/features/show/widget/show_compact_preview.widget.dart';
import 'package:kwotmusic/l10n/localizations.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import 'show_options.model.dart';

class ShowOptionsBottomSheet extends StatefulWidget {
  //=
  static Future show(
    BuildContext context, {
    required ShowOptionsArgs args,
  }) {
    return showMaterialBottomSheet<void>(
      context,
      expand: false,
      builder: (context, controller) {
        return ChangeNotifierProvider(
            create: (_) => ShowOptionsModel(args: args),
            child: const ShowOptionsBottomSheet());
      },
    );
  }

  const ShowOptionsBottomSheet({Key? key}) : super(key: key);

  @override
  State<ShowOptionsBottomSheet> createState() => _ShowOptionsBottomSheetState();
}

class _ShowOptionsBottomSheetState extends State<ShowOptionsBottomSheet> {
  //=

  @override
  Widget build(BuildContext context) {
    final tileMargin = EdgeInsets.only(top: ComponentInset.small.h);

    return Container(
        padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.r),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const BottomSheetDragHandle(),
          SizedBox(height: ComponentInset.normal.h),
          _buildHeader(),
          SizedBox(height: ComponentInset.normal.h),
          Container(color: DynamicTheme.get(context).background(), height: 2.r),
          SizedBox(height: ComponentInset.normal.h),
          BottomSheetTile(
              iconPath: Assets.iconShare,
              margin: tileMargin,
              text: LocaleResources.of(context).share,
              onTap: _onShareButtonTapped),
          SizedBox(height: ComponentInset.normal.h),
          _buildWatchButton(),
          SizedBox(height: ComponentInset.normal.h)
        ]));
  }

  Widget _buildHeader() {
    return Selector<ShowOptionsModel, Show>(
        selector: (_, model) => model.show,
        builder: (_, show, __) {
          return ShowCompactPreview(show: show);
        });
  }

  Widget _buildWatchButton() {
    return Button(
      alignment: Alignment.center,
      height: ComponentSize.large.r,
      onPressed: _onWatchButtonTapped,
      text: LocaleResources.of(context).watchTheShow,
      type: ButtonType.primary,
    );
  }

  ShowOptionsModel showOptionsModel() {
    return context.read<ShowOptionsModel>();
  }

  void _onShareButtonTapped() async {
    final show = showOptionsModel().show;
    final shareableLink = show.shareableLink;
    if (shareableLink.isEmpty) {
      return;
    }

    Share.share(shareableLink);
  }

  void _onWatchButtonTapped() async {
    RootNavigation.popUntilRoot(context);

    final show = showOptionsModel().show;
    locator<FeedRouting>().showShowDetailPage(context, show: show);
  }
}
