import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/bottomsheet/bottomsheet_drag_handle.widget.dart';
import 'package:kwotmusic/components/widgets/bottomsheet/material_bottom_sheet.dart';
import 'package:kwotmusic/components/widgets/bottomsheet/widget/bottom_sheet_tile.widget.dart';
import 'package:kwotmusic/core.dart';
import 'package:kwotmusic/features/artist/artist_actions.model.dart';
import 'package:kwotmusic/features/artist/widget/artist_profile_compact_preview.widget.dart';
import 'package:kwotmusic/features/misc/report/report_content.model.dart';
import 'package:kwotmusic/l10n/localizations.dart';
import 'package:kwotmusic/router/routes.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../util/date_time_methods.dart';
import '../../profile/subscriptions/cancel/cancel_subscription_plan_confirmation.bottomsheet.dart';
import '../profile/artist.model.dart';
import '../widget/join_fan_club_bottomsheet.dart';
import 'artist_options.model.dart';

class ArtistOptionsBottomSheet extends StatefulWidget {
  //=
  static Future show(
    BuildContext context, {
    required Artist artist,
    required VoidCallback onTapCancel,
    ArtistModel? model,
  }) {
    return showMaterialBottomSheet<void>(
      context,
      expand: false,
      builder: (_, __) => ChangeNotifierProvider(
        create: (_) => ArtistOptionsModel(artist: artist),
        child: ArtistOptionsBottomSheet(
          onTapCancel: onTapCancel,
          model: model,
        ),
      ),
    );
  }

  ArtistOptionsBottomSheet({Key? key, required this.onTapCancel, this.model})
      : super(key: key);
  VoidCallback onTapCancel;
  ArtistModel? model;
  @override
  State<ArtistOptionsBottomSheet> createState() =>
      _ArtistOptionsBottomSheetState();
}

class _ArtistOptionsBottomSheetState extends State<ArtistOptionsBottomSheet> {
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
          BottomSheetTile(
              iconPath: Assets.iconReport,
              margin: tileMargin,
              text: LocaleResources.of(context).report,
              onTap: _onReportButtonTapped),
          widget.model!.showFanClub
              ? Column(
                  children: <Widget>[
                    BottomSheetTile(
                        iconPath: Assets.iconUpgradePlan,
                        margin: tileMargin,
                        text: LocaleResources.of(context).upgradeFanPlan,
                        onTap: () {
                          RootNavigation.pop(context);
                          JoinFanClubBottomSheet.show(
                            context,
                            artistName: widget.model!.artist!.name,
                            subscriptionPlans:
                                widget.model!.subscriptionResult!,
                            artistModel: widget.model!, isFromUpgrade: true,
                          ).then((value) {
                            if (value == true) {
                              widget.model!.fetchArtist();
                            }
                          });
                        }),
                    BottomSheetTile(
                        iconPath: Assets.iconCancelPlan,
                        margin: tileMargin,
                        text: LocaleResources.of(context).cancelFanPlan,
                        onTap: () {
                          RootNavigation.pop(context);
                          CancelSubscriptionPlanConfirmationBottomSheet.show(
                              context,
                              planEndDate: DateConvertor.dateForBottomSheet(widget.model!.artist!.fanPlanExpiry!) ?? "" ,
                              isFromArtist: true,
                              onTapCancel: widget.onTapCancel);
                        }),
                  ],
                )
              : const SizedBox.shrink(),
          SizedBox(height: ComponentInset.normal.h)
        ]));
  }

  Widget _buildHeader() {
    return Selector<ArtistOptionsModel, Artist>(
        selector: (_, model) => model.artist,
        builder: (_, artist, __) {
          return ArtistProfileCompactPreview(artist: artist);
        });
  }

  ArtistOptionsModel modelOf(BuildContext context) {
    return context.read<ArtistOptionsModel>();
  }

  ArtistActionsModel artistActionsModel() {
    return locator<ArtistActionsModel>();
  }

  void _onShareButtonTapped() async {
    final artist = modelOf(context).artist;
    final shareableLink = artist.shareableLink;
    if (shareableLink.isEmpty) {
      return;
    }

    Share.share(shareableLink);
  }

  void _onReportButtonTapped() {
    RootNavigation.popUntilRoot(context);

    final artist = modelOf(context).artist;
    final args =
        ReportContentArgs(content: ReportableContent.fromArtist(artist));
    DashboardNavigation.pushNamed(context, Routes.reportContent,
        arguments: args);
  }
}
