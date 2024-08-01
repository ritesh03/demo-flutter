import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/features/dashboard/dashboard.model.dart';
import 'package:provider/provider.dart';

class DashboardConfig {
  DashboardConfig({
    this.isNavigationBarVisible = false,
    this.isAudioPlaybackBarVisible = false,
    this.isVideoPlaybackBarVisible = false,
    this.selectedTabIndex = 2,
  });

  final bool isNavigationBarVisible;
  final bool isAudioPlaybackBarVisible;
  final bool isVideoPlaybackBarVisible;
  final int selectedTabIndex;

  double get _defaultNavigationBarHeight => 64.r;

  double get navigationBarHeight {
    return isNavigationBarVisible ? _defaultNavigationBarHeight : 0;
  }

  double get _defaultPlaybackBarHeight => 80.h;

  double get playbackBarHeight {
    return (isAudioPlaybackBarVisible || isVideoPlaybackBarVisible)
        ? _defaultPlaybackBarHeight
        : 0;
  }

  bool get isPlaybackBarVisible =>
      isAudioPlaybackBarVisible || isVideoPlaybackBarVisible;

  DashboardConfig copyWith({
    bool? isNavigationBarVisible,
    bool? isAudioPlaybackBarVisible,
    bool? isVideoPlaybackBarVisible,
    int? selectedTabIndex,
  }) {
    return DashboardConfig(
      isNavigationBarVisible:
          isNavigationBarVisible ?? this.isNavigationBarVisible,
      isAudioPlaybackBarVisible:
          isAudioPlaybackBarVisible ?? this.isAudioPlaybackBarVisible,
      isVideoPlaybackBarVisible:
          isVideoPlaybackBarVisible ?? this.isVideoPlaybackBarVisible,
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DashboardConfig &&
          runtimeType == other.runtimeType &&
          isNavigationBarVisible == other.isNavigationBarVisible &&
          isAudioPlaybackBarVisible == other.isAudioPlaybackBarVisible &&
          isVideoPlaybackBarVisible == other.isVideoPlaybackBarVisible &&
          selectedTabIndex == other.selectedTabIndex;

  @override
  int get hashCode {
    return hashValues(
      isNavigationBarVisible,
      isAudioPlaybackBarVisible,
      isVideoPlaybackBarVisible,
      selectedTabIndex,
    );
  }
}

class DashboardConfigNotifier extends ValueNotifier<DashboardConfig> {
  DashboardConfigNotifier() : super(DashboardConfig());
}

class DashboardConfigAwareFooter extends StatelessWidget {
  const DashboardConfigAwareFooter({Key? key}) : super(key: key);

  static Widget asSliver() {
    return const SliverToBoxAdapter(child: DashboardConfigAwareFooter());
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<DashboardConfig>(
        valueListenable: context.read<DashboardModel>().dashboardConfigNotifier,
        builder: (_, config, __) {
          double totalHeight = ComponentInset.large.h +
              config.navigationBarHeight +
              config.playbackBarHeight;
          return SizedBox(height: totalHeight);
        });
  }
}
