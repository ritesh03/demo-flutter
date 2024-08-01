import 'package:flutter/material.dart'  hide SearchBar;
import 'package:kwotdata/kwotdata.dart';
import 'package:kwotmusic/components/kit/kit.dart';
import 'package:kwotmusic/components/widgets/bottomsheet/bottomsheet_drag_handle.widget.dart';
import 'package:kwotmusic/components/widgets/bottomsheet/material_bottom_sheet.dart';
import 'package:kwotmusic/components/widgets/button.dart';
import 'package:kwotmusic/core.dart';
import 'package:kwotmusic/features/show/widget/show_compact_preview.widget.dart';
import 'package:kwotmusic/l10n/localizations.dart';
import 'package:kwotmusic/router/routes.dart';

class PurchaseShowOptionsArgs {
  PurchaseShowOptionsArgs({
    required this.show,
  });

  final Show show;
}

class PurchaseShowBottomSheet extends StatefulWidget {
  //=
  static Future showBottomSheet(
    BuildContext context, {
    required Show show,
  }) {
    return showMaterialBottomSheet<void>(
      context,
      expand: false,
      builder: (_, __) => PurchaseShowBottomSheet(show: show),
    );
  }

  const PurchaseShowBottomSheet({
    Key? key,
    required this.show,
  }) : super(key: key);

  final Show show;

  @override
  State<PurchaseShowBottomSheet> createState() =>
      _PurchaseShowBottomSheetState();
}

class _PurchaseShowBottomSheetState extends State<PurchaseShowBottomSheet> {
  //=

  @override
  Widget build(BuildContext context) {
    final localization = LocaleResources.of(context);

    return Container(
        padding: EdgeInsets.symmetric(horizontal: ComponentInset.normal.r),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const BottomSheetDragHandle(),
          SizedBox(height: ComponentInset.normal.h),

          /// SHOW PREVIEW
          ShowCompactPreview(show: widget.show),
          SizedBox(height: ComponentInset.normal.h),

          /// DIVIDER
          Container(color: DynamicTheme.get(context).background(), height: 2.r),
          SizedBox(height: ComponentInset.normal.h),

          /// TITLE
          Text(localization.showPurchaseDisplayTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyles.boldHeading2
                  .copyWith(color: DynamicTheme.get(context).white())),
          SizedBox(height: ComponentInset.small.h),

          /// SUMMARY
          Text(localization.showPurchaseDisplaySummary,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyles.body
                  .copyWith(color: DynamicTheme.get(context).neutral10())),
          SizedBox(height: ComponentInset.normal.h),

          /// START PURCHASE PROCESS
          _buildPurchaseButton(),
          SizedBox(height: ComponentInset.normal.h)
        ]));
  }

  Widget _buildPurchaseButton() {
    return Button(
      alignment: Alignment.center,
      height: ComponentSize.large.r,
      onPressed: _onStartPurchaseButtonTapped,
      text: LocaleResources.of(context).purchase,
      type: ButtonType.primary,
    );
  }

  void _onStartPurchaseButtonTapped() {
    RootNavigation.popUntilRoot(context);
    DashboardNavigation.pushNamed(context, Routes.purchase);
  }
}
