import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/button.dart';
import 'package:kwotmusic/components/widgets/list/item_list.widget.dart';
import 'package:kwotmusic/components/widgets/list/item_list_util.dart';
import 'package:kwotmusic/components/widgets/marquee/simple_marquee.dart';
import 'package:kwotmusic/components/widgets/page/page_state.dart';
import 'package:kwotmusic/components/widgets/textfield.dart';
import 'package:kwotmusic/core.dart';
import 'package:kwotmusic/features/dashboard/dashboard_config.dart';
import 'package:kwotmusic/features/playback/audio/audio_playback_actions.model.dart';
import 'package:kwotmusic/features/radiostation/widget/radio_station_grid_item.widget.dart';
import 'package:kwotmusic/features/radiostation/widget/radio_station_list_item.widget.dart';
import 'package:kwotmusic/l10n/localizations.dart';
import 'package:provider/provider.dart';

import 'radio_stations.model.dart';

class RadioStationsPage extends StatefulWidget {
  const RadioStationsPage({Key? key}) : super(key: key);

  @override
  State<RadioStationsPage> createState() => _RadioStationsPageState();
}

class _RadioStationsPageState extends PageState<RadioStationsPage> {
  //=

  @override
  void initState() {
    super.initState();
    radioStationsModelOf(context).init();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: PreferredSize(
                preferredSize: Size.fromHeight(ComponentSize.large.h),
                child: _buildAppBar()),
            body: Selector<RadioStationsModel, ItemListViewMode>(
                selector: (_, model) => model.viewMode,
                builder: (_, viewMode, __) {
                  final viewColumnCount =
                      radioStationsModelOf(context).viewColumnCount;
                  return _buildItemList(viewMode, viewColumnCount);
                })));
  }

  /*
   * APP BAR
   */

  Widget _buildAppBar() {
    return Row(children: [
      AppIconButton(
          width: ComponentSize.large.r,
          height: ComponentSize.large.r,
          assetColor: DynamicTheme.get(context).neutral20(),
          assetPath: Assets.iconArrowLeft,
          padding: EdgeInsets.all(ComponentInset.small.r),
          onPressed: () => DashboardNavigation.pop(context)),
      const Spacer(),
      _buildListViewModeSelection(),
      _buildGridViewModeSelection(),
      SizedBox(width: ComponentInset.small.w)
    ]);
  }

  Widget _buildListViewModeSelection() {
    return Selector<RadioStationsModel, ItemListViewMode>(
        selector: (_, model) => model.viewMode,
        builder: (_, viewMode, __) {
          return AppIconButton(
              width: ComponentSize.normal.r,
              height: ComponentSize.normal.r,
              assetColor: viewMode.isListMode
                  ? DynamicTheme.get(context).white()
                  : DynamicTheme.get(context).neutral20(),
              assetPath: Assets.iconList,
              padding: EdgeInsets.all(ComponentInset.smaller.r),
              onPressed: () =>
                  radioStationsModelOf(context).showListViewMode());
        });
  }

  Widget _buildGridViewModeSelection() {
    return Selector<RadioStationsModel, ItemListViewMode>(
        selector: (_, model) => model.viewMode,
        builder: (_, viewMode, __) {
          return AppIconButton(
              width: ComponentSize.normal.r,
              height: ComponentSize.normal.r,
              assetColor: viewMode.isGridMode
                  ? DynamicTheme.get(context).white()
                  : DynamicTheme.get(context).neutral20(),
              assetPath: Assets.iconGrid,
              padding: EdgeInsets.all(ComponentInset.smaller.r),
              onPressed: () =>
                  radioStationsModelOf(context).showGridViewMode());
        });
  }

  /*
   * HEADER
   */

  Widget _buildHeader() {
    return Container(
        padding: EdgeInsets.only(
            top: ComponentInset.small.r,
            left: ComponentInset.normal.r,
            right: ComponentInset.normal.r,
            bottom: ComponentInset.normal.r),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [_buildTitle(), _buildSearchBar()]));
  }

  Widget _buildTitle() {
    return Container(
        height: ComponentSize.small.h,
        margin: EdgeInsets.only(bottom: ComponentInset.normal.r),
        child: Selector<RadioStationsModel, String?>(
            selector: (_, model) => model.pageTitle,
            builder: (_, pageTitle, __) {
              return SimpleMarquee(
                  text: pageTitle ??
                      LocaleResources.of(context).radioStationsPageTitle,
                  textStyle: TextStyles.boldHeading2.copyWith(
                    color: DynamicTheme.get(context).white(),
                  ));
            }));
  }

  Widget _buildSearchBar() {
    return SearchBar(
        hintText: LocaleResources.of(context).radioStationsSearchHint,
        onQueryChanged: radioStationsModelOf(context).updateSearchQuery,
        onQueryCleared: radioStationsModelOf(context).clearSearchQuery);
  }

  /*
   * BODY
   */

  Widget _buildItemList(ItemListViewMode viewMode, int columnCount) {
    return ItemListWidget<RadioStation, RadioStationsModel>(
        columnItemSpacing: ComponentInset.normal.h,
        padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.w),
        columnCount: columnCount,
        headerSlivers: [SliverToBoxAdapter(child: _buildHeader())],
        footerSlivers: [DashboardConfigAwareFooter.asSliver()],
        itemBuilder: (context, radioStation, index) {
          switch (viewMode) {
            case ItemListViewMode.list:
              return RadioStationListItem(
                  radioStation: radioStation,
                  onRadioStationTap: (radioStation) {
                    playRadioStation(context, radioStation);
                  });
            case ItemListViewMode.grid:
              return RadioStationGridItem(
                  radioStation: radioStation,
                  onRadioStationTap: (radioStation) {
                    playRadioStation(context, radioStation);
                  },
                  width: 0.5.sw);
          }
        });
  }

  RadioStationsModel radioStationsModelOf(BuildContext context) {
    return context.read<RadioStationsModel>();
  }

  void playRadioStation(BuildContext context, RadioStation radioStation) {
    locator<AudioPlaybackActionsModel>().playRadioStation(radioStation);
  }
}
