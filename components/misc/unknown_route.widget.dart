import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/button.dart';
import 'package:kwotmusic/core.dart';

class UnknownRouteWidget extends StatelessWidget {
  final String? routeName;

  const UnknownRouteWidget({Key? key, required this.routeName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: PreferredSize(
            child: _buildAppBar(context),
            preferredSize: Size.fromHeight(ComponentSize.large.h),
          ),
          body: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.all(ComponentInset.normal.r),
              child: Text(
                "Unknown route: $routeName",
                style: TextStyles.heading4,
              ))),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Row(children: [
      AppIconButton(
        width: ComponentSize.large.h,
        height: ComponentSize.large.h,
        assetColor: DynamicTheme.get(context).neutral20(),
        assetPath: Assets.iconArrowLeft,
        padding: EdgeInsets.all(ComponentInset.small.r),
        onPressed: () => DashboardNavigation.pop(context),
      )
    ]);
  }
}
