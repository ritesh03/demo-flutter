import 'package:flutter/material.dart'  hide SearchBar;
import 'package:flutter_scale_tap/flutter_scale_tap.dart';
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/gradient_border_painter.dart';
import 'package:kwotmusic/components/widgets/photo/photo.dart';
import 'package:kwotmusic/util/util.dart';

class LiveShowGridItem extends StatelessWidget {
  const LiveShowGridItem({
    Key? key,
    required this.width,
    required this.show,
    required this.onTap,
    this.padding = EdgeInsets.zero,
  }) : super(key: key);

  final double width;
  final Show show;
  final Function(Show show) onTap;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return ScaleTap(
        onPressed: () => onTap(show),
        child: Container(
            width: width,
            padding: padding,

            /// For ScaleTap to recognize whole item as tappable
            color: Colors.transparent,
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildThumbnail(context),
                  SizedBox(height: ComponentInset.small.h),
                  _buildTitle(context),
                ])));
  }

  Widget _buildThumbnail(BuildContext context) {
    return SizedBox(
        width: width,
        height: width,
        child: CustomPaint(
          painter: GradientBorderPainter(
            gradient: DynamicTheme.get(context).primaryGradient(),
            radius: Radius.circular(width),
            strokeWidth: 2.r,
          ),
          child: Padding(
            padding: EdgeInsets.all(ComponentInset.small.r),
            child: Photo.show(
              show.thumbnail,
              options: PhotoOptions(
                width: width,
                height: width,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ));
  }

  Widget _buildTitle(BuildContext context) {
    return Text(
      withExtraNextLineCharacters(show.title, 2),
      overflow: TextOverflow.ellipsis,
      style: TextStyles.heading6
          .copyWith(color: DynamicTheme.get(context).white()),
      textAlign: TextAlign.center,
      maxLines: 2,
    );
  }
}
