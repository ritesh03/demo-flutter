import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/bottomsheet/bottomsheet_drag_handle.widget.dart';
import 'package:kwotmusic/components/widgets/button.dart';
import 'package:kwotmusic/components/widgets/gradient/foreground_gradient_photo.widget.dart';

class PromptDialogSheet extends StatelessWidget {
  const PromptDialogSheet({
    Key? key,
    this.height,
    required this.backgroundAssetPath,
    required this.highlightedActionTitle,
    required this.onHighlightedActionTap,
    required this.onNormalActionTap,
    required this.normalActionTitle,
    required this.subtitle,
    required this.title,
    this.useSmallHeight = false,
  }) : super(key: key);

  final double? height;
  final String backgroundAssetPath;
  final String highlightedActionTitle;
  final VoidCallback onHighlightedActionTap;
  final VoidCallback onNormalActionTap;
  final String normalActionTitle;
  final String subtitle;
  final String title;
  final bool useSmallHeight;

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      ForegroundGradientPhoto(
        photoPath: backgroundAssetPath,
        height: obtainBackgroundPhotoHeight(),
        startColor: DynamicTheme.get(context).neutral80(),
        startColorShift: 0.1,
        photoAlignment: Alignment.topCenter,
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
      ),
      _buildForeground(context)
    ]);
  }

  Widget _buildForeground(BuildContext context) {
    return Container(
        height: obtainHeight(),
        padding: EdgeInsets.only(
            left: ComponentInset.normal.r,
            right: ComponentInset.normal.r,
            bottom: ComponentInset.normal.r),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const BottomSheetDragHandle(),
              const Spacer(),
              Text(title,
                  style: TextStyles.boldHeading2,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center),
              SizedBox(height: ComponentInset.small.h),
              Text(subtitle,
                  style: TextStyles.body
                      .copyWith(color: DynamicTheme.get(context).neutral10()),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center),
              SizedBox(height: ComponentInset.normal.h),
              Button(
                  onPressed: onNormalActionTap,
                  text: normalActionTitle,
                  type: ButtonType.text,
                  padding:
                      EdgeInsets.symmetric(horizontal: ComponentInset.normal.r),
                  height: ComponentSize.large.h),
              SizedBox(height: ComponentInset.normal.h),
              Button(
                  onPressed: onHighlightedActionTap,
                  text: highlightedActionTitle,
                  type: ButtonType.primary,
                  width: 1.sw,
                  height: ComponentSize.large.h),
            ]));
  }

  double obtainHeight() {
    return height ?? (useSmallHeight || subtitle.isEmpty ? 384.h : 416.h);
  }

  double obtainBackgroundPhotoHeight() {
    return obtainHeight() * 0.50;
  }
}
