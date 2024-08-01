import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/photo/photo.dart';
import 'package:kwotmusic/features/misc/report/report_content.model.dart';
import 'package:kwotmusic/util/report_target_ext.dart';

class ReportContentPreview extends StatelessWidget {
  const ReportContentPreview({
    Key? key,
    required this.content,
    this.margin,
    this.padding,
  }) : super(key: key);

  final ReportableContent content;
  final EdgeInsets? margin;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: margin,
        padding: padding,
        child: Row(children: [
          _buildThumbnail(),
          SizedBox(width: ComponentInset.normal.w),
          Expanded(
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitle(context),
                  _buildSubtitle(context),
                ]),
          )
        ]));
  }

  Widget _buildThumbnail() {
    return Photo.kind(
      content.thumbnail,
      kind: content.target.photoKind,
      options: PhotoOptions(
          width: 48.r,
          height: 48.r,
          borderRadius: BorderRadius.circular(ComponentRadius.normal.r)),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Text(content.title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyles.boldBody
            .copyWith(color: DynamicTheme.get(context).white()));
  }

  Widget _buildSubtitle(BuildContext context) {
    return Text(content.target.getReportTypeText(context),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyles.heading6
            .copyWith(color: DynamicTheme.get(context).neutral10()));
  }
}
