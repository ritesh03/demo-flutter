import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/indicator/indicators.dart';
import 'package:kwotmusic/l10n/localizations.dart';

class LoadingConfigFragment extends StatelessWidget {
  const LoadingConfigFragment({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localization = LocaleResources.of(context);
    return Column(children: [
      /// TITLE
      _PageTitle(title: localization.appConfigLoadingPageTitle),
      SizedBox(height: ComponentInset.small.r),

      /// INDICATOR
      const Expanded(child: LoadingIndicator()),
    ]);
  }
}

class _PageTitle extends StatelessWidget {
  const _PageTitle({
    Key? key,
    required this.title,
  }) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyles.boldHeading2);
  }
}
