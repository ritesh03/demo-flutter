import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/bottomsheet/bottomsheet_drag_handle.widget.dart';
import 'package:kwotmusic/components/widgets/bottomsheet/material_bottom_sheet.dart';
import 'package:kwotmusic/components/widgets/bottomsheet/widget/bottom_sheet_tile.widget.dart';
import 'package:kwotmusic/core.dart';
import 'package:kwotmusic/features/misc/report/report_content.model.dart';
import 'package:kwotmusic/features/show/widget/show_compact_preview.widget.dart';
import 'package:kwotmusic/l10n/localizations.dart';
import 'package:kwotmusic/router/routes.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import 'show_options.model.dart';

class ShowDetailOptionsBottomSheet extends StatefulWidget {
  //=
  static Future show(
    BuildContext context, {
    required ShowOptionsArgs args,
  }) {
    return showMaterialBottomSheet<void>(
      context,
      expand: false,
      builder: (_, __) => ChangeNotifierProvider(
          create: (_) => ShowOptionsModel(args: args),
          child: const ShowDetailOptionsBottomSheet()),
    );
  }

  const ShowDetailOptionsBottomSheet({Key? key}) : super(key: key);

  @override
  State<ShowDetailOptionsBottomSheet> createState() =>
      _ShowDetailOptionsBottomSheetState();
}

class _ShowDetailOptionsBottomSheetState
    extends State<ShowDetailOptionsBottomSheet> {
  //=

  ShowOptionsModel get showOptionsModel => context.read<ShowOptionsModel>();

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
              iconPath: Assets.iconSave,
              margin: tileMargin,
              text: LocaleResources.of(context).saveToWatchLater,
              onTap: _onSaveButtonTapped),
          BottomSheetTile(
              iconPath: Assets.iconDownload,
              margin: tileMargin,
              text: LocaleResources.of(context).download,
              onTap: _onDownloadButtonTapped),
          BottomSheetTile(
              iconPath: Assets.iconShare,
              margin: tileMargin,
              text: LocaleResources.of(context).share,
              onTap: _onShareButtonTapped),
          if (showOptionsModel.canMinimize)
            BottomSheetTile(
                iconPath: Assets.iconMinimize,
                margin: tileMargin,
                text: LocaleResources.of(context).minimize,
                onTap: _onReportButtonTapped),
          BottomSheetTile(
              iconPath: Assets.iconReport,
              margin: tileMargin,
              text: LocaleResources.of(context).report,
              onTap: _onReportButtonTapped),
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

  void _onSaveButtonTapped() {
    RootNavigation.pop(context);
  }

  void _onDownloadButtonTapped() {
    RootNavigation.pop(context);
  }

  void _onShareButtonTapped() async {
    final show = showOptionsModel.show;
    final shareableLink = show.shareableLink;
    if (shareableLink.isEmpty) {
      return;
    }

    Share.share(shareableLink);
  }

  void _onReportButtonTapped() {
    RootNavigation.popUntilRoot(context);

    final show = showOptionsModel.show;
    final args = ReportContentArgs(content: ReportableContent.fromShow(show));
    DashboardNavigation.pushNamed(context, Routes.reportContent,
        arguments: args);
  }
}
