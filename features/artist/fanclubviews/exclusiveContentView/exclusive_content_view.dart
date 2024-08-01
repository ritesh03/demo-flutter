import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'  hide SearchBar;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kwotdata/models/artist/exclusive.content.dart';
import 'package:provider/provider.dart';
import '../../../../components/kit/assets.dart';
import '../../../../components/kit/component_inset.dart';
import '../../../../components/kit/component_size.dart';
import '../../../../components/kit/textstyles.dart';
import '../../../../components/kit/theme/dynamic_theme.dart';
import '../../../../components/widgets/button.dart';
import '../../../../components/widgets/list/item_list.widget.dart';
import '../../../../components/widgets/segmented_control_tabs.widget.dart';
import '../../../../components/widgets/textfield/search/searchbar.widget.dart';
import '../../../../l10n/localizations.dart';
import '../../../../navigation/dashboard_navigation.dart';
import '../../../dashboard/dashboard_config.dart';
import '../photos_widget.dart';
import '../song_widget.dart';
import '../videos_widget.dart';
import 'exclusive_content_view_model.dart';

class ExclusiveContentView extends StatefulWidget {
  const ExclusiveContentView({Key? key}) : super(key: key);

  @override
  State<ExclusiveContentView> createState() => _ExclusiveContentViewState();
}

class _ExclusiveContentViewState extends State<ExclusiveContentView>
    with TickerProviderStateMixin {
  late final PageController _pageController;
  late final TabController _stepBarController;
  ExclusiveContentViewModel get model =>
      context.read<ExclusiveContentViewModel>();
  @override
  void initState() {
    print(":: _ExclusiveContentViewState");
    model.init();
    _stepBarController = TabController(
        length: ExclusiveSteps.values.length, vsync: this, initialIndex: 0);
    _pageController = PageController(
      keepPage: true,
    );
    _stepBarController.addListener(() {
      if (_stepBarController.index == 0) {
        model.type = "songs";
        model.showSearchField = true;
        model.selectedField = 0;
        model.clearSearchQuery();
        model.exclusiveController.refresh();
      } else if (_stepBarController.index == 1) {
        model.type = "photos";
        model.showSearchField = false;
        model.selectedField = 1;
        model.clearSearchQuery();
        model.exclusiveController.refresh();
      } else if (_stepBarController.index == 2) {
        model.type = "videos";
        model.showSearchField = true;
        model.selectedField = 2;
        model.clearSearchQuery();
        model.exclusiveController.refresh();
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: PreferredSize(
              preferredSize: Size.fromHeight(
                // _PageTopBar
                145.h +
                    // SizedBox
                    ComponentInset.small.r +
                    // _SubscriptionPlanPurchaseStepBar
                    ComponentSize.normal.r +
                    // SizedBox
                    ComponentInset.normal.r,
              ),
              child: Selector<ExclusiveContentViewModel, bool>(
                  selector: (_, model) => model.showSearchField,
                  builder: (_, canShow, __) {
                      return Selector<ExclusiveContentViewModel, int>(
                      selector: (_, model) => model.selectedField,
                      builder: (_, selectedFiled, __) {
                        return _buildProfileTopBar(
                            context,
                            _stepBarController,
                            model,
                            canShow,
                          selectedFiled,
                        );
                      });

                  })),
          body: Selector<ExclusiveContentViewModel, bool>(
              selector: (_, model) => model.canShowCircularProgress,
              builder: (_, canShow, __) {
                if (!canShow) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return _ContentWidget(stepBarController: _stepBarController, model: model,);

              })),
    );
  }
}

Widget _buildProfileTopBar(
  BuildContext context,
  TabController controller,
  ExclusiveContentViewModel model,
    bool showStatusValue,
    int selectedFiled,
) {
  return Stack(
    children: [
      Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            AppIconButton(
                width: ComponentSize.large.r,
                height: ComponentSize.large.r,
                assetColor: DynamicTheme.get(context).white(),
                assetPath: Assets.iconArrowLeft,
                padding: EdgeInsets.all(ComponentInset.small.r),
                onPressed: () => DashboardNavigation.pop(context)),
            const Spacer(),
          ]),
          _BuildPageTopBarWidget(
            text: LocaleResources.of(context).exclusiveContent,
          ),
          SizedBox(
            height: ComponentInset.normal.h,
          ),
          _ExclusiveContentStepBar(
              controller: controller,
              height: ComponentSize.normal.h,
              localeResource: LocaleResources.of(context),
              margin:
                  EdgeInsets.symmetric(horizontal: ComponentInset.normal.r)),
          SizedBox(
            height: ComponentInset.normal.h,
          ),
      showStatusValue? _SearchField(
            model: model, selectedFiled: selectedFiled,
          ):const SizedBox.shrink(),
          showStatusValue?   SizedBox(
            height: ComponentInset.normal.h,
          ):const SizedBox.shrink(),
        ],
      ),
    ],
  );
}

class _SearchField extends StatelessWidget {
  ExclusiveContentViewModel model;
  int selectedFiled;
  _SearchField({Key? key, required this.model,required this.selectedFiled}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.w),
        child: SearchBar(
            hintText: selectedFiled ==0? LocaleResources.of(context).searchSong:LocaleResources.of(context).searchVideo,
            onQueryChanged: model.updateSearchQuery,
            onQueryCleared: model.clearSearchQuery));
  }
}

class _BuildPageTopBarWidget extends StatelessWidget {
  const _BuildPageTopBarWidget({
    Key? key,
    required this.text,
  }) : super(key: key);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.w),
      child: Column(
        children: [
          Text(text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyles.boldHeading2
                  .copyWith(color: DynamicTheme.get(context).neutral10())),
        ],
      ),
    );
  }
}

class _ExclusiveContentStepBar extends StatelessWidget {
  const _ExclusiveContentStepBar({
    Key? key,
    required this.controller,
    required this.height,
    required this.localeResource,
    required this.margin,
  }) : super(key: key);

  final TabController controller;
  final double height;
  final EdgeInsets margin;
  final TextLocaleResource localeResource;

  @override
  Widget build(BuildContext context) {
    return ControlledSegmentedControlTabBar<ExclusiveSteps>(
        controller: controller,
        height: height,
        items: ExclusiveSteps.values,
        margin: margin,
        itemTitle: (step) {
          switch (step) {
            case ExclusiveSteps.songs:
              return localeResource.songs;
            case ExclusiveSteps.photos:
              return localeResource.photos;
            case ExclusiveSteps.videos:
              return localeResource.videos;
          }
        });
  }
}

enum ExclusiveSteps {
  songs(position: 0),
  photos(position: 1),
  videos(position: 2);

  final int position;
  const ExclusiveSteps({
    required this.position,
  });
}

class _ContentWidget extends StatelessWidget {
  TabController stepBarController;
  ExclusiveContentViewModel model;
  _ContentWidget({Key? key, required this.stepBarController,required this.model}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ItemListWidget<ExclusiveContent, ExclusiveContentViewModel>(
        footerSlivers: [DashboardConfigAwareFooter.asSliver()],
        columnItemSpacing: ComponentInset.normal.r,
        columnCount: stepBarController.index==1?3:1,
        padding: stepBarController.index==1? EdgeInsets.symmetric(horizontal: 16.w):EdgeInsets.zero,
        itemBuilder: (context, event, index) {
          if (stepBarController.index == 0) {
            return SongListWidget(
              songImage: event.songs!.image,
              title: event.songs!.title,
              url: event.songs!.url,
              id: event.songs!.id,
              songType: event.songs!.type, isFromFeed: false,
            );
          } else if (stepBarController.index == 1) {
            return PhotosWidget( photoUrl: event.photos!.image,);
          } else {
            return VideosWidget(
              addedAt: event.videos!.addedAt,
              duration: "${event.videos!.duration}",
              image: event.videos!.image,
              title: event.videos!.title,
              views: "${event.videos!.views}",
              isFromFeed: false,
              id: event.videos?.id??'',
              url: event.videos?.url,
            );
          }
        });
  }
}


