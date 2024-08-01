import 'package:flutter/material.dart'  hide SearchBar;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/multi_value_listenable_builder.widget.dart';
import 'package:kwotmusic/util/util.dart';

import 'fullscreen_control_button.dart';

class FullScreenLikeControlButton extends StatelessWidget {
  const FullScreenLikeControlButton({
    Key? key,
    required this.likedNotifier,
    required this.likesNotifier,
    required this.onTap,
  }) : super(key: key);

  final ValueNotifier<bool> likedNotifier;
  final ValueNotifier<int> likesNotifier;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final size = ComponentSize.large.r;
    return FullScreenControlButton(
        height: size,
        onTap: onTap,
        child: Container(
            constraints: BoxConstraints(minWidth: size),
            padding: EdgeInsets.all(ComponentInset.small.r),
            child: TwoValuesListenableBuilder<bool, int>(
                valueListenable1: likedNotifier,
                valueListenable2: likesNotifier,
                builder: (_, liked, likes, __) {
                  return Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildIcon(context, liked: liked),
                        _buildCount(context, likes: likes)
                      ]);
                })));
  }

  Widget _buildIcon(
    BuildContext context, {
    required bool liked,
  }) {
    return SizedBox(
      width: ComponentSize.small.r,
      height: ComponentSize.small.r,
      child: SvgPicture.asset(
          liked ? Assets.iconHeartFilled : Assets.iconHeartOutline,
          color: DynamicTheme.get(context).white()),
    );
  }

  Widget _buildCount(
    BuildContext context, {
    required int likes,
  }) {
    if (likes < 0) {
      return Container();
    }

    return Text(likes.prettyCount,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyles.boldCaption
            .copyWith(color: DynamicTheme.get(context).white()),
        textAlign: TextAlign.center);
  }
}
