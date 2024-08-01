import 'package:flutter/material.dart'  hide SearchBar;
import 'package:flutter_scale_tap/flutter_scale_tap.dart';
import 'package:kwotcommon/kwotcommon.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/photo/photo.dart';
import 'package:kwotmusic/features/skit/skit_actions.model.dart';

class SkitListItem extends StatelessWidget {
  const SkitListItem({
    Key? key,
    required this.skit,
    required this.onTap,
  }) : super(key: key);

  final Skit skit;
  final Function(Skit skit) onTap;

  @override
  Widget build(BuildContext context) {
    return ScaleTap(
        onPressed: () => onTap(skit),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: ComponentSize.large.h,

          /// For ScaleTap to recognize whole item as tappable
          color: Colors.transparent,
          child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            _buildThumbnail(context),
            SizedBox(width: ComponentInset.small.w),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildTitle(context),
                    _buildSubtitle(context),
                  ]),
            ),
          ]),
        ));
  }

  Widget _buildThumbnail(BuildContext context) {
    return Photo.skit(
      skit.thumbnail,
      options: PhotoOptions(
        width: ComponentSize.large.r,
        height: ComponentSize.large.r,
        borderRadius: BorderRadius.circular(ComponentRadius.normal.r),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Text(skit.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyles.boldBody
            .copyWith(color: DynamicTheme.get(context).white()));
  }

  Widget _buildSubtitle(BuildContext context) {
    final skitTypeStr =
        locator<SkitActionsModel>().getSkitTypeText(context, type: skit.type);

    final artistName = skit.artist.name;

    return Text("$skitTypeStr · $artistName",
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyles.heading6
            .copyWith(color: DynamicTheme.get(context).neutral10()));
  }
}
