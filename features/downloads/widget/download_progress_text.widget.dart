import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotmusic/components/kit/kit.dart';

class DownloadProgressText extends StatelessWidget {
  const DownloadProgressText({
    Key? key,
    required this.progress,
    required this.textColor,
  }) : super(key: key);

  final int progress;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Text('$progress%',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyles.body.copyWith(color: textColor));
  }
}
