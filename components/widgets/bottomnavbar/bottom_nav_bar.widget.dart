import 'package:circle_nav_bar/circle_nav_bar.dart';
import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/photo/svg_asset_photo.dart';
import 'package:kwotmusic/features/profile/notifications/widget/unread_notification_indicator.widget.dart';

class BottomNavBarItem {
  BottomNavBarItem({
    required this.text,
    required this.iconPath,
    this.isProfileTabItem = false,
  });

  final String text;
  final String iconPath;
  final bool isProfileTabItem;
}

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({
    Key? key,
    required this.backgroundColor,
    required this.circleGradient,
    required this.circleSize,
    required this.height,
    required this.iconColor,
    required this.iconSize,
    required this.items,
    required this.onTap,
    required this.selectedIconColor,
    required this.selectedIconSize,
    required this.selectedIndex,
    required this.visible,
  }) : super(key: key);

  final Color backgroundColor;
  final Gradient circleGradient;
  final double circleSize;
  final double height;
  final Color iconColor;
  final double iconSize;
  final List<BottomNavBarItem> items;
  final Function(int) onTap;
  final Color selectedIconColor;
  final double selectedIconSize;
  final int selectedIndex;
  final bool visible;

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _offsetController;

  @override
  void initState() {
    super.initState();

    _offsetController = AnimationController(
        duration: const Duration(milliseconds: 250), vsync: this);
  }

  @override
  void didUpdateWidget(covariant BottomNavBar oldWidget) {
    if (oldWidget.visible && !widget.visible) {
      _offsetController.reverse();
    } else if (!oldWidget.visible && widget.visible) {
      _offsetController.forward();
    } else if (widget.visible) {
      _offsetController.forward();
    } else {
      _offsetController.reverse();
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _offsetController,
      builder: (context, child) {
        return Transform.translate(
          offset:
              Offset(0, (widget.height * 3) * (1 - _offsetController.value)),
          child: child,
        );
      },
      child: CircleNavBar(
        activeIcons: [
          for (final item in widget.items)
            _NavActiveItem(
              color: widget.selectedIconColor,
              iconPath: item.iconPath,
              size: widget.selectedIconSize,
            ),
        ],
        inactiveIcons: [
          for (final item in widget.items)
            item.isProfileTabItem
                ? _ProfileNavInactiveItem(
                    iconPath: item.iconPath,
                    title: item.text,
                    color: widget.iconColor,
                    size: widget.iconSize,
                  )
                : _NavInactiveItem(
                    iconPath: item.iconPath,
                    title: item.text,
                    color: widget.iconColor,
                    size: widget.iconSize,
                  ),
        ],
        color: widget.backgroundColor,
        circleGradient: widget.circleGradient,
        height: widget.height,
        iconCurve: Curves.fastOutSlowIn,
        circleWidth: widget.circleSize,
        activeIndex: widget.selectedIndex,
        shadowColor: Colors.transparent,
        onTap: widget.onTap,
      ),
    );
  }

  @override
  void dispose() {
    _offsetController.dispose();
    super.dispose();
  }
}

class _NavActiveItem extends StatelessWidget {
  const _NavActiveItem({
    Key? key,
    required this.iconPath,
    required this.color,
    required this.size,
  }) : super(key: key);

  final String iconPath;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SvgAssetPhoto(iconPath, color: color, width: size, height: size),
    );
  }
}

class _NavInactiveItem extends StatelessWidget {
  const _NavInactiveItem({
    Key? key,
    required this.iconPath,
    required this.color,
    required this.size,
    required this.title,
  }) : super(key: key);

  final String iconPath;
  final Color color;
  final double size;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Expanded(
        flex: 2,
        child: SvgAssetPhoto(iconPath, color: color, width: size, height: size),
      ),
      Expanded(
        child: Text(title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyles.heading6.copyWith(color: color),
            textAlign: TextAlign.center),
      ),
      SizedBox(height: 4.r),
    ]);
  }
}

class _ProfileNavInactiveItem extends StatelessWidget {
  const _ProfileNavInactiveItem({
    Key? key,
    required this.iconPath,
    required this.color,
    required this.size,
    required this.title,
  }) : super(key: key);

  final String iconPath;
  final Color color;
  final double size;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Expanded(
        flex: 2,
        child: Stack(alignment: Alignment.center, children: [
          SvgAssetPhoto(iconPath, color: color, width: size, height: size),
          Positioned(
            top: 6.r,
            right: 6.r,
            child: const UnreadNotificationIndicator(),
          ),
        ]),
      ),
      Expanded(
        child: Text(title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyles.heading6.copyWith(color: color),
            textAlign: TextAlign.center),
      ),
      SizedBox(height: 4.r),
    ]);
  }
}
