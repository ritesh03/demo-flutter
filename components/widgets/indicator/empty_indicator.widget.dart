import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/l10n/localizations.dart';

class EmptyIndicator extends StatelessWidget {
  const EmptyIndicator({
    Key? key,
    this.message,
  }) : super(key: key);

  final String? message;

  @override
  Widget build(BuildContext context) {
    //=

    final graphicSize = 100.r;
    final message = this.message ?? LocaleResources.of(context).errorNoData;

    return Container(
        padding: EdgeInsets.symmetric(horizontal: ComponentInset.large.w),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                Assets.graphicEmptyBox,
                width: graphicSize,
                height: graphicSize,
              ),
              if (message.isNotEmpty)
                Text(message,
                    style: TextStyles.body
                        .copyWith(color: DynamicTheme.get(context).neutral40()),
                    textAlign: TextAlign.center)
            ]));
  }
}
